// lib/features/Address/presentation/widgets/address_card.dart
import 'package:flutter/material.dart';

import '../../../domain/entities/address_entity.dart';
import 'default_address_badge.dart';

class AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback onSetDefault;
  final VoidCallback onTap;

  const AddressCard({
    super.key,
    required this.address,
    required this.onSetDefault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = address.isDefault ?? false;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Row(
          children: [
            Text(address.label ?? 'Address'),
            const SizedBox(width: 8),
            if (isDefault) const DefaultAddressBadge(),
          ],
        ),
        subtitle: Text(address.addressLine ?? ''),
        trailing: isDefault
            ? null
            : TextButton(
          onPressed: onSetDefault,
          child: const Text('Set as default'),
        ),
      ),
    );
  }
}