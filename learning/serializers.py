from rest_framework import serializers
from courses.serializers import CourseSerializer
from .models import Enrollment

class EnrollmentSerializer(serializers.ModelSerializer):
    course = CourseSerializer(read_only=True)
    class Meta:
        model = Enrollment
        fields = ['id', 'course', 'enrolled_at', 'completed', 'progress_percent']

# learning/serializers.py (AJOUTEZ CECI À LA FIN DU FICHIER)

from rest_framework import serializers
# Assurez-vous d'avoir cet import si CourseSerializer est défini dans courses/serializers.py
# from courses.serializers import CourseSerializer 


# --- Serializer de Réponse pour RecommendationsView (/api/recommendations/) ---
class RecommendationItemSerializer(serializers.Serializer):
    """Pour la liste interne des recommandations"""
    score = serializers.FloatField(read_only=True, help_text="Score de pertinence.")
    # Assurez-vous que CourseSerializer est importé ou défini
    course = CourseSerializer(read_only=True) 

class RecommendationResponseSerializer(serializers.Serializer):
    """Schéma complet de la réponse pour l'endpoint de recommandations."""
    # Ceci correspond à l'objet retourné par votre vue : {'results': [...] }
    results = RecommendationItemSerializer(many=True)


# --- Serializers de Réponse pour TrackProgressView (/api/progress/track/{lesson_id}/) ---
class ProgressSuccessSerializer(serializers.Serializer):
    """Réponse en cas de succès du suivi de progression."""
    detail = serializers.CharField(read_only=True, help_text="Message de confirmation.")
    progress_percent = serializers.FloatField(read_only=True, help_text="Pourcentage de complétion du cours mis à jour.")

class ProgressFailureSerializer(serializers.Serializer):
    """Réponse en cas d'erreur (403 ou 404)."""
    detail = serializers.CharField(read_only=True, help_text="Message d'erreur (ex: non inscrit, leçon non trouvée).")