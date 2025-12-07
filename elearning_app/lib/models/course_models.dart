// lib/models/course_models.dart

class Course {
  final int id;
  final String title;
  final String description;
  final String niveauCible;

  final String category;
  final String author;
  final double duration;
  final double progress;
  final String imageUrl;

  final List<Lesson> lessons;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.niveauCible,
    required this.category,
    required this.author,
    required this.duration,
    required this.progress,
    required this.imageUrl,
    this.lessons = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Fonction utilitaire pour parser les doubles (gère num et String)
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // 🎯 CORRECTION : Fonction pour agréger et dé-dupliquer les leçons des modules
    List<Lesson> extractAndDeduplicateLessons(dynamic modulesJson) {
      if (modulesJson is! List) return [];

      // Utiliser un Map pour garantir que chaque ID de leçon est unique
      final Map<int, Lesson> uniqueLessonsMap = {};

      for (var module in modulesJson) {
        if (module is Map && module['lessons'] is List) {
          for (var lessonJson in module['lessons']) {
            final lesson = Lesson.fromJson(lessonJson);
            
            // Si le JSON contient des doublons, seul le dernier sera conservé pour cet ID.
            uniqueLessonsMap[lesson.id] = lesson;
          }
        }
      }

      // Retourner la liste des leçons uniques.
      return uniqueLessonsMap.values.toList();
    }
    
    return Course(
      // Champ INT (Id)
      id: json['id'] ?? 0, 

      // Champs STRING : Utilisation de .toString() pour la sécurité
      title: json['title']?.toString() ?? '', 
      description: json['description']?.toString() ?? '',
      niveauCible: (json['level'] ?? json['niveau_cible'])?.toString() ?? 'N/A',

      category: json['category']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      
      // Champs DOUBLE (via parseDouble)
      duration: parseDouble(json['duration']), 
      progress: parseDouble(json['progress']), 
      
      // Champ STRING (URL)
      imageUrl: json['image_url']?.toString() ?? '',
      
      // 🎯 NOUVEAU PARSING : Lecture des leçons à partir de "modules"
      lessons: extractAndDeduplicateLessons(json['modules']),
    );
  }
}

// -----------------------------------------------------
// Classe Lesson
// -----------------------------------------------------

class Lesson {
  final int id;
  final String title;
  final String content; // ⬅️ Le contenu textuel que nous affichons
  final int order;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Fonction utilitaire pour lire les int de manière sécurisée
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return Lesson(
      id: parseInt(json['id']), 
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      
      // ⚠️ IMPORTANT: 'order' doit être > 0 dans votre API/BDD pour s'afficher correctement.
      order: parseInt(json['order']),
      
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

// -----------------------------------------------------
// Module (Maintenu)
// -----------------------------------------------------
class Module {
  final int id;
  final String title;
  final int order;

  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    required this.order,
    required this.lessons,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      order: json['order'] ?? 0,
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => Lesson.fromJson(e))
          .toList(),
    );
  }
}