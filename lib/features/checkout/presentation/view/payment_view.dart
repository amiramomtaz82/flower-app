import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
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
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  double _progress = 0.0;
  bool _isRedirectHandled = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_checkUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              _checkUrl(change.url!);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.sessionUrl));
  }

  bool _checkUrl(String url) {
    if (_isRedirectHandled) return true;

    // 1. Success check: matches successUrl or contains success query param
    final isSuccess = (widget.successUrl.isNotEmpty && url.startsWith(widget.successUrl)) ||
        url.contains('status=success') ||
        url.contains('status=paid') ||
        url.contains('success=true');

    if (isSuccess) {
      _isRedirectHandled = true;
      if (mounted) {
        context.go(AppRoutes.orderSuccess, extra: widget.orderId);
      }
      return true;
    }

    // 2. Cancel/Fail check: matches cancelUrl or contains cancel query param
    final isCancel = (widget.cancelUrl.isNotEmpty && url.startsWith(widget.cancelUrl)) ||
        url.contains('status=cancel') ||
        url.contains('status=failed') ||
        url.contains('cancel=true');

    if (isCancel) {
      _isRedirectHandled = true;
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.paymentFailedOrCancelled.tr()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.completePayment.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
        bottom: _progress < 1.0
            ? PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0CB359)),
          ),
        )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(AppStrings.cancelPaymentTitle.tr()),
        content: Text(AppStrings.cancelPaymentWarning.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(AppStrings.continuePayment.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              AppStrings.cancel.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }
}