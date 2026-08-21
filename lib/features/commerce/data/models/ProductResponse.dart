import 'package:flower_app/features/commerce/data/models/product_dto.dart';

import '../../../../core/pagination/pagination_model.dart';



class ProductResponse {
  ProductResponse({
      this.data, 
      this.isSuccess, 
      this.message, 
      this.messageLocalized, 
      this.statusCode,});

  ProductResponse.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    isSuccess = json['isSuccess'];
    message = json['message'];
    messageLocalized = json['messageLocalized'];
    statusCode = json['statusCode'];
  }
  Data? data;
  bool? isSuccess;
  String? message;
  String? messageLocalized;
  String? statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['isSuccess'] = isSuccess;
    map['message'] = message;
    map['messageLocalized'] = messageLocalized;
    map['statusCode'] = statusCode;
    return map;
  }

}

/// items : [{"id":0,"name":"string","imageUrl":"string","currency":"string","price":0,"originalPrice":0,"discountPercentage":0,"status":"InStock"}]
/// pagination : {"page":0,"pageSize":0,"totalCount":0,"totalPages":0,"hasNextPage":true,"hasPreviousPage":true}

class Data {
  Data({
      this.items, 
      this.pagination,});

  Data.fromJson(dynamic json) {
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        items?.add(ProductDTO.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null;
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

/// page : 0
/// pageSize : 0
/// totalCount : 0
/// totalPages : 0
/// hasNextPage : true
/// hasPreviousPage : true




