import 'package:flutter/material.dart';

import '../data/exceptions/api_exception.dart';
import '../data/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await _api.login(_username.text.trim(), _password.text); // password not trimmed: spaces can be part of it
      if (mounted) Navigator.pushReplacementNamed(context, '/items');
    } on ApiException catch (e) {
      _showError(e.statusCode == 400 ? 'Wrong username or password' : '$e');
    } catch (_) {
      _showError('Could not reach the server');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _required(String? v) => (v == null || v.isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              autofillHints: const [AutofillHints.username],
              validator: _required,
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              validator: _required,
              onFieldSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _login,
              child: Text(_loading ? 'Logging in…' : 'Log in'),
            ),
          ],
        ),
      ),
    );
  }
}