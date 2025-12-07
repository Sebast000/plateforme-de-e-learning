from django.db.models.signals import post_save
from django.dispatch import receiver
from learning.models import Enrollment
from .models import Certificate
from .utils import generate_certificate_pdf

@receiver(post_save, sender=Enrollment)
def create_certificate(sender, instance, created, **kwargs):
    if instance.completed:
        # Vérifier qu’un certificat n’existe pas déjà
        cert, created = Certificate.objects.get_or_create(
            user=instance.user,
            course=instance.course
        )
        if created or not cert.pdf_file:
            generate_certificate_pdf(cert)
