import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../water_parameter.dart';
import '../water_analysis_service.dart';
import '../auth_service.dart';
import '../app_widgets.dart';
import 'result_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};
  bool _isAnalysing = false;

  @override
  void initState() {
    super.initState();
    for (final p in kWaterParameters) {
      _controllers[p.key] = TextEditingController();
      _errors[p.key] = null;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      for (final p in kWaterParameters) {
        final text = _controllers[p.key]!.text.trim();
        if (text.isEmpty) {
          _errors[p.key] = 'Required';
          valid = false;
          continue;
        }
        final val = double.tryParse(text);
        if (val == null) {
          _errors[p.key] = 'Enter a valid number';
          valid = false;
          continue;
        }
        if (val < p.inputMin || val > p.inputMax) {
          _errors[p.key] = 'Must be ${p.inputMin}–${p.inputMax}';
          valid = false;
          continue;
        }
        _errors[p.key] = null;
      }
    });
    return valid;
  }

  Future<void> _runAnalysis() async {
    if (!_validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all parameters correctly.',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      );
      return;
    }

    setState(() => _isAnalysing = true);

    final Map<String, double> values = {};
    for (final p in kWaterParameters) {
      values[p.key] = double.parse(_controllers[p.key]!.text.trim());
    }

    // Get user ID
    final user = await AuthService.getCurrentUser();
    final userId = user?['email'] as String? ?? 'anonymous';

    // Run analysis (includes ML API call)
    final result = await WaterAnalysisService.analyse(
      values,
      userId: userId,
    );
    await WaterAnalysisService.saveResult(result);
    await AuthService.incrementTestCount();

    setState(() => _isAnalysing = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.frostCardMid,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text(
          'Reset All Fields?',
          style: GoogleFonts.outfit(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'All entered values will be cleared.',
          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                for (final c in _controllers.values) {
                  c.clear();
                }
                for (final k in _errors.keys) {
                  _errors[k] = null;
                }
              });
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child:
                Text('Reset', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _fillSample(bool safe) {
    final Map<String, String> safeValues = {
      'ph': '7.2', 'Hardness': '180.0', 'Solids': '320.0',
      'Chloramines': '2.5', 'Sulfate': '180.0', 'Conductivity': '310.0',
      'Organic_carbon': '1.4', 'Trihalomethanes': '45.0', 'Turbidity': '2.5',
    };
    final Map<String, String> unsafeValues = {
      'ph': '3.5', 'Hardness': '450.0', 'Solids': '38000.0',
      'Chloramines': '10.5', 'Sulfate': '420.0', 'Conductivity': '700.0',
      'Organic_carbon': '24.0', 'Trihalomethanes': '110.0', 'Turbidity': '7.8',
    };
    final values = safe ? safeValues : unsafeValues;
    setState(() {
      for (final p in kWaterParameters) {
        _controllers[p.key]!.text = values[p.key] ?? '';
        _errors[p.key] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WATER TEST'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Sample Buttons ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: AppTheme.frostCard,
                  border: const Border(
                    bottom: BorderSide(color: AppTheme.borderDim),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick fill with sample data:',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _SampleChip(
                          label: '✓ Safe Sample',
                          color: AppTheme.safeGreen,
                          onTap: () => _fillSample(true),
                        ),
                        const SizedBox(width: 10),
                        _SampleChip(
                          label: '✕ Unsafe Sample',
                          color: AppTheme.dangerRed,
                          onTap: () => _fillSample(false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ── Parameter Inputs ──────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: [
                    Text(
                      'ENTER WATER PARAMETERS',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Values are sent to ML model for potability prediction',
                      style: GoogleFonts.outfit(
                        color: AppTheme.lavender.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...kWaterParameters.map(
                      (p) => ParameterInputCard(
                        param: p,
                        controller: _controllers[p.key]!,
                        errorText: _errors[p.key],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Sticky Analyse Button ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              decoration: BoxDecoration(
                color: AppTheme.iceWhite,
                border: const Border(
                  top: BorderSide(color: AppTheme.borderDim),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _isAnalysing
                  ? Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.frostCard,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.electricBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Analysing water quality...',
                            style: GoogleFonts.outfit(
                              color: AppTheme.electricBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GlowButton(
                      label: 'ANALYSE WATER',
                      icon: Icons.biotech_outlined,
                      onTap: _runAnalysis,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SampleChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
