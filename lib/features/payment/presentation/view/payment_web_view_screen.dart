import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../config/di/di.dart';
import '../../../../core/app_constants/app_strings.dart';

import '../../../../core/go_routes/routes_name.dart';

import '../manager/payements_cubit.dart';
import '../manager/payment_events.dart';
import '../manager/payment_states.dart';


class PaymentWebViewScreen extends StatelessWidget {
  final String sessionUrl;
  final String successUrl;
  final String cancelUrl;
  final String orderId;

  const PaymentWebViewScreen({
    super.key,
    required this.sessionUrl,
    required this.successUrl,
    required this.cancelUrl,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentCubit>(),
      child: _PaymentWebViewContent(
        sessionUrl: sessionUrl,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        orderId: orderId,
      ),
    );
  }
}

class _PaymentWebViewContent extends StatefulWidget {
  final String sessionUrl;
  final String successUrl;
  final String cancelUrl;
  final String orderId;

  const _PaymentWebViewContent({
    required this.sessionUrl,
    required this.successUrl,
    required this.cancelUrl,
    required this.orderId,
  });

  @override
  State<_PaymentWebViewContent> createState() => _PaymentWebViewContentState();
}

class _PaymentWebViewContentState extends State<_PaymentWebViewContent> {
  late final WebViewController _controller;
  double _progress = 0.0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress / 100.0);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_interceptUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) _interceptUrl(change.url!);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.sessionUrl));
  }

  bool _interceptUrl(String url) {
    if (_isNavigating) return true;

    final isSuccess = (widget.successUrl.isNotEmpty && url.startsWith(widget.successUrl)) ||
        url.contains('status=success') ||
        url.contains('status=paid');

    final isCancel = (widget.cancelUrl.isNotEmpty && url.startsWith(widget.cancelUrl)) ||
        url.contains('status=cancel') ||
        url.contains('status=failed');

    if (isSuccess || isCancel) {
      _isNavigating = true;
      // Dispatches verification event to Cubit to poll server status!
      context.read<PaymentCubit>().doEvents(StartPaymentVerificationEvent(widget.orderId));
      return true;
    }

    return false;
  }

  void _showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Payment Incomplete'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
            },
            child: const Text('Cancel Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<PaymentCubit>().doEvents(RetryPaymentEvent(widget.orderId));
            },
            child: const Text('Retry Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listenWhen: (prev, curr) =>
      prev.paymentStatusResource != curr.paymentStatusResource ||
          prev.retrySessionResource != curr.retrySessionResource,
      listener: (context, state) {
        // 1. Success Verified by Server
        if (state.paymentStatusResource.isSuccess) {
          context.go(AppRoutes.orderSuccess, extra: widget.orderId);
        }

        // 2. Failed or Timeout
        if (state.paymentStatusResource.isError) {
          _isNavigating = false;
          _showFailureDialog(context, state.paymentStatusResource.errorMessage ?? 'Payment failed.');
        }

        // 3. Retry Session Generated
        if (state.retrySessionResource.isSuccess) {
          final newSession = state.retrySessionResource.data;
          if (newSession != null) {
            _isNavigating = false;
            _controller.loadRequest(Uri.parse(newSession.sessionUrl));
          }
        }
      },
      builder: (context, state) {
        final isVerifying = state.paymentStatusResource.isLoading || state.retrySessionResource.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.completePayment.tr()),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (isVerifying)
                Container(
                  color: Colors.white.withOpacity(0.94),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          state.verificationMessage ?? 'Please wait...',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}