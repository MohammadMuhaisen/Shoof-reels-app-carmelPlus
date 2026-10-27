import 'dart:convert';

import 'package:http/http.dart' as http;

const baseUrl = 'http://127.0.0.1:8000/api';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message, [this.errors = const {}]);

  final int statusCode;
  final String message;
  final Map<String, List<String>> errors;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({this.token});

  final String? token;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handle(response);
  }

  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
    return _handle(response);
  }

  Map<String, dynamic> _handle(http.Response response) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException(
        response.statusCode,
        'Unexpected response from the server.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final errors = <String, List<String>>{};
    final rawErrors = data['errors'];
    if (rawErrors is Map<String, dynamic>) {
      rawErrors.forEach((field, messages) {
        errors[field] = List<String>.from(messages as List);
      });
    }

    throw ApiException(
      response.statusCode,
      data['message'] as String? ?? 'Something went wrong.',
      errors,
    );
  }
}
