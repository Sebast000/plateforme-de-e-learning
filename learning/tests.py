# learning/tests.py

from django.test import TestCase
from django.contrib.auth import get_user_model

from courses.models import Course, Module, Lesson, Category
from learning.models import Enrollment, Progress
from learning.utils import update_course_progress
from evaluations.models import Quiz, QuizResult
from learning.recommender import get_personalized_course_recommendations

User = get_user_model()


class ProgressUtilityTests(TestCase):

    def setUp(self):
        # Création de l'utilisateur
        self.user = User.objects.create_user(username='testuser', password='password')
        self.category = Category.objects.create(name='Python')

        # Création du cours
        self.course = Course.objects.create(
            title='Python 101',
            category=self.category,
            level='Débutant',
            created_by=self.user
        )

        self.module = Module.objects.create(course=self.course, title='Intro', order=1)

        # Leçons
        self.lesson1 = Lesson.objects.create(module=self.module, title='L1', order=1)
        self.lesson2 = Lesson.objects.create(module=self.module, title='L2', order=2)
        self.lesson3 = Lesson.objects.create(module=self.module, title='L3', order=3)

        # Inscription
        self.enrollment = Enrollment.objects.create(user=self.user, course=self.course)

    def test_progress_calculation(self):
        # 1. Compléter la première leçon
        success, message = update_course_progress(self.user, self.lesson1)
        self.assertTrue(success)
        self.enrollment.refresh_from_db()
        self.assertAlmostEqual(self.enrollment.progress_percent, 33.33, places=2)
        self.assertFalse(self.enrollment.completed)

        # 2. Deuxième leçon
        success, message = update_course_progress(self.user, self.lesson2)
        self.assertTrue(success)
        self.enrollment.refresh_from_db()
        self.assertAlmostEqual(self.enrollment.progress_percent, 66.67, places=2)
        self.assertFalse(self.enrollment.completed)

        # 3. Dernière leçon
        success, message = update_course_progress(self.user, self.lesson3)
        self.assertTrue(success)
        self.enrollment.refresh_from_db()

        # Vérification finale
        self.assertEqual(self.enrollment.progress_percent, 100.0)
        self.assertTrue(self.enrollment.completed)

    def test_unsubscribed_user(self):
        unsubscribed_user = User.objects.create_user(username='unsub', password='pw')
        success, message = update_course_progress(unsubscribed_user, self.lesson1)

        self.assertFalse(success)
        self.assertIn("Non inscrit au cours", message)


class RecommenderTests(TestCase):

    def setUp(self):
        # Utilisateur à recommander
        self.user = User.objects.create_user(
            username='tester',
            password='pw',
            level='Intermédiaire'
        )

        self.cat_python = Category.objects.create(name='Python')
        self.cat_web = Category.objects.create(name='Web')

        # Intérêts
        self.user.interests.add(self.cat_python)

        # Cours A — Lacune
        self.course_A_deficiency = Course.objects.create(
            title='Python Avancé',
            category=self.cat_python,
            level='Intermédiaire',
            created_by=self.user
        )
        self.module_A = Module.objects.create(course=self.course_A_deficiency, title='M1')
        self.quiz_A = Quiz.objects.create(module=self.module_A, title='Quiz A')

        # Cours B — Normal
        self.course_B_normal = Course.objects.create(
            title='Python Securité',
            category=self.cat_python,
            level='Intermédiaire',
            created_by=self.user
        )

        # Cours C — Faible intérêt
        self.course_C_low = Course.objects.create(
            title='Web Design',
            category=self.cat_web,
            level='Intermédiaire',
            created_by=self.user
        )

    def test_deficiency_priority(self):
        # Simuler une lacune (quiz échoué)
        QuizResult.objects.create(
            user=self.user,
            quiz=self.quiz_A,
            score=5,
            passed=False
        )

        # Obtenir recommandations
        recs = get_personalized_course_recommendations(self.user, max_results=3)

        # Vérifier ordre
        first_rec_id = recs[0]['course'].id
        self.assertEqual(
            first_rec_id,
            self.course_A_deficiency.id,
            "Le cours lié à la lacune n'est pas en première position."
        )

        second_rec_id = recs[1]['course'].id
        self.assertEqual(
            second_rec_id,
            self.course_B_normal.id,
            "Le cours de priorité normale n'est pas en deuxième position."
        )

        # Vérifier scores
        self.assertTrue(recs[0]['score'] > recs[1]['score'])
