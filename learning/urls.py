from django.urls import path
from .views import RecommendationsView, TrackProgressView

urlpatterns = [
    path('recommendations/', RecommendationsView.as_view(), name='recommendations'),
    path('progress/track/<int:lesson_id>/', TrackProgressView.as_view(), name='track-progress'),
]
