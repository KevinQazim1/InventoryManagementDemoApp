import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_management_app/data/exceptions/api_exception.dart';
import '../models/item.dart';

// service that contains async functions containing all CRUD operations the app can use
class ApiService {

  static const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://192.168.40.40:8000/api/items');  // making the base url dynamic incase the ip changes
  static const _json = {'Content-Type': 'application/json'};

  static const _timeout = Duration(seconds: 10);  // adding a timeout to 10 seconds to show error if server does not respond within 10 seconds


  // Making these async so app does them in background process

  // getting all items from the django url and use the converter to turn it into models the app can use / READ
  Future<List<Item>> getItems() async {
    final res = await http.get(Uri.parse('$baseUrl/')).timeout(_timeout);   // parsing through the json and storing the resule
    _check(res, 200);
    final List data = jsonDecode(res.body);
    return data.map((j) => Item.fromJson(j)).toList();
  }

  // used fo the q scanner stretch goal / READ -> for SKU scanner
  Future<Item?> findBySku(String sku) async {
    final res = await http.get(Uri.parse('$baseUrl/').replace(queryParameters: {'sku': sku})).timeout(_timeout);
    _check(res, 200);
    final List data = jsonDecode(res.body);
    return data.isEmpty ? null : Item.fromJson(data.first);
  }

  // creating an item, encoding the item made to JSON for the django server / CREATE
  Future<Item> createItem(Item item) async {
    final res = await http.post(Uri.parse('$baseUrl/'), headers: _json, body: jsonEncode(item.toJson())).timeout(_timeout);
    _check(res, 201);
    return Item.fromJson(jsonDecode(res.body));
  }

  // Using put to update the provided item, then using the converted json from the item and decoding it to a model the app can use / UPDATE
  Future<Item> updateItem(Item item) async {
    final res = await http.put(Uri.parse('$baseUrl/${item.id}/'), headers: _json, body: jsonEncode(item.toJson())).timeout(_timeout);
    _check(res, 200);
    return Item.fromJson(jsonDecode(res.body));
  }

  // deleting the item using the provided Id / DELETE
  Future<void> deleteItem(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id/')).timeout(_timeout);
    _check(res, 204);
  }

  // helper func to check if the http call responds with what is expected
  void _check(http.Response res, int expected) {
    if (res.statusCode != expected) {
      throw ApiException(res.statusCode, res.body);
    }
  }
}