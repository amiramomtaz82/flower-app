import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/driver_entity.dart';

class DriverInfoCard extends StatelessWidget {
  final DriverEntity? driver;

  const DriverInfoCard({
    super.key,
    required this.driver,
  });

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      final launched = await launchUrl(uri);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final primary = colors?.primary ?? colorScheme.primary;

    if (driver == null) {
      final errorColor = colors?.error ?? colorScheme.error;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: errorColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: errorColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                AppStrings.waitingForDriver.tr(),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: errorColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors?.background),


      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 44,
              height: 44,
              color: primary.withOpacity(0.08),
              child: (driver?.photoUrl != null && driver!.photoUrl!.isNotEmpty)
                  ? Image.network(
                driver!.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  AppAssets.deleivery_boy,
                  fit: BoxFit.cover,
                ),
              )
                  : Image.asset(
                AppAssets.deleivery_boy,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver!.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors?.textPrimary ?? colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.deliveryHeroSubtitle.tr(),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors?.secondary ?? colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (driver!.phone.isNotEmpty) ...[
            // WhatsApp Button
            InkWell(
              onTap: () => _openWhatsApp(context, driver!.phone),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),

                child:Image.asset(AppAssets.whatsUp,height:25,width: 25,)
              ),
            ),

            // Phone Call Button
            InkWell(
              onTap: () => _makePhoneCall(context, driver!.phone),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(4),

                child:Image.asset(AppAssets.call,height: 25,width: 25,)
                ),
              ),

          ],
        ],
      ),
    );
  }
}