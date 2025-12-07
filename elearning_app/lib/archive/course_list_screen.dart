// lib/screens/courses/course_list_screen.dart

import 'package:flutter/material.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue des cours')),
      body: const Center(
        child: Text('Ceci est la page de la liste complète des cours.'),
      ),
    );
  }
}