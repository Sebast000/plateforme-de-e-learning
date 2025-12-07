from rest_framework import generics, permissions
from .models import Category, Course, Module, Lesson
from .serializers import (
    CategorySerializer,
    CourseSerializer,
    ModuleSerializer,
    LessonSerializer
)

# Permission importée depuis learning
from learning.permissions import IsEnrolledInCourse


# --- CATEGORIES ---
class CategoryListCreate(generics.ListCreateAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer


# --- COURSES ---
class CourseListCreate(generics.ListCreateAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer


class CourseDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer


# --- MODULES ---
class ModuleListCreate(generics.ListCreateAPIView):
    queryset = Module.objects.all()
    serializer_class = ModuleSerializer


# --- LESSONS ---
class LessonListCreate(generics.ListCreateAPIView):
    queryset = Lesson.objects.all()
    serializer_class = LessonSerializer


class LessonDetail(generics.RetrieveAPIView):
    queryset = Lesson.objects.all()
    serializer_class = LessonSerializer
    permission_classes = [permissions.IsAuthenticated, IsEnrolledInCourse]
