// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductListResponse _$ProductListResponseFromJson(Map<String, dynamic> json) =>
    ProductListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ProductListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductListResponseToJson(
  ProductListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

ProductListData _$ProductListDataFromJson(Map<String, dynamic> json) =>
    ProductListData(
      data: (json['data'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductListDataToJson(ProductListData instance) =>
    <String, dynamic>{'data': instance.data, 'meta': instance.meta};
