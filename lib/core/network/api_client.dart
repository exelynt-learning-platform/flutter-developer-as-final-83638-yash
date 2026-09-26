import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/failures.dart';

class ApiClient {
  static const String baseUrl = 'https://669b3f09276e45187d34eb4e.mockapi.io/api/v1';

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      case 400:
        throw ServerFailure('Bad request. Please verify inputs.', statusCode: 400);
      case 404:
        throw ServerFailure('Requested resource not found.', statusCode: 404);
      case 500:
      default:
        throw ServerFailure(
          'Server error with status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
    }
  }
}
