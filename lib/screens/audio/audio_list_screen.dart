import 'package:flutter/material.dart';
import 'package:nostress/models/audio_therapy_model.dart';

class AudioListScreen extends StatelessWidget {
  const AudioListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Áudio'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Mockup de dados
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.music_note),
              title: Text('Áudio Terapêutico ${index + 1}'),
              subtitle: const Text('Relaxe com este áudio calmante'),
              trailing: const Icon(Icons.play_circle),
              onTap: () {
                // Ação ao clicar no áudio
              },
            ),
          );
        },
      ),
    );
  }
} 