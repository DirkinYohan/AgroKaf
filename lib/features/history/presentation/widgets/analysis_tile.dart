import 'dart:io';

import 'package:flutter/material.dart';

import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/utils/date_formatter.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/result_badge.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';

/// Hero tag shared by the history thumbnail and the detail photo.
String analysisHeroTag(Analysis a) => 'analysis-photo-${a.id}';

/// One row of the history: thumbnail, result badge, date and lot/note.
class AnalysisTile extends StatelessWidget {
  const AnalysisTile({super.key, required this.analysis, required this.onTap});

  static const double _thumbSize = 72;

  final Analysis analysis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String subtitle = <String>[
      analysis.lotName,
      analysis.note,
    ].where((String s) => s.trim().isNotEmpty).join(' · ');

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      semanticLabel:
          '${analysis.status.label}, ${DateFormatter.dateTime(analysis.createdAt)}',
      child: Row(
        children: <Widget>[
          Hero(
            tag: analysisHeroTag(analysis),
            child: ClipRRect(
              borderRadius: AppRadius.mdAll,
              child: Image.file(
                File(analysis.imagePath),
                width: _thumbSize,
                height: _thumbSize,
                fit: BoxFit.cover,
                cacheWidth: (_thumbSize * 3).round(),
                errorBuilder: (_, _, _) => Container(
                  width: _thumbSize,
                  height: _thumbSize,
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ResultBadge(status: analysis.status),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormatter.dateTime(analysis.createdAt),
                  style: textTheme.bodySmall,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
