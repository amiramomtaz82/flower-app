import 'package:json_annotation/json_annotation.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';

part 'message_response_model.g.dart';

@JsonSerializable()
class MessageResponseModel {
  final String message;
  final String messageLocalized;

  const MessageResponseModel({
    required this.message,
    required this.messageLocalized,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseModelToJson(this);

  AuthMessageEntity toEntity() =>
      AuthMessageEntity(message: message, messageLocalized: messageLocalized);
}
