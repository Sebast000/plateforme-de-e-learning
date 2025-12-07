import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importe les fournisseurs et la structure principale
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'widgets/app_shell.dart'; // Conteneur principal après la connexion
import 'screens/auth/auth_screen.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElearningApp());
}

class ElearningApp extends StatelessWidget {
  const ElearningApp({super.key});

  // 💡 DÉFINITION DE LA PALETTE DE COULEURS
  static const Color primaryIndigo = Color(0xFF4F46E5); 
  static const Color secondaryAccent = Color(0xFF06B6D4); 

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
      ],
      child: MaterialApp(
        title: 'E-Learning App',
        debugShowCheckedModeBanner: false,
        
        theme: ThemeData(
          useMaterial3: true,
          
          // 1. SCHÉMA DE COULEUR
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryIndigo,
            primary: primaryIndigo,
            secondary: secondaryAccent,
            surface: Colors.white, // C'est ici que l'erreur de caractère illégal est corrigée.
            surfaceContainerHighest: Colors.grey.shade100, 
          ),
          
          // 2. THÈME DES CHAMPS DE TEXTE (Input Decoration)
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade100, 
            labelStyle: TextStyle(color: Colors.grey.shade600),
            
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryIndigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),

          // 3. THÈME DES BOUTONS PRINCIPAUX (ElevatedButton)
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              elevation: 2, 
            ),
          ),
          
          // 4. THÈME DES CARTES (Card / Conteneurs d'information)
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: EdgeInsets.zero,
          ),
          
          // 5. THÈME DES BARRES DE PROGRESSION
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: primaryIndigo, 
          )
        ),
        
        // Logique de navigation au démarrage
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Étape 1: Afficher l'indicateur de chargement
            if (auth.isLoading) { 
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: primaryIndigo)),
              );
            }
            
            // Étape 2: Si connecté, aller à l'application principale
            if (auth.isAuthenticated) return const AppShell();
            
            // Étape 3: Sinon, afficher l'écran d'authentification unique
            return const AuthScreen();
          },
        ),
        
        // La route /home est conservée pour la navigation interne (ex: après connexion réussie).
        routes: {
            '/home': (context) => const AppShell(), 
        },
      ),
    );
  }
}