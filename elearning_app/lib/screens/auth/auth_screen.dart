// lib/screens/auth/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/register_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nous utilisons DefaultTabController pour basculer facilement entre Login et Register
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // L'AppBar contient le titre et les onglets (Login/Register)
        appBar: AppBar(
          title: Text(
            'Authentification',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // Bas de l'AppBar pour les onglets
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Se Connecter', icon: Icon(Icons.login)),
              Tab(text: 'S\'inscrire', icon: Icon(Icons.person_add)),
            ],
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        // Le corps de l'écran affiche le contenu de l'onglet sélectionné
        body: TabBarView(
          children: [
            // Onglet 1: Formulaire de Connexion
            _buildAuthTab(
              child: LoginForm(authProvider: context.read<AuthProvider>()),
            ),
            // Onglet 2: Formulaire d'Inscription
            _buildAuthTab(
              child: RegisterForm(authProvider: context.read<AuthProvider>()),
            ),
          ],
        ),
      ),
    );
  }

  // Wrapper pour centrer et scroller le contenu du formulaire
  Widget _buildAuthTab({required Widget child}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: child,
        ),
      ),
    );
  }
}