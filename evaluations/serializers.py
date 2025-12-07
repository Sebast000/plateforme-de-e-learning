# D:\UVBFL3\ProjetTutore\evaluations\serializers.py

from rest_framework import serializers
from .models import *
from users.models import User


# --- A: Initial Test ---
class InitialTestChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = InitialTestChoice
        fields = '__all__'


class InitialTestQuestionSerializer(serializers.ModelSerializer):
    choices = InitialTestChoiceSerializer(many=True)

    class Meta:
        model = InitialTestQuestion
        fields = '__all__'


class InitialTestResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = InitialTestResult
        fields = '__all__'


# --- B: Quiz ---
class QuizChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuizChoice
        fields = '__all__'


class QuizQuestionSerializer(serializers.ModelSerializer):
    choices = QuizChoiceSerializer(many=True)

    class Meta:
        model = QuizQuestion
        fields = '__all__'


class QuizSerializer(serializers.ModelSerializer):
    questions = QuizQuestionSerializer(many=True)

    class Meta:
        model = Quiz
        fields = '__all__'


# ----------------------------------------------------------------------
# --- SERIALIZERS DE DOCUMENTATION (Input/Output) ---
# ----------------------------------------------------------------------

# --- Output pour SubmitInitialTestView (/api/initial-test/submit/) ---
class InitialTestSubmitResponseSerializer(serializers.Serializer):
    """Documente la réponse de la soumission du test initial."""
    score = serializers.IntegerField(read_only=True, help_text="Score total obtenu (0-100).") 
    assigned_level = serializers.CharField(read_only=True, help_text="Niveau assigné (Débutant, Intermédiaire, Avancé).")

# --- Output pour SubmitQuizView (/api/quiz/{quiz_id}/submit/) ---
class QuizSubmitResponseSerializer(serializers.Serializer):
    """Documente la réponse de la soumission d'un quiz."""
    score = serializers.IntegerField(read_only=True, help_text="Score du quiz (0-100).")
    passed = serializers.BooleanField(read_only=True, help_text="Indique si l'utilisateur a réussi le quiz (score >= 60).")


# --- INPUT pour la soumission des tests et quiz (CORRECTION D'INDENTATION) ---
class SubmissionInputSerializer(serializers.Serializer):
    """
    Serializer pour documenter le corps de la requête de soumission qui attend
    un dictionnaire avec une clé 'answers' contenant une liste d'IDs (entiers).
    """
    answers = serializers.ListField(
        child=serializers.IntegerField(
            min_value=1, 
            help_text="ID du choix de réponse sélectionné."
        ),
        min_length=1,
        help_text="Liste des identifiants (IDs) des choix de réponse de l'utilisateur."
    )