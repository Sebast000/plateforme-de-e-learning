# users/models.py (ou l'emplacement de votre modèle User)

from django.contrib.auth.models import AbstractUser
from django.db import models

# Import nécessaire si le modèle Category est dans une autre application (ex: courses.models)
from courses.models import Category 

class User(AbstractUser):
    bio = models.TextField(blank=True, null=True)
    level = models.CharField(max_length=50, default="Débutant")
    
    # MODIFICATION CRITIQUE : Passage du JSONField au ManyToManyField
    interests = models.ManyToManyField(
        Category, 
        blank=True, 
        related_name='interested_users'
    )

    def __str__(self):
        return self.username