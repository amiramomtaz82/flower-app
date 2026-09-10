// lib/features/Address/presentation/widgets/address_card.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/address_entity.dart';
import 'default_address_badge.dart';

enum AddressCardMode { checkout, management }

class AddressCard extends StatelessWidget {
  final AddressEntity address;
  final AddressCardMode mode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    this.mode = AddressCardMode.checkout,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  static const Color _primaryPink = Color(0xFFD21E6A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = address.isDefault ?? false;
    final title = (address.label?.trim().isNotEmpty ?? false)
        ? address.label!.trim()
        : (address.areaId ?? AppStrings.address.tr());
    final subtitle = address.addressLine ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _primaryPink : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading: Radio in Checkout mode, Location Pin in Management mode
              if (mode == AddressCardMode.checkout)
                Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  activeColor: _primaryPink,
                  onChanged: (_) => onTap?.call(),
                )
              else
                const Icon(
                  Icons.location_on_outlined,
                  size: 22,
                  color: Colors.black87,
                ),
              const SizedBox(width: 12),

              // Address Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDefault && mode == AddressCardMode.checkout) ...[
                          const SizedBox(width: 8),
                          const DefaultAddressBadge(),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Actions
              if (mode == AddressCardMode.management) ...[
                if (onDelete != null)
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.black87,
                      size: 20,
                    ),
                    onPressed: onEdit,
                  ),
                ],
              ] else if (mode == AddressCardMode.checkout) ...[
                if (onEdit != null)
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.black87,
                      size: 20,
                    ),
                    onPressed: onEdit,
                  ),
                if (!isDefault && onSetDefault != null)
                  TextButton(
                    onPressed: onSetDefault,
                    child: Text(
                      AppStrings.setAsDefault.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}