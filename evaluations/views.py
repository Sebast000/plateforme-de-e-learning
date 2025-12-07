# D:\UVBFL3\ProjetTutore\evaluations\views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from drf_spectacular.utils import extend_schema 

# Importations critiques de Django REST Framework
from rest_framework.permissions import IsAuthenticated # <--- AJOUT CRITIQUE

# Importations de vos Modèles (Manquantes dans l'extrait, mais nécessaires)
from .models import InitialTestQuestion, InitialTestChoice, InitialTestResult, Quiz, QuizQuestion, QuizChoice, QuizResult
from users.models import User

# Importations des Serializers (Manquantes dans l'extrait, mais nécessaires)
from .serializers import (
    InitialTestQuestionSerializer,
    InitialTestSubmitResponseSerializer,
    QuizSerializer,
    QuizSubmitResponseSerializer,
    SubmissionInputSerializer 
)


# ----------------------------------------------------------------------
# ---- A : TEST INITIAL ----
# ----------------------------------------------------------------------
class InitialTestQuestionsView(APIView):
    # Les questions peuvent être accessibles sans être connecté (si désiré)
    # permission_classes = [AllowAny] 
    
    @extend_schema(
        summary="Obtenir toutes les questions pour le test de positionnement initial.",
        tags=['initial-test'],
        responses={200: InitialTestQuestionSerializer(many=True)}
    )
    def get(self, request):
        questions = InitialTestQuestion.objects.all()
        serializer = InitialTestQuestionSerializer(questions, many=True)
        return Response(serializer.data)


class SubmitInitialTestView(APIView):
    # CORRECTION CRITIQUE (1/2) : Seuls les utilisateurs connectés peuvent soumettre
    permission_classes = [IsAuthenticated] 
    
    @extend_schema(
        summary="Soumettre les réponses du test initial.",
        tags=['initial-test'],
        request=SubmissionInputSerializer, 
        responses={200: InitialTestSubmitResponseSerializer}
    )
    def post(self, request):
        answers = request.data.get("answers", [])
        user = request.user
        
        correct = 0
        for choice_id in answers:
            try:
                choice = InitialTestChoice.objects.get(id=choice_id)
                if choice.is_correct:
                    correct += 1
            except InitialTestChoice.DoesNotExist:
                pass 

        total = InitialTestQuestion.objects.count()
        score = int((correct / total) * 100) if total else 0

        # Définir le niveau
        if score <= 40:
            level = "Débutant"
        elif score <= 70:
            level = "Intermédiaire"
        else:
            level = "Avancé"

        # Enregistrer et mettre à jour le profil (user est garanti d'être authentifié)
        InitialTestResult.objects.create(
            user=user,
            score=score,
            level_assigned=level
        )
        user.level = level
        user.save()

        return Response({"score": score, "assigned_level": level})
    

# ----------------------------------------------------------------------
# ---- B : QUIZ ----
# ----------------------------------------------------------------------
class QuizDetailView(APIView):
    @extend_schema(
        summary="Obtenir les questions et détails d'un quiz.",
        tags=['quiz'],
        responses={200: QuizSerializer}
    )
    def get(self, request, quiz_id):
        try:
            quiz = Quiz.objects.get(id=quiz_id)
        except Quiz.DoesNotExist:
            return Response({"detail": "Quiz non trouvé."}, status=status.HTTP_404_NOT_FOUND)
            
        serializer = QuizSerializer(quiz)
        return Response(serializer.data)


class SubmitQuizView(APIView):
    # CORRECTION CRITIQUE (2/2) : Seuls les utilisateurs connectés peuvent soumettre
    permission_classes = [IsAuthenticated] 
    
    @extend_schema(
        summary="Soumettre les réponses d'un quiz.",
        tags=['quiz'],
        responses={200: QuizSubmitResponseSerializer},
        request=SubmissionInputSerializer
    )
    def post(self, request, quiz_id):
        answers = request.data.get("answers", [])
        user = request.user
        
        try:
            quiz = Quiz.objects.get(id=quiz_id)
        except Quiz.DoesNotExist:
            return Response({"detail": "Quiz non trouvé."}, status=status.HTTP_404_NOT_FOUND)

        correct = 0
        for choice_id in answers:
            try:
                choice = QuizChoice.objects.get(id=choice_id)
                # Vérification de l'appartenance au quiz (sécurité)
                if choice.question.quiz == quiz and choice.is_correct:
                    correct += 1
            except QuizChoice.DoesNotExist:
                pass

        total = QuizQuestion.objects.filter(quiz=quiz).count()
        score = int((correct / total) * 100) if total else 0

        passed = score >= 60

        QuizResult.objects.create(
            user=user,
            quiz=quiz,
            score=score,
            passed=passed
        )

        return Response({"score": score, "passed": passed})