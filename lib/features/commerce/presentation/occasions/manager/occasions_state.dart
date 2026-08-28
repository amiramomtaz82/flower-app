import 'package:equatable/equatable.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/occasion_entity.dart';
import '../../../domain/entities/product_entity.dart';

class OccasionsState extends Equatable {
  final Resource<List<OccasionEntity>> occasionsResource;
  final Resource<List<ProductEntity>> productsResource;
  final String? selectedOccasionId;

  OccasionsState({
    Resource<List<OccasionEntity>>? occasionsResource,
    Resource<List<ProductEntity>>? productsResource,
    this.selectedOccasionId,
  }) : occasionsResource = occasionsResource ?? Resource.initial(),
       productsResource = productsResource ?? Resource.initial();

  factory OccasionsState.initial() => OccasionsState();

  OccasionsState copyWith({
    Resource<List<OccasionEntity>>? occasionsResource,
    Resource<List<ProductEntity>>? productsResource,
    String? selectedOccasionId,
  }) {
    return OccasionsState(
      occasionsResource: occasionsResource ?? this.occasionsResource,
      productsResource: productsResource ?? this.productsResource,
      selectedOccasionId: selectedOccasionId ?? this.selectedOccasionId,
    );
  }

  @override
  List<Object?> get props => [
    occasionsResource,
    productsResource,
    selectedOccasionId,
  ];
}
