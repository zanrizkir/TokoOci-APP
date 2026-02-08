// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  price: ProductModel._parsePrice(json['price']),
  stock: ProductModel._parseStock(json['stock']),
  categoryId: (json['category_id'] as num).toInt(),
  brand: json['brand'] as String?,
  specifications: json['specifications'] as String?,
  imageUrl: json['image_url'] as String?,
  isActive: json['is_active'] as bool,
  category: json['category'] == null
      ? null
      : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'stock': instance.stock,
      'category_id': instance.categoryId,
      'brand': instance.brand,
      'specifications': instance.specifications,
      'image_url': instance.imageUrl,
      'is_active': instance.isActive,
      'category': instance.category,
    };
