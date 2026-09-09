import 'package:json_annotation/json_annotation.dart';

part 'update_cart_item_request.g.dart';

@JsonSerializable()
class UpdateCartItemRequest {
  final int quantity;

  const UpdateCartItemRequest({required this.quantity});

  factory UpdateCartItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCartItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCartItemRequestToJson(this);
}
