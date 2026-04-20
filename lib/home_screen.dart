import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../auth_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToTest;
  final VoidCallback onGoToDashboard;
  final VoidCallback onGoToProfile;

  const HomeScreen({
    super.key,
    required this.onGoToTest,
    required this.onGoToDashboard,
    required this.onGoToProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) setState(() => _user = user);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.iceWhite,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildHeroSection(),
                  const SizedBox(height: 36),
                  _buildActionCards(),
                  const SizedBox(height: 28),
                  _buildParameterChips(),
                  const SizedBox(height: 28),
                  _buildInfoBanner(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -80,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (ctx, _) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.electricBlue.withOpacity(0.07),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.skyBlue.withOpacity(0.06),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AQUASAFE',
              style: GoogleFonts.outfit(
                color: AppTheme.electricBlue,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            Text(
              'Water Quality & Safety',
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (_user != null)
              GestureDetector(
                onTap: widget.onGoToProfile,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppTheme.primaryGradient,
                    boxShadow: AppTheme.blueShadow,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (_user!['name'] as String?)
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: GoogleFonts.outfit(
                      color: AppTheme.snowSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderDim),
                    color: AppTheme.snowSurface,
                  ),
                  child: Text(
                    'LOG IN',
                    style: GoogleFonts.outfit(
                      color: AppTheme.electricBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (ctx, _) => Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.electricBlue
                    .withOpacity(0.08 * _pulseAnim.value),
              ),
              child: Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.snowSurface,
                    border: Border.all(
                      color: AppTheme.borderDim,
                      width: 1.5,
                    ),
                    boxShadow: AppTheme.blueShadow,
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    color: AppTheme.electricBlue,
                    size: 42,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Know Your Water,\nProtect Your Health',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Analyse 9 key parameters and get\nan instant ML safety prediction.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards() {
    return Column(
      children: [
        _ActionCard(
          icon: Icons.science_outlined,
          title: 'Check Water Quality',
          subtitle: 'Enter parameters & get ML prediction',
          color: AppTheme.electricBlue,
          onTap: widget.onGoToTest,
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.dashboard_outlined,
          title: 'View Dashboard',
          subtitle: 'History, trends & statistics',
          color: AppTheme.skyBlue,
          onTap: widget.onGoToDashboard,
        ),
      ],
    );
  }

  Widget _buildParameterChips() {
    final params = [
      'pH', 'Hardness', 'TDS', 'Chloramines',
      'Sulfate', 'Conductivity', 'Org. Carbon', 'THMs', 'Turbidity'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONITORED PARAMETERS',
          style: GoogleFonts.outfit(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: params
              .map((p) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.snowSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderDim),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Text(
                      p,
                      style: GoogleFonts.outfit(
                        color: AppTheme.electricBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.iceBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppTheme.electricBlue, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Based on WHO & EPA standards. Uses ML model for potability prediction. Results are indicative.',
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.snowSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.color.withOpacity(0.25)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: widget.color, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}
