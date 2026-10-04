import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String? orderId;

  const OrderSuccessScreen({super.key, this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  String? _resolvedOrderId;

  @override
  void initState() {
    super.initState();
    _resolvedOrderId = widget.orderId;
    if (_resolvedOrderId == null || _resolvedOrderId!.isEmpty) {
      _fetchLatestOrderId();
    }
  }

  Future<void> _fetchLatestOrderId() async {
    try {
      if (getIt.isRegistered<OrderRemoteDataSource>()) {
        final res = await getIt<OrderRemoteDataSource>().getOrders(
          pageNumber: 1,
          pageSize: 1,
        );
        if (res.orders.isNotEmpty && mounted) {
          setState(() {
            _resolvedOrderId = res.orders.first.id;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = LightColors();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Track order'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(AppAssets.success, width: 150, height: 150),
            const SizedBox(height: 30),
            SizedBox(
              height: 100,
              width: 311,
              child: Text(
                "Your order is placed successfully ",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () async {
                  var targetOrderId = _resolvedOrderId;
                  if (targetOrderId == null || targetOrderId.isEmpty) {
                    try {
                      if (getIt.isRegistered<OrderRemoteDataSource>()) {
                        final res = await getIt<OrderRemoteDataSource>().getOrders(
                          pageNumber: 1,
                          pageSize: 1,
                        );
                        if (res.orders.isNotEmpty) {
                          targetOrderId = res.orders.first.id;
                        }
                      }
                    } catch (_) {}
                  }

                  if (context.mounted) {
                    if (targetOrderId != null && targetOrderId.isNotEmpty) {
                      context.go(
                        '${AppRoutes.orderTracking}?orderId=$targetOrderId',
                        extra: targetOrderId,
                      );
                    } else {
                      context.go(AppRoutes.myOrders);
                    }
                  }
                },
                child: const Text(
                  'Track Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}