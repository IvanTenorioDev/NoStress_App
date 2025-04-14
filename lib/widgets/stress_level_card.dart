import 'package:flutter/material.dart';
import 'package:nostress/models/assessment_model.dart';
import 'package:intl/intl.dart';
import 'package:nostress/screens/assessment/gad7_screen.dart';

class StressLevelCard extends StatelessWidget {
  final Assessment assessment;
  
  const StressLevelCard({
    Key? key,
    required this.assessment,
  }) : super(key: key);
  
  Color _getLevelColor(String level) {
    switch (level) {
      case 'Ansiedade Mínima':
        return Colors.green;
      case 'Ansiedade Leve':
        return Colors.amber;
      case 'Ansiedade Moderada':
        return Colors.orange;
      case 'Ansiedade Severa':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'Ansiedade Mínima':
        return Icons.sentiment_very_satisfied;
      case 'Ansiedade Leve':
        return Icons.sentiment_satisfied;
      case 'Ansiedade Moderada':
        return Icons.sentiment_neutral;
      case 'Ansiedade Severa':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
  
  String _getFormattedDate(DateTime date) {
    return DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(date);
  }
  
  double _getProgressValue() {
    final maxScore = 21; // Pontuação máxima do GAD-7
    return assessment.score / maxScore;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severity = assessment.getSeverityLevel();
    final color = _getLevelColor(severity);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getLevelIcon(severity),
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nível de Ansiedade',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Última avaliação: ${_getFormattedDate(assessment.timestamp)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            LinearProgressIndicator(
              value: _getProgressValue(),
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  severity,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Pontuação: ${assessment.score}/21',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              _getRecommendationText(severity),
              style: theme.textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GAD7Screen()),
                );
              },
              child: const Text('Nova Avaliação'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRecommendationText(String level) {
    switch (level) {
      case 'Ansiedade Mínima':
        return 'Seu nível de ansiedade está baixo. Continue as práticas que estão funcionando para você.';
      case 'Ansiedade Leve':
        return 'Você está experimentando ansiedade leve. Exercícios de respiração e mindfulness podem ajudar.';
      case 'Ansiedade Moderada':
        return 'Sua ansiedade está em nível moderado. Recomendamos práticas regulares de relaxamento e considerar suporte adicional.';
      case 'Ansiedade Severa':
        return 'Você está experimentando ansiedade severa. Sugerimos fortemente buscar apoio profissional além das ferramentas deste app.';
      default:
        return 'Faça uma nova avaliação para receber recomendações personalizadas.';
    }
  }
} 