import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/data/models/product_dto.dart';
import 'package:flower_app/features/commerce/data/models/product_details_response.dart';

class CommerceDummyData {
  static PaginatedResponse<ProductDTO> getDummyBestSellers() {
    final items = List.generate(
      10,
      (index) => ProductDTO(
        id: index,
        name: 'Pink Rose Bouquet ${index + 1}',
        imageUrl: 'https://cdn.flowery-app.com/products/103.jpg',
        currency: 'EGP',
        price: 1500.00,
        originalPrice: 1800.00,
        discountPercentage: 20,
        status: 'InStock',
      ),
    );

    return PaginatedResponse(
      data: items,
      pagination: PaginationModel(
        page: 1,
        pageSize: 10,
        totalCount: 50,
        totalPages: 5,
        hasNextPage: true,
        hasPreviousPage: false,
      ),
    );
  }

  static ProductDetailsDTO getDummyProductDetails(String id) {
    return ProductDetailsDTO(
      id: int.tryParse(id) ?? 0,
      name: '15 Pink Rose Bouquet',
      imageUrl: 'https://cdn.flowery-app.com/products/103.jpg',
      currency: 'EGP',
      price: 1500.00,
      originalPrice: 1800.00,
      discountPercentage: 20,
      status: 'InStock',
      images: [
        'https://cdn.flowery-app.com/products/103_1.jpg',
        'https://cdn.flowery-app.com/products/103_2.jpg',
        'https://cdn.flowery-app.com/products/103_3.jpg',
        'https://cdn.flowery-app.com/products/103_4.jpg',
      ],
      description:
          'Lorem ipsum dolor sit amet consectetur. Id sit morbi ornare morbi duis rhoncus orci massa.',
      includes: [
        IncludeDTO(name: 'Pink roses: 15'),
        IncludeDTO(name: 'White wrap'),
      ],
      categoryId: 'dummy-category-id',
      occasionIds: ['dummy-occasion-id'],
    );
  }
}
