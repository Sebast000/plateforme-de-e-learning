from django.contrib import admin
from .models import Category, Course, Module, Lesson

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'description')
    search_fields = ('name',)


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('id', 'title', 'category', 'level', 'created_by')  # supprimé 'created_at' qui n'existe pas
    list_filter = ('level', 'category')
    search_fields = ('title', 'description', 'created_by__username')


@admin.register(Module)
class ModuleAdmin(admin.ModelAdmin):
    list_display = ('id', 'title', 'course', 'order')
    list_filter = ('course',)
    search_fields = ('title',)


@admin.register(Lesson)
class LessonAdmin(admin.ModelAdmin):
    list_display = ('id', 'title', 'module', 'order')
    list_filter = ('module',)
    search_fields = ('title', 'content')
