import 'package:flutter/material.dart';
import 'package:nostress/models/audio_therapy_model.dart';
import 'package:nostress/services/audio_service.dart';
import 'package:nostress/screens/audio/audio_player_screen.dart';

class AudioRecommendationCard extends StatefulWidget {
  final String userId;
  
  const AudioRecommendationCard({
    Key? key,
    required this.userId,
  }) : super(key: key);
  
  @override
  State<AudioRecommendationCard> createState() => _AudioRecommendationCardState();
}

class _AudioRecommendationCardState extends State<AudioRecommendationCard> {
  final AudioService _audioService = AudioService();
  bool _isLoading = true;
  List<AudioTherapy> _recommendedAudios = [];
  
  @override
  void initState() {
    super.initState();
    _loadRecommendedAudios();
  }
  
  Future<void> _loadRecommendedAudios() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final audios = await _audioService.getRecommendedAudios();
      
      if (mounted) {
        setState(() {
          _recommendedAudios = audios;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Erro ao carregar áudios recomendados: $e');
    }
  }
  
  void _navigateToAudioPlayer(AudioTherapy audio) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AudioPlayerScreen(audio: audio),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recomendado para Você',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_recommendedAudios.isEmpty)
              _buildEmptyState()
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendedAudios.length,
                  itemBuilder: (context, index) {
                    final audio = _recommendedAudios[index];
                    return _buildAudioCard(audio);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.headphones,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma recomendação encontrada.\nComplete uma avaliação para receber sugestões.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAudioCard(AudioTherapy audio) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _navigateToAudioPlayer(audio),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getAudioIcon(audio),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                audio.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              audio.duration,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getAudioIcon(AudioTherapy audio) {
    if (audio.tags.contains('respiração') || audio.tags.contains('respiracao')) {
      return Icons.air;
    } else if (audio.tags.contains('meditação') || audio.tags.contains('meditacao')) {
      return Icons.self_improvement;
    } else if (audio.tags.contains('sono') || audio.tags.contains('dormir')) {
      return Icons.nightlight;
    } else if (audio.tags.contains('foco') || audio.tags.contains('concentração')) {
      return Icons.visibility;
    } else if (audio.tags.contains('emergência') || audio.tags.contains('urgente')) {
      return Icons.emergency;
    }
    return Icons.headphones;
  }
} 