import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = Theme.of(context).extension<LightColors>()!;
    final pillBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colors.hint, width: 1),
    );

    return SizedBox(
      height: 40,
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.search),
        child: AbsorbPointer(
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: AppStrings.search.tr(),
              prefixIcon: Icon(Icons.search, color: colors.hint),
              border: pillBorder,
              enabledBorder: pillBorder,
              focusedBorder: pillBorder,
            ),
          ),
        ),
      ),
    );
  }
}
