import 'package:equatable/equatable.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/home_section_entity.dart';
import '../../../domain/entities/occasion_entity.dart';
import '../../../domain/entities/product_entity.dart';

class HomeState extends Equatable {
  final Resource<List<HomeSectionEntity>> sectionsResource;
  final Resource<List<CategoryEntity>> categoriesResource;
  final Resource<List<OccasionEntity>> occasionsResource;
  final Map<String, Resource<List<ProductEntity>>> carouselResources;

  // client-side: fetch products per occasion and keep the ones flagged
  final Resource<List<ProductEntity>> bestSellerResource;

  HomeState({
    Resource<List<HomeSectionEntity>>? sectionsResource,
    Resource<List<CategoryEntity>>? categoriesResource,
    Resource<List<OccasionEntity>>? occasionsResource,
    Map<String, Resource<List<ProductEntity>>>? carouselResources,
    Resource<List<ProductEntity>>? bestSellerResource,
  }) : sectionsResource = sectionsResource ?? Resource.initial(),
       categoriesResource = categoriesResource ?? Resource.initial(),
       occasionsResource = occasionsResource ?? Resource.initial(),
       carouselResources = carouselResources ?? const {},
       bestSellerResource = bestSellerResource ?? Resource.initial();

  factory HomeState.initial() => HomeState();

  HomeState copyWith({
    Resource<List<HomeSectionEntity>>? sectionsResource,
    Resource<List<CategoryEntity>>? categoriesResource,
    Resource<List<OccasionEntity>>? occasionsResource,
    Map<String, Resource<List<ProductEntity>>>? carouselResources,
    Resource<List<ProductEntity>>? bestSellerResource,
  }) {
    return HomeState(
      sectionsResource: sectionsResource ?? this.sectionsResource,
      categoriesResource: categoriesResource ?? this.categoriesResource,
      occasionsResource: occasionsResource ?? this.occasionsResource,
      carouselResources: carouselResources ?? this.carouselResources,
      bestSellerResource: bestSellerResource ?? this.bestSellerResource,
    );
  }

  @override
  List<Object?> get props => [
    sectionsResource,
    categoriesResource,
    occasionsResource,
    carouselResources,
    bestSellerResource,
  ];
}
