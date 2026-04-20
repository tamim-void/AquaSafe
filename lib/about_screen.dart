import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../water_parameter.dart';
import '../app_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ABOUT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBanner(),
            const SizedBox(height: 28),
            const SectionHeader(title: 'ABOUT AQUASAFE'),
            _buildInfoCard(
              content:
                  'AquaSafe is an intelligent water quality monitoring application '
                  'that analyses 9 key physico-chemical parameters to predict '
                  'whether water is potable using a Machine Learning model. '
                  'The scoring algorithm is based on WHO and EPA guidelines, '
                  'with ML predictions powered by a Stacking Classifier (~85% accuracy).',
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'PARAMETERS ANALYSED',
              subtitle: 'Based on the water_potability dataset',
            ),
            ...kWaterParameters.map((p) => _ParameterInfoRow(param: p)),
            const SizedBox(height: 24),
            const SectionHeader(title: 'SCORING METHODOLOGY'),
            _buildScoringCard(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'TECH STACK'),
            _buildTechCard(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'REFERENCE STANDARDS'),
            _buildStandardsCard(),
            const SizedBox(height: 24),
            _buildDisclaimer(),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'AquaSafe v1.0.0\nBuilt with Flutter & Dart',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.electricBlue.withOpacity(0.12),
            AppTheme.lavender.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.electricBlue.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.frostCard,
              border: Border.all(
                  color: AppTheme.electricBlue.withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.water_drop,
                color: AppTheme.electricBlue, size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AQUASAFE',
                  style: GoogleFonts.outfit(
                    color: AppTheme.electricBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Water Quality Monitoring\n& AI Safety Predictions',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Text(
        content,
        style: GoogleFonts.outfit(
          color: AppTheme.textSecondary,
          fontSize: 13,
          height: 1.65,
        ),
      ),
    );
  }

  Widget _buildScoringCard() {
    final levels = [
      {
        'range': '75 – 100',
        'label': 'SAFE',
        'desc': 'Water meets safety standards.',
        'color': AppTheme.safeGreen,
      },
      {
        'range': '45 – 74',
        'label': 'MODERATE',
        'desc': 'Borderline — treatment recommended.',
        'color': AppTheme.warnAmber,
      },
      {
        'range': '0 – 44',
        'label': 'UNSAFE',
        'desc': 'Do not consume — immediate action required.',
        'color': AppTheme.dangerRed,
      },
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Column(
        children: [
          Text(
            'Each parameter is scored 0–100 based on deviation from WHO/EPA '
            'safe ranges, then combined using weighted averages. '
            'ML model provides an additional potability prediction.',
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          ...levels.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (l['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: (l['color'] as Color).withOpacity(0.3)),
                      ),
                      child: Text(
                        l['range'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: l['color'] as Color,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l['label'] as String,
                          style: GoogleFonts.outfit(
                            color: l['color'] as Color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l['desc'] as String,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTechCard() {
    final items = [
      {'key': 'ML Model', 'val': 'Stacking Classifier (Scikit-learn)'},
      {'key': 'Backend API', 'val': 'Flask / FastAPI on Render'},
      {'key': 'Frontend', 'val': 'Flutter & Dart'},
      {'key': 'Storage', 'val': 'SharedPreferences / Firebase'},
      {'key': 'Accuracy', 'val': '~85%'},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Column(
        children: items
            .map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(i['key']!,
                          style: GoogleFonts.outfit(
                              color: AppTheme.textMuted, fontSize: 12)),
                      Text(i['val']!,
                          style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStandardsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Column(
        children: [
          _StandardRow(
              org: 'WHO',
              name: 'World Health Organization',
              detail: 'Guidelines for Drinking-water Quality'),
          Divider(color: AppTheme.borderDim, height: 20),
          _StandardRow(
              org: 'EPA',
              name: 'U.S. Environmental Protection Agency',
              detail: 'National Primary Drinking Water Regulations'),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warnAmber.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.warnAmber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_outlined,
              color: AppTheme.warnAmber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'DISCLAIMER: AquaSafe provides indicative results for educational '
              'purposes only. Results should NOT replace laboratory testing. '
              'Always consult certified testing facilities.',
              style: GoogleFonts.outfit(
                color: AppTheme.warnAmber.withOpacity(0.85),
                fontSize: 11.5,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParameterInfoRow extends StatelessWidget {
  final WaterParameter param;
  const _ParameterInfoRow({required this.param});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.electricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              param.unit,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppTheme.electricBlue,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(param.label,
                    style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text('Safe: ${param.safeMin} – ${param.safeMax} ${param.unit}',
                    style: GoogleFonts.outfit(
                        color: AppTheme.safeGreen, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandardRow extends StatelessWidget {
  final String org, name, detail;
  const _StandardRow(
      {required this.org, required this.name, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.electricBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(org,
              style: GoogleFonts.outfit(
                  color: AppTheme.electricBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(detail,
                  style: GoogleFonts.outfit(
                      color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
