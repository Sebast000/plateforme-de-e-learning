// lib/widgets/app_shell.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home/courses_screen.dart'; // Catalogue
import '../screens/profile/profile_screen.dart'; // Profil
// 🎯 NOUVEAU : Importation du ForumScreen que nous avons créé
import '../screens/forum/forum_screen.dart'; 

class AppShell extends StatefulWidget {
  const AppShell({super.key}); 

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  
  // 🎯 CORRECTION: La liste ne peut pas être 'const' si elle contient 
  // des widgets qui ne sont pas 'const' (comme CoursesScreen et ProfileScreen
  // qui ont été définis sans 'const' dans votre code original)
  // et pour éviter des bugs potentiels liés à Provider.
  final List<Widget> _pages = [ 
    // 0: Catalogue
    const CoursesScreen(), 
    
    // 1: Recommandations (Placeholder)
    const Center(child: Text("Recommandations (à venir)")),
    
    // 2: Forum 🎯 CORRECTION: Remplacement du Placeholder par ForumScreen
    const ForumScreen(), 
    
    // 3: Profil 
    const ProfileScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }
  
  @override
  Widget build(BuildContext context) {
    // Note : L'utilisation de listen: false ici est correcte pour la déconnexion
    final auth = Provider.of<AuthProvider>(context, listen: false); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Learning App'),
        actions: [
          // Affichage du nom d'utilisateur et bouton de déconnexion
          TextButton.icon(
            icon: const Icon(Icons.person, color: Colors.white),
            // Utilisation de auth.user?.username pour éviter les erreurs null
            label: Text(auth.user?.username ?? 'Utilisateur', style: const TextStyle(color: Colors.white)),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      // Affiche la page sélectionnée dans la liste _pages
      body: _pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Meilleure pratique : utiliser le thème
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Catalogue'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Pour vous'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profil'),
        ],
      ),
    );
  }
}