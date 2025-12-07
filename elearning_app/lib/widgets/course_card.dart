// lib/widgets/course_card.dart

import 'package:flutter/material.dart';
import '../models/course_models.dart'; 
// CORRECTION : Le chemin est ajusté de 'courses' à 'course' (singulier) pour cet exemple.
// Si votre dossier est 'courses', utilisez le chemin précédent.
import '../screens/course/course_detail_page.dart'; 

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isHorizontal; 

  const CourseCard({
    super.key,
    required this.course,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    } else {
      return _buildVerticalCard(context);
    }
  }

  // --- Version 1 : Carte Verticale (Catalogue) ---
  Widget _buildVerticalCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias, 
      child: InkWell(
        onTap: () {
          // Navigation vers CourseDetailPage est maintenant définie
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de Couverture
            Image.asset(
              course.imageUrl, 
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            // Détails du Cours
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie
                  Text(
                    course.category,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Titre du Cours
                  Text(
                    course.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Durée et Auteur
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${course.duration.toStringAsFixed(1)} h', 
                           style: theme.textTheme.bodySmall),
                      
                      const Spacer(),
                      
                      Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(course.author, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Version 2 : Carte Horizontale (Progression) ---
  Widget _buildHorizontalCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(right: 16.0), 
      child: InkWell(
        onTap: () {
          // Navigation vers CourseDetailPage est maintenant définie
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
          );
        },
        child: Container(
          width: 300, 
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image miniature
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  course.imageUrl,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Détails et Progression
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      course.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Indicateur de Progression
                    Row(
                      children: [
                        Text(
                          'Progression: ${(course.progress * 100).toInt()}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: course.progress,
                            backgroundColor: Colors.grey.shade200,
                            color: theme.colorScheme.primary,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}