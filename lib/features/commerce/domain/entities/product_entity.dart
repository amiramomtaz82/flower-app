import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable{
 const ProductEntity({
    this.id,
    this.name,
    this.imageUrl,
    this.currency,
    this.price,
    this.originalPrice,
    this.discountPercentage,
    this.status,});


  final String? id;
  final String? name;
  final String? imageUrl;
 final  String? currency;
 final num? price;
 final num? originalPrice;
final num? discountPercentage;
final   String? status;

  @override
  // TODO: implement props
  List<Object?> get props => [id,name,imageUrl,currency,price,originalPrice,
  discountPercentage,status];



}
