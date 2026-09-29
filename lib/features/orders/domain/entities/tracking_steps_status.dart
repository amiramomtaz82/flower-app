enum TrackingStepStatus {
  received,
  preparing,
  outForDelivery,
  awaitingConfirmation,
  delivered,
  cancelled;
  int get timelineIndex {
    switch (this) {
      case TrackingStepStatus.received:
        return 0;
      case TrackingStepStatus.preparing:
        return 1;
      case TrackingStepStatus.outForDelivery:
      case TrackingStepStatus.awaitingConfirmation:
        return 2;
      case TrackingStepStatus.delivered:
        return 3;
      case TrackingStepStatus.cancelled:
        return 0;
    }
  }
}
