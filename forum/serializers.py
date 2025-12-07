# D:\UVBFL3\ProjetTutore\forum\serializers.py

from rest_framework import serializers
from .models import ForumTopic, ForumMessage, ForumReply


# ==================================
# 1. SERIALIZERS DE CRÉATION (INPUT)
# ==================================

class ForumTopicCreateSerializer(serializers.ModelSerializer):
    """
    Serializer minimal utilisé pour valider les données de la requête POST /api/forum/topics/.
    Il inclut uniquement les champs modifiables par l'utilisateur.
    """
    class Meta:
        model = ForumTopic
        # L'utilisateur fournit UNIQUEMENT le titre et la description
        fields = ['title', 'description']
        
    # Validation champ par champ
    def validate_title(self, value):
        if len(value) < 3:
            raise serializers.ValidationError("Le titre doit contenir au moins 3 caractères.")
        return value

    # Validation globale
    def validate(self, attrs):
        if "spam" in attrs["title"].lower():
            raise serializers.ValidationError("Le titre ne doit pas contenir le mot 'spam'.")
        return attrs


class ForumMessageCreateSerializer(serializers.ModelSerializer):
    """
    Serializer minimal pour la création d'un message (contenu uniquement).
    """
    class Meta:
        model = ForumMessage
        # L'utilisateur fournit UNIQUEMENT le contenu. Topic et User sont gérés par la vue.
        fields = ['content'] 
        
        
class ForumReplyCreateSerializer(serializers.ModelSerializer):
    """
    Serializer minimal pour la création d'une réponse (contenu uniquement).
    """
    class Meta:
        model = ForumReply
        # L'utilisateur fournit UNIQUEMENT le contenu. Message et User sont gérés par la vue.
        fields = ['content'] 


# =======================================
# 2. SERIALIZERS DE LECTURE (READ/OUTPUT)
# =======================================

class ForumReplySerializer(serializers.ModelSerializer):
    class Meta:
        model = ForumReply
        fields = "__all__"
        # Ajout de 'user' à read_only, car il est défini par request.user dans views.py
        read_only_fields = ['id', 'user', 'created_at'] # Ajout de created_at


class ForumMessageSerializer(serializers.ModelSerializer):
    # Les réponses sont incluses lors de la lecture
    replies = ForumReplySerializer(many=True, read_only=True)

    class Meta:
        model = ForumMessage
        fields = "__all__"
        # user et replies sont définis par le serveur et le modèle
        read_only_fields = ['id', 'user', 'replies', 'created_at'] # Ajout de created_at


class ForumTopicSerializer(serializers.ModelSerializer):
    # Les messages sont inclus lors de la lecture
    messages = ForumMessageSerializer(many=True, read_only=True)
    
    class Meta:
        model = ForumTopic
        fields = "__all__"
        # Tous les champs liés à l'identité/date sont en lecture seule
        read_only_fields = ['id', 'created_by', 'messages', 'created_at'] 
        
    # Validation champ par champ (utilisé aussi pour les mises à jour si non surchargé)
    def validate_title(self, value):
        if len(value) < 3:
            raise serializers.ValidationError("Le titre doit contenir au moins 3 caractères.")
        return value

    # Validation globale (utilisé aussi pour les mises à jour si non surchargé)
    def validate(self, attrs):
        # Vérifiez si 'title' est dans attrs avant d'y accéder
        if "title" in attrs and "spam" in attrs["title"].lower():
            raise serializers.ValidationError("Le titre ne doit pas contenir le mot 'spam'.")
        return attrs