// lib/screens/profile/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Apparence ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Apparence',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
            _buildToggleTile(
              Icons.dark_mode_outlined,
              'Mode Sombre',
              // Simuler l'état du mode sombre
              ValueNotifier<bool>(false), 
              (bool value) {
              
              
                debugPrint('Mode Sombre : $value');
              },
            ),
            _buildListTile(
              Icons.language,
              'Langue de l\'application',
              subtitle: 'Français',
              onTap: () {
                

              },
            ),
            
            const Divider(height: 30),

            // --- Section Notifications ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
            _buildToggleTile(
              Icons.notifications_active_outlined,
              'Recevoir des notifications',
              ValueNotifier<bool>(true), 
              (bool value) {
                
                
                debugPrint('Notifications : $value');
              },
            ),
            _buildToggleTile(
              Icons.access_time,
              'Rappels d\'étude quotidiens',
              ValueNotifier<bool>(true), 
              (bool value) {
                

                debugPrint('Rappels : $value');
              },
            ),

            const Divider(height: 30),

            // --- Section Compte et Support ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Support et Infos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
            _buildListTile(Icons.info_outline, 'À propos de l\'application', onTap: () {}),
            _buildListTile(Icons.assignment_ind_outlined, 'Conditions d\'utilisation', onTap: () {}),
            
            const Divider(height: 30),
            
            // --- Option de Déconnexion ---
            _buildListTile(
              Icons.logout,
              'Déconnexion',
              color: Colors.red,
              onTap: () {
                

                debugPrint('Déconnexion cliquée');
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget utilitaire pour les options simples (sans Switch)
  Widget _buildListTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400) : null,
      onTap: onTap,
    );
  }

  // Widget utilitaire pour les options avec Switch
  Widget _buildToggleTile(IconData icon, String title, ValueNotifier<bool> initialValue, ValueChanged<bool> onChanged) {
    return ValueListenableBuilder<bool>(
      valueListenable: initialValue,
      builder: (context, value, child) {
        return ListTile(
          leading: Icon(icon, color: Colors.grey.shade700),
          title: Text(title),
          trailing: Switch(
            value: value,
            onChanged: (newValue) {
              initialValue.value = newValue; // Simuler le changement d'état local
              onChanged(newValue);
            },
          ),
          onTap: () {
            // Permet de basculer en touchant n'importe où sur la tuile
            initialValue.value = !value;
            onChanged(initialValue.value);
          },
        );
      },
    );
  }
}