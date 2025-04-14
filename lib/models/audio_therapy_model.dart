import 'package:cloud_firestore/cloud_firestore.dart';

class AudioTherapy {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final List<String> tags;
  final String duration;
  final String voiceType; // 'masculine', 'feminine', 'neutral'
  final String coverImageUrl;
  final int sessionCount; // Número de vezes que foi ouvido
  
  AudioTherapy({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.tags,
    required this.duration,
    required this.voiceType,
    this.coverImageUrl = '',
    this.sessionCount = 0,
  });
  
  factory AudioTherapy.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AudioTherapy(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      duration: data['duration'] ?? '0:00',
      voiceType: data['voiceType'] ?? 'neutral',
      coverImageUrl: data['coverImageUrl'] ?? '',
      sessionCount: data['sessionCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'tags': tags,
      'duration': duration,
      'voiceType': voiceType,
      'coverImageUrl': coverImageUrl,
      'sessionCount': sessionCount,
    };
  }
  
  AudioTherapy copyWith({
    String? title,
    String? description,
    String? audioUrl,
    List<String>? tags,
    String? duration,
    String? voiceType,
    String? coverImageUrl,
    int? sessionCount,
  }) {
    return AudioTherapy(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      voiceType: voiceType ?? this.voiceType,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }
  
  // Método para incrementar a contagem de sessões
  AudioTherapy incrementSessionCount() {
    return copyWith(sessionCount: sessionCount + 1);
  }
  
  // Método para verificar se é uma meditação de emergência
  bool get isEmergency => tags.contains('urgente') || tags.contains('emergência');
  
  // Método para verificar o tipo de técnica
  bool isType(String type) => tags.contains(type.toLowerCase());
} 