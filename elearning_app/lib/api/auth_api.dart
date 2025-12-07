// lib/api/auth_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // NOUVEL IMPORT NÉCESSAIRE pour kIsWeb
import 'package:http/http.dart' as http;

class AuthApi {
  
  // 🎯 CORRECTION : Utilisation de kIsWeb pour déterminer l'adresse IP correcte.
  // 127.0.0.1 (localhost) est utilisé pour le Web.
  // 10.0.2.2 (l'alias de l'hôte) est utilisé pour l'émulateur Android.
  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000/api'
      : 'http://10.0.2.2:8000/api';
      
  final _jsonHeaders = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  // --- Connexion (/api/token/) ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token/'); 
    final res = await http.post(
      url,
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password})
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    // Gestion des erreurs du backend
    final errorBody = jsonDecode(res.body);
    throw Exception('Erreur de connexion: ${errorBody['detail'] ?? errorBody['non_field_errors']?[0] ?? res.body}');
  }

  // --- Inscription (/api/register/) ---
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/register/');
    final res = await http.post(
      url,
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'email': email, 'password': password})
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    
    // Gestion des erreurs du backend
    final errorBody = jsonDecode(res.body);
    throw Exception('Erreur d\'inscription: ${errorBody.toString()}');
  }

  // --- Récupération des détails utilisateur (API Profil) ---
  Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/profile/'); 
    final res = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Échec de la récupération du profil');
  }
}