import 'package:cloud_firestore/cloud_firestore.dart';

class Assessment {
  final String id;
  final String type; // 'gad7', 'stress_level', etc.
  final DateTime timestamp;
  final int score;
  final Map<String, dynamic> responses;
  final String userId;
  
  Assessment({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.score,
    required this.responses,
    required this.userId,
  });
  
  factory Assessment.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Assessment(
      id: doc.id,
      type: data['type'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      score: data['score'] ?? 0,
      responses: data['responses'] as Map<String, dynamic>? ?? {},
      userId: data['userId'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'score': score,
      'responses': responses,
      'userId': userId,
    };
  }
  
  String getSeverityLevel() {
    if (type == 'gad7') {
      if (score >= 0 && score <= 4) {
        return 'Ansiedade Mínima';
      } else if (score >= 5 && score <= 9) {
        return 'Ansiedade Leve';
      } else if (score >= 10 && score <= 14) {
        return 'Ansiedade Moderada';
      } else {
        return 'Ansiedade Severa';
      }
    } else if (type == 'stress_level') {
      if (score >= 0 && score <= 3) {
        return 'Estresse Baixo';
      } else if (score >= 4 && score <= 6) {
        return 'Estresse Moderado';
      } else {
        return 'Estresse Alto';
      }
    }
    return 'Não Classificado';
  }
}

// Modelo para o questionário GAD-7
class GAD7Question {
  final int id;
  final String question;
  
  GAD7Question({
    required this.id,
    required this.question,
  });
  
  static List<GAD7Question> getGAD7Questions() {
    return [
      GAD7Question(
        id: 1,
        question: 'Sentir-se nervoso, ansioso ou muito tenso',
      ),
      GAD7Question(
        id: 2,
        question: 'Não ser capaz de impedir ou de controlar as preocupações',
      ),
      GAD7Question(
        id: 3,
        question: 'Preocupar-se muito com diversas coisas',
      ),
      GAD7Question(
        id: 4,
        question: 'Dificuldade para relaxar',
      ),
      GAD7Question(
        id: 5,
        question: 'Ficar tão agitado que se torna difícil permanecer sentado',
      ),
      GAD7Question(
        id: 6,
        question: 'Ficar facilmente aborrecido ou irritado',
      ),
      GAD7Question(
        id: 7,
        question: 'Sentir medo como se algo horrível fosse acontecer',
      ),
    ];
  }
}

// Opções de resposta para o GAD-7
class GAD7Option {
  final int value;
  final String label;
  
  GAD7Option({
    required this.value,
    required this.label,
  });
  
  static List<GAD7Option> getOptions() {
    return [
      GAD7Option(value: 0, label: 'Nunca'),
      GAD7Option(value: 1, label: 'Vários dias'),
      GAD7Option(value: 2, label: 'Mais da metade dos dias'),
      GAD7Option(value: 3, label: 'Quase todos os dias'),
    ];
  }
}

// Classe para análise de expressões faciais
class FacialStressAnalysis {
  final String userId;
  final DateTime timestamp;
  final double stressScore; // 0-100
  final Map<String, double> emotionScores; // {'alegria': 0.2, 'tristeza': 0.5, ...}
  
  FacialStressAnalysis({
    required this.userId,
    required this.timestamp,
    required this.stressScore,
    required this.emotionScores,
  });
  
  factory FacialStressAnalysis.fromMap(Map<String, dynamic> map) {
    return FacialStressAnalysis(
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      stressScore: map['stressScore']?.toDouble() ?? 0.0,
      emotionScores: Map<String, double>.from(map['emotionScores'] ?? {}),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'stressScore': stressScore,
      'emotionScores': emotionScores,
    };
  }
  
  String getStressLevel() {
    if (stressScore < 30) {
      return 'Baixo';
    } else if (stressScore < 70) {
      return 'Moderado';
    } else {
      return 'Alto';
    }
  }
} 