
class Item {

  final int? id; // null until the server creates it
  final String name;
  final String sku;
  final String description;
  final int quantity;
  final String price; // kept as a String, exactly like the API sends it (no float rounding)
  final String location;

  Item({
    this.id,
    required this.name,
    required this.sku,
    this.description = '',
    this.quantity = 0,
    required this.price,
    this.location = '',
  });

  // turning the recieved json to a item model
  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    name: json['name'],
    sku: json['sku'],
    description: json['description'],
    quantity: json['quantity'],
    price: json['price'],
    location: json['location'],
  );

// No id / timestamps: the server owns those.
  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'description': description,
    'quantity': quantity,
    'price': price,
    'location': location,
  };
}