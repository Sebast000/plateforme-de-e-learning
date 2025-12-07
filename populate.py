import os
import django

# --- IMPORTANT : adapter au nom de ton projet ---
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "core_project.settings")
django.setup()

from django.contrib.auth import get_user_model
from courses.models import Category, Course, Module, Lesson
from evaluations.models import Quiz, QuizQuestion, QuizChoice, QuizResult, InitialTestQuestion, InitialTestChoice, InitialTestResult

User = get_user_model()


# ------------------------------------------------------
#      FONCTIONS PRINCIPALES
# ------------------------------------------------------

def clean_database():
    print("🧹 Suppression des anciennes données...")

    # Supprimer toutes les évaluations
    QuizChoice.objects.all().delete()
    QuizQuestion.objects.all().delete()
    Quiz.objects.all().delete()
    QuizResult.objects.all().delete()

    InitialTestChoice.objects.all().delete()
    InitialTestQuestion.objects.all().delete()
    InitialTestResult.objects.all().delete()

    # Supprimer les cours, modules, leçons et catégories
    Lesson.objects.all().delete()
    Module.objects.all().delete()
    Course.objects.all().delete()
    Category.objects.all().delete()

    print("✔ Base nettoyée.\n")


def create_admin_user():
    print("👤 Vérification / création de l'utilisateur admin...")

    admin_user, created = User.objects.get_or_create(
        username="admin",
        defaults={"email": "admin@example.com"}
    )

    if created:
        admin_user.set_password("admin1234")
        admin_user.save()
        print("  ✔ Utilisateur admin créé : admin / admin1234")
    else:
        print("  ✔ Utilisateur admin déjà existant")

    print("")
    return admin_user


def create_categories():
    print("📚 Création des catégories...")

    categories_data = [
        "Programmation",
        "Science des données",
        "Développement Mobile",
        "Développement Web",
        "Cybersécurité",
    ]

    categories = {}

    for name in categories_data:
        cat = Category.objects.create(name=name)
        categories[name] = cat
        print(f"  ✔ {name}")

    print("")
    return categories


def create_courses(categories, admin_user):
    print("📘 Création des cours...")

    courses_data = [
        {
            "title": "Python pour Débutants",
            "category": "Programmation",
            "description": "Apprenez Python étape par étape.",
            "level": "Débutant",
        },
        {
            "title": "Flutter Mastery",
            "category": "Développement Mobile",
            "description": "Créer des applications mobiles cross-platform.",
            "level": "Intermédiaire",
        },
        {
            "title": "Analyse de données avec Pandas",
            "category": "Science des données",
            "description": "Manipulez vos datasets professionnellement.",
            "level": "Débutant",
        },
    ]

    courses = {}

    for data in courses_data:
        course = Course.objects.create(
            title=data["title"],
            description=data["description"],
            level=data["level"],
            category=categories[data["category"]],
            created_by=admin_user
        )
        courses[data["title"]] = course
        print(f"  ✔ {data['title']}")

    print("")
    return courses


def create_modules(courses):
    print("📦 Création des modules...")

    modules_data = {
        "Python pour Débutants": [
            "Installation & environnement",
            "Variables & Types",
            "Conditions & Boucles",
        ],
        "Flutter Mastery": [
            "Introduction à Flutter",
            "Widgets essentiels",
            "Navigation",
        ],
        "Analyse de données avec Pandas": [
            "Importer les données",
            "Manipuler les DataFrames",
            "Opérations avancées",
        ],
    }

    modules = {}

    for course_title, module_list in modules_data.items():
        course = courses[course_title]

        modules[course_title] = []
        for idx, module_name in enumerate(module_list):
            mod = Module.objects.create(
                title=module_name,
                course=course,
                order=idx
            )
            modules[course_title].append(mod)
            print(f"  ✔ Module {module_name} (dans {course_title})")

    print("")
    return modules


def create_lessons(modules):
    print("📖 Création des leçons...")

    for course_title, module_list in modules.items():
        for module in module_list:
            # Création de 10 leçons par module
            for i in range(1, 11):
                Lesson.objects.create(
                    title=f"Leçon {i} - {module.title}",
                    content=f"Contenu de la leçon {i} pour le module {module.title}.",
                    module=module,
                    order=i-1
                )
                print(f"  ✔ Leçon {i} créée dans module {module.title}")

    print("")


def create_quiz(modules):
    print("❓ Création des quiz...")

    # Crée un quiz par cours attaché au premier module
    for course_title, module_list in modules.items():
        first_module = module_list[0]

        quiz = Quiz.objects.create(
            title=f"Quiz {course_title}",
            module=first_module
        )

        # Exemple de 2 questions par quiz
        q1 = QuizQuestion.objects.create(
            quiz=quiz,
            question=f"Question 1 pour {course_title} ?"
        )
        QuizChoice.objects.create(question=q1, text="Réponse A", is_correct=True)
        QuizChoice.objects.create(question=q1, text="Réponse B")
        QuizChoice.objects.create(question=q1, text="Réponse C")

        q2 = QuizQuestion.objects.create(
            quiz=quiz,
            question=f"Question 2 pour {course_title} ?"
        )
        QuizChoice.objects.create(question=q2, text="Réponse A")
        QuizChoice.objects.create(question=q2, text="Réponse B", is_correct=True)
        QuizChoice.objects.create(question=q2, text="Réponse C")

        print(f"  ✔ Quiz créé pour le cours {course_title}")

    print("")


def main():
    clean_database()
    admin_user = create_admin_user()
    categories = create_categories()
    courses = create_courses(categories, admin_user)
    modules = create_modules(courses)
    create_lessons(modules)
    create_quiz(modules)

    print("\n🔥 POPULATE TERMINÉ AVEC SUCCÈS !")


if __name__ == "__main__":
    main()
