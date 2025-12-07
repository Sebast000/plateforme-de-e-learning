from django.urls import path
from .views import DownloadCertificateView

urlpatterns = [
    path("<int:certificate_id>/download/", DownloadCertificateView.as_view()),
]
