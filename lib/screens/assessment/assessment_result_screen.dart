import 'package:flutter/material.dart';
import 'package:nostress/models/assessment_model.dart';
import 'package:nostress/screens/audio/audio_list_screen.dart';
import 'package:nostress/screens/tools/breathing_exercise_screen.dart';
import 'package:nostress/screens/home/home_screen.dart';

class AssessmentResultScreen extends StatelessWidget {
  final int score;
  
  const AssessmentResultScreen({
    Key? key,
    required this.score,
  }) : super(key: key);
  
  String _getSeverityLevel() {
    if (score >= 0 && score <= 4) {
      return 'Ansiedade Mínima';
    } else if (score >= 5 && score <= 9) {
      return 'Ansiedade Leve';
    } else if (score >= 10 && score <= 14) {
      return 'Ansiedade Moderada';
    } else {
      return 'Ansiedade Severa';
    }
  }
  
  Color _getLevelColor() {
    if (score >= 0 && score <= 4) {
      return Colors.green;
    } else if (score >= 5 && score <= 9) {
      return Colors.amber;
    } else if (score >= 10 && score <= 14) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  IconData _getLevelIcon() {
    if (score >= 0 && score <= 4) {
      return Icons.sentiment_very_satisfied;
    } else if (score >= 5 && score <= 9) {
      return Icons.sentiment_satisfied;
    } else if (score >= 10 && score <= 14) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }
  
  String _getRecommendationText() {
    final severity = _getSeverityLevel();
    
    switch (severity) {
      case 'Ansiedade Mínima':
        return 'Seus sintomas de ansiedade são mínimos. Continue mantendo práticas saudáveis de bem-estar para preservar sua saúde mental.';
      case 'Ansiedade Leve':
        return 'Você está apresentando sintomas leves de ansiedade. Recomendamos exercícios de respiração e meditações curtas diárias para ajudar a gerenciar esses sintomas.';
      case 'Ansiedade Moderada':
        return 'Seus sintomas indicam ansiedade moderada. Considere incorporar técnicas de relaxamento e mindfulness regularmente. Se os sintomas persistirem, considere conversar com um profissional de saúde.';
      case 'Ansiedade Severa':
        return 'Você está apresentando sintomas significativos de ansiedade. Recomendamos fortemente buscar o apoio de um profissional de saúde mental, além de utilizar as ferramentas deste aplicativo como suporte complementar.';
      default:
        return 'Não foi possível determinar um nível específico de ansiedade. Recomendamos utilizar as ferramentas de relaxamento disponíveis no aplicativo.';
    }
  }
  
  List<Widget> _getRecommendedActions() {
    final List<Widget> actions = [];
    
    // Exercícios de respiração são bons para todos os níveis
    actions.add(
      _buildActionButton(
        label: 'Exercícios de Respiração',
        icon: Icons.air,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BreathingExerciseScreen()),
          );
        },
      ),
    );
    
    // Meditações são boas para todos os níveis
    actions.add(
      _buildActionButton(
        label: 'Meditações Guiadas',
        icon: Icons.headphones,
        onTap: (context) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AudioListScreen()),
          );
        },
      ),
    );
    
    // Para ansiedade moderada a severa, sugerir mais recursos
    if (score >= 10) {
      actions.add(
        _buildActionButton(
          label: 'Recursos de Ajuda',
          icon: Icons.support,
          onTap: (context) {
            _showHelpResourcesDialog(context);
          },
        ),
      );
    }
    
    return actions;
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Function(BuildContext) onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton.icon(
            onPressed: () => onTap(context),
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        );
      },
    );
  }
  
  void _showHelpResourcesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recursos de Apoio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CVV - Centro de Valorização da Vida',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Telefone: 188 (ligação gratuita)'),
            const Text('Site: www.cvv.org.br'),
            
            const SizedBox(height: 12),
            
            const Text(
              'CAPS - Centro de Atenção Psicossocial',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Procure o CAPS mais próximo da sua localidade'),
            
            const SizedBox(height: 12),
            
            const Text(
              'LEMBRETE IMPORTANTE:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Este aplicativo não substitui ajuda profissional. Em caso de crise, busque atendimento especializado imediatamente.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = _getSeverityLevel();
    final color = _getLevelColor();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Avaliação'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Resultado visual
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getLevelIcon(),
                        color: color,
                        size: 60,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score/21',
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Nível de ansiedade
              Text(
                severity,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Descrição
              Text(
                _getRecommendationText(),
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Título de ações recomendadas
              const Text(
                'Ações Recomendadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Lista de ações recomendadas
              ..._getRecommendedActions(),
              
              const Spacer(),
              
              // Botão de voltar para a tela inicial
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Voltar para o Início'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 