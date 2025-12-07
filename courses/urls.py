from django.urls import path
from .views import CategoryListCreate, CourseListCreate, CourseDetail, ModuleListCreate, LessonListCreate

urlpatterns = [
    path('categories/', CategoryListCreate.as_view()),
    path('courses/', CourseListCreate.as_view()),
    path('courses/<int:pk>/', CourseDetail.as_view()),
    path('modules/', ModuleListCreate.as_view()),
    path('lessons/', LessonListCreate.as_view()),
]
