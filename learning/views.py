# learning/views.py

import math
import re
from django.db.models import Count
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
# 🎯 CORRECTION: Ajout de OpenApiTypes pour indiquer une requête sans corps
from drf_spectacular.utils import extend_schema, OpenApiTypes 

from courses.models import Course, Lesson 
from learning.models import Enrollment
from courses.serializers import CourseSerializer
from .recommender import get_personalized_course_recommendations 
# Importez les serializers de réponse que nous allons créer
from .serializers import ( 
    RecommendationResponseSerializer, 
    ProgressSuccessSerializer, 
    ProgressFailureSerializer
) 
from .utils import update_course_progress 


class RecommendationsView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Obtenir les recommandations de cours personnalisées pour l'utilisateur.",
        tags=['recommendations'],
        # Documente la réponse (liste de cours + score)
        responses={200: RecommendationResponseSerializer}, 
    )
    def get(self, request):
        user = request.user
        max_results = int(request.query_params.get('n', 10))
        top_with_scores = get_personalized_course_recommendations(user, max_results=max_results)
        
        final_response_data = []
        for item in top_with_scores:
            course_data = CourseSerializer(item['course'], context={'request': request}).data
            final_response_data.append({
                'score': item['score'],
                'course': course_data
            })

        return Response({'results': final_response_data})


class TrackProgressView(APIView):
    """
    Permet à l'utilisateur de marquer une leçon spécifique comme complétée.
    URL: POST /api/progress/track/<int:lesson_id>/
    """
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Marquer une leçon comme complétée.",
        tags=['progress'],
        # 🎯 CORRECTION: Indiquer explicitement à Spectacular qu'il n'y a pas de Request Body
        request=OpenApiTypes.NONE, 
        # Documente la réponse de succès et les erreurs potentielles
        responses={
            200: ProgressSuccessSerializer, 
            403: ProgressFailureSerializer,
            404: ProgressFailureSerializer
        }
    )
    def post(self, request, lesson_id):
        try:
            lesson = Lesson.objects.get(pk=lesson_id)
        except Lesson.DoesNotExist:
            return Response({"detail": "Leçon non trouvée."}, status=status.HTTP_404_NOT_FOUND)

        success, message = update_course_progress(request.user, lesson)
        
        if success:
            # Assurez-vous que l'accès à enrollments.get() est valide
            try:
                progress_percent = request.user.enrollments.get(course=lesson.module.course).progress_percent
            except Enrollment.DoesNotExist:
                progress_percent = 0 # Cas d'erreur (bien que l'update progress devrait l'éviter)
            
            return Response({"detail": message, "progress_percent": progress_percent}, status=status.HTTP_200_OK)
        else:
            return Response({"detail": message}, status=status.HTTP_403_FORBIDDEN)