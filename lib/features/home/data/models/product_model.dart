import 'package:json_annotation/json_annotation.dart';
import 'category_model.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String name;
  final String description;
  
  // FIX: Price bisa string "25999000.00" atau double
  @JsonKey(fromJson: _parsePrice)
  final double price;
  
  // FIX: Stock bisa string atau int
  @JsonKey(fromJson: _parseStock)
  final int stock;
  
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String? brand;
  final String? specifications;
  
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  final CategoryModel? category;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.brand,
    this.specifications,
    this.imageUrl,
    required this.isActive,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  // Helper function untuk parse price yang bisa string/double/int
  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove currency symbols and commas
      final cleaned = value
          .replaceAll('Rp', '')
          .replaceAll('IDR', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  // Helper function untuk parse stock
  static int _parseStock(dynamic value) {
    if (value == null) return 0;
    
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}