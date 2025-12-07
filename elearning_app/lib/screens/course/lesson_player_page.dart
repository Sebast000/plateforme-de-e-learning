// lib/screens/course/lesson_player_page.dart

import 'package:flutter/material.dart';

// Le fichier où se trouvent les classes Course et Lesson
import '../../models/course_models.dart';

class LessonPlayerPage extends StatelessWidget {
  final Course course;
  final Lesson lesson;

  const LessonPlayerPage({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const tabs = [
      Tab(text: 'Programme', icon: Icon(Icons.list)),
      Tab(text: 'Ressources', icon: Icon(Icons.folder_open)),
      Tab(text: 'Notes', icon: Icon(Icons.edit_note)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.title, style: theme.textTheme.titleMedium),
        ),
        body: Column(
          children: [
            // 🎯 CORRECTION : Utilisation du widget pour afficher le contenu textuel
            _buildLessonContentView(context),

            Container(
              color: theme.colorScheme.surface,
              child: TabBar(
                tabs: tabs,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  _buildProgramList(theme),
                  _buildResourcesView(theme),
                  _buildNotesView(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Widgets
  // ----------------------------------------------------------

  // 🎯 NOUVEAU WIDGET : Affiche le contenu de la leçon dans l'espace 16:9
  Widget _buildLessonContentView(BuildContext context) {
    final theme = Theme.of(context);
    
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contenu de la Leçon',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Divider(height: 20),
              
              // Affichage du contenu de la leçon
              Text(
                lesson.content.isEmpty
                    ? '⚠️ Contenu textuel non disponible pour cette leçon. Veuillez le remplir dans l\'administration Django.'
                    : lesson.content,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 100), // Espace pour le défilement
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: course.lessons.length,
      itemBuilder: (context, index) {
        final l = course.lessons[index];
        return ListTile(
          leading: Icon(l.isCompleted ? Icons.check_circle : Icons.circle_outlined),
          // ⚠️ Assurez-vous que l'ordre est >= 1 dans Django
          title: Text(l.title), 
          subtitle: Text("Ordre : ${l.order}"),
          onTap: () {
            // Optionnel : Permet de naviguer vers la leçon cliquée dans le programme
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LessonPlayerPage(course: course, lesson: l),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResourcesView(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ressources pour cette leçon', style: theme.textTheme.titleLarge),
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Fiche PDF'),
            trailing: Icon(Icons.download, color: theme.colorScheme.primary),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Code source'),
            trailing: Icon(Icons.download, color: theme.colorScheme.primary),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNotesView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Prenez des notes pour "${lesson.title}"', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          const Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: "Saisissez vos notes ici...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('Notes sauvegardées');
            },
            icon: const Icon(Icons.save),
            label: const Text('Sauvegarder les notes'),
          ),
        ],
      ),
    );
  }
}