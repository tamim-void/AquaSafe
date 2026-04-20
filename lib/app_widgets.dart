import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../water_parameter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Animated Safety Score Ring
// ─────────────────────────────────────────────────────────────────────────────
class SafetyScoreRing extends StatefulWidget {
  final double score;
  final WaterSafetyLevel level;
  final double size;

  const SafetyScoreRing({
    super.key,
    required this.score,
    required this.level,
    this.size = 180,
  });

  @override
  State<SafetyScoreRing> createState() => _SafetyScoreRingState();
}

class _SafetyScoreRingState extends State<SafetyScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.level) {
      case WaterSafetyLevel.safe:
        return AppTheme.safeGreen;
      case WaterSafetyLevel.moderate:
        return AppTheme.warnAmber;
      case WaterSafetyLevel.unsafe:
        return AppTheme.dangerRed;
    }
  }

  String get _label {
    switch (widget.level) {
      case WaterSafetyLevel.safe:
        return 'DRINKABLE';
      case WaterSafetyLevel.moderate:
        return 'MODERATE';
      case WaterSafetyLevel.unsafe:
        return 'UNSAFE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  color: AppTheme.frostCardMid,
                  strokeWidth: widget.size * 0.09,
                ),
              ),
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _anim.value,
                  color: _color.withOpacity(0.15),
                  strokeWidth: widget.size * 0.14,
                ),
              ),
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _anim.value,
                  color: _color,
                  strokeWidth: widget.size * 0.09,
                  gradient: true,
                  gradientColor: _color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.score * _anim.value).toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      color: _color,
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _label,
                    style: GoogleFonts.outfit(
                      color: _color,
                      fontSize: widget.size * 0.075,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool gradient;
  final Color? gradientColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.gradient = false,
    this.gradientColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient && gradientColor != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      paint.shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + 2 * pi * progress,
        colors: [
          gradientColor!.withOpacity(0.4),
          gradientColor!,
        ],
      ).createShader(rect);
    } else {
      paint.color = color;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Parameter Input Card
// ─────────────────────────────────────────────────────────────────────────────
class ParameterInputCard extends StatelessWidget {
  final WaterParameter param;
  final TextEditingController controller;
  final String? errorText;

  const ParameterInputCard({
    super.key,
    required this.param,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: errorText != null
              ? AppTheme.dangerRed.withOpacity(0.5)
              : AppTheme.borderDim,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.electricBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppTheme.electricBlue.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    param.unit,
                    style: GoogleFonts.outfit(
                      color: AppTheme.electricBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    param.label,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              param.description,
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Range: ${param.inputMin} – ${param.inputMax}',
                errorText: errorText,
                errorStyle:
                    GoogleFonts.outfit(color: AppTheme.dangerRed, fontSize: 11),
                suffixText: param.unit,
                suffixStyle:
                    GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 12),
                isDense: true,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.verified_outlined,
                    color: AppTheme.safeGreen, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Safe: ${param.safeMin} – ${param.safeMax} ${param.unit}',
                  style: GoogleFonts.outfit(
                    color: AppTheme.safeGreen,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Parameter Result Bar
// ─────────────────────────────────────────────────────────────────────────────
class ParameterResultBar extends StatefulWidget {
  final ParameterResult result;

  const ParameterResultBar({super.key, required this.result});

  @override
  State<ParameterResultBar> createState() => _ParameterResultBarState();
}

class _ParameterResultBarState extends State<ParameterResultBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.result.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _barColor {
    switch (widget.result.status) {
      case ParameterStatus.safe:
        return AppTheme.safeGreen;
      case ParameterStatus.warning:
        return AppTheme.warnAmber;
      case ParameterStatus.danger:
        return AppTheme.dangerRed;
    }
  }

  IconData get _statusIcon {
    switch (widget.result.status) {
      case ParameterStatus.safe:
        return Icons.check_circle_outline;
      case ParameterStatus.warning:
        return Icons.warning_amber_outlined;
      case ParameterStatus.danger:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _barColor.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon, color: _barColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.result.parameter.label,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${widget.result.value.toStringAsFixed(2)} ${widget.result.parameter.unit}',
                style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.result.score.toStringAsFixed(0)}%',
                style: GoogleFonts.outfit(
                  color: _barColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _anim.value,
                backgroundColor: AppTheme.frostCardMid,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glowing Button
// ─────────────────────────────────────────────────────────────────────────────
class GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool fullWidth;

  const GlowButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppTheme.electricBlue,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.iceWhite, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: AppTheme.iceWhite,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Text(
                subtitle!,
                style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
