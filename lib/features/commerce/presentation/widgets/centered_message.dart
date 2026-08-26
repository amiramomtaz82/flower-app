import 'package:flutter/material.dart';

/// Fills the space a list would have taken with a single line of text, shared
/// by the categories page and the occasion page for their empty and error
/// states. A null [text] — an error the API gave no message for — falls back to
/// a generic one.
class CenteredMessage extends StatelessWidget {
  const CenteredMessage({super.key, required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text ?? 'Something went wrong',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
