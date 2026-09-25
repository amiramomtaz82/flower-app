import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/order_tracking_entity.dart';
import '../../../domain/entities/timeline_milestone_entity.dart';
import '../../../domain/entities/tracking_steps_status.dart';

class TrackingTimelineWidget extends StatelessWidget {
  final List<TimelineMilestoneEntity> milestones;
  final TrackingStepStatus currentStatus;

  const TrackingTimelineWidget({
    super.key,
    required this.milestones,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final primary = colors?.primary ?? colorScheme.primary;
    final inactiveBorder = colors?.surface ?? colorScheme.outlineVariant;
    final inactiveText = colors?.hint ?? colorScheme.outline;

    final currentStep = currentStatus.timelineIndex;

    return Column(
      children: List.generate(milestones.length, (index) {
        final isPassed = index <= currentStep;
        final isLast = index == milestones.length - 1;
        final milestone = milestones[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPassed ? primary : inactiveBorder,
                      width: 2.5,
                    ),
                    color: isPassed ? primary : (colors?.white ?? colorScheme.surface),
                  ),
                  child: isPassed
                      ? Center(
                    child: Icon(
                      Icons.check,
                      size: 11,
                      color: colors?.white ?? colorScheme.surface,
                    ),
                  )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 44,
                    color: isPassed && index < currentStep
                        ? primary
                        : inactiveBorder,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title.tr(),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isPassed ? FontWeight.bold : FontWeight.w500,
                        color: isPassed
                            ? (colors?.textPrimary ?? colorScheme.onSurface)
                            : inactiveText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      milestone.timestamp,
                      style: textTheme.bodySmall?.copyWith(
                        color: isPassed
                            ? (colors?.secondary ?? colorScheme.onSurfaceVariant)
                            : inactiveText,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}