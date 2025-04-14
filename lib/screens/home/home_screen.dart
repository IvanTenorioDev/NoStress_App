import 'package:flutter/material.dart';
import 'package:nostress/screens/assessment/gad7_screen.dart';
import 'package:nostress/screens/audio/audio_list_screen.dart';
import 'package:nostress/screens/profile/profile_screen.dart';
import 'package:nostress/screens/tools/sandbox_screen.dart';
import 'package:nostress/screens/emergency/sos_screen.dart';
import 'package:nostress/screens/tools/breathing_exercise_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  
  void _navigateToGAD7() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GAD7Screen()),
    );
  }
  
  void _navigateToAudioList() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AudioListScreen()),
    );
  }
  
  void _navigateToSandbox() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SandboxScreen()),
    );
  }
  
  void _navigateToSOS() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SOSScreen()),
    );
  }
  
  void _navigateToBreathingExercise() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BreathingExerciseScreen()),
    );
  }
  
  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NoStress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency),
            tooltip: 'Ajuda Emergencial',
            onPressed: _navigateToSOS,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Ferramentas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'Áudio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildToolsTab();
      case 2:
        return const AudioListScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }
  
  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Cabeçalho de boas-vindas
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 24,
                      child: const Text(
                        'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, Usuário',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text('Como você está se sentindo hoje?'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Emojis de sentimento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodButton('😞', 'Triste'),
                    _buildMoodButton('😐', 'Neutro'),
                    _buildMoodButton('🙂', 'Bem'),
                    _buildMoodButton('😄', 'Ótimo'),
                    _buildMoodButton('😰', 'Ansioso'),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Indicador de progresso semanal
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu Progresso Semanal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const LinearProgressIndicator(
                  value: 0.7,
                  minHeight: 10,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                const SizedBox(height: 8),
                const Text('70% dos seus objetivos concluídos'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressItem('5', 'Exercícios'),
                    _buildProgressItem('3', 'Meditações'),
                    _buildProgressItem('2', 'Avaliações'),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Recomendações
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendado para Você',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRecommendationCard(
                        'Respiração 4-7-8',
                        Icons.air,
                        Colors.blue,
                        _navigateToBreathingExercise,
                      ),
                      _buildRecommendationCard(
                        'Meditação Guiada',
                        Icons.self_improvement,
                        Colors.purple,
                        () {},
                      ),
                      _buildRecommendationCard(
                        'Sons Relaxantes',
                        Icons.music_note,
                        Colors.teal,
                        _navigateToAudioList,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Botões de ação rápida
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Avaliação GAD-7',
                icon: Icons.assignment,
                color: Colors.blue,
                onTap: _navigateToGAD7,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                label: 'Respiração',
                icon: Icons.air,
                color: Colors.green,
                onTap: _navigateToBreathingExercise,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Biblioteca de Áudio',
                icon: Icons.headphones,
                color: Colors.orange,
                onTap: _navigateToAudioList,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                label: 'Ajuda Emergencial',
                icon: Icons.emergency,
                color: Colors.red,
                onTap: _navigateToSOS,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Ferramentas para Tranquilidade',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        
        const SizedBox(height: 24),
        
        // Cartões de ferramentas
        _buildToolCard(
          title: 'Respiração 4-7-8',
          description: 'Técnica de respiração para reduzir o estresse',
          icon: Icons.air,
          color: Colors.blue,
          onTap: _navigateToBreathingExercise,
        ),
        
        _buildToolCard(
          title: 'Caixa de Areia Virtual',
          description: 'Explore ferramentas de bem-estar',
          icon: Icons.psychology,
          color: Colors.purple,
          onTap: _navigateToSandbox,
        ),
        
        _buildToolCard(
          title: 'Diário de Gratidão',
          description: 'Registre momentos positivos do seu dia',
          icon: Icons.favorite,
          color: Colors.pink,
          onTap: () {},
        ),
        
        _buildToolCard(
          title: 'Biblioteca de Áudio',
          description: 'Sons e meditações para relaxar',
          icon: Icons.headphones,
          color: Colors.teal,
          onTap: _navigateToAudioList,
        ),
        
        _buildToolCard(
          title: 'Ajuda Emergencial',
          description: 'Recursos para momentos de crise',
          icon: Icons.emergency,
          color: Colors.red,
          onTap: _navigateToSOS,
        ),
      ],
    );
  }
  
  Widget _buildMoodButton(String emoji, String label) {
    return Column(
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.1),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget _buildProgressItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecommendationCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          radius: 28,
          child: Icon(icon, size: 28),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios, color: color),
        onTap: onTap,
      ),
    );
  }
} 