import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/constants/api_constants.dart';
// import '../../domain/models/auth_response.dart';
// import '../../domain/models/user_model.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource({required this.client});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.register}'),
      headers: ApiConstants.defaultHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.login}'),
      headers: ApiConstants.defaultHeaders,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.profile}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get profile: ${response.statusCode}');
    }
  }

  Future<void> logout(String token) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/${ApiConstants.logout}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }
}