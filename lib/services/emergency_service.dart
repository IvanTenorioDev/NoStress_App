import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nostress/models/user_model.dart';
import 'package:nostress/services/auth_service.dart';

class EmergencyService {
  final AuthService _authService = AuthService();
  
  // Obter contatos de emergência do usuário
  Future<List<Contact>> getEmergencyContacts() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado.');
      }
      return userData.contacts.contacts;
    } catch (e) {
      throw Exception('Erro ao obter contatos de emergência: ${e.toString()}');
    }
  }
  
  // Adicionar um contato de emergência
  Future<void> addEmergencyContact(Contact contact) async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado.');
      }
      
      final contacts = List<Contact>.from(userData.contacts.contacts);
      contacts.add(contact);
      
      await _authService.updateUserData({
        'contacts': {
          'contacts': contacts.map((e) => e.toMap()).toList(),
        },
      });
    } catch (e) {
      throw Exception('Erro ao adicionar contato de emergência: ${e.toString()}');
    }
  }
  
  // Remover um contato de emergência
  Future<void> removeEmergencyContact(String phoneNumber) async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData == null) {
        throw Exception('Usuário não autenticado.');
      }
      
      final contacts = userData.contacts.contacts
          .where((contact) => contact.phone != phoneNumber)
          .toList();
      
      await _authService.updateUserData({
        'contacts': {
          'contacts': contacts.map((e) => e.toMap()).toList(),
        },
      });
    } catch (e) {
      throw Exception('Erro ao remover contato de emergência: ${e.toString()}');
    }
  }
  
  // Verificar permissões de localização
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Verificar se os serviços de localização estão habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviços de localização desabilitados.');
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permissões de localização permanentemente negadas, não é possível solicitar permissões.');
    }
    
    return true;
  }
  
  // Obter a localização atual
  Future<Position> getCurrentLocation() async {
    await _checkLocationPermission();
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
  
  // Enviar SMS com localização para contatos de emergência
  Future<void> sendEmergencySMS() async {
    try {
      final contacts = await getEmergencyContacts();
      if (contacts.isEmpty) {
        throw Exception('Nenhum contato de emergência cadastrado.');
      }
      
      final position = await getCurrentLocation();
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      
      final userData = await _authService.getCurrentUserData();
      final userName = userData?.name ?? 'Usuário';
      
      final message =
          'ALERTA DE EMERGÊNCIA: $userName está passando por uma crise e precisa de ajuda. '
          'Localização atual: $googleMapsUrl';
      
      for (final contact in contacts) {
        final url = Uri.parse('sms:${contact.phone}?body=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      }
    } catch (e) {
      throw Exception('Erro ao enviar SMS de emergência: ${e.toString()}');
    }
  }
  
  // Ligar para o primeiro contato de emergência
  Future<void> callEmergencyContact() async {
    try {
      final contacts = await getEmergencyContacts();
      if (contacts.isEmpty) {
        throw Exception('Nenhum contato de emergência cadastrado.');
      }
      
      final phoneNumber = contacts.first.phone;
      final url = Uri.parse('tel:$phoneNumber');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw Exception('Não foi possível iniciar a chamada.');
      }
    } catch (e) {
      throw Exception('Erro ao ligar para contato de emergência: ${e.toString()}');
    }
  }
  
  // Ativar o "Modo Escudo" (retorna uma função para desativar)
  Future<Function> activateShieldMode() async {
    // Aqui você pode implementar a lógica para silenciar notificações
    // e ajustar brilho da tela. Como isso depende de configurações específicas
    // da plataforma, estamos apenas simulando o comportamento.
    
    // Em uma implementação real, você usaria plugins específicos para
    // controlar notificações e brilho da tela.
    
    return () {
      // Função para desativar o modo escudo
      // Restauraria as configurações originais
    };
  }
} 