import 'package:flutter/material.dart';
import 'package:nostress/models/assessment_model.dart';
import 'package:nostress/services/assessment_service.dart';
import 'package:nostress/screens/assessment/assessment_result_screen.dart';

class GAD7Screen extends StatefulWidget {
  const GAD7Screen({Key? key}) : super(key: key);

  @override
  State<GAD7Screen> createState() => _GAD7ScreenState();
}

class _GAD7ScreenState extends State<GAD7Screen> {
  final AssessmentService _assessmentService = AssessmentService();
  final Map<int, int> _responses = {};
  bool _isSubmitting = false;
  
  final List<GAD7Question> _questions = GAD7Question.getGAD7Questions();
  final List<GAD7Option> _options = GAD7Option.getOptions();
  
  int _currentQuestionIndex = 0;
  
  void _selectAnswer(int value) {
    setState(() {
      _responses[_questions[_currentQuestionIndex].id] = value;
      
      // Avançar para a próxima pergunta
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _submitAssessment();
      }
    });
  }
  
  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }
  
  Future<void> _submitAssessment() async {
    // Verificar se todas as perguntas foram respondidas
    if (_responses.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, responda todas as perguntas.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Salvar as respostas
      await _assessmentService.saveGAD7Assessment(_responses);
      
      // Calcular a pontuação total
      int totalScore = 0;
      _responses.forEach((key, value) {
        totalScore += value;
      });
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        // Navegar para a tela de resultados
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AssessmentResultScreen(score: totalScore),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar avaliação: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliação GAD-7'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nas últimas 2 semanas, com que frequência você foi incomodado por:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Indicador de progresso
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Pergunta atual
              Text(
                currentQuestion.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Opções de resposta
              Expanded(
                child: ListView.builder(
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = _responses[currentQuestion.id] == option.value;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isSelected ? 4 : 1,
                      color: isSelected 
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : null,
                      child: InkWell(
                        onTap: () => _selectAnswer(option.value),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: option.value,
                                groupValue: _responses[currentQuestion.id],
                                onChanged: (value) {
                                  if (value != null) {
                                    _selectAnswer(value);
                                  }
                                },
                                activeColor: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Botões de navegação
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botão de voltar
                    if (_currentQuestionIndex > 0)
                      OutlinedButton.icon(
                        onPressed: _goToPreviousQuestion,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                      )
                    else
                      const SizedBox.shrink(),
                    
                    // Botão de próximo ou finalizar
                    if (_currentQuestionIndex < _questions.length - 1)
                      ElevatedButton.icon(
                        onPressed: _responses[currentQuestion.id] != null
                            ? () {
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Próxima'),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _isSubmitting || _responses[currentQuestion.id] == null
                            ? null
                            : _submitAssessment,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: const Text('Finalizar'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 