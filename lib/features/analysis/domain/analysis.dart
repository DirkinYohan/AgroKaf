import 'package:agrokaf/core/models/diagnosis_status.dart';

/// One saved analysis of the history.
class Analysis {
  const Analysis({
    this.id,
    required this.imagePath,
    required this.status,
    required this.healthyProbability,
    required this.phomaProbability,
    this.otherProbability,
    required this.confidence,
    required this.inferenceMs,
    required this.createdAt,
    this.modelVersion,
    this.note = '',
    this.lotName = '',
  });

  final int? id;
  final String imagePath;
  final DiagnosisStatus status;
  final double healthyProbability;
  final double phomaProbability;

  /// Null for analyses made with the 2-class model (v1), which had no
  /// "other" class.
  final double? otherProbability;
  final double confidence;
  final int inferenceMs;
  final DateTime createdAt;
  final String? modelVersion;
  final String note;
  final String lotName;

  static const int noteMaxLength = 200;
  static const int lotMaxLength = 60;

  Map<String, Object?> toRow() => <String, Object?>{
    if (id != null) 'id': id,
    'image_path': imagePath,
    'status': status.name,
    'healthy_prob': healthyProbability,
    'phoma_prob': phomaProbability,
    'other_prob': otherProbability,
    'confidence': confidence,
    'inference_ms': inferenceMs,
    'model_version': modelVersion,
    'note': note.trim().isEmpty ? null : note.trim(),
    'lot_name': lotName.trim().isEmpty ? null : lotName.trim(),
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  factory Analysis.fromRow(Map<String, Object?> row) => Analysis(
    id: row['id'] as int?,
    imagePath: row['image_path']! as String,
    status: DiagnosisStatus.values.firstWhere(
      (DiagnosisStatus s) => s.name == row['status'],
      orElse: () => DiagnosisStatus.inconclusive,
    ),
    healthyProbability: (row['healthy_prob']! as num).toDouble(),
    phomaProbability: (row['phoma_prob']! as num).toDouble(),
    otherProbability: (row['other_prob'] as num?)?.toDouble(),
    confidence: (row['confidence']! as num).toDouble(),
    inferenceMs: row['inference_ms']! as int,
    modelVersion: row['model_version'] as String?,
    note: (row['note'] as String?) ?? '',
    lotName: (row['lot_name'] as String?) ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
  );
}

/// Counters shown on Inicio.
class AnalysisStats {
  const AnalysisStats({
    this.total = 0,
    this.healthy = 0,
    this.phoma = 0,
    this.other = 0,
    this.inconclusive = 0,
  });

  final int total;
  final int healthy;
  final int phoma;
  final int other;
  final int inconclusive;

  factory AnalysisStats.of(List<Analysis> analyses) {
    int count(DiagnosisStatus s) =>
        analyses.where((Analysis a) => a.status == s).length;
    return AnalysisStats(
      total: analyses.length,
      healthy: count(DiagnosisStatus.healthy),
      phoma: count(DiagnosisStatus.phoma),
      other: count(DiagnosisStatus.other),
      inconclusive: count(DiagnosisStatus.inconclusive),
    );
  }
}
