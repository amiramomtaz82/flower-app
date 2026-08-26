sealed class OccasionsEvent {}

/// [initialOccasionId] is the occasion the user tapped on Home, if any.
class OccasionsStarted extends OccasionsEvent {
  OccasionsStarted({this.initialOccasionId});

  final String? initialOccasionId;
}

class OccasionSelected extends OccasionsEvent {
  OccasionSelected(this.occasionId);

  final String occasionId;
}
