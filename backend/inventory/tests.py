from django.test import TestCase
from rest_framework.test import APITestCase

# Create your tests here.

class ItemApiTests(APITestCase):
    def test_crud(self):

        r = self.client.post("/api/items/", {"name": "A", "sku": "A-1", "quantity": 1, "price": "2.00"}, format="json")
        self.assertEqual(r.status_code, 201)

        item_id = r.data["id"]

        self.assertEqual(self.client.get(f"/api/items/?sku=A-1").data[0]["id"], item_id)
        self.assertEqual(self.client.patch(f"/api/items/{item_id}/", {"quantity": 9}, format="json").data["quantity"], 9)
        self.assertEqual(self.client.delete(f"/api/items/{item_id}/").status_code, 204)

    def test_rejects_negative_quantity(self):

        r = self.client.post("/api/items/", {"name": "B", "sku": "B-1", "quantity": -1, "price": "1.00"}, format="json")
        self.assertEqual(r.status_code, 400)