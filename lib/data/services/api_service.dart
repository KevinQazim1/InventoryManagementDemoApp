import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventory_management_app/data/exceptions/api_exception.dart';
import '../models/item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // new import for securing sensitive info for auth

// service that contains async functions containing all CRUD operations the app can use
class ApiService {

  
  // making the base url dynamic incase the ip changes / splitting up the url to account for api/login 
  static const _apiRoot = String.fromEnvironment('API_URL', defaultValue: 'http://192.168.40.40:8000/api');
  static const baseUrl = '$_apiRoot/items';


  static const _json = {'Content-Type': 'application/json'};

  static const _timeout = Duration(seconds: 10);  // adding a timeout to 10 seconds to show error if server does not respond within 10 seconds


  // using the new security plugin for the auth features -> incoroperating the auth to the api urls
  static const _storage = FlutterSecureStorage();
  static String? _token; // static: every screen creates its own ApiService, but they all share ONE token

  // Every request shows the token (if we have one)
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Token $_token',
  };


  // Making these async so app does them in background process


  // functions for auth
    // Checking on app start, does token exist? 
  Future<bool> loadToken() async {
    _token = await _storage.read(key: 'token');
    return _token != null;
  }

  // loggin in, than writing the token in the phones secure storage
  Future<void> login(String username, String password) async {
    final res = await http
        .post(Uri.parse('$_apiRoot/login/'), headers: _headers,
            body: jsonEncode({'username': username, 'password': password}))
        .timeout(_timeout);
    _check(res, 200);
    _token = jsonDecode(res.body)['token'];
    await _storage.write(key: 'token', value: _token); // only the token is saved, never the password
  }

  // Logging out
  Future<void> logout() async {
    try {
      await http.post(Uri.parse('$_apiRoot/logout/'), headers: _headers).timeout(_timeout);
    } catch (_) {
      // server unreachable, still log out on this phone so the user isn't stuck
    }
    _token = null;
    await _storage.delete(key: 'token');
  }


  /*
  Now adding headers to each request made, so the token is in every request
  */

  // getting all items from the django url and use the converter to turn it into models the app can use / READ
  Future<List<Item>> getItems() async {
    final res = await http.get(Uri.parse('$baseUrl/'), headers: _headers).timeout(_timeout);   // parsing through the json and storing the resule
    _check(res, 200);
    final List data = jsonDecode(res.body);
    return data.map((j) => Item.fromJson(j)).toList();
  }

  // used fo the q scanner stretch goal / READ -> for SKU scanner
  Future<Item?> findBySku(String sku) async {
    final res = await http.get(Uri.parse('$baseUrl/').replace(queryParameters: {'sku': sku}), headers: _headers).timeout(_timeout);
    _check(res, 200);
    final List data = jsonDecode(res.body);
    return data.isEmpty ? null : Item.fromJson(data.first);
  }

  // creating an item, encoding the item made to JSON for the django server / CREATE
  Future<Item> createItem(Item item) async {
    final res = await http.post(Uri.parse('$baseUrl/'), headers: _headers, body: jsonEncode(item.toJson())).timeout(_timeout);
    _check(res, 201);
    return Item.fromJson(jsonDecode(res.body));
  }

  // Using put to update the provided item, then using the converted json from the item and decoding it to a model the app can use / UPDATE
  Future<Item> updateItem(Item item) async {
    final res = await http.put(Uri.parse('$baseUrl/${item.id}/'), headers: _headers, body: jsonEncode(item.toJson())).timeout(_timeout);
    _check(res, 200);
    return Item.fromJson(jsonDecode(res.body));
  }

  // deleting the item using the provided Id / DELETE
  Future<void> deleteItem(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id/'), headers: _headers).timeout(_timeout);
    _check(res, 204);
  }

  // helper func to check if the http call responds with what is expected
  void _check(http.Response res, int expected) {

    if (res.statusCode == 401) {
      _token = null;
      _storage.delete(key: 'token'); // token was rejected (logged out elsewhere / deleted in admin)
    }

    if (res.statusCode != expected) {
      throw ApiException(res.statusCode, res.body);
    }
  }
}