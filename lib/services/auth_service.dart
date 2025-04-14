import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nostress/models/user_model.dart' as app_models;

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Obter usuário atual
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Obter o ID do usuário atual
  String? get currentUserId => _firebaseAuth.currentUser?.uid;
  
  // Registrar com email e senha
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _createUserInFirestore(userCredential.user!.uid, name, email);
        return userCredential.user!.uid;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Senha muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Este email já está em uso.');
      }
      throw Exception(e.message ?? 'Erro desconhecido.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Login com email e senha
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Usuário não encontrado para este email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta.');
      }
      throw Exception(e.message ?? 'Erro desconhecido.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Sair
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  // Recuperar senha
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Erro ao enviar email de recuperação.');
    }
  }
  
  // Criar usuário no Firestore
  Future<void> _createUserInFirestore(String uid, String name, String email) async {
    final userData = app_models.User(
      id: uid,
      name: name,
      email: email,
      moodHistory: [],
      contacts: app_models.EmergencyContacts(),
      audioPrefs: app_models.AudioPreferences(),
    );
    
    await _firestore.collection('users').doc(uid).set(userData.toMap());
  }
  
  // Obter dados do usuário atual
  Future<app_models.User?> getCurrentUserData() async {
    if (currentUserId == null) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists) {
        return app_models.User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dados do usuário: ${e.toString()}');
    }
  }
  
  // Atualizar dados do usuário
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUserId == null) throw Exception('Usuário não autenticado.');
    
    try {
      await _firestore.collection('users').doc(currentUserId).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar dados do usuário: ${e.toString()}');
    }
  }
} 