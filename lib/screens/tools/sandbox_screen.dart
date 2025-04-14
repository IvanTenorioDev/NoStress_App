import 'package:flutter/material.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({Key? key}) : super(key: key);

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  int _selectedToolIndex = 0;
  
  final List<Map<String, dynamic>> _tools = [
    {
      'name': 'Respiração Guiada',
      'icon': Icons.air,
      'color': Colors.blue,
      'description': 'Exercícios de respiração para acalmar a mente e relaxar o corpo.',
    },
    {
      'name': 'Visualização Positiva',
      'icon': Icons.image,
      'color': Colors.green,
      'description': 'Técnicas de visualização para cultivar pensamentos positivos.',
    },
    {
      'name': 'Escrita Terapêutica',
      'icon': Icons.edit_note,
      'color': Colors.purple,
      'description': 'Expresse seus pensamentos e sentimentos através da escrita.',
    },
    {
      'name': 'Relaxamento Muscular',
      'icon': Icons.self_improvement,
      'color': Colors.orange,
      'description': 'Técnica de relaxamento progressivo para aliviar a tensão física.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTool = _tools[_selectedToolIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ferramentas de Bem-estar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experimente nossas ferramentas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Selecione uma ferramenta para ajudar no seu bem-estar',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 24),
            
            // Lista horizontal de ferramentas
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tools.length,
                itemBuilder: (context, index) {
                  final tool = _tools[index];
                  final isSelected = index == _selectedToolIndex;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedToolIndex = index;
                      });
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? tool['color'].withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? tool['color'] : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tool['icon'],
                            color: tool['color'],
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tool['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? tool['color'] : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Detalhes da ferramenta selecionada
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedTool['icon'],
                            color: selectedTool['color'],
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            selectedTool['name'],
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        selectedTool['description'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Divider(),
                      
                      const SizedBox(height: 24),
                      
                      Expanded(
                        child: Center(
                          child: Text(
                            'Conteúdo da ferramenta ${selectedTool['name']}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Iniciar a ferramenta selecionada
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedTool['color'],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Iniciar Atividade'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 