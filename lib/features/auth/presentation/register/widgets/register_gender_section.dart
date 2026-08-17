import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/widgets/gender_option_widget.dart';
import 'package:flower_app/features/auth/domain/entities/gender.dart';
import 'package:flutter/material.dart';

class RegisterGenderSection extends StatelessWidget {
  final Gender selectedGender;
  final ValueChanged<Gender> onChanged;

  const RegisterGenderSection({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          'gender'.tr(),
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 24),
        GenderOptionWidget(
          label: 'female'.tr(),
          selected: selectedGender == Gender.female,
          onTap: () => onChanged(Gender.female),
          color: colorScheme.primary,
        ),
        const SizedBox(width: 16),
        GenderOptionWidget(
          label: 'male'.tr(),
          selected: selectedGender == Gender.male,
          onTap: () => onChanged(Gender.male),
          color: colorScheme.primary,
        ),
      ],
    );
  }
}
