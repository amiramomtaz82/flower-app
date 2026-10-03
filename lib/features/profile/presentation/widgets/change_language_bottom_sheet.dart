import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/config/locale/locale_service.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/features/profile/presentation/widgets/language_card.dart';
import 'package:flutter/material.dart';

class ChangeLanguageBottomSheet extends StatefulWidget {
  const ChangeLanguageBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;
    return showModalBottomSheet(
      context: context,
      backgroundColor: colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ChangeLanguageBottomSheet(),
    );
  }

  @override
  State<ChangeLanguageBottomSheet> createState() =>
      _ChangeLanguageBottomSheetState();
}

class _ChangeLanguageBottomSheetState extends State<ChangeLanguageBottomSheet> {
  late String _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = context.locale.languageCode;
  }

  Future<void> _applyLanguage() async {
    if (_selectedLocale != context.locale.languageCode) {
      await context.setLocale(Locale(_selectedLocale));
      getIt<LocaleService>().setLanguageCode(_selectedLocale);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 80,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.darkGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              AppStrings.changeLanguage.tr(),
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Arabic Card
            LanguageCard(
              title: AppStrings.arabic.tr(),
              selected: _selectedLocale == 'ar',
              primaryColor: colors.primary,
              onTap: () => setState(() => _selectedLocale = 'ar'),
            ),
            const SizedBox(height: 12),

            // English Card
            LanguageCard(
              title: AppStrings.english.tr(),
              selected: _selectedLocale == 'en',
              primaryColor: colors.primary,
              onTap: () => setState(() => _selectedLocale = 'en'),
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applyLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  AppStrings.apply.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
