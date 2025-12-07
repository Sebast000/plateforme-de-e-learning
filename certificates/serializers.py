# D:\UVBFL3\ProjetTutore\certificates\serializers.py

from rest_framework import serializers

class CertificateDownloadResponseSerializer(serializers.Serializer):
    """Réponse de succès pour le téléchargement, simule un message de confirmation."""
    detail = serializers.CharField(
        read_only=True, 
        help_text="Le fichier PDF est téléchargé."
    )