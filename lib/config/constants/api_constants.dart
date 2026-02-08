class ApiConstants {
  // Base URL - Ganti dengan URL ngrok Anda
  static const String baseUrl = 
      'https://tawanda-untongued-extrinsically.ngrok-free.dev/api/v1';

  // Endpoints - Full URLs
  static const String test = '$baseUrl/test';
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String profile = '$baseUrl/profile';
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';
  static const String cart = '$baseUrl/cart';
  static const String cartAdd = '$cart/add';
  static const String cartUpdate = '$cart/update';
  static const String cartRemove = '$cart/remove';
  static const String cartClear = '$cart/clear';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}