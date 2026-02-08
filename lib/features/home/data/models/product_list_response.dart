import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart';
import 'pagination_meta.dart';

part 'product_list_response.g.dart';

@JsonSerializable()
class ProductListResponse {
  final bool success;
  final String message;
  final ProductListData data;

  ProductListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductListResponseToJson(this);
}

@JsonSerializable()
class ProductListData {
  final List<ProductModel> data;
  final PaginationMeta meta;

  ProductListData({
    required this.data,
    required this.meta,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) =>
      _$ProductListDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProductListDataToJson(this);
}