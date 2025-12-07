# D:\UVBFL3\ProjetTutore\certificates\views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.http import FileResponse
from .models import Certificate
from drf_spectacular.utils import extend_schema, OpenApiTypes
# Importation du nouveau serializer
from .serializers import CertificateDownloadResponseSerializer 

class DownloadCertificateView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        # Utilise OpenApiTypes.BINARY pour indiquer que la réponse est un fichier (PDF)
        responses={
            200: OpenApiTypes.BINARY, 
            404: {"description": "Certificat introuvable."},
            401: {"description": "Non authentifié (JWT manquant ou invalide)."}
        },
        description="Télécharge le certificat de l'utilisateur en tant que fichier PDF."
    )
    def get(self, request, certificate_id):
        cert = Certificate.objects.filter(id=certificate_id, user=request.user).first()
        if not cert or not cert.pdf_file:
            # Note: Si vous voulez le schéma détaillé, utilisez le serializer.
            # Mais ici, 404 est suffisant pour le swagger.
            return Response({"error": "Certificat introuvable."}, status=404)

        return FileResponse(cert.pdf_file.open('rb'), content_type='application/pdf')