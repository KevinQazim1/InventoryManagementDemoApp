from django.db import models

# Create your models here.

# Item Model
class Item(models.Model):   # no Id field is needed since django will automatically create them
    name = models.CharField(max_length=200)
    sku = models.CharField(max_length=64, unique=True)  # makes the db reject duplicates with unique = true, needed for SKUs on items since they all have to be unique
    description = models.TextField(blank=True)
    quantity = models.PositiveIntegerField(default=0)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    location = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"] # default sort for every query

    def __str__(self): # what the admin shows
        return f"{self.name} ({self.sku})"
