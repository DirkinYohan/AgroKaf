import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/app_card.dart';
import 'package:agrokaf/core/widgets/fade_slide_in.dart';
import 'package:agrokaf/core/widgets/state_views.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';
import 'package:agrokaf/features/analysis/presentation/analysis_launcher.dart';
import 'package:agrokaf/features/analysis/presentation/pages/analysis_preview_page.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:agrokaf/features/history/presentation/widgets/analysis_tile.dart';
import 'package:agrokaf/features/home/presentation/widgets/analyze_card.dart';
import 'package:agrokaf/features/home/presentation/widgets/home_header.dart';
import 'package:agrokaf/features/home/presentation/widgets/home_sections.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/presentation/providers/profile_providers.dart';

/// "Inicio" tab: greeting, the main analyze action, stats, recent analyses
/// and photo tips.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const String _statsTitle = 'Tu resumen';
  static const String _recentTitle = 'Análisis recientes';
  static const String _seeAll = 'Ver todo';
  static const String _emptyTitle = 'Aún no hay análisis';
  static const String _emptyMessage = 'Tus últimos resultados aparecerán aquí.';
  static const int _recentCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserProfile? profile = ref.watch(profileProvider).value;
    final AnalysisStats stats = ref.watch(analysisStatsProvider);
    final List<Analysis> recent =
        (ref.watch(analysesProvider).value ?? const <Analysis>[])
            .take(_recentCount)
            .toList(growable: false);
    final ModelStatus? modelStatus = ref.watch(modelStatusProvider).value;
    final bool modelProblem =
        modelStatus == ModelStatus.unavailable ||
        modelStatus == ModelStatus.incompatible;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: <Widget>[
            HomeHeader(
              name: profile?.userName,
              imagePath: profile?.profileImagePath,
              onAvatarTap: () => context.go(AppRoutes.profile),
              onSettingsTap: () => context.push(AppRoutes.settings),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              child: AnalyzeCard(
                onCamera: () => startAnalysis(context, ref, ImageSource.camera),
                onGallery: () =>
                    startAnalysis(context, ref, ImageSource.gallery),
              ),
            ),
            if (modelProblem) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              ModelUnavailableBanner(status: modelStatus!),
            ],
            const SizedBox(height: AppSpacing.lg),
            const SectionTitle(title: _statsTitle),
            const SizedBox(height: AppSpacing.sm),
            StatsRow(
              total: stats.total,
              healthy: stats.healthy,
              phoma: stats.phoma,
              other: stats.other,
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionTitle(
              title: _recentTitle,
              actionLabel: recent.isEmpty ? null : _seeAll,
              onAction: () => context.go(AppRoutes.history),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (recent.isEmpty)
              const AppCard(
                child: EmptyState(
                  icon: Icons.eco_outlined,
                  title: _emptyTitle,
                  message: _emptyMessage,
                  compact: true,
                ),
              )
            else
              for (final Analysis a in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AnalysisTile(
                    analysis: a,
                    onTap: () =>
                        context.push(AppRoutes.analysisDetailPath(a.id!)),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
            const FadeSlideIn(index: 2, child: PhotoTipsCard()),
          ],
        ),
      ),
    );
  }
}
