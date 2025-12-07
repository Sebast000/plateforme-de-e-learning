# D:\UVBFL3\ProjetTutore\forum\views.py

from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import ForumTopic, ForumMessage, ForumReply
from .serializers import (
    ForumTopicSerializer, ForumMessageSerializer, ForumReplySerializer, 
    ForumTopicCreateSerializer, ForumMessageCreateSerializer, ForumReplyCreateSerializer # 👈 IMPORTS MIS À JOUR
)
from .permissions import IsOwnerOrReadOnly
from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiTypes


# LIST + CREATE Topics
class ForumTopicListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: ForumTopicSerializer(many=True)}, 
        description="Liste tous les sujets du forum, triés par date de création récente."
    )
    def get(self, request):
        topics = ForumTopic.objects.all().order_by("-created_at")
        serializer = ForumTopicSerializer(topics, many=True)
        return Response(serializer.data)

    @extend_schema(
        request=ForumTopicCreateSerializer, # 🎯 OK, utilise le serializer minimal pour la REQUÊTE
        responses={201: ForumTopicSerializer}, # OK, utilise le serializer complet pour la RÉPONSE
        description="Crée un nouveau sujet de forum."
    )
    def post(self, request):
        # 🎯 CORRECTION : Utiliser le serializer de création pour la validation
        serializer = ForumTopicCreateSerializer(data=request.data)
        
        if serializer.is_valid():
            # Sauvegarder l'objet et injecter le créateur
            topic = serializer.save(created_by=request.user)
            # Retourner le serializer COMPLET (lecture) pour la réponse détaillée 201
            return Response(ForumTopicSerializer(topic).data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Messages pour un topic
class ForumMessageCreateView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        request=ForumMessageCreateSerializer, # 🎯 OK, utilise le serializer minimal pour la REQUÊTE
        responses={201: ForumMessageSerializer}, # OK, utilise le serializer complet pour la RÉPONSE
        description="Crée un message (ou premier message) dans un sujet spécifique."
    )
    def post(self, request, topic_id):
        # Utiliser le serializer minimal pour la validation du contenu
        serializer = ForumMessageCreateSerializer(data=request.data)
        
        if serializer.is_valid():
            try:
                topic = ForumTopic.objects.get(id=topic_id)
            except ForumTopic.DoesNotExist:
                return Response({"detail": "Topic not found."}, status=status.HTTP_404_NOT_FOUND)

            # Sauvegarder l'objet en injectant les IDs gérés par le serveur
            message = serializer.save(topic=topic, user=request.user)
            # Retourner le serializer COMPLET pour la réponse détaillée 201
            return Response(ForumMessageSerializer(message).data, status=status.HTTP_201_CREATED)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Réponse à un message
class ForumReplyCreateView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        request=ForumReplyCreateSerializer, # 🎯 OK, utilise le serializer minimal pour la REQUÊTE
        responses={201: ForumReplySerializer}, # OK, utilise le serializer complet pour la RÉPONSE
        description="Crée une réponse à un message existant du forum."
    )
    def post(self, request, message_id):
        # Utiliser le serializer minimal pour la validation du contenu
        serializer = ForumReplyCreateSerializer(data=request.data)
        
        if serializer.is_valid():
            try:
                message = ForumMessage.objects.get(id=message_id)
            except ForumMessage.DoesNotExist:
                return Response({"detail": "Message not found."}, status=status.HTTP_404_NOT_FOUND)

            # Sauvegarder l'objet en injectant les IDs gérés par le serveur
            reply = serializer.save(message=message, user=request.user)
            # Retourner le serializer COMPLET pour la réponse détaillée 201
            return Response(ForumReplySerializer(reply).data, status=status.HTTP_201_CREATED)
            
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)