class ProductDTO {
  ProductDTO({
    this.id,
    this.name,
    this.imageUrl,
    this.currency,
    this.price,
    this.originalPrice,
    this.discountPercentage,
    this.status,});

  ProductDTO.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    currency = json['currency'];
    price = json['price'];
    originalPrice = json['originalPrice'];
    discountPercentage = json['discountPercentage'];
    status = json['status'];
  }
  num? id;
  String? name;
  String? imageUrl;
  String? currency;
  num? price;
  num? originalPrice;
  num? discountPercentage;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['imageUrl'] = imageUrl;
    map['currency'] = currency;
    map['price'] = price;
    map['originalPrice'] = originalPrice;
    map['discountPercentage'] = discountPercentage;
    map['status'] = status;
    return map;
  }

}