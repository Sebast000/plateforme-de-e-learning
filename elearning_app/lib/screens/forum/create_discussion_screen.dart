// lib/screens/forum/create_discussion_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; 
import 'package:provider/provider.dart'; 
// ⚠️ ASSUREZ-VOUS QUE CE CHEMIN VERS VOTRE AuthProvider EST CORRECT
import '../../../providers/auth_provider.dart';


class CreateDiscussionScreen extends StatefulWidget {
  const CreateDiscussionScreen({super.key});

  @override
  State<CreateDiscussionScreen> createState() => _CreateDiscussionScreenState();
}

class _CreateDiscussionScreenState extends State<CreateDiscussionScreen> {
  // Contrôleurs pour récupérer le texte des champs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  bool _isLoading = false; // État pour gérer le chargement

  // 🎯 FONCTION CLÉ : Envoie les données à l'API Django
  Future<void> _submitDiscussion() async {
    final title = _titleController.text.trim();
    final description = _contentController.text.trim(); // Renommé en 'description' pour Django

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar( 
        const SnackBar(content: Text('Veuillez remplir le titre et la description.')),
      );
      return;
    }

    // 🎯 ÉTAPE 1 : Récupérer le jeton (Token) de l'utilisateur
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authToken = authProvider.authToken; // Utilisation de 'authToken' corrigée
    
    // 🔎 LIGNE DE DÉBOGAGE CRITIQUE : Affiche la valeur envoyée
    print('Valeur du Jeton (authToken): $authToken'); 
    
    // Vérification du Token
    if (authToken == null || authToken.isEmpty) { 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Jeton manquant. Veuillez vous connecter.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ⚠️ Assurez-vous que l'URL est correcte
      final url = Uri.parse('http://127.0.0.1:8000/api/discussions/'); 
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 🎯 ÉTAPE 2 : ENVOI DU TOKEN DANS LE HEADER Authorization
          // Assurez-vous que le format 'Token XXXX' est celui attendu par Django DRF
          'Authorization': 'Token $authToken', 
        },
        body: json.encode({
          'title': title,
          'description': description, // Nom de champ pour le modèle Django
        }),
      );

      // 🚨 Vérification 'mounted' après l'opération asynchrone
      if (!mounted) return; 

      if (response.statusCode == 201) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discussion publiée avec succès! (201)')),
        );
        if (!mounted) return; 
        Navigator.pop(context); // Retourne au Forum
        
      } else {
        // Gère les erreurs 400, 403, 500, etc.
        final errorBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur ${response.statusCode}: ${errorBody.toString()}')),
        );
      }
    } catch (e) {
      // Gère les erreurs de connexion réseau
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite (Network): $e')),
      );
    } finally {
      setState(() { 
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Discussion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ pour le titre
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de la discussion',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Champ pour le contenu/description
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Détails ou question...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Bouton de soumission
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // Désactiver le bouton pendant le chargement
                onPressed: _isLoading ? null : _submitDiscussion, 
                icon: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Soumission...' : 'Publier la Discussion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}