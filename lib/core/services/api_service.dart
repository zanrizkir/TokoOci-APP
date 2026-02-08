import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/../config/constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if exists
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Get token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token to storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Remove token (logout)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http
        .get(Uri.parse(endpoint), headers: headers)
        .timeout(ApiConstants.timeout);

    return response;
  }

  // POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http
        .post(Uri.parse(endpoint), headers: headers, body: jsonEncode(data))
        .timeout(ApiConstants.timeout);

    return response;
  }

  // PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http
        .put(Uri.parse(endpoint), headers: headers, body: jsonEncode(data))
        .timeout(ApiConstants.timeout);

    return response;
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http
        .delete(Uri.parse(endpoint), headers: headers)
        .timeout(ApiConstants.timeout);

    return response;
  }

  // Helper method to handle API errors
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        final responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw 'Bad request';
      case 401:
        throw 'Unauthorized';
      case 403:
        throw 'Forbidden';
      case 404:
        throw 'Not found';
      case 422:
        final responseJson = jsonDecode(response.body);
        throw responseJson['errors'] ?? 'Validation error';
      case 500:
        throw 'Server error';
      default:
        throw 'Failed with status: ${response.statusCode}';
    }
  }

  // Get categories
  Future<http.Response> getCategories() async {
    final headers = await _getHeaders();
    final response = await http
        .get(Uri.parse(ApiConstants.categories), headers: headers)
        .timeout(ApiConstants.timeout);

    return response;
  }

  // Get products with optional filters
  Future<http.Response> getProducts({
    int? categoryId,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 10,
  }) async {
    final headers = await _getHeaders();

    // Build query parameters
    final params = <String, String>{
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (categoryId != null && categoryId > 0) {
      params['category_id'] = categoryId.toString();
    }

    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final uri = Uri.parse(
      ApiConstants.products,
    ).replace(queryParameters: params);

    final response = await http
        .get(uri, headers: headers)
        .timeout(ApiConstants.timeout);

    return response;
  }

  // Get single product by ID
  Future<http.Response> getProduct(int id) async {
    final headers = await _getHeaders();
    final response = await http
        .get(Uri.parse('${ApiConstants.products}/$id'), headers: headers)
        .timeout(ApiConstants.timeout);

    return response;
  }
}
