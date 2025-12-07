import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    // 🚨 Déclenchement de l'appel API au démarrage
    Future.microtask(() {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);

      final authToken = authProvider.authToken; // ✅ Utilisation correcte
      if (authToken != null) {
        courseProvider.fetchCourses(authToken);
      } else {
        debugPrint("Alerte: Jeton d'authentification manquant dans DashboardPage.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final courseProvider = context.watch<CourseProvider>();

    final coursesInProgress = courseProvider.coursesInProgress;
    final featuredCourses = courseProvider.featuredCourses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Bonjour, ${auth.user?.username ?? 'Apprenant'} !', // ✅ Utilisation correcte
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            if (courseProvider.isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 15),
                    Text("Chargement des cours depuis l'API..."),
                  ],
                ),
              )
            else if (courseProvider.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    'Erreur: ${courseProvider.errorMessage!}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coursesInProgress.isNotEmpty) ...[
                    _buildSectionHeader(theme, 'Continuer l\'apprentissage', 'Voir tout', () {}),
                    const SizedBox(height: 10),
                    _buildHorizontalCourseList(coursesInProgress),
                    const SizedBox(height: 30),
                  ] else if (featuredCourses.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Bienvenue ! Commencez votre premier cours ci-dessous.',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],

                  _buildSectionHeader(theme, 'Cours Recommandés', 'Explorer', () {}),
                  const SizedBox(height: 10),
                  _buildVerticalCourseGrid(featuredCourses),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String actionText, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          TextButton(onPressed: onTap, child: Text(actionText, style: TextStyle(color: theme.colorScheme.secondary))),
        ],
      ),
    );
  }

  Widget _buildHorizontalCourseList(List<dynamic> courses) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CourseCard(course: courses[index], isHorizontal: true),
          );
        },
      ),
    );
  }

  Widget _buildVerticalCourseGrid(List<dynamic> courses) {
    if (courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text("Aucun cours disponible pour le moment."),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.7,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return CourseCard(course: courses[index]);
        },
      ),
    );
  }
}
