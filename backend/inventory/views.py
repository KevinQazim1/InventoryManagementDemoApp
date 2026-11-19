from rest_framework import viewsets
from .models import Item
from .serializers import ItemSerializer
# new imports using djangos token auth system
from rest_framework.decorators import api_view
from rest_framework.response import Response

# Create your views here.

class ItemViewSet(viewsets.ModelViewSet):

    serializer_class = ItemSerializer # turning items into JSON / Item object serialized into JSON

# gets called on every request to see which rows to work with -> filter by sku to allow the scanner logic -> if scanner is used filter items based off the sku
    def get_queryset(self):

        items = Item.objects.all() # A lazy call for all items line does not run yet
        sku = self.request.query_params.get("sku")

        if sku: # used by the QR scanner: /api/items/?sku=CBL-USBC-1M
            items = items.filter(sku=sku)

        return items;

    # Decorator to wrap function within django, with only POST allowed (Create)
    @api_view(["POST"]) # Not using Delete here for loggin out because logging out is an action strictly, no resource or argument is needed so POST is the conventional way to log a user out
    def logout(request):
        
        if request.auth:  # the Token object, when the request came in with a token
            request.auth.delete()  # deleting it at the "front desk" makes the card useless everywhere / DELETE FROM authtoken_token WHERE key = ''
        
        return Response(status=204) # success code
