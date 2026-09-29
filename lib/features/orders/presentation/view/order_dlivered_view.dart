import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:flower_app/config/di/di.dart';

import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/network/base_response.dart';

import 'package:flower_app/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:flower_app/features/orders/domain/oredr_details_entity.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_order_by_id_ue_case.dart';


import '../widgets/order_delivered/cost_breakdowen.dart';
import '../widgets/order_delivered/delivered_actions_button.dart';
import '../widgets/order_delivered/delivered_address_card.dart';
import '../widgets/order_delivered/delivered_order_item_card.dart';
import '../widgets/order_delivered/delivered_payement_card.dart';
import '../widgets/order_delivered/delivery_status_header.dart';

class OrderDeliveredView extends StatefulWidget {
  final String orderId;
  final OrderTrackingEntity? trackingData;
  /// Optional: allows widget tests or pre-cached flows to inject data directly
  final OrderDetailsEntity? orderDetails;
  final VoidCallback? onReorder;
  final VoidCallback? onRate;

  const OrderDeliveredView({
    super.key,
    this.orderId = '',
    this.trackingData,
    this.orderDetails,
    this.onReorder,
    this.onRate,
  });

  @override
  State<OrderDeliveredView> createState() => _OrderDeliveredViewState();
}

class _OrderDeliveredViewState extends State<OrderDeliveredView> {
  Future<BaseResponse<OrderDetailsEntity>>? _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    // 🎯 Trigger the API call here if orderDetails wasn't injected
    if (widget.orderDetails == null && widget.orderId.isNotEmpty) {
      _fetchDetails();
    }
  }

  void _fetchDetails() {
    setState(() {
      _orderDetailsFuture = getIt<GetOrderByIdUseCase>()(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final primary = colors?.primary ?? Theme.of(context).colorScheme.primary;

    // 1. If already provided (e.g. in widget tests), render directly
    if (widget.orderDetails != null) {
      return _buildContent(context, widget.orderDetails!);
    }

    if (_orderDetailsFuture == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primary),
        ),
      );
    }

    // 2. Fetch using FutureBuilder
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<BaseResponse<OrderDetailsEntity>>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          // ⏳ A. While loading, show progress indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          // ❌ B. If error occurred or returned null data, show proper error UI with Retry
          final response = snapshot.data;
          if (snapshot.hasError ||
              response == null ||
              response is! SuccessResponse<OrderDetailsEntity>) {
            final errorMessage = response is ErrorResponse<OrderDetailsEntity>
                ? response.errMessage
                : AppStrings.dataNotFound.tr();

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: colors?.secondary ?? Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors?.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchDetails,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppStrings.retry.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          //  C. Order details successfully retrieved
          final details = response.data;
          return _buildContent(context, details);
        },
      ),
    );
  }



  Widget _buildContent(BuildContext context, OrderDetailsEntity details) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colors?.primary ?? colorScheme.primary;
    final successColor = colors?.success ?? const Color(0xff0CB359);
    final cardBorder = (colors?.grey ?? Colors.grey).withValues(alpha: 0.2);
    final cardBg = colors?.white ?? colorScheme.surface;

    final resolvedAddress = details.addressDetail.trim().isNotEmpty
        ? details.addressDetail
        : ((widget.trackingData?.userAddress.addressLine.trim().isNotEmpty ?? false)
        ? widget.trackingData!.userAddress.addressLine
        : AppStrings.notDetermined.tr());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Delivery Status Header
                    DeliveryStatusHeader(
                      userName: details.customerName,
                      successColor: successColor,
                    ),
                    const SizedBox(height: 20),

                    // 2. Delivery Address Card
                    DeliveredAddressCard(
                      title: details.addressTitle,
                      detail: resolvedAddress,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                    ),
                    const SizedBox(height: 12),

                    // 3. Payment Method Card (from OrderDetailsEntity)
                    DeliveredPaymentCard(
                      amount: '${details.currency} ${details.total.toStringAsFixed(0)}',
                      paymentMethod: details.paymentMethod,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                    ),
                    const SizedBox(height: 16),

                    // 4. Order Items Card (List of OrderItemEntity)
                   DeliveredOrderItemsCard(
                      items: details.items,
                      currency: details.currency,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      primary: primary,
                    ),
                    const SizedBox(height: 20),

                    // 5. Cost Breakdown
                    CostBreakdown(
                      subTotal: details.subTotal,
                      deliveryFee: details.deliveryFee,
                      total: details.total,
                      currency: details.currency,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 6. Bottom Action Buttons (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: DeliveredActionsButton(
                primary: primary,
                onReorder: widget.onReorder,
                onRate: widget.onRate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}








