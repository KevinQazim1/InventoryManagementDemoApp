
// a custom exception to display a readable error to the user if there is a server error
class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

// editing the to string for the cases that the token/session for authentication is not avaible
  @override
  String toString() => switch (statusCode) {
        400 => 'Check the form: $body',
        401 => 'Your session expired, please log in again',
        _ => 'Server error ($statusCode)',
      };
}