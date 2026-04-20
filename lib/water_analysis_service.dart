import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'water_parameter.dart';
import 'app_config.dart';

class WaterAnalysisService {
  static const String _historyKey = 'water_test_history';

  // ── Call Flask ML API ─────────────────────────────────────────────────────
  /// Sends the 9 water parameters to the live Render Flask endpoint.
  /// The Flask app expects a flat JSON body with the exact parameter keys.
  /// Returns null if the API is unreachable — local scoring is used instead.
  static Future<Map<String, dynamic>?> predictFromApi(
      Map<String, double> values) async {
    try {
      // Build the request body — Flask model expects these exact key names
      final Map<String, dynamic> body = {
        'ph':               values['ph'],
        'Hardness':         values['Hardness'],
        'Solids':           values['Solids'],
        'Chloramines':      values['Chloramines'],
        'Sulfate':          values['Sulfate'],
        'Conductivity':     values['Conductivity'],
        'Organic_carbon':   values['Organic_carbon'],
        'Trihalomethanes':  values['Trihalomethanes'],
        'Turbidity':        values['Turbidity'],
      };

      final response = await http
          .post(
            Uri.parse(AppConfig.mlApiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20)); // Render cold-starts can be slow

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // ── Parse exact Flask response shape ──────────────────────────────
        // Flask returns:
        // {
        //   "status": "success",
        //   "result": "Potable" | "Not Potable",
        //   "message": "The water is safe to drink."
        // }

        final status = data['status'] as String?;
        if (status != 'success') {
          // ignore: avoid_print
          print('[AquaSafe] ML API error: ${data['message']}');
          return null;
        }

        final String? prediction = data['result'] as String?;
        if (prediction == null) {
          // ignore: avoid_print
          print('[AquaSafe] ML API missing result field: ${response.body}');
          return null;
        }

        return {
          'prediction': prediction,   // "Potable" or "Not Potable"
          'confidence': null,         // Flask model doesn't return confidence
          'message': data['message'], // e.g. "The water is safe to drink."
        };
      }

      // ignore: avoid_print
      print('[AquaSafe] ML API returned status ${response.statusCode}: ${response.body}');
      return null;
    } on Exception catch (e) {
      // API unreachable (cold start timeout, network error, etc.)
      // Falls back to local scoring silently.
      // ignore: avoid_print
      print('[AquaSafe] ML API unreachable: $e');
      return null;
    }
  }

  // ── Score a single parameter (0–100) ─────────────────────────────────────
  static double scoreParameter(WaterParameter param, double value) {
    if (param.key == 'ph') {
      if (value >= param.safeMin && value <= param.safeMax) return 100;
      final double deviation = value < param.safeMin
          ? param.safeMin - value
          : value - param.safeMax;
      return (100 - deviation * 40).clamp(0, 100);
    }

    if (param.safeMin == 0) {
      if (value <= param.safeMax) return 100;
      final double excess = (value - param.safeMax) / param.safeMax;
      return (100 - excess * 120).clamp(0, 100);
    }

    if (value >= param.safeMin && value <= param.safeMax) return 100;
    if (value < param.safeMin) {
      final double deficit =
          (param.safeMin - value) / (param.safeMax - param.safeMin);
      return (100 - deficit * 100).clamp(0, 100);
    }
    final double excess =
        (value - param.safeMax) / (param.safeMax - param.safeMin);
    return (100 - excess * 100).clamp(0, 100);
  }

  static ParameterStatus statusFromScore(double score) {
    if (score >= 75) return ParameterStatus.safe;
    if (score >= 40) return ParameterStatus.warning;
    return ParameterStatus.danger;
  }

  // ── Full analysis (local scoring + ML prediction) ─────────────────────────
  static Future<WaterTestResult> analyse(
    Map<String, double> values, {
    String userId = 'anonymous',
  }) async {
    // 1) Call Flask ML API in parallel with local scoring
    final mlFuture = predictFromApi(values);

    // 2) Local parameter scoring
    final List<ParameterResult> results = [];
    double weightedSum = 0;
    double totalWeight = 0;

    for (final param in kWaterParameters) {
      final double? v = values[param.key];
      if (v == null) continue;

      final double score = scoreParameter(param, v);
      final ParameterStatus status = statusFromScore(score);

      results.add(ParameterResult(
        parameter: param,
        value: v,
        score: score,
        status: status,
      ));

      weightedSum += score * param.weight;
      totalWeight += param.weight;
    }

    final double safetyScore =
        totalWeight > 0 ? (weightedSum / totalWeight).clamp(0, 100) : 0;

    WaterSafetyLevel level;
    String recommendation;

    if (safetyScore >= 75) {
      level = WaterSafetyLevel.safe;
      recommendation =
          'Water meets safety standards and is suitable for drinking. '
          'Maintain current treatment protocols and conduct periodic testing.';
    } else if (safetyScore >= 45) {
      level = WaterSafetyLevel.moderate;
      recommendation =
          'Water quality is borderline. Additional treatment or filtration is '
          'recommended before consumption. Address parameters in warning/danger zones.';
    } else {
      level = WaterSafetyLevel.unsafe;
      recommendation =
          'Water is NOT safe for drinking. Immediate remediation required. '
          'Do not consume. Contact your local water authority.';
    }

    // 3) Await ML result (already running in parallel)
    final mlResult = await mlFuture;

    // If ML API returned a message, append it to the recommendation
    final String? mlMessage = mlResult?['message'] as String?;
    final String finalRecommendation = mlMessage != null
        ? '$recommendation\n\nML Model: $mlMessage'
        : recommendation;

    return WaterTestResult(
      testedAt: DateTime.now(),
      values: values,
      safetyScore: safetyScore,
      safetyLevel: level,
      parameterResults: results,
      recommendation: finalRecommendation,
      mlPrediction: mlResult?['prediction'] as String?,
      mlConfidence: null, // Flask model does not return confidence score
      userId: userId,
    );
  }

  // ── Save result ───────────────────────────────────────────────────────────
  static Future<void> saveResult(WaterTestResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_historyKey) ?? [];
    final Map<String, dynamic> data = {
      'testedAt': result.testedAt.toIso8601String(),
      'values': result.values,
      'safetyScore': result.safetyScore,
      'safetyLevel': result.safetyLevel.index,
      'mlPrediction': result.mlPrediction,
      'mlConfidence': result.mlConfidence,
      'userId': result.userId,
    };
    existing.add(jsonEncode(data));
    if (existing.length > 100) existing.removeAt(0);
    await prefs.setStringList(_historyKey, existing);
  }

  // ── Load all history ──────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_historyKey) ?? [];
    return raw
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

  // ── Clear ALL history ─────────────────────────────────────────────────────
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Clear history for a specific user only ────────────────────────────────
  static Future<void> clearHistoryForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_historyKey) ?? [];
    final kept = raw.where((s) {
      try {
        final d = jsonDecode(s) as Map<String, dynamic>;
        return (d['userId'] as String?) != userId;
      } catch (_) {
        return true;
      }
    }).toList();
    await prefs.setStringList(_historyKey, kept);
  }
}
