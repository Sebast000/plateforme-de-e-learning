// lib/widgets/auth/register_form.dart

import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

class RegisterForm extends StatefulWidget {
  final AuthProvider authProvider;
  const RegisterForm({super.key, required this.authProvider});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await widget.authProvider.register(_username, _email, _password);
      setState(() {
        _successMessage = 'Inscription réussie ! Vous pouvez maintenant vous connecter.';
        _formKey.currentState!.reset(); // Effacer le formulaire
      });
    } catch (e) {
      setState(() {
        // Gérer les erreurs spécifiques de Django (ex: utilisateur déjà existant)
        final errorText = e.toString();
        if (errorText.contains('username') || errorText.contains('email')) {
          _errorMessage = 'Ce nom d\'utilisateur ou cet email est déjà utilisé.';
        } else {
          _errorMessage = 'Erreur: Veuillez vérifier les informations.';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Champ Nom d'utilisateur
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Nom d\'utilisateur',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom d\'utilisateur.';
              }
              return null;
            },
            onSaved: (value) {
              _username = value!;
            },
          ),
          const SizedBox(height: 16),
          // Champ Email
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Veuillez entrer une adresse email valide.';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          const SizedBox(height: 16),
          // Champ Mot de passe
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
          
          if (_successMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                _successMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
                : const Text('S\'inscrire', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}