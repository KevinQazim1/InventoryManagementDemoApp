from django.shortcuts import render
from rest_framework import viewsets
from .models import Item
from .serializers import ItemSerializer
# Create your views here.

class ItemViewSet(viewsets.ModelViewSet):

    serializer_class = ItemSerializer

    def get_queryset(self):

        items = Item.objects.all()
        sku = self.request.query_params.get("sku")

        if sku: # used by the QR scanner: /api/items/?sku=CBL-USBC-1M
            items = items.filter(sku=sku)

        return items
