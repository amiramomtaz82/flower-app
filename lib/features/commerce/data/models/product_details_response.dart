import 'package:flower_app/features/commerce/data/models/product_dto.dart';

class ProductDetailsResponse {
  ProductDetailsResponse({
    this.success,
    this.message,
    this.data,
    this.error,
  });

  ProductDetailsResponse.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ProductDetailsDTO.fromJson(json['data']) : null;
    error = json['error'];
  }

  bool? success;
  String? message;
  ProductDetailsDTO? data;
  dynamic error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['error'] = error;
    return map;
  }
}

class ProductDetailsDTO extends ProductDTO {
  ProductDetailsDTO({
    String? id,
    super.name,
    super.imageUrl,
    super.currency,
    super.price,
    super.originalPrice,
    super.discountPercentage,
    super.status,
    this.images,
    this.description,
    this.includes,
    this.categoryId,
    this.occasionIds,
  }) : super(id: id);

  ProductDetailsDTO.fromJson(dynamic json) : super.fromJson(json) {
    images = json['images'] != null ? json['images'].cast<String>() : [];
    if (json['includes'] != null) {
      includes = [];
      json['includes'].forEach((v) {
        includes?.add(IncludeDTO.fromJson(v));
      });
    }
    description = json['description'];
    categoryId = json['categoryId'];
    occasionIds = json['occasionIds'] != null ? json['occasionIds'].cast<String>() : [];
  }

  List<String>? images;
  String? description;
  List<IncludeDTO>? includes;
  String? categoryId;
  List<String>? occasionIds;

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['images'] = images;
    map['description'] = description;
    if (includes != null) {
      map['includes'] = includes?.map((v) => v.toJson()).toList();
    }
    map['categoryId'] = categoryId;
    map['occasionIds'] = occasionIds;
    return map;
  }
}

class IncludeDTO {
  IncludeDTO({this.name});

  IncludeDTO.fromJson(dynamic json) {
    name = json['name'];
  }
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }
}
