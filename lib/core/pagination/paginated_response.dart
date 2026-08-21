import 'package:flower_app/core/pagination/pagination_model.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationModel pagination;

  const PaginatedResponse({
    required this.data,
    required this.pagination,
  });
}