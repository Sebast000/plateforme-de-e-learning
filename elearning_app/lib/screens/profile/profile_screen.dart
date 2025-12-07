// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';

import 'package:elearning_app/screens/profile/settings_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) { 
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          // Bouton de navigation vers les Paramètres
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Section de l'utilisateur (Avatar et Nom)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              width: double.infinity,
              color: theme.colorScheme.surface, 
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nom de l\'utilisateur (Étudiant)',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'utilisateur@elearning.com',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            
            // 2. Statistiques Rapides
            const Divider(),
            _buildStatGrid(theme),
            const Divider(),

            // 3. Menus de Navigation (Options du compte)
            _buildMenuList(context, theme), // CORRECTION 2: Passer context ici
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher les statistiques (grille simple)
  Widget _buildStatGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(theme, '12', 'Cours Terminés', Icons.star_border),
          _buildStatItem(theme, '150', 'Heures Apprises', Icons.access_time),
          _buildStatItem(theme, 'A2', 'Niveau Global', Icons.trending_up),
        ],
      ),
    );
  }
  
  // Widget pour un seul élément de statistique
  Widget _buildStatItem(ThemeData theme, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 5),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  // Widget pour la liste des options (Compte, Aide)
  // CORRECTION 1: Ajout de BuildContext en argument
  Widget _buildMenuList(BuildContext context, ThemeData theme) { 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10, bottom: 5),
          child: Text('Paramètres du Compte', style: theme.textTheme.titleMedium),
        ),
        _buildProfileTile(Icons.person_outline, 'Modifier le Profil', () {}),
        _buildProfileTile(Icons.notifications_none, 'Notifications', () {}),
        _buildProfileTile(Icons.payments_outlined, 'Historique des Paiements', () {}),

        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 20, bottom: 5),
          child: Text('Aide et Support', style: theme.textTheme.titleMedium),
        ),
        _buildProfileTile(Icons.help_outline, 'Centre d\'Aide', () {}),
        _buildProfileTile(Icons.gavel_outlined, 'Politique de Confidentialité', () {}),
        
        const Divider(),
        _buildProfileTile(
          Icons.logout, 
          'Gérer le Compte et Déconnexion', 
          () {
            // Renvoyer l'utilisateur vers la page de paramètres où l'action de déconnexion est claire.
            debugPrint('Tentative de déconnexion. Redirection vers les Paramètres.');
            
            // Ligne 133 est maintenant correcte car context est passé
            Navigator.push( 
              context, 
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }, 
          color: Colors.red.shade700
        ),
      ],
    );
  }
  
  // Widget réutilisable pour les options de la liste
  Widget _buildProfileTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey.shade600),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}