from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import User
from courses.models import Category


# -------------------------------------------------------
# SERIALIZER POUR LECTURE / OUTPUT
# -------------------------------------------------------
class UserSerializer(serializers.ModelSerializer):
    # Renvoie la liste des intérêts sous forme de texte
    interests = serializers.SlugRelatedField(
        many=True,
        read_only=True,
        slug_field='name'  # ← important : affiche le nom de la catégorie
    )

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'bio', 'level', 'interests']



# -------------------------------------------------------
# SERIALIZER D’ENREGISTREMENT / INPUT (REGISTER)
# -------------------------------------------------------
class RegisterSerializer(serializers.ModelSerializer):
    # Le client envoie une liste d'IDs de catégories
    interests = serializers.ListField(
        child=serializers.IntegerField(),
        required=False
    )

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'bio', 'interests']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        interests_ids = validated_data.pop('interests', [])

        # Hasher mot de passe
        validated_data['password'] = make_password(validated_data['password'])

        # Création de l’utilisateur
        user = User.objects.create(**validated_data)

        # Ajout des intérêts (relation ManyToMany)
        if interests_ids:
            categories = Category.objects.filter(id__in=interests_ids)
            user.interests.set(categories)

        return user



# -------------------------------------------------------
# LOGIN
# -------------------------------------------------------
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()
