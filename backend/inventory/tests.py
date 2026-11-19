from django.contrib.auth.models import User
from rest_framework.test import APITestCase


class ItemApiTests(APITestCase):
    def setUp(self):  # runs before EVERY test
        self.user = User.objects.create_user("tester", password="pass12345")
        self.client.force_authenticate(user=self.user)  # test shortcut: "pretend this user has a valid card"

    # ...your two existing tests stay exactly the same...

    def test_requires_login(self):
        self.client.force_authenticate(user=None)  # take the card away
        self.assertEqual(self.client.get("/api/items/").status_code, 401)

    def test_login_returns_token(self):
        self.client.force_authenticate(user=None)
        r = self.client.post("/api/login/", {"username": "tester", "password": "pass12345"}, format="json")
        self.assertEqual(r.status_code, 200)
        self.assertIn("token", r.data)