from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token
from rest_framework.routers import DefaultRouter
from .views import ItemViewSet, logout

router = DefaultRouter()
router.register("items", ItemViewSet, basename="item")

urlpatterns = [
    path("login/", obtain_auth_token),   # entering credentials, providing auth token
    path("logout/", logout),             # deleting the token
] + router.urls # -> /api/login -> api cannot be accessed unless credentials are provided
