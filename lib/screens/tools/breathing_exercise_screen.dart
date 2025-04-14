import 'dart:async';
import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({Key? key}) : super(key: key);

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  Timer? _timer;
  int _secondsRemaining = 0;
  int _currentStep = 0; // 0: inativo, 1: inalar, 2: segurar, 3: exalar
  bool _isExerciseActive = false;
  
  // Sequência do exercício de respiração 4-7-8
  final List<Map<String, dynamic>> _steps = [
    {'text': 'Inale', 'duration': 4, 'color': Colors.blue},
    {'text': 'Segure', 'duration': 7, 'color': Colors.green},
    {'text': 'Exale', 'duration': 8, 'color': Colors.indigo},
  ];
  
  int _completedCycles = 0;
  int _selectedTotalCycles = 3; // Padrão: 3 ciclos
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  void _startExercise() {
    setState(() {
      _isExerciseActive = true;
      _completedCycles = 0;
      _startNextStep();
    });
  }
  
  void _stopExercise() {
    _timer?.cancel();
    _animationController.reset();
    
    setState(() {
      _isExerciseActive = false;
      _currentStep = 0;
      _secondsRemaining = 0;
    });
  }
  
  void _startNextStep() {
    // Se completou todos os passos, iniciar novo ciclo ou finalizar
    if (_currentStep >= _steps.length) {
      _completedCycles++;
      
      if (_completedCycles >= _selectedTotalCycles) {
        _exerciseCompleted();
        return;
      }
      
      _currentStep = 0;
    }
    
    final stepData = _steps[_currentStep];
    _secondsRemaining = stepData['duration'];
    
    // Configurar animação baseada no passo atual
    if (_currentStep == 0) { // Inalar - expandir
      _animationController.duration = Duration(seconds: _secondsRemaining);
      _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0.0);
    } else if (_currentStep == 1) { // Segurar - manter tamanho
      _animationController.stop();
    } else if (_currentStep == 2) { // Exalar - contrair
      _animationController.duration = Duration(seconds: _secondsRemaining);
      _animation = Tween<double>(begin: 1.0, end: 0.5).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0.0);
    }
    
    _startTimer();
  }
  
  void _startTimer() {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _currentStep++;
          _startNextStep();
        }
      });
    });
  }
  
  void _exerciseCompleted() {
    _stopExercise();
    
    // Mostrar diálogo de conclusão
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercício Concluído'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Parabéns! Você completou $_selectedTotalCycles ciclos do exercício de respiração 4-7-8.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Como você está se sentindo agora?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mais relaxado(a)'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Igual'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStepData = _currentStep > 0 && _currentStep <= _steps.length
        ? _steps[_currentStep - 1]
        : {'text': 'Preparado?', 'color': theme.colorScheme.primary};
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiração 4-7-8'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Explicação do exercício
              if (!_isExerciseActive) ...[
                const Text(
                  'Técnica de Respiração 4-7-8',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Esta técnica ajuda a reduzir a ansiedade e promover o relaxamento:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Passos da técnica
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildStepItem(
                          number: 1,
                          text: 'Inale profundamente pelo nariz por 4 segundos',
                          color: Colors.blue,
                        ),
                        _buildStepItem(
                          number: 2,
                          text: 'Segure a respiração por 7 segundos',
                          color: Colors.green,
                        ),
                        _buildStepItem(
                          number: 3,
                          text: 'Exale lentamente pela boca por 8 segundos',
                          color: Colors.indigo,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Seleção de ciclos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Número de ciclos:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _selectedTotalCycles,
                      items: [3, 5, 7, 10].map((cycles) {
                        return DropdownMenuItem<int>(
                          value: cycles,
                          child: Text('$cycles'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTotalCycles = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                ElevatedButton.icon(
                  onPressed: _startExercise,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Exercício'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                  ),
                ),
              ],
              
              // Visualização do exercício em andamento
              if (_isExerciseActive) ...[
                // Informações do ciclo
                Text(
                  'Ciclo ${_completedCycles + 1} de $_selectedTotalCycles',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Círculo de animação de respiração
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: MediaQuery.of(context).size.width * _animation.value,
                          height: MediaQuery.of(context).size.width * _animation.value,
                          decoration: BoxDecoration(
                            color: (currentStepData['color'] as Color).withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Instrução atual
                                Text(
                                  currentStepData['text'] as String,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: currentStepData['color'] as Color,
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Contador
                                Text(
                                  '$_secondsRemaining',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: currentStepData['color'] as Color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botão de parar
                ElevatedButton.icon(
                  onPressed: _stopExercise,
                  icon: const Icon(Icons.stop),
                  label: const Text('Parar Exercício'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStepItem({
    required int number,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 