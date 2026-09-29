import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

/// Signature matching the top-level launchUrl function from url_launcher
typedef LaunchUrlFn = Future<bool> Function(
    Uri url, {
    LaunchMode mode,
    WebViewConfiguration webViewConfiguration,
    String? webOnlyWindowName,
    });

@lazySingleton
class UrlLauncherService {
  final LaunchUrlFn _launchUrl;

  UrlLauncherService() : _launchUrl = launchUrl;

  UrlLauncherService.withLauncher(this._launchUrl);

  /// Sanitizes phone number and launches WhatsApp chat
  Future<bool> launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    return _safeLaunch(uri, mode: LaunchMode.externalApplication);
  }

  /// Sanitizes phone number and initiates a phone call dialer
  Future<bool> launchPhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    return _safeLaunch(uri);
  }

  /// Generic web/custom URL launcher
  Future<bool> launchUrlString(
      String url, {
        LaunchMode mode = LaunchMode.platformDefault,
      }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return _safeLaunch(uri, mode: mode);
  }

  Future<bool> _safeLaunch(
      Uri uri, {
        LaunchMode mode = LaunchMode.platformDefault,
      }) async {
    try {
      return await _launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }
}