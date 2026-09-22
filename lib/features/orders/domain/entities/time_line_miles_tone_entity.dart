import 'package:equatable/equatable.dart';

class TimelineMilestoneEntity extends Equatable {
  final String title;
  final String timestamp;
  final bool isCompleted;
  const TimelineMilestoneEntity({
    required this.title,
    required this.timestamp,
    required this.isCompleted,
  });
  @override
  List<Object?> get props => [title, timestamp, isCompleted];
}
