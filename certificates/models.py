from django.db import models
from django.conf import settings
from courses.models import Course
import uuid

class Certificate(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    issued_at = models.DateTimeField(auto_now_add=True)
    certificate_code = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    pdf_file = models.FileField(upload_to='certificates/', null=True, blank=True)

    def __str__(self):
        return f"{self.user} - {self.course} ({self.certificate_code})"
