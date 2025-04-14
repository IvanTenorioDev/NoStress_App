import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nostress/models/user_model.dart';

class MoodTrackerCard extends StatefulWidget {
  final String userId;
  
  const MoodTrackerCard({
    Key? key,
    required this.userId,
  }) : super(key: key);
  
  @override
  State<MoodTrackerCard> createState() => _MoodTrackerCardState();
}

class _MoodTrackerCardState extends State<MoodTrackerCard> {
  bool _isLoading = true;
  List<MoodRecord> _moodRecords = [];
  
  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }
  
  Future<void> _loadMoodData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Buscar registros de humor dos últimos 7 dias
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      
      if (snapshot.exists) {
        final userData = User.fromFirestore(snapshot);
        
        // Filtrar registros dos últimos 7 dias
        final recentMoods = userData.moodHistory
            .where((mood) => mood.timestamp.isAfter(startDate) && 
                            mood.timestamp.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
        
        // Ordenar por data
        recentMoods.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        if (mounted) {
          setState(() {
            _moodRecords = recentMoods;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Erro ao carregar dados de humor: $e');
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seu Humor na Semana',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Registrar humor',
                  onPressed: _showMoodDialog,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_moodRecords.isEmpty)
              _buildEmptyState()
            else
              SizedBox(
                height: 200,
                child: _buildMoodChart(),
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
              Icons.show_chart,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum registro de humor encontrado.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showMoodDialog,
              child: const Text('Registrar Humor'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMoodChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == 10) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(value.toInt().toString()),
                );
              },
              interval: 2,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _moodRecords.length || value.toInt() < 0) {
                  return const SizedBox.shrink();
                }
                
                final date = _moodRecords[value.toInt()].timestamp;
                final formattedDate = DateFormat('E', 'pt_BR').format(date);
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(formattedDate),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _moodRecords.length - 1.0,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              _moodRecords.length,
              (i) => FlSpot(i.toDouble(), _moodRecords[i].moodScore.toDouble()),
            ),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, bar, __) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showMoodDialog() {
    int selectedMood = 5;
    final textController = TextEditingController();
    final List<String> commonTriggers = [
      'Trabalho', 'Família', 'Saúde', 'Finanças', 'Relacionamento', 'Sono'
    ];
    final selectedTriggers = <String>[];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Como você está se sentindo?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('😢', style: TextStyle(fontSize: 24)),
                    const Text('😐', style: TextStyle(fontSize: 24)),
                    const Text('😊', style: TextStyle(fontSize: 24)),
                  ],
                ),
                
                Slider(
                  value: selectedMood.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: selectedMood.toString(),
                  onChanged: (value) {
                    setState(() {
                      selectedMood = value.toInt();
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'O que está afetando seu humor? (opcional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                
                Wrap(
                  spacing: 8,
                  children: commonTriggers.map((trigger) {
                    final isSelected = selectedTriggers.contains(trigger);
                    return FilterChip(
                      label: Text(trigger),
                      selected: isSelected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            selectedTriggers.add(trigger);
                          } else {
                            selectedTriggers.remove(trigger);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                _saveMoodRecord(
                  moodScore: selectedMood,
                  note: textController.text,
                  triggers: selectedTriggers,
                );
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveMoodRecord({
    required int moodScore,
    required String note,
    required List<String> triggers,
  }) async {
    try {
      final newMood = MoodRecord(
        timestamp: DateTime.now(),
        moodScore: moodScore,
        note: note,
        triggers: triggers,
      );
      
      // Obter registros atuais
      final docRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
      final doc = await docRef.get();
      
      if (doc.exists) {
        final userData = User.fromFirestore(doc);
        final updatedMoodHistory = List<MoodRecord>.from(userData.moodHistory)
          ..add(newMood);
        
        // Atualizar Firestore
        await docRef.update({
          'moodHistory': updatedMoodHistory.map((m) => m.toMap()).toList(),
        });
        
        // Recarregar dados
        _loadMoodData();
      }
    } catch (e) {
      debugPrint('Erro ao salvar humor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar registro de humor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 