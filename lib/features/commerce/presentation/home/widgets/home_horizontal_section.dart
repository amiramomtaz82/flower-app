import 'package:flutter/material.dart';

import 'section_header.dart';

class HomeHorizontalSection extends StatelessWidget {
  const HomeHorizontalSection({
    super.key,
    required this.title,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.isLoading = false,
    this.errorMessage,
    this.onViewAll,
  });

  final String title;
  final double height;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onViewAll: onViewAll),
        const SizedBox(height: 12),
        SizedBox(height: height, child: _buildBody(context)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    if (itemCount == 0) {
      return Center(
        child: Text(
          'Nothing here yet',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: itemBuilder,
    );
  }
}
