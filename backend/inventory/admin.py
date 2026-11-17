from django.contrib import admin
from .models import Item

# Register your models here.

@admin.register(Item)
class ItemAdmin(admin.ModelAdmin):
    list_display = ["name", "sku", "quantity", "price", "location"]
    search_fields = ["name", "sku"]