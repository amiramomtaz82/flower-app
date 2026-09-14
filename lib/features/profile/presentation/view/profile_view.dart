import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/profile/presentation/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().doEvent(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileScreenTitle)),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final resource = state.resource;

          if (resource.isLoading || resource.status == ApiStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (resource.status == ApiStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resource.errorMessage ?? AppStrings.somethingWentWrong,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileCubit>().doEvent(LoadProfile());
                      },
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = resource.data;
          if (profile == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileCubit>().doEvent(LoadProfile());
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 4),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colors.surface,
                        backgroundImage: profile.profileImageUrl.isNotEmpty
                            ? (profile.profileImageUrl.startsWith('http')
                                      ? NetworkImage(profile.profileImageUrl)
                                      : FileImage(
                                          File(profile.profileImageUrl),
                                        ))
                                  as ImageProvider
                            : null,
                        child: profile.profileImageUrl.isEmpty
                            ? Icon(Icons.person, size: 40, color: colors.white)
                            : null,
                      ),
                      // const SizedBox(height: 2),
                      Row(
                        /// mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text(profile.name, style: textTheme.titleLarge),
                          // const SizedBox(width: 2),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: colors.darkGrey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              final updated = await context.push<bool>(
                                AppRoutes.editProfile,
                                extra: profile,
                              );
                              if (updated == true && context.mounted) {
                                context.read<ProfileCubit>().doEvent(
                                  LoadProfile(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      //const SizedBox(height: 2),
                      Text(
                        profile.email,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ProfileTile(
                  icon: Icons.receipt_long_outlined,
                  title: AppStrings.myOrders,
                  colors: colors,
                  onTap: () {
                    context.push(AppRoutes.myOrders);
                  },
                ),
                ProfileTile(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.savedAddresses,
                  colors: colors,
                  onTap: () {
                    context.push(AppRoutes.savedAddresses);
                  },
                ),
                const Divider(height: 32),
                ProfileTile(
                  icon: Icons.notifications_none_outlined,
                  title: AppStrings.notification,
                  colors: colors,
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeThumbColor: colors.primary,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                ),
                const Divider(height: 32),
                ProfileTile(
                  icon: Icons.translate,
                  title: AppStrings.language,
                  colors: colors,
                  trailing: Text(
                    'English',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  onTap: () {},
                ),
                ProfileTile(
                  icon: null,
                  title: 'About us',
                  colors: colors,
                  onTap: () {},
                ),
                ProfileTile(
                  icon: null,
                  title: AppStrings.termsAndConditions,
                  colors: colors,
                  onTap: () {},
                ),
                const Divider(height: 32),
                ProfileTile(
                  icon: Icons.logout,
                  title: AppStrings.logout,
                  colors: colors,
                  trailingIcon: Icons.arrow_forward,
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    AppStrings.appVersion,
                    style: textTheme.bodySmall?.copyWith(color: colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
