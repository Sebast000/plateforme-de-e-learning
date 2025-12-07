# learning/utils.py

from django.db.models import Count
from courses.models import Course, Module, Lesson # Nécessaire pour le calcul
from learning.models import Enrollment, Progress # Nécessaire pour la mise à jour

def update_course_progress(user, lesson: Lesson):
    """
    Enregistre la progression de la leçon et met à jour le pourcentage global d'inscription.
    """
    course = lesson.module.course
    
    try:
        enrollment = Enrollment.objects.get(user=user, course=course)
    except Enrollment.DoesNotExist:
        # L'utilisateur doit être inscrit pour enregistrer la progression
        return False, "Non inscrit au cours."
        
    # 1. Enregistrer la leçon comme complétée (ou s'assurer qu'elle l'est)
    Progress.objects.get_or_create(
        enrollment=enrollment, 
        lesson=lesson
    )
    
    # 2. Calculer le nouveau pourcentage de progression
    
    # Méthode simple : compter toutes les leçons du cours
    total_lessons = Lesson.objects.filter(module__course=course).count()
    
    # Compter les leçons complétées par l'utilisateur
    completed_lessons_count = Progress.objects.filter(
        enrollment=enrollment
    ).count()

    if total_lessons > 0:
        new_percent = (completed_lessons_count / total_lessons) * 100
        enrollment.progress_percent = round(new_percent, 2)
    else:
        enrollment.progress_percent = 0.0

    # 3. Marquer le cours comme complété si 100% atteint
    if enrollment.progress_percent >= 100.0:
        enrollment.completed = True
        
    enrollment.save()
    return True, "Progression mise à jour."