// ─── Water Parameter Definition ───────────────────────────────────────────────
class WaterParameter {
  final String key;
  final String label;
  final String unit;
  final String description;
  final double safeMin;
  final double safeMax;
  final double inputMin;
  final double inputMax;
  final double weight;

  const WaterParameter({
    required this.key,
    required this.label,
    required this.unit,
    required this.description,
    required this.safeMin,
    required this.safeMax,
    required this.inputMin,
    required this.inputMax,
    this.weight = 1.0,
  });
}

// ─── All 9 parameters ────────────────────────────────────────────────────────
const List<WaterParameter> kWaterParameters = [
  WaterParameter(
    key: 'ph',
    label: 'pH Level',
    unit: 'pH',
    description: 'Acidity or alkalinity of water. WHO safe range: 6.5 – 8.5.',
    safeMin: 6.5, safeMax: 8.5, inputMin: 0.0, inputMax: 14.0, weight: 1.5,
  ),
  WaterParameter(
    key: 'Hardness',
    label: 'Hardness',
    unit: 'mg/L',
    description: 'Calcium & magnesium concentration. Acceptable below 300 mg/L.',
    safeMin: 0, safeMax: 300, inputMin: 0, inputMax: 600, weight: 1.0,
  ),
  WaterParameter(
    key: 'Solids',
    label: 'Total Dissolved Solids',
    unit: 'ppm',
    description: 'Total dissolved substances. Safe below 500 ppm.',
    safeMin: 0, safeMax: 500, inputMin: 0, inputMax: 50000, weight: 1.2,
  ),
  WaterParameter(
    key: 'Chloramines',
    label: 'Chloramines',
    unit: 'ppm',
    description: 'Disinfectant used in treatment. Safe up to 4 ppm (EPA).',
    safeMin: 0, safeMax: 4, inputMin: 0, inputMax: 12, weight: 1.3,
  ),
  WaterParameter(
    key: 'Sulfate',
    label: 'Sulfate',
    unit: 'mg/L',
    description: 'Naturally occurring mineral. WHO guideline: below 250 mg/L.',
    safeMin: 0, safeMax: 250, inputMin: 0, inputMax: 500, weight: 1.0,
  ),
  WaterParameter(
    key: 'Conductivity',
    label: 'Conductivity',
    unit: 'μS/cm',
    description: 'Ability to pass electrical current. Safe below 400 μS/cm.',
    safeMin: 0, safeMax: 400, inputMin: 0, inputMax: 800, weight: 0.9,
  ),
  WaterParameter(
    key: 'Organic_carbon',
    label: 'Organic Carbon',
    unit: 'ppm',
    description: 'Total organic carbon measure. EPA recommends below 2 ppm.',
    safeMin: 0, safeMax: 2, inputMin: 0, inputMax: 30, weight: 1.1,
  ),
  WaterParameter(
    key: 'Trihalomethanes',
    label: 'Trihalomethanes',
    unit: 'μg/L',
    description: 'By-products of water chlorination. Safe below 80 μg/L.',
    safeMin: 0, safeMax: 80, inputMin: 0, inputMax: 120, weight: 1.4,
  ),
  WaterParameter(
    key: 'Turbidity',
    label: 'Turbidity',
    unit: 'NTU',
    description: 'Cloudiness or haziness of water. WHO guideline: below 4 NTU.',
    safeMin: 0, safeMax: 4, inputMin: 0, inputMax: 10, weight: 1.2,
  ),
];

// ─── Test Result Model ──────────────────────────────────────────────────────
class WaterTestResult {
  final DateTime testedAt;
  final Map<String, double> values;
  final double safetyScore;
  final WaterSafetyLevel safetyLevel;
  final List<ParameterResult> parameterResults;
  final String recommendation;
  final String? mlPrediction;
  final double? mlConfidence;
  final String userId;

  WaterTestResult({
    required this.testedAt,
    required this.values,
    required this.safetyScore,
    required this.safetyLevel,
    required this.parameterResults,
    required this.recommendation,
    this.mlPrediction,
    this.mlConfidence,
    this.userId = 'anonymous',
  });
}

class ParameterResult {
  final WaterParameter parameter;
  final double value;
  final double score;
  final ParameterStatus status;

  ParameterResult({
    required this.parameter,
    required this.value,
    required this.score,
    required this.status,
  });
}

enum WaterSafetyLevel { safe, moderate, unsafe }
enum ParameterStatus { safe, warning, danger }
