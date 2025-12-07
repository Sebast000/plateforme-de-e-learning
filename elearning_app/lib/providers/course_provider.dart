import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/course_models.dart'; // Assurez-vous que le chemin vers Course est correct

class CourseProvider extends ChangeNotifier {
  // ⚠️ Configuration de l'API
  // Utilisez l'adresse de loopback pour l'émulateur Android, ou l'IP locale pour un appareil physique.
  final String _baseUrl = 'http://127.0.0.1:8000/api';

  // --- États ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Course> _allCourses = [];
  
  // --- Getters publics ---
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Liste complète des cours
  List<Course> get allCourses => _allCourses; 

  // Données filtrées basées sur le modèle Course
  List<Course> get coursesInProgress => _allCourses.where((c) => c.progress > 0 && c.progress < 1).toList();
  List<Course> get featuredCourses => _allCourses.where((c) => c.progress == 0 || c.progress > 0).toList();

  // --- Méthode de gestion de l'état ---

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _errorMessage = null; // Effacer les erreurs précédentes au début du chargement
    }
    notifyListeners();
  }

  // --- Fonction de chargement des cours ---
  
  Future<void> fetchCourses(String authToken) async {
    // Si nous avons déjà des cours et que nous ne sommes pas en mode forcé, on arrête
    if (_allCourses.isNotEmpty && !kDebugMode) {
      debugPrint("INFO: Cours déjà chargés (Mode Production).");
      return; 
    }
    
    _setLoading(true);

    try {
      final url = Uri.parse('$_baseUrl/courses/'); // ⚠️ Vérifiez si le chemin est /api/courses/
      debugPrint('Tentative de GET sur : $url');

      // 1. Appel API
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Utilisation du jeton d'authentification pour les requêtes protégées
          'Authorization': 'Token $authToken', 
        },
      );
      
      debugPrint('Statut de la réponse de l\'API : ${response.statusCode}');

      if (response.statusCode == 200) {
        // La requête a réussi
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        
        // ⚠️ Assurez-vous que 'results' correspond à la clé de votre liste de cours dans la réponse API
        final List<dynamic> results = data['results'] ?? data; // Utilise 'data' si pas de pagination 'results'
        
        _allCourses = results
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('SUCCÈS : ${_allCourses.length} cours chargés depuis l\'API.');

      } else {
        // Erreur HTTP (401, 404, 500...)
        _errorMessage = 'Erreur HTTP ${response.statusCode}. Corps: ${response.body}';
        debugPrint('ERREUR API : ${_errorMessage!}');
        _allCourses = []; 
      }

    } catch (e) {
      // Échec de la connexion (réseau, timeout, URL incorrecte)
      _errorMessage = 'Erreur de connexion (Network/URL) : $e. Vérifiez que votre serveur est démarré et l\'adresse 10.0.2.2 est correcte.';
      debugPrint('ERREUR DE CONNEXION : ${_errorMessage!}');
      _allCourses = [];
    } finally {
      // Si la liste est vide en mode debug, simuler des données pour ne pas bloquer l'UI
      if (_allCourses.isEmpty && kDebugMode) {
        _simulateCourses();
        _errorMessage ??= "ATTENTION: Les cours affichés sont SIMULÉS. Vérifiez la console pour la connexion API.";
      }
      _setLoading(false);
    }
  }

  // --- Simulation de données (pour le développement) ---

  void _simulateCourses() {
    _allCourses = [
      Course(
        id: 1, 
        title: "Français A1: Débutant", 
        description: "Bases de la grammaire.", 
        niveauCible: 'A1', 
        category: 'Grammaire', 
        author: 'Dr. Dupont', 
        duration: 12.5, 
        progress: 0.5, // En cours
        imageUrl: 'https://placehold.co/600x400/3498db/ffffff?text=A1', 
        lessons: const []
      ),
      Course(
        id: 2, 
        title: "Conversation B2: Avancé", 
        description: "Maîtriser le débat.", 
        niveauCible: 'B2', 
        category: 'Conversation', 
        author: 'Mme. Dubois', 
        duration: 8.0, 
        progress: 0.0, // Non commencé
        imageUrl: 'https://placehold.co/600x400/2ecc71/ffffff?text=B2', 
        lessons: const []
      ),
      Course(
        id: 3, 
        title: "Culture Française", 
        description: "Histoire et traditions.", 
        niveauCible: 'B1', 
        category: 'Culture', 
        author: 'M. Petit', 
        duration: 5.0, 
        progress: 1.0, // Terminé (il ne devrait pas apparaître dans featured/progress)
        imageUrl: 'https://placehold.co/600x400/f39c12/ffffff?text=Culture', 
        lessons: const []
      ),
    ];
    debugPrint("SIMULATION : 3 cours ont été générés en tant que secours.");
  }
}