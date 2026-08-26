import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/data/models/product_dto.dart';

class ProductResponse {
  ProductResponse({
    this.data,
    this.success,
    this.message,
    this.error,
  });

  ProductResponse.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    success = json['success'];
    message = json['message'];
    error = json['error'];
  }

  Data? data;
  bool? success;
  String? message;
  dynamic error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['success'] = success;
    map['message'] = message;
    map['error'] = error;
    return map;
  }
}

class Data {
  Data({
    this.items,
    this.pagination,
  });

  Data.fromJson(dynamic json) {
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(ProductDTO.fromJson(v));
      });
    }
    // API returns pagination fields flat inside data (not nested)
    pagination = PaginationModel(
      page: json['pageNumber'],
      pageSize: json['pageSize'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }

  List<ProductDTO>? items;
  PaginationModel? pagination;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (items != null) {
      map['items'] = items?.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      map['pagination'] = pagination?.toJson();
    }
    return map;
  }
}
