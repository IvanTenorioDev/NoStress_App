import 'package:flutter/material.dart';
import 'package:nostress/models/user_model.dart';
import 'package:nostress/models/assessment_model.dart';
import 'package:nostress/screens/assessment/gad7_screen.dart';
import 'package:nostress/screens/audio/audio_list_screen.dart';
import 'package:nostress/screens/profile/profile_screen.dart';
import 'package:nostress/screens/tools/sandbox_screen.dart';
import 'package:nostress/screens/emergency/sos_screen.dart';
import 'package:nostress/services/auth_service.dart';
import 'package:nostress/services/assessment_service.dart';
import 'package:nostress/widgets/stress_level_card.dart';
import 'package:nostress/widgets/audio_recommendation_card.dart';
import 'package:nostress/widgets/greeting_card.dart';
import 'package:nostress/widgets/mood_tracker_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final AssessmentService _assessmentService = AssessmentService();
  
  User? _userData;
  Assessment? _latestAssessment;
  bool _isLoading = true;
  
  int _currentNavIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userData = await _authService.getCurrentUserData();
      final latestAssessment = await _assessmentService.getLatestGAD7Assessment();
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _latestAssessment = latestAssessment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
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
  
  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_userData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Erro ao carregar seus dados.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildToolsTab();
      case 2:
        return _buildAudioTab();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }
  
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Cabeçalho com saudação
          GreetingCard(userData: _userData!),
          
          const SizedBox(height: 24),
          
          // Indicador de nível de estresse/ansiedade
          if (_latestAssessment != null)
            StressLevelCard(assessment: _latestAssessment!)
          else
            _buildNoAssessmentCard(),
          
          const SizedBox(height: 16),
          
          // Rastreador de humor semanal
          MoodTrackerCard(userId: _userData!.id),
          
          const SizedBox(height: 16),
          
          // Recomendações de áudio
          AudioRecommendationCard(userId: _userData!.id),
          
          const SizedBox(height: 24),
          
          // Botões de ação rápida
          _buildQuickActionButtons(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Ferramentas para Tranquilidade',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Cartões de ferramentas
        _buildToolCard(
          title: 'Caixa de Areia Virtual',
          description: 'Arraste elementos para relaxar sua mente',
          icon: Icons.beach_access,
          onTap: _navigateToSandbox,
        ),
        
        _buildToolCard(
          title: 'Diário de Gratidão',
          description: 'Registre momentos positivos do seu dia',
          icon: Icons.favorite,
          onTap: () {
            // Navegação para o diário de gratidão
          },
        ),
        
        _buildToolCard(
          title: 'Respiração Guiada',
          description: 'Exercícios de respiração 4-7-8',
          icon: Icons.air,
          onTap: () {
            // Navegação para tela de respiração
          },
        ),
        
        _buildToolCard(
          title: 'Checklist Anti-Ansiedade',
          description: 'Passos simples para acalmar-se rapidamente',
          icon: Icons.check_circle_outline,
          onTap: () {
            // Navegação para checklist
          },
        ),
      ],
    );
  }
  
  Widget _buildAudioTab() {
    return const AudioListScreen();
  }
  
  Widget _buildQuickActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Avaliação GAD-7',
                icon: Icons.assessment_outlined,
                onTap: _navigateToGAD7,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'Meditações',
                icon: Icons.headphones_outlined,
                onTap: _navigateToAudioList,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Caixa de Areia',
                icon: Icons.beach_access_outlined,
                onTap: _navigateToSandbox,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'Emergência',
                icon: Icons.emergency_outlined,
                color: Colors.red.shade100,
                textColor: Colors.red.shade700,
                iconColor: Colors.red.shade700,
                onTap: _navigateToSOS,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    Color? color,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Material(
      color: color ?? theme.colorScheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNoAssessmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avaliação de Bem-estar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você ainda não realizou uma avaliação. Faça agora para receber recomendações personalizadas.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToGAD7,
              child: const Text('Fazer avaliação GAD-7'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'Ferramentas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones_outlined),
            activeIcon: Icon(Icons.headphones),
            label: 'Áudios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSOS,
        backgroundColor: Colors.red,
        child: const Icon(Icons.emergency_outlined),
      ),
    );
  }
} 