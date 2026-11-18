import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/data/models/item.dart';


void main() {
  test('Item survives a JSON round trip', () {
    final json = {
      'id': 1, 'name': 'Mouse', 'sku': 'MSE-1', 'description': '',
      'quantity': 3, 'price': '24.50', 'location': 'A2',
    };
    final item = Item.fromJson(json);
    expect(item.price, '24.50');
    expect(item.toJson().containsKey('id'), false); // the server owns the id
  });
}