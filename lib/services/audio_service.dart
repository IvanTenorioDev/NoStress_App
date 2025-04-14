import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:nostress/models/audio_therapy_model.dart';
import 'package:nostress/models/user_model.dart';
import 'package:nostress/services/auth_service.dart';

class AudioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  AudioService() {
    _initAudioSession();
  }
  
  // Inicializar a sessão de áudio
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }
  
  // Obter lista de áudios terapêuticos
  Stream<List<AudioTherapy>> getAudioTherapies({String? voiceType, List<String>? tags}) {
    Query query = _firestore.collection('audio_therapies');
    
    if (voiceType != null) {
      query = query.where('voiceType', isEqualTo: voiceType);
    }
    
    if (tags != null && tags.isNotEmpty) {
      // Firestore não suporta arrays com operador 'contains any', então faremos a filtragem no lado do cliente
      return query.snapshots().map((snapshot) {
        final audios = snapshot.docs
            .map((doc) => AudioTherapy.fromFirestore(doc))
            .toList();
        
        if (tags.isNotEmpty) {
          return audios.where((audio) {
            for (final tag in tags) {
              if (audio.tags.contains(tag)) {
                return true;
              }
            }
            return false;
          }).toList();
        }
        
        return audios;
      });
    }
    
    return query.snapshots().map((snapshot) => 
        snapshot.docs.map((doc) => AudioTherapy.fromFirestore(doc)).toList());
  }
  
  // Obter áudios de emergência
  Stream<List<AudioTherapy>> getEmergencyAudios() {
    return getAudioTherapies(tags: ['urgente', 'emergência']);
  }
  
  // Obter áudios por tipo específico
  Stream<List<AudioTherapy>> getAudiosByType(String type) {
    return getAudioTherapies(tags: [type]);
  }
  
  // Obter áudios recomendados para o usuário
  Future<List<AudioTherapy>> getRecommendedAudios() async {
    final userData = await _authService.getCurrentUserData();
    if (userData == null) return [];
    
    // Implementar lógica de recomendação baseada no histórico e preferências
    final preferredVoice = userData.audioPrefs.voiceType;
    
    // Obtém os áudios com a voz preferida do usuário
    final snapshot = await _firestore.collection('audio_therapies')
        .where('voiceType', isEqualTo: preferredVoice)
        .limit(5)
        .get();
    
    return snapshot.docs.map((doc) => AudioTherapy.fromFirestore(doc)).toList();
  }
  
  // Reproduzir áudio
  Future<void> playAudio(AudioTherapy audio, {bool loop = false}) async {
    try {
      await _audioPlayer.setUrl(audio.audioUrl);
      await _audioPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      _audioPlayer.play();
      
      // Incrementar contador de uso
      await _incrementAudioSessionCount(audio.id);
    } catch (e) {
      throw Exception('Erro ao reproduzir áudio: ${e.toString()}');
    }
  }
  
  // Pausar áudio
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }
  
  // Retomar reprodução
  Future<void> resumeAudio() async {
    await _audioPlayer.play();
  }
  
  // Parar áudio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }
  
  // Ajustar volume
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }
  
  // Incrementar contador de sessões
  Future<void> _incrementAudioSessionCount(String audioId) async {
    try {
      await _firestore.collection('audio_therapies').doc(audioId).update({
        'sessionCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Erro ao atualizar contador de sessões: ${e.toString()}');
    }
  }
  
  // Obter detalhes de um áudio específico
  Future<AudioTherapy?> getAudioDetails(String audioId) async {
    try {
      final doc = await _firestore.collection('audio_therapies').doc(audioId).get();
      if (doc.exists) {
        return AudioTherapy.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do áudio: ${e.toString()}');
    }
  }
  
  // Obter a posição atual de reprodução
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  // Obter duração total do áudio
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  
  // Verificar se está tocando
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  
  // Liberar recursos ao finalizar
  void dispose() {
    _audioPlayer.dispose();
  }
} 