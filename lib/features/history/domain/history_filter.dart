import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';

/// Filter chips of the history.
enum HistoryFilter {
  all('Todas', null),
  healthy('Sanas', DiagnosisStatus.healthy),
  phoma('Phoma', DiagnosisStatus.phoma),
  other('Otras', DiagnosisStatus.other),
  inconclusive('No concluyentes', DiagnosisStatus.inconclusive);

  const HistoryFilter(this.label, this.status);

  final String label;
  final DiagnosisStatus? status;
}

/// Applies the status filter and a case/accent-insensitive search over the
/// note and the lot name (pure, unit-testable).
List<Analysis> filterAnalyses(
  List<Analysis> analyses, {
  HistoryFilter filter = HistoryFilter.all,
  String query = '',
}) {
  final String q = normalizeForSearch(query.trim());
  return analyses
      .where((Analysis a) => filter.status == null || a.status == filter.status)
      .where(
        (Analysis a) =>
            q.isEmpty ||
            normalizeForSearch(a.note).contains(q) ||
            normalizeForSearch(a.lotName).contains(q),
      )
      .toList(growable: false);
}

/// Lowercase without Spanish accents, so "cafe" finds "Café".
String normalizeForSearch(String text) {
  const Map<String, String> accents = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  final StringBuffer out = StringBuffer();
  for (final String ch in text.toLowerCase().split('')) {
    out.write(accents[ch] ?? ch);
  }
  return out.toString();
}
