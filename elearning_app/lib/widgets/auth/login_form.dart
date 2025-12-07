// lib/widgets/auth/login_form.dart

import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

class LoginForm extends StatefulWidget {
  final AuthProvider authProvider;
  const LoginForm({super.key, required this.authProvider});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    
    // 1. Début du chargement (pas besoin de mounted ici car synchrone)
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authProvider.login(_username, _password);
    } catch (e) {
      // 2. Mise à jour de l'erreur APRÈS l'attente (vérifier mounted)
      if (mounted) { 
        setState(() {
          _errorMessage = e.toString().contains('401') 
              ? 'Nom d\'utilisateur ou mot de passe invalide.'
              : 'Erreur lors de la connexion. Veuillez réessayer.';
        });
      }
    } finally {
      // 3. Arrêt du chargement APRÈS l'attente (vérifier mounted)
      if (mounted) { 
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Nom d\'utilisateur',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom d\'utilisateur.';
              }
              return null;
            },
            onSaved: (value) {
              _username = value!;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères.';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),

          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Se Connecter', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}