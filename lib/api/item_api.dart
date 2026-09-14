import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/item.dart';

class ItemApi {
  final ApiClient _client = ApiClient();

  // OAS 3.1: GET /api/uni/v1/items
  Future<List<Item>> getItems({
    String? type,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _client.dio.get(
      '/api/uni/v1/items',
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
    final response = await _client.dio.get('/api/uni/v1/items/$id');
    return Item.fromJson(response.data as Map<String, dynamic>);
  }

  // OAS 3.1: POST /api/uni/v1/items (multipart/form-data)
  Future<Item> createItem({
    required String type,
    required String title,
    required String description,
    required String location,
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
      'type': type,
      'title': title,
      'description': description,
      'location': location,
    };
    if (eventFrom != null) formDataMap['eventFrom'] = eventFrom;
    if (eventTo != null) formDataMap['eventTo'] = eventTo;
    if (multipartFile != null) {
      formDataMap['image'] = multipartFile;
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _client.dio.post(
      '/api/uni/v1/items',
      data: formData,
    );

    return Item.fromJson(response.data as Map<String, dynamic>);
  }

  // OAS 3.1: PATCH /api/uni/v1/items/{id}/status
  Future<Item> updateStatus(String id, String status) async {
    final response = await _client.dio.patch(
      '/api/uni/v1/items/$id/status',
      data: {'status': status},
    );
    return Item.fromJson(response.data as Map<String, dynamic>);
  }
}
