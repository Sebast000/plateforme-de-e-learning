# learning/recommender.py

import math
import re
from django.db.models import Count
from django.contrib.auth import get_user_model
from courses.models import Course 
from evaluations.models import QuizResult
from rest_framework import permissions
from learning.models import Enrollment
from courses.models import Lesson 

class IsEnrolledInCourse(permissions.BasePermission):
    """
    Permission personnalisée pour vérifier si l'utilisateur est inscrit au cours 
    contenant la leçon demandée (obj).
    """
    message = "Vous devez être inscrit à ce cours pour accéder à ce contenu."

    def has_object_permission(self, request, view, obj):
        # La lecture (GET) est la seule méthode d'intérêt ici
        if request.method not in permissions.SAFE_METHODS:
            return False

        # 1. L'objet (obj) est la Leçon. On remonte au Cours via Module.
        if isinstance(obj, Lesson):
            course = obj.module.course
        else:
            # Cette permission n'est pas conçue pour d'autres objets
            return False 

        # 2. Vérifier si un enregistrement Enrollment existe pour l'utilisateur et le cours
        return Enrollment.objects.filter(user=request.user, course=course).exists()