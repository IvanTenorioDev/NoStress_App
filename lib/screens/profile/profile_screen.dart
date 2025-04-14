import 'package:flutter/material.dart';
import 'package:nostress/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dados simulados
  final UserModel _user = UserModel(
    id: 'user123',
    name: 'Maria Silva',
    email: 'maria.silva@exemplo.com',
    photoUrl: '',
    createdAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Abrir configurações
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            CircleAvatar(
              radius: 64,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: _user.photoUrl.isEmpty
                  ? Text(
                      _user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(height: 16),
            
            // Nome do usuário
            Text(
              _user.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            const SizedBox(height: 4),
            
            // Email
            Text(
              _user.email,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 32),
            
            // Estatísticas
            _buildStatsCard(),
            
            const SizedBox(height: 24),
            
            // Preferências
            _buildPreferencesCard(),
            
            const SizedBox(height: 24),
            
            // Botão de logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Fazer logout
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suas Estatísticas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Dias Consecutivos', '7'),
                _buildStatItem('Exercícios Realizados', '24'),
                _buildStatItem('Avaliações', '3'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
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
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suas Preferências',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildPreferenceSwitch('Notificações diárias', true),
            _buildPreferenceSwitch('Modo escuro', false),
            _buildPreferenceSwitch('Sons de relaxamento', true),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Alterar configuração
            },
          ),
        ],
      ),
    );
  }
} 