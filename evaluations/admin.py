from django.contrib import admin
from .models import (
    InitialTestQuestion, InitialTestChoice, InitialTestResult,
    Quiz, QuizQuestion, QuizChoice, QuizResult
)

# --- ADMIN TEST INITIAL ---
class InitialTestChoiceInline(admin.TabularInline):
    model = InitialTestChoice
    extra = 2  # nombre de choix par défaut

@admin.register(InitialTestQuestion)
class InitialTestQuestionAdmin(admin.ModelAdmin):
    inlines = [InitialTestChoiceInline]
    list_display = ['question']

@admin.register(InitialTestResult)
class InitialTestResultAdmin(admin.ModelAdmin):
    list_display = ['user', 'score', 'level_assigned', 'created_at']
    readonly_fields = ['created_at']


# --- ADMIN QUIZ ---
class QuizChoiceInline(admin.TabularInline):
    model = QuizChoice
    extra = 4  # 4 choix par question

class QuizQuestionInline(admin.TabularInline):
    model = QuizQuestion
    extra = 3  # 3 questions par quiz

@admin.register(Quiz)
class QuizAdmin(admin.ModelAdmin):
    inlines = [QuizQuestionInline]
    list_display = ['title', 'module']

@admin.register(QuizQuestion)
class QuizQuestionAdmin(admin.ModelAdmin):
    inlines = [QuizChoiceInline]
    list_display = ['question', 'quiz']

@admin.register(QuizChoice)
class QuizChoiceAdmin(admin.ModelAdmin):
    list_display = ['text', 'question', 'is_correct']

@admin.register(QuizResult)
class QuizResultAdmin(admin.ModelAdmin):
    list_display = ['user', 'quiz', 'score', 'passed', 'created_at']
    readonly_fields = ['created_at']
