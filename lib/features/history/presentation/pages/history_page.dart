import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/theme/app_colors.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/core/widgets/fade_slide_in.dart';
import 'package:agrokaf/core/widgets/state_views.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';
import 'package:agrokaf/features/history/domain/history_filter.dart';
import 'package:agrokaf/features/history/presentation/widgets/analysis_tile.dart';

/// "Historial" tab: saved analyses with filters, search and delete-all.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  static const String title = 'Historial';
  static const String emptyTitle = 'Aún no hay análisis';

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  static const String _emptyMessage =
      'Cuando analices una hoja de café y la guardes, aparecerá aquí.';
  static const String _analyzeLabel = 'Analizar una planta';
  static const String _searchHint = 'Buscar por nota o lote';
  static const String _noResultsTitle = 'Sin resultados';
  static const String _noResultsMessage =
      'Prueba con otro filtro u otra palabra.';
  static const String _loadError = 'No pudimos cargar tu historial.';
  static const String _deleteAllTooltip = 'Borrar todo el historial';

  final TextEditingController _searchController = TextEditingController();
  HistoryFilter _filter = HistoryFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteAll() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.error,
            ),
            title: const Text('¿Borrar todo el historial?'),
            content: const Text(
              'Se borrarán todos los análisis y sus fotos de este celular. '
              'Esta acción no se puede deshacer.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onError,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Borrar todo'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await ref.read(analysisRepositoryProvider).deleteAll();
    ref.invalidate(analysesProvider);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Historial borrado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Analysis>> analyses = ref.watch(analysesProvider);
    final bool hasAny = analyses.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(HistoryPage.title),
        actions: <Widget>[
          if (hasAny)
            IconButton(
              tooltip: _deleteAllTooltip,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _confirmDeleteAll,
            ),
        ],
      ),
      body: analyses.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: _loadError,
          onRetry: () => ref.invalidate(analysesProvider),
        ),
        data: (List<Analysis> all) {
          if (all.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.history_rounded,
                title: HistoryPage.emptyTitle,
                message: _emptyMessage,
                actionLabel: _analyzeLabel,
                onAction: () => context.go(AppRoutes.home),
              ),
            );
          }
          final List<Analysis> visible = filterAnalyses(
            all,
            filter: _filter,
            query: _query,
          );
          return Column(
            children: <Widget>[
              _buildSearchAndFilters(),
              Expanded(
                child: visible.isEmpty
                    ? const Center(
                        child: EmptyState(
                          icon: Icons.search_off_rounded,
                          title: _noResultsTitle,
                          message: _noResultsMessage,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.xl,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, int i) => FadeSlideIn(
                          key: ValueKey<int?>(visible[i].id),
                          index: i,
                          child: AnalysisTile(
                            analysis: visible[i],
                            onTap: () => context.push(
                              AppRoutes.analysisDetailPath(visible[i].id!),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _searchController,
            onChanged: (String v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: _searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final HistoryFilter f in HistoryFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(f.label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
