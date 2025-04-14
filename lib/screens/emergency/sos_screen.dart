import 'package:flutter/material.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda Emergencial'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alerta
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Se você estiver enfrentando uma emergência que ameaça sua vida, ligue imediatamente para os serviços de emergência.',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.red.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.phone),
                      label: const Text('Ligar para 192 (SAMU)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // Abrir discador com número de emergência
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Título da seção
            Text(
              'Linhas de Apoio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            // Lista de contatos
            _buildContactCard(
              context,
              'Centro de Valorização da Vida (CVV)',
              '188',
              'Apoio emocional e prevenção ao suicídio',
              Icons.support_agent,
              Colors.blue,
            ),
            
            _buildContactCard(
              context,
              'Disque Saúde Mental',
              '0800 2800 031',
              'Orientação e informação sobre saúde mental',
              Icons.health_and_safety,
              Colors.green,
            ),
            
            _buildContactCard(
              context,
              'Central de Atendimento à Mulher',
              '180',
              'Orientação para mulheres em situação de violência',
              Icons.female,
              Colors.purple,
            ),
            
            const SizedBox(height: 32),
            
            // Dicas de manejo de crise
            _buildCrisisManagementCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    String title,
    String phone,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          radius: 24,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 8),
            Text(
              phone,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone_enabled),
          color: color,
          onPressed: () {
            // Abrir discador com número específico
          },
        ),
      ),
    );
  }

  Widget _buildCrisisManagementCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Técnicas para Momentos de Crise',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            _buildCrisisTechniqueItem(
              '1. Respiração',
              'Respire fundo contando até 4, segure por 7, e solte por 8.',
              Icons.air,
            ),
            
            _buildCrisisTechniqueItem(
              '2. Grounding',
              'Identifique 5 coisas que você pode ver, 4 que pode tocar, 3 que pode ouvir, 2 que pode cheirar e 1 que pode provar.',
              Icons.touch_app,
            ),
            
            _buildCrisisTechniqueItem(
              '3. Redirecionamento',
              'Mude seu ambiente físico. Levante-se e caminhe, vá para outro cômodo ou saia ao ar livre.',
              Icons.directions_walk,
            ),
            
            _buildCrisisTechniqueItem(
              '4. Expressão',
              'Escreva seus pensamentos e sentimentos em um papel ou converse com alguém de confiança.',
              Icons.edit_note,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisTechniqueItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 