import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/item.dart';

class ItemApi {
  final ApiClient _client = ApiClient();

  // OAS 3.1: GET /api/uni/v1/items
  // REQUIRED query parameters: `type` (LOST|FOUND) and `status` (OPEN|CLOSED|MATCHED|CLAIMED)
  Future<List<Item>> getItems({
    required String type,
    required String status,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{
      'type': type.toUpperCase(),
      'status': status.toUpperCase(),
      'page': page,
      'size': size,
    };
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final response = await _client.dio.get(
      ApiEndpoints.items,
      queryParameters: queryParams,
    );

    final data = response.data;
    List<dynamic> itemsList = [];
    if (data is List) {
      itemsList = data;
    } else if (data is Map && data.containsKey('content')) {
      itemsList = data['content'] as List<dynamic>;
    } else if (data is Map && data.containsKey('items')) {
      itemsList = data['items'] as List<dynamic>;
    }

    return itemsList.map((item) => Item.fromJson(item as Map<String, dynamic>)).toList();
  }

  // OAS 3.1: GET /api/uni/v1/items/{id}
  Future<Item> getItemById(String id) async {
    final response = await _client.dio.get(ApiEndpoints.itemById(id));
    return Item.fromJson(response.data as Map<String, dynamic>);
  }

  // OAS 3.1: POST /api/uni/v1/items (multipart/form-data)
  Future<Item> createItem({
    required String type,
    required String title,
    required String description,
    required String location,
    String? category,
    String? eventFrom,
    String? eventTo,
    File? imageFile,
  }) async {
    MultipartFile? multipartFile;
    if (imageFile != null) {
      final fileName = imageFile.path.split('/').last;
      multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      );
    }

    final formDataMap = <String, dynamic>{
      'type': type.toUpperCase(),
      'title': title,
      'description': description,
      'location': location,
    };
    if (category != null && category.isNotEmpty) {
      formDataMap['category'] = category;
    }
    if (eventFrom != null && eventFrom.isNotEmpty) {
      formDataMap['eventFrom'] = eventFrom;
    }
    if (eventTo != null && eventTo.isNotEmpty) {
      formDataMap['eventTo'] = eventTo;
    }
    if (multipartFile != null) {
      formDataMap['image'] = multipartFile;
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _client.dio.post(
      ApiEndpoints.items,
      data: formData,
    );

    return Item.fromJson(response.data as Map<String, dynamic>);
  }

  // OAS 3.1: PATCH /api/uni/v1/items/{id}/status
  // Backend rule: Only the case creator or a campus moderator can change status
  Future<Item> updateStatus(String id, String status) async {
    final response = await _client.dio.patch(
      ApiEndpoints.itemStatus(id),
      data: {'status': status.toUpperCase()},
    );
    return Item.fromJson(response.data as Map<String, dynamic>);
  }
}
