from django.urls import path
from .views import InitialTestQuestionsView, SubmitInitialTestView, QuizDetailView, SubmitQuizView

urlpatterns = [
    path('initial-test/questions/', InitialTestQuestionsView.as_view()),
    path('initial-test/submit/', SubmitInitialTestView.as_view()),
    path('quiz/<int:quiz_id>/', QuizDetailView.as_view()),
    path('quiz/<int:quiz_id>/submit/', SubmitQuizView.as_view()),
]
