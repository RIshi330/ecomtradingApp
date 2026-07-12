import 'package:flutter/material.dart';

import '../admin/job_form.dart';
import 'app_text_styles.dart';


class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.filled = false,
    this.valueColor,
    this.width = 160,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool filled;
  final Color? valueColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.primaryContainer : AppColors.surfaceContainerLowest;
    final fg = filled ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant;
    return Container(
      width: width,
      height: 128,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: filled ? null : Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.labelCaps(color: fg)),
              Icon(icon, color: filled ? Colors.white : AppColors.primary, size: 20),
            ],
          ),
          Text(
            value,
            style: AppText.displayLg(
              color: valueColor ?? (filled ? Colors.white : AppColors.primary),
            ).copyWith(fontSize: 32, height: 1.1),
          ),
        ],
      ),
    );
  }
}

/// Small pipeline-stage chip used in the horizontal scroller
/// ("Applied 84", "Screening 22", ...).
class PipelineStatChip extends StatelessWidget {
  const PipelineStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 12, vertical: dense ? 4 : 12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: dense ? AppColors.surfaceContainerLow : Colors.white,
        borderRadius: BorderRadius.circular(dense ? 6 : 8),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: dense
            ? null
            : const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 14 : 20, color: AppColors.primary),
          const SizedBox(width: 8),
          if (dense)
            Text('$label $value',
                style: AppText.labelCaps(color: AppColors.onSurfaceVariant)
                    .copyWith(fontSize: 10))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.labelCaps().copyWith(fontSize: 10)),
                Text(value, style: AppText.titleMd()),
              ],
            ),
        ],
      ),
    );
  }
}

/// Teal "tag pill" used for skills/categories on candidate cards.
class TagPill extends StatelessWidget {
  const TagPill(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.containerTeal,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppText.labelCaps(color: AppColors.secondary).copyWith(fontSize: 10),
      ),
    );
  }
}

/// Status pill e.g. "ACTIVE" / "DRAFT" used on job posting cards.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.containerTeal : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.primary : AppColors.outline,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
