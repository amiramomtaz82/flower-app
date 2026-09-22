import 'package:flutter/material.dart';

class OrderTrackingView extends StatefulWidget {
  final String orderId;

  const OrderTrackingView({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
