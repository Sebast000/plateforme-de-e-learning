import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- Modèle utilisateur ---
class User {
  final int id;
  final String username;
  final String email;
  final String? niveauInitial;

  User({required this.id, required this.username, required this.email, this.niveauInitial});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      // Changé 'niveauInitial' en 'niveau_initial' pour coller aux conventions API courantes si besoin
      niveauInitial: json['niveau_initial'] as String? ?? json['niveauInitial'] as String?,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final String _baseUrl = 'http://10.0.2.2:8000/api';

  String? _authToken;
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get authToken => _authToken;
  User? get user => _user;
  
  // Utilisation standardisée
  User? get currentUser => _user;

  AuthProvider() {
    _checkInitialAuth();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _checkInitialAuth() {
    _setLoading(true);
    // Supprimé le délai artificiel. L'authentification initiale est instantanée ici.
    _isAuthenticated = _authToken != null;
    _setLoading(false);
  }

  Future<void> login(String username, String password) async {
    // Début du chargement
    _setLoading(true);

    try {
      // --- LOGIQUE DE CONNEXION SIMULÉE ---
      if (username.isNotEmpty && password.isNotEmpty) {
        // Simulation d'un délai pour mieux observer l'état de chargement
        if (kDebugMode) await Future.delayed(const Duration(milliseconds: 500));
        
        _authToken = 'SIMULATED_TOKEN_12345';
        
        // Simulation de la réponse JSON de l'API
        final userData = {
          'id': 99,
          'username': username,
          'email': 'user@simulated.com',
          'niveauInitial': 'A2',
        };

        _user = User.fromJson(userData);
        _isAuthenticated = true;
        
        // notifyListeners est appelé via _setLoading(false) si le chargement passe à false

      } else {
        throw Exception('Veuillez remplir tous les champs.');
      }
      
    } catch (e) {
      // En cas d'échec de la connexion simulée/réelle
      rethrow; // Propage l'exception pour que le formulaire de connexion puisse l'afficher
    } finally {
      // Fin du chargement (sera appelé même en cas d'erreur)
      _setLoading(false); 
      // Si la connexion réussit, notifyListeners() dans _setLoading mettra à jour l'état et déclenchera la navigation.
    }
  }

  Future<void> register(String username, String email, String password) async {
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        // Tente d'extraire un message d'erreur plus spécifique
        throw Exception(errorBody['detail'] ?? "Échec de l'inscription.");
      }
    } catch (e) {
      // Pour une meilleure gestion d'erreur dans l'UI
      throw Exception("Erreur d'inscription ou de connexion réseau : $e");
    } finally {
      _setLoading(false);
    }
  }

  void logout() async {
    _setLoading(true);
    _authToken = null;
    _user = null;
    _isAuthenticated = false;
    // Garde un petit délai pour l'effet visuel de déconnexion
    await Future.delayed(const Duration(milliseconds: 500)); 
    _setLoading(false);
  }
}