import 'package:flutter/material.dart';

class PaginationFooter extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasNextPage;
  final String? loadMoreError;
  final VoidCallback? onRetry;

  const PaginationFooter({
    super.key,
    required this.isLoadingMore,
    required this.hasNextPage,
    this.loadMoreError,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(loadMoreError!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!hasNextPage) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('No more items'),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}