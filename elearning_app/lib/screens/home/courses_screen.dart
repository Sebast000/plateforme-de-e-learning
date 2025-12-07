// lib/screens/home/courses_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart'; 
import '../course/course_detail_page.dart'; 


class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      courseProvider.fetchCourses(authProvider.authToken ?? ''); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    return Consumer<CourseProvider>( 
      builder: (context, courseProvider, child) {
        
        Widget dynamicContent;
        if (courseProvider.isLoading) {
          dynamicContent = _buildLoadingWidget(auth.authToken);
        } else if (courseProvider.errorMessage != null) {
          dynamicContent = _buildErrorWidget(courseProvider.errorMessage!);
        } else {
          dynamicContent = _buildCourseList(courseProvider);
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue, ${auth.user?.username ?? 'Apprenant'} !',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Votre niveau actuel : ${auth.user?.niveauInitial ?? 'Non évalué'}',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const Divider(height: 40),
              dynamicContent, 
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingWidget(String? authToken) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text(
            'Chargement des cours depuis l\'API ${authToken != null ? "avec token" : "sans token"}...',
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade100,
        child: Text(
          'Erreur de Chargement : $message',
          style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCourseList(CourseProvider courseProvider) {
    final courses = courseProvider.featuredCourses;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catalogue des Cours (${courses.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        
        if (courses.isEmpty)
          const Center(child: Text("Aucun cours n'est disponible pour le moment.")),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Card(
                elevation: 4, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell( 
                  // 🎯 NAVIGATION CORRIGÉE
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => CourseDetailPage(course: course), 
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.school, size: 30, color: Colors.deepPurple),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${(course.progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: course.progress > 0 ? Colors.green : Colors.grey
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Auteur: ${course.author} | Niveau: ${course.niveauCible}',
                          style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: course.progress,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.deepPurpleAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}