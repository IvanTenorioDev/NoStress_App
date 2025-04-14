import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo simplificado para uso na tela de perfil
class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime createdAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    required this.createdAt,
  });
}

class User {
  final String id;
  final String name;
  final String email;
  final List<MoodRecord> moodHistory;
  final EmergencyContacts contacts;
  final AudioPreferences audioPrefs;
  final bool isDarkMode;
  final bool isDyslexiaMode;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.moodHistory,
    required this.contacts,
    required this.audioPrefs,
    this.isDarkMode = false,
    this.isDyslexiaMode = false,
  });
  
  factory User.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      moodHistory: (data['moodHistory'] as List<dynamic>?)
          ?.map((e) => MoodRecord.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      contacts: EmergencyContacts.fromMap(
          data['contacts'] as Map<String, dynamic>? ?? {}),
      audioPrefs: AudioPreferences.fromMap(
          data['audioPrefs'] as Map<String, dynamic>? ?? {}),
      isDarkMode: data['isDarkMode'] ?? false,
      isDyslexiaMode: data['isDyslexiaMode'] ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'moodHistory': moodHistory.map((e) => e.toMap()).toList(),
      'contacts': contacts.toMap(),
      'audioPrefs': audioPrefs.toMap(),
      'isDarkMode': isDarkMode,
      'isDyslexiaMode': isDyslexiaMode,
    };
  }
  
  User copyWith({
    String? name,
    String? email,
    List<MoodRecord>? moodHistory,
    EmergencyContacts? contacts,
    AudioPreferences? audioPrefs,
    bool? isDarkMode,
    bool? isDyslexiaMode,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      moodHistory: moodHistory ?? this.moodHistory,
      contacts: contacts ?? this.contacts,
      audioPrefs: audioPrefs ?? this.audioPrefs,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isDyslexiaMode: isDyslexiaMode ?? this.isDyslexiaMode,
    );
  }
}

class MoodRecord {
  final DateTime timestamp;
  final int moodScore; // 1-10
  final String note;
  final List<String> triggers;
  
  MoodRecord({
    required this.timestamp,
    required this.moodScore,
    this.note = '',
    this.triggers = const [],
  });
  
  factory MoodRecord.fromMap(Map<String, dynamic> map) {
    return MoodRecord(
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      moodScore: map['moodScore'] ?? 5,
      note: map['note'] ?? '',
      triggers: List<String>.from(map['triggers'] ?? []),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'moodScore': moodScore,
      'note': note,
      'triggers': triggers,
    };
  }
}

class EmergencyContacts {
  final List<Contact> contacts;
  
  EmergencyContacts({
    this.contacts = const [],
  });
  
  factory EmergencyContacts.fromMap(Map<String, dynamic> map) {
    return EmergencyContacts(
      contacts: (map['contacts'] as List<dynamic>?)
          ?.map((e) => Contact.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'contacts': contacts.map((e) => e.toMap()).toList(),
    };
  }
}

class Contact {
  final String name;
  final String phone;
  final String relationship;
  
  Contact({
    required this.name,
    required this.phone,
    this.relationship = '',
  });
  
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}

class AudioPreferences {
  final String voiceType; // 'masculine', 'feminine', 'neutral'
  final String backgroundSound; // 'ocean', 'forest', 'white_noise', 'none'
  final double volume;
  
  AudioPreferences({
    this.voiceType = 'neutral',
    this.backgroundSound = 'none',
    this.volume = 0.7,
  });
  
  factory AudioPreferences.fromMap(Map<String, dynamic> map) {
    return AudioPreferences(
      voiceType: map['voiceType'] ?? 'neutral',
      backgroundSound: map['backgroundSound'] ?? 'none',
      volume: map['volume']?.toDouble() ?? 0.7,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'voiceType': voiceType,
      'backgroundSound': backgroundSound,
      'volume': volume,
    };
  }
  
  AudioPreferences copyWith({
    String? voiceType,
    String? backgroundSound,
    double? volume,
  }) {
    return AudioPreferences(
      voiceType: voiceType ?? this.voiceType,
      backgroundSound: backgroundSound ?? this.backgroundSound,
      volume: volume ?? this.volume,
    );
  }
} 