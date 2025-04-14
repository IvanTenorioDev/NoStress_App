import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:nostress/models/assessment_model.dart';
import 'package:nostress/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class AssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  
  // Salvar resultado de um questionário GAD-7
  Future<void> saveGAD7Assessment(Map<int, int> responses) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado.');
    
    // Calcular pontuação total
    int totalScore = 0;
    responses.forEach((key, value) {
      totalScore += value;
    });
    
    final assessment = Assessment(
      id: const Uuid().v4(),
      type: 'gad7',
      timestamp: DateTime.now(),
      score: totalScore,
      responses: responses.map((key, value) => MapEntry(key.toString(), value)),
      userId: userId,
    );
    
    try {
      await _firestore.collection('assessments').add(assessment.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar avaliação GAD-7: ${e.toString()}');
    }
  }
  
  // Salvar análise de estresse facial
  Future<void> saveFacialStressAnalysis(
    FacialStressAnalysis analysis,
  ) async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado.');
    
    try {
      await _firestore.collection('facial_analyses').add(analysis.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar análise facial: ${e.toString()}');
    }
  }
  
  // Analisar expressão facial a partir de uma imagem
  Future<Map<String, double>> analyzeFacialExpression(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        throw Exception('Nenhum rosto detectado na imagem.');
      }
      
      // Pegar o primeiro rosto detectado
      final face = faces.first;
      
      // Mapa para armazenar probabilidades de emoções
      final Map<String, double> emotionScores = {
        'sorrindo': face.smilingProbability ?? 0.0,
        // O ML Kit não fornece diretamente outras emoções, precisaríamos de um modelo personalizado
        // ou outra API para análises mais completas
      };
      
      // Calcular um "score de estresse" simples (quanto menos sorriso, maior o estresse)
      // Isso é simplificado, uma implementação real precisaria de um modelo mais completo
      final stressScore = 100 - ((face.smilingProbability ?? 0.0) * 100);
      
      emotionScores['estresse'] = stressScore / 100;
      
      return emotionScores;
    } catch (e) {
      throw Exception('Erro ao analisar expressão facial: ${e.toString()}');
    }
  }
  
  // Obter histórico de avaliações GAD-7 do usuário
  Stream<List<Assessment>> getGAD7History() {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado.');
    
    return _firestore
        .collection('assessments')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'gad7')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Assessment.fromFirestore(doc))
            .toList());
  }
  
  // Obter histórico de análises faciais do usuário
  Stream<List<FacialStressAnalysis>> getFacialAnalysisHistory() {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado.');
    
    return _firestore
        .collection('facial_analyses')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacialStressAnalysis.fromMap(doc.data()))
            .toList());
  }
  
  // Obter a avaliação GAD-7 mais recente
  Future<Assessment?> getLatestGAD7Assessment() async {
    final userId = _authService.currentUserId;
    if (userId == null) return null;
    
    try {
      final snapshot = await _firestore
          .collection('assessments')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'gad7')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Assessment.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar avaliação GAD-7: ${e.toString()}');
    }
  }
  
  // Analisar tendência de estresse baseado no histórico
  Future<Map<String, dynamic>> analyzeStressTrend() async {
    final userId = _authService.currentUserId;
    if (userId == null) throw Exception('Usuário não autenticado.');
    
    try {
      // Obter avaliações dos últimos 30 dias
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      final snapshot = await _firestore
          .collection('assessments')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'gad7')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: false)
          .get();
      
      final assessments = snapshot.docs
          .map((doc) => Assessment.fromFirestore(doc))
          .toList();
      
      if (assessments.isEmpty) {
        return {
          'trend': 'Sem dados suficientes',
          'averageScore': 0,
          'dataPoints': <Map<String, dynamic>>[],
        };
      }
      
      // Calcular média
      final totalScore = assessments.fold<int>(
          0, (sum, assessment) => sum + assessment.score);
      final averageScore = totalScore / assessments.length;
      
      // Criar pontos de dados para gráfico
      final dataPoints = assessments.map((assessment) => {
        'date': assessment.timestamp,
        'score': assessment.score,
      }).toList();
      
      // Determinar tendência
      String trend = 'Estável';
      if (assessments.length > 1) {
        final firstScore = assessments.first.score;
        final lastScore = assessments.last.score;
        final difference = lastScore - firstScore;
        
        if (difference > 2) {
          trend = 'Piorando';
        } else if (difference < -2) {
          trend = 'Melhorando';
        }
      }
      
      return {
        'trend': trend,
        'averageScore': averageScore,
        'dataPoints': dataPoints,
      };
    } catch (e) {
      throw Exception('Erro ao analisar tendência de estresse: ${e.toString()}');
    }
  }
  
  // Liberar recursos
  void dispose() {
    _faceDetector.close();
  }
} 