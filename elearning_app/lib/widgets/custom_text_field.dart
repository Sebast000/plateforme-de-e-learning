import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false, // Par défaut, non obscurci
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Le style (couleurs, bordures) est déjà défini dans ThemeData(inputDecorationTheme)
    // dans main.dart, ce qui rend ce widget très propre.
    
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        
        // La couleur de l'icône/label sera gérée par le thème, mais on peut forcer la couleur ici si besoin :
        // prefixIconColor: Theme.of(context).colorScheme.primary,
        
        // Règle l'ombre/élévation si le mode est activé (Filled=true dans main.dart)
        // fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        
      ),
    );
  }
}