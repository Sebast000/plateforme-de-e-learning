from django.db import models
from django.conf import settings
from courses.models import Course, Module, Lesson


# --- A : Test d'évaluation initial ---
class InitialTestQuestion(models.Model):
    question = models.CharField(max_length=500)

    def __str__(self):
        return self.question


class InitialTestChoice(models.Model):
    question = models.ForeignKey(InitialTestQuestion, on_delete=models.CASCADE, related_name="choices")
    text = models.CharField(max_length=300)
    is_correct = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.text}"


class InitialTestResult(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    score = models.IntegerField()
    level_assigned = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)


# --- B : Quiz attaché à un module ---
class Quiz(models.Model):
    module = models.ForeignKey(Module, on_delete=models.CASCADE, related_name="quizzes")
    title = models.CharField(max_length=255)

    def __str__(self):
        return self.title


class QuizQuestion(models.Model):
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE, related_name="questions")
    question = models.CharField(max_length=500)

    def __str__(self):
        return self.question


class QuizChoice(models.Model):
    question = models.ForeignKey(QuizQuestion, on_delete=models.CASCADE, related_name="choices")
    text = models.CharField(max_length=300)
    is_correct = models.BooleanField(default=False)

    def __str__(self):
        return self.text


class QuizResult(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE)
    score = models.IntegerField()
    passed = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True)
