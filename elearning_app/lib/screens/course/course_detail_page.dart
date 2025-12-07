// lib/screens/course/course_detail_page.dart

import 'package:flutter/material.dart';
// Importe le modèle de l'API (Course et Lesson)
import 'package:elearning_app/models/course_models.dart';
import 'lesson_player_page.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course}); 

  // Récupération des leçons de l'API
  List<Lesson> get lessons => course.lessons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const tabs = [
      Tab(text: 'Programme', icon: Icon(Icons.list_alt)),
      Tab(text: 'Aperçu', icon: Icon(Icons.info_outline)),
      Tab(text: 'Q&R', icon: Icon(Icons.forum_outlined)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  course.title,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset( 
                      'assets/images/default_course_bg.jpg', 
                      fit: BoxFit.cover,
                      color: Colors.black.withAlpha(102), 
                      colorBlendMode: BlendMode.darken,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          Text(
                            // Utilisation de .toStringAsFixed(0) pour ne pas afficher de décimales (ex: 0%)
                            '${(course.progress * 100).toStringAsFixed(0)}% Complété',
                            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: course.progress,
                              color: theme.colorScheme.secondary,
                              backgroundColor: Colors.white30,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                tabs: tabs,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3.0,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildProgramView(context, theme), 
              _buildOverviewView(theme),
              _buildQnAView(theme),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(context, theme),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildProgramView(BuildContext context, ThemeData theme) {
    if (lessons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "Aucune leçon n'est disponible pour ce cours. Veuillez vérifier les données API.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];

        return ListTile(
          leading: Icon(
            // 🎯 CORRECTION: Utilisation d'une icône neutre (plus de vidéo par défaut)
            Icons.list_alt, 
            color: lesson.isCompleted ? theme.colorScheme.primary : Colors.grey,
          ),
          // ⚠️ NOTE: lesson.order doit être > 0 dans l'API pour que 'Leçon 0' disparaisse.
          title: Text('Leçon ${lesson.order}: ${lesson.title}'), 
          trailing: lesson.isCompleted
              ? Icon(Icons.check_circle, color: theme.colorScheme.secondary)
              : const Icon(Icons.lock_outline, color: Colors.grey),
          onTap: () {
            debugPrint('Lancement de la leçon: ${lesson.title}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonPlayerPage(course: course, lesson: lesson), 
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewView(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description du Cours', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            course.description.isEmpty ? "Pas de description fournie." : course.description,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 20),
          Text('Détails', style: theme.textTheme.titleLarge),
          _buildDetailRow(Icons.access_time_outlined, 'Durée Totale', '${course.duration.toStringAsFixed(1)} heures'),
          _buildDetailRow(Icons.category_outlined, 'Catégorie', course.category),
          _buildDetailRow(Icons.person_outline, 'Formateur', course.author),
          _buildDetailRow(Icons.bar_chart, 'Niveau Cible', course.niveauCible), 
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildQnAView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              "Posez vos questions sur ce cours.",
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Démarrer une discussion"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, ThemeData theme) {
    String buttonText = course.progress == 0.0
        ? 'Commencer le cours'
        : course.progress == 1.0
            ? 'Revoir le cours'
            : 'Reprendre où j\'en étais';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (lessons.isNotEmpty) {
              final firstIncompleteLesson = lessons.firstWhere(
                (l) => !l.isCompleted,
                orElse: () => lessons.first,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonPlayerPage(course: course, lesson: firstIncompleteLesson),
                ),
              );
            }
          },
          child: Text(buttonText),
        ),
      ),
    );
  }
}