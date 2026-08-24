import 'package:flower_app/core/app_constants/app_assets.dart';

import '../../../domain/entities/product_entity.dart';

List<ProductEntity> dummyList = const [
  ProductEntity(
    id: '1',
    name: 'Sunny',
    price: 600,
    currency: 'EGP',
    imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946',
    status: 'inStock',
  ),
  ProductEntity(
    id: '2',
    name: 'Red roses',
    price: 600,
    currency: 'EGP',
    imageUrl: 'https://images.unsplash.com/photo-1518895949257-7621c3c786d7',
    status: 'inStock',
  ),
  ProductEntity(
    id: '3',
    name: 'Spring vase',
    price: 600,
    currency: 'EGP',
    imageUrl: 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9',
    status: 'inStock',
  ),
];


final Map<String, List<ProductEntity>> dummyProductsByCategory = {
  '1': [
    const ProductEntity(
      id: '101',
      name: 'Red Rose Bouquet',
      imageUrl: AppAssets.categoryTulip,
      currency: 'EGP',
      price: 500,
      originalPrice: 600,
      discountPercentage: 17,
      status: 'Available',
      isBestSeller: true,
    ),
    const ProductEntity(
      id: '102',
      name: 'Pink Rose Bouquet',
      imageUrl: AppAssets.categoryTulip,
      currency: 'EGP',
      price: 450,
      originalPrice: 500,
      discountPercentage: 10,
      status: 'Available',
      isBestSeller: false,
    ),
  ],

  '2': [
    const ProductEntity(
      id: '201',
      name: 'Luxury Gift Box',
      imageUrl: AppAssets.categoryGift,
      currency: 'EGP',
      price: 700,
      originalPrice: 800,
      discountPercentage: 12,
      status: 'Available',
      isBestSeller: true,
    ),
    const ProductEntity(
      id: '202',
      name: 'Chocolate Gift',
      imageUrl: AppAssets.categoryGift,
      currency: 'EGP',
      price: 350,
      originalPrice: 400,
      discountPercentage: 12,
      status: 'Available',
      isBestSeller: false,
    ),
  ],

  '3': [
    const ProductEntity(
      id: '301',
      name: 'Birthday Card',
      imageUrl: AppAssets.categoryCard,
      currency: 'EGP',
      price: 150,
      originalPrice: 180,
      discountPercentage: 17,
      status: 'Available',
      isBestSeller: true,
    ),
    const ProductEntity(
      id: '302',
      name: 'Love Card',
      imageUrl: AppAssets.categoryCard,
      currency: 'EGP',
      price: 120,
      originalPrice: 150,
      discountPercentage: 20,
      status: 'Available',
      isBestSeller: false,
    ),
  ],

  '4': [
    const ProductEntity(
      id: '401',
      name: 'Gold Bracelet',
      imageUrl: AppAssets.categoryJewellery,
      currency: 'EGP',
      price: 1200,
      originalPrice: 1400,
      discountPercentage: 14,
      status: 'Available',
      isBestSeller: true,
    ),
    const ProductEntity(
      id: '402',
      name: 'Elegant Necklace',
      imageUrl: AppAssets.categoryJewellery,
      currency: 'EGP',
      price: 1500,
      originalPrice: 1700,
      discountPercentage: 12,
      status: 'Available',
      isBestSeller: false,
    ),
  ],

  '5': [
    const ProductEntity(
      id: '501',
      name: 'Tulip Bouquet',
      imageUrl: AppAssets.categoryTulip,
      currency: 'EGP',
      price: 600,
      originalPrice: 700,
      discountPercentage: 14,
      status: 'Available',
      isBestSeller: true,
    ),
    const ProductEntity(
      id: '502',
      name: 'Mixed Flowers',
      imageUrl: AppAssets.categoryTulip,
      currency: 'EGP',
      price: 550,
      originalPrice: 650,
      discountPercentage: 15,
      status: 'Available',
      isBestSeller: false,
    ),
  ],
};