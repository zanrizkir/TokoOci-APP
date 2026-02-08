import 'package:json_annotation/json_annotation.dart';
import 'category_model.dart';

part 'category_list_response.g.dart';

@JsonSerializable()
class CategoryListResponse {
  final bool success;
  final String message;
  final List<CategoryModel> data;

  CategoryListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryListResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$CategoryListResponseToJson(this);
}