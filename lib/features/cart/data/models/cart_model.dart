import 'package:json_annotation/json_annotation.dart';
import 'package:tokooci_app/features/home/data/models/product_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartItemModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'product_id')
  final int productId;
  final int quantity;
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);
}

@JsonSerializable()
class CartResponse {
  final bool success;
  final String message;
  final CartData data;

  CartResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) =>
      _$CartResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$CartResponseToJson(this);
}

@JsonSerializable()
class CartData {
  final List<CartItemModel> items;
  @JsonKey(name: 'total_items')
  final int totalItems;
  @JsonKey(name: 'total_price')
  final double totalPrice;

  CartData({
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  factory CartData.fromJson(Map<String, dynamic> json) =>
      _$CartDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$CartDataToJson(this);
}