from django.contrib import admin
from .models import Certificate
# from .utils import generate_certificate_pdf  # <-- commente pour éviter l'erreur Windows

@admin.register(Certificate)
class CertificateAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'course', 'issued_at', 'certificate_code')
    search_fields = ('user__username', 'course__title', 'certificate_code')
    list_filter = ('issued_at', 'course')
