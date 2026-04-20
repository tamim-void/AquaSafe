import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../water_parameter.dart';
import '../app_widgets.dart';

class ResultScreen extends StatelessWidget {
  final WaterTestResult result;

  const ResultScreen({super.key, required this.result});

  Color get _levelColor {
    switch (result.safetyLevel) {
      case WaterSafetyLevel.safe:
        return AppTheme.safeGreen;
      case WaterSafetyLevel.moderate:
        return AppTheme.warnAmber;
      case WaterSafetyLevel.unsafe:
        return AppTheme.dangerRed;
    }
  }

  IconData get _levelIcon {
    switch (result.safetyLevel) {
      case WaterSafetyLevel.safe:
        return Icons.check_circle_outline;
      case WaterSafetyLevel.moderate:
        return Icons.warning_amber_outlined;
      case WaterSafetyLevel.unsafe:
        return Icons.dangerous_outlined;
    }
  }

  String get _levelTitle {
    switch (result.safetyLevel) {
      case WaterSafetyLevel.safe:
        return 'Water is Safe to Drink';
      case WaterSafetyLevel.moderate:
        return 'Moderate Risk Detected';
      case WaterSafetyLevel.unsafe:
        return 'Water is NOT Safe';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYSIS RESULT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ML Prediction Card (if available) ─────────────────────────
            if (result.mlPrediction != null) _buildMlPredictionCard(),
            if (result.mlPrediction != null) const SizedBox(height: 16),

            // ── Score Card ────────────────────────────────────────────────
            _buildScoreCard(),
            const SizedBox(height: 20),

            // ── Verdict Banner ────────────────────────────────────────────
            _buildVerdictBanner(),
            const SizedBox(height: 24),

            // ── Parameter Breakdown ───────────────────────────────────────
            const SectionHeader(
              title: 'PARAMETER BREAKDOWN',
              subtitle: 'Individual safety score per parameter',
            ),
            ...result.parameterResults
                .map((r) => ParameterResultBar(result: r)),
            const SizedBox(height: 24),

            // ── Recommendation ────────────────────────────────────────────
            _buildRecommendation(),
            const SizedBox(height: 20),

            // ── Back Button ───────────────────────────────────────────────
            GlowButton(
              label: 'RUN ANOTHER TEST',
              icon: Icons.science_outlined,
              color: AppTheme.electricBlue,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMlPredictionCard() {
    final bool isPotable = result.mlPrediction == 'Potable';
    final Color mlColor = isPotable ? AppTheme.safeGreen : AppTheme.dangerRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.skyBlue.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined,
                  color: AppTheme.skyBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'ML MODEL PREDICTION',
                style: GoogleFonts.outfit(
                  color: AppTheme.skyBlue,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            result.mlPrediction!,
            style: GoogleFonts.outfit(
              color: mlColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (result.mlConfidence != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: mlColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: mlColor.withOpacity(0.3)),
              ),
              child: Text(
                'Confidence: ${(result.mlConfidence! * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.outfit(
                  color: mlColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _levelColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _levelColor.withOpacity(0.06),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'SAFETY SCORE',
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          SafetyScoreRing(
            score: result.safetyScore,
            level: result.safetyLevel,
            size: 190,
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (_) {
              final safe = result.parameterResults
                  .where((r) => r.status == ParameterStatus.safe)
                  .length;
              final warn = result.parameterResults
                  .where((r) => r.status == ParameterStatus.warning)
                  .length;
              final danger = result.parameterResults
                  .where((r) => r.status == ParameterStatus.danger)
                  .length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(
                      value: '$safe',
                      label: 'SAFE',
                      color: AppTheme.safeGreen),
                  _MiniStat(
                      value: '$warn',
                      label: 'WARNING',
                      color: AppTheme.warnAmber),
                  _MiniStat(
                      value: '$danger',
                      label: 'DANGER',
                      color: AppTheme.dangerRed),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _levelColor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(_levelIcon, color: _levelColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _levelTitle,
              style: GoogleFonts.outfit(
                color: _levelColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: AppTheme.electricBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'RECOMMENDATION',
                style: GoogleFonts.outfit(
                  color: AppTheme.electricBlue,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.recommendation,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: AppTheme.textMuted,
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
