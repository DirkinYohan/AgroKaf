import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/features/analysis/data/analysis_repository.dart';
import 'package:agrokaf/features/analysis/data/classifier_service.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';

/// Single classifier for the whole app (interpreter created once).
final Provider<ClassifierService> classifierServiceProvider =
    Provider<ClassifierService>((Ref ref) {
      final ClassifierService service = ClassifierService();
      ref.onDispose(service.dispose);
      return service;
    });

/// Completes when the model finished loading (successfully or not).
/// Started from the splash screen; never throws.
final FutureProvider<ModelStatus> modelStatusProvider =
    FutureProvider<ModelStatus>((Ref ref) async {
      final ClassifierService service = ref.watch(classifierServiceProvider);
      await service.load();
      return service.status;
    });

final Provider<AnalysisRepository> analysisRepositoryProvider =
    Provider<AnalysisRepository>(
      (Ref ref) => AnalysisRepository(
        ref.watch(databaseServiceProvider),
        ref.watch(imageServiceProvider),
      ),
    );

/// Whole history, newest first. Invalidate after saving or deleting.
final FutureProvider<List<Analysis>> analysesProvider =
    FutureProvider<List<Analysis>>(
      (Ref ref) => ref.watch(analysisRepositoryProvider).getAll(),
    );

/// Counters for Inicio, derived from the history.
final Provider<AnalysisStats> analysisStatsProvider = Provider<AnalysisStats>((
  Ref ref,
) {
  final List<Analysis> all =
      ref.watch(analysesProvider).value ?? const <Analysis>[];
  return AnalysisStats.of(all);
});
