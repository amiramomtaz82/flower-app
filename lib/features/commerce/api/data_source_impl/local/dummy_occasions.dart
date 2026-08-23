import 'package:flower_app/core/app_constants/app_assets.dart';

import '../../../domain/entities/occasion_entity.dart';

List<OccasionEntity> dummyOccasions = const [
  OccasionEntity(
    id: '1',
    name: 'Wedding',
    imageUrl: AppAssets.occasionWedding,
  ),
  OccasionEntity(
    id: '2',
    name: 'Birthday',
    imageUrl:
        'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3',
  ),
  OccasionEntity(
    id: '3',
    name: 'Graduation',
    imageUrl:
        'https://images.unsplash.com/photo-1523240795612-9a054b0db644',
  ),
];
