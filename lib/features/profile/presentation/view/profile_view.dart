import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flower_app/core/app_constants/app_urls.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/profile/presentation/widgets/change_language_bottom_sheet.dart';
import 'package:flower_app/features/profile/presentation/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
      appBar: AppBar(title: Text(AppStrings.profileScreenTitle.tr())),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.logoutResource != current.logoutResource,
        listener: (context, state) {
          if (state.logoutResource.isSuccess) {
            context.go(AppRoutes.login);
          } else if (state.logoutResource.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.logoutResource.errorMessage ??
                      AppStrings.somethingWentWrong.tr(),
                ),
              ),
            );
          }
        },
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
                  title: AppStrings.myOrders.tr(),
                  colors: colors,
                  onTap: () {},
                ),
                ProfileTile(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.savedAddresses.tr(),
                  colors: colors,
                  onTap: () {},
                ),
                const Divider(height: 32),
                ProfileTile(
                  icon: Icons.notifications_none_outlined,
                  title: AppStrings.notification.tr(),
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
                  title: AppStrings.language.tr(),
                  colors: colors,
                  trailing: Text(
                    context.locale.languageCode == 'ar'
                        ? AppStrings.arabic.tr()
                        : AppStrings.english.tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  onTap: () => ChangeLanguageBottomSheet.show(context),
                ),
                ProfileTile(
                  icon: null,
                  title: AppStrings.aboutUs.tr(),
                  colors: colors,
                  onTap: () => _launchWebUrl(AppUrls.aboutUs),
                ),
                ProfileTile(
                  icon: null,
                  title: AppStrings.termsAndConditions.tr(),
                  colors: colors,
                  onTap: () => _launchWebUrl(AppUrls.termsAndConditions),
                ),
                const Divider(height: 32),
                ProfileTile(
                  icon: Icons.logout,
                  title: AppStrings.logout.tr(),
                  colors: colors,
                  trailingIcon: Icons.arrow_forward,
                  onTap: () => _showLogoutConfirmationDialog(context),
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.uppercaseLogout.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.confirmLogout.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D1B20),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: const BorderSide(color: Color(0xFF535353)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        AppStrings.cancel.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF535353),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<ProfileCubit>().doEvent(LogoutEvent());
                      },
                      child: Text(
                        AppStrings.logout.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchWebUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot launch: $urlString (No browser found)'),
            ),
          );
        }
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $urlString')),
        );
      }
    } catch (e) {
      debugPrint('🚨 launchUrl error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
