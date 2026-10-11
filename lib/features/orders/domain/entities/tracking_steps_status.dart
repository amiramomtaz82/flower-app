enum TrackingStepStatus {
  received,
  preparing,
  pickedUp,
  outForDelivery,
  awaitingDeliveryConfirmation,
  delivered,
  cancelled;

  int get timelineIndex {
    switch (this) {
      case TrackingStepStatus.received:
        return 0;
      case TrackingStepStatus.preparing:
        return 1;
      case TrackingStepStatus.pickedUp:
        return 2;
      case TrackingStepStatus.outForDelivery:
        return 3;
      case TrackingStepStatus.awaitingDeliveryConfirmation:
        return 4;
      case TrackingStepStatus.delivered:
        return 5;
      case TrackingStepStatus.cancelled:
        return 0;
    }
  }
}