import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tokooci_app/config/constants/api_constants.dart';
import '../models/cart_model.dart';

class CartRemoteDataSource {
  final http.Client client;

  CartRemoteDataSource({required this.client});

  Future<CartResponse> getCart(String token) async {
    final response = await client.get(
      Uri.parse(ApiConstants.cart),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CartResponse.fromJson(data);
    } else {
      throw Exception('Failed to get cart: ${response.statusCode}');
    }
  }

  Future<CartResponse> addToCart({
    required String token,
    required int productId,
    required int quantity,
  }) async {
    final response = await client.post(
      Uri.parse(ApiConstants.cartAdd),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CartResponse.fromJson(data);
    } else {
      throw Exception('Failed to add to cart: ${response.statusCode}');
    }
  }

  Future<CartResponse> updateCartItem({
    required String token,
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.cartUpdate}/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CartResponse.fromJson(data);
    } else {
      throw Exception('Failed to update cart: ${response.statusCode}');
    }
  }

  Future<void> removeFromCart({
    required String token,
    required int cartItemId,
  }) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.cartRemove}/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart: ${response.statusCode}');
    }
  }

  Future<void> clearCart(String token) async {
    final response = await client.delete(
      Uri.parse(ApiConstants.cartClear),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart: ${response.statusCode}');
    }
  }
}