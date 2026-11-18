
// a custom exception to display a readable error to the user if there is a server error
class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => statusCode == 400 ? 'Check the form: $body' : 'Server error ($statusCode)';
}