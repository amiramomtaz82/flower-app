import 'package:equatable/equatable.dart';

class GiftRecipientEntity extends Equatable {
  final String name;
  final String phone;

  const GiftRecipientEntity({
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [
    name,
    phone,
  ];
}