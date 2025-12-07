// lib/screens/forum/forum_screen.dart

import 'package:flutter/material.dart';
// 🎯 NOUVEAU : Importation du nouvel écran de création de discussion
import 'create_discussion_screen.dart'; 

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  // 🎯 NOUVELLE MÉTHODE : Gère la navigation vers l'écran de création
  void _navigateToCreateDiscussion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDiscussionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum de Discussion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Démarrer une nouvelle discussion',
            onPressed: () {
              // 🎯 ACTION : Appelle la navigation
              _navigateToCreateDiscussion(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // L'icône avec la correction d'opacité
              Icon(Icons.forum, size: 80, color: theme.colorScheme.primary.withAlpha(127)),
              
              const SizedBox(height: 20),
              Text(
                "Bienvenue sur le Forum!",
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Lancez un sujet pour poser vos questions, discuter avec la communauté ou partager vos connaissances.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_comment),
                label: const Text('Démarrer une discussion'),
                onPressed: () {
                  // 🎯 ACTION : Appelle la navigation
                  _navigateToCreateDiscussion(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}