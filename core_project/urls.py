from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponseRedirect, JsonResponse
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

# Redirection de la racine "/" vers "/api/"
def redirect_root(request):
    return HttpResponseRedirect('/api/')

# Endpoint racine de l'API
def api_root(request):
    return JsonResponse({"message": "Bienvenue sur l'API Elearning!"})


urlpatterns = [
    path('', redirect_root),
    path('api/', api_root),

    path('admin/', admin.site.urls),
    
    # App URLs
    path('api/', include('users.urls')),
    path('api/', include('courses.urls')),
    path('api/', include('evaluations.urls')),
    path('api/', include('learning.urls')),
   path('api/', include('forum.urls')),
    path('api/certificates/', include('certificates.urls')),

    # Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]

