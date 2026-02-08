import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tokooci_app/core/services/api_service.dart';
import 'package:tokooci_app/features/home/data/models/pagination_meta.dart';
import '../models/category_list_response.dart';
import '../models/product_list_response.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class HomeRemoteDataSource {
  final ApiService apiService;

  HomeRemoteDataSource({required this.apiService});

  Future<CategoryListResponse> getCategories() async {
    final response = await apiService.getCategories();
    
    print('=== DEBUG CATEGORIES API ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CategoryListResponse.fromJson(data);
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  Future<ProductListResponse> getProducts({
    int? categoryId,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await apiService.getProducts(
      categoryId: categoryId,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: page,
      perPage: perPage,
    );
    
    print('=== DEBUG PRODUCTS API ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      
      // Parse manually karena struktur JSON berbeda dengan model
      final bool success = json['success'] ?? false;
      final String message = json['message'] ?? '';
      
      // Data utama berisi pagination dan list produk
      final Map<String, dynamic> paginationData = json['data'];
      
      // Parse list produk
      final List<dynamic> productsJson = paginationData['data'];
      final List<ProductModel> products = productsJson
          .map((item) => ProductModel.fromJson(item))
          .toList();
      
      // Parse pagination meta
      final PaginationMeta meta = PaginationMeta(
        currentPage: paginationData['current_page'] as int? ?? 1,
        from: paginationData['from'] as int? ?? 1,
        lastPage: paginationData['last_page'] as int? ?? 1,
        links: paginationData['links'] as List<dynamic>? ?? [],
        path: paginationData['path'] as String? ?? '',
        perPage: (paginationData['per_page'] is String 
            ? int.tryParse(paginationData['per_page']) 
            : paginationData['per_page']) as int? ?? 10,
        to: paginationData['to'] as int? ?? 0,
        total: paginationData['total'] as int? ?? 0,
      );
      
      // Buat ProductListData
      final ProductListData productListData = ProductListData(
        data: products,
        meta: meta,
      );
      
      // Kembalikan ProductListResponse
      return ProductListResponse(
        success: success,
        message: message,
        data: productListData,
      );
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}