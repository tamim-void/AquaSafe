import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _barCtrl;
  late AnimationController _rippleCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _barProgress;
  late Animation<double> _ripple;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textOpacity =
        Tween<double>(begin: 0, end: 1).animate(_fadeCtrl);
    _textSlide = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );

    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _barProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut),
    );

    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _ripple = Tween<double>(begin: 0, end: 1).animate(_rippleCtrl);

    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _fadeCtrl.forward();
    _barCtrl.forward();
    final isLoggedIn = await AuthService.isLoggedIn();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      Navigator.pushReplacementNamed(
          context, isLoggedIn ? '/main' : '/login');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _fadeCtrl.dispose();
    _barCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.iceWhite,
      body: Stack(
        children: [
          // ── Frost background circles ────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.electricBlue.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.skyBlue.withOpacity(0.08),
              ),
            ),
          ),

          // ── Ripple rings ────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _ripple,
            builder: (_, __) => Positioned(
              left: size.width / 2 - 100,
              top: size.height * 0.35 - 100,
              child: Opacity(
                opacity: (1 - _ripple.value) * 0.15,
                child: Container(
                  width: 200 + _ripple.value * 80,
                  height: 200 + _ripple.value * 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.electricBlue,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ─────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.snowSurface,
                            border: Border.all(
                              color: AppTheme.borderDim,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlue
                                    .withOpacity(0.15),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: AppTheme.electricBlue,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Title & subtitle ──────────────────────────────────
                  AnimatedBuilder(
                    animation: _fadeCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _textOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Column(
                          children: [
                            Text(
                              'AQUASAFE',
                              style: GoogleFonts.outfit(
                                color: AppTheme.electricBlue,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Smart Water Safety Prediction Using AI',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Powered by Machine Learning',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),

                  // ── Loading bar ───────────────────────────────────────
                  AnimatedBuilder(
                    animation: _barCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Loading',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      '${(_barProgress.value * 100).toInt()}%',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.electricBlue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 200,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.borderDim,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _barProgress.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.electricBlue
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Version ─────────────────────────────────────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeCtrl,
              builder: (_, __) => Opacity(
                opacity: _textOpacity.value * 0.6,
                child: Text(
                  'AquaSafe v1.0.0 • WHO/EPA Standards',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
