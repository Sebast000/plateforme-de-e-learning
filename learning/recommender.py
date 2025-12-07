# learning/recommender.py

import math
import re
from django.db.models import Count
from django.contrib.auth import get_user_model
from courses.models import Course 
from evaluations.models import QuizResult # Assurez-vous que QuizResult est bien ici
from learning.models import Enrollment
# from courses.models import Lesson # Plus nécessaire ici si l'import de QuizResult suffit

# --- Configuration des Poids ---
WEIGHT_INTEREST = 5.0
WEIGHT_LEVEL_EXACT = 20.0
WEIGHT_LEVEL_ADJACENT = 8.0
WEIGHT_POPULARITY = 3.0
WEIGHT_PENALTY_COMPLETED = 50.0
WEIGHT_BONUS_CONTINUE = 5.0
WEIGHT_BONUS_DEFICIENCY = 30.0 # Bonus élevé pour les lacunes

User = get_user_model() 

def tokenize(text):
    """Tokenise un texte pour l'analyse par mots-clés."""
    if not text:
        return []
    return [t.lower() for t in re.split(r'\W+', text) if t.strip()]

def get_personalized_course_recommendations(user: User, max_results=10):
    """
    Calcule un score pondéré pour tous les cours en fonction du profil utilisateur
    et des résultats de quiz pour identifier les lacunes.
    """

    # --- 1. Préparation des données d'entrée ---
    
    # 1.1. Récupérer les intérêts. 
    user_interest_names = user.interests.values_list('name', flat=True)
    interests = set([s.lower() for s in user_interest_names]) 
    
    # 1.2. Identifier les cours déjà inscrits
    user_enrollments = Enrollment.objects.filter(user=user).select_related('course')
    enrolled_course_data = {e.course_id: e for e in user_enrollments}
    
    # 1.3. Identifier les lacunes spécifiques (NOUVEAU CRITÈRE)
    failed_quiz_course_ids = set(
        QuizResult.objects
        .filter(user=user, passed=False) 
        .select_related('quiz__module__course')
        .values_list('quiz__module__course_id', flat=True)
    )
    
    # 1.4. Charger tous les cours avec le décompte des inscriptions
    courses = Course.objects.select_related('category').annotate(
        enroll_count=Count('enrollments')
    ).all()
    
    
    # --- 2. Boucle de Scoring ---
    
    scored = []
    level_order = {'débutant': 0, 'debutant': 0, 'intermédiaire': 1, 'intermediaire': 1, 'avancé': 2, 'avance': 2}
    user_level = (user.level or "").lower()
    user_level_order = level_order.get(user_level, None)

    for course in courses:
        score = 0.0
        
        # A) Intérêt / Contenu
        course_category_name = getattr(course.category, 'name', '')
        text_tokens = " ".join(filter(None, [course.title, course.description, course_category_name]))
        tokens = set(tokenize(text_tokens))

        interest_matches = len(interests & tokens)
        score += interest_matches * WEIGHT_INTEREST 
        
        # B) Niveau
        course_level = (course.level or "").lower()
        course_level_order = level_order.get(course_level, None)

        if user_level_order is not None and course_level_order is not None:
            if user_level_order == course_level_order:
                score += WEIGHT_LEVEL_EXACT 
            elif abs(user_level_order - course_level_order) == 1:
                score += WEIGHT_LEVEL_ADJACENT

        # C) Popularité
        enroll_count = getattr(course, 'enroll_count', 0)
        score += math.log(1 + enroll_count) * WEIGHT_POPULARITY

        # D) Lacunes (Correction) : BONUS pour les cours liés aux échecs
        if course.id in failed_quiz_course_ids:
            score += WEIGHT_BONUS_DEFICIENCY # Priorité maximale
            
        # E) Statut d'Inscription (Pénalité/Bonus)
        if course.id in enrolled_course_data:
            enrollment = enrolled_course_data[course.id]
            
            if enrollment.completed:
                score -= WEIGHT_PENALTY_COMPLETED 
            elif enrollment.progress_percent > 0:
                score += WEIGHT_BONUS_CONTINUE 

        scored.append((score, course))

    # --- 3. Assemblage Final ---
    
    scored.sort(key=lambda x: x[0], reverse=True)
    
    top_with_scores = []
    for s, c in scored[:max_results]:
        top_with_scores.append({
            'score': round(s, 2),
            'course': c 
        })

    return top_with_scores