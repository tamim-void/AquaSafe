import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../auth_service.dart';
import '../water_analysis_service.dart';
import '../app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _editing = false;
  final _nameCtrl = TextEditingController();
  int _totalTests = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    final history = await WaterAnalysisService.loadHistory();
    if (mounted) {
      setState(() {
        _user = user;
        _totalTests = history.length;
        _nameCtrl.text = user?['name'] ?? '';
      });
    }
  }

  Future<void> _saveName() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    _user!['name'] = _nameCtrl.text.trim();
    await AuthService.updateCurrentUser(_user!);
    setState(() => _editing = false);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.frostCardMid,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text('Log Out?',
            style: GoogleFonts.outfit(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'You will need to sign in again.',
          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: Text('Log Out',
                style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PROFILE')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline,
                  color: AppTheme.textMuted, size: 64),
              const SizedBox(height: 16),
              Text(
                'Not logged in',
                style: GoogleFonts.outfit(
                    color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 20),
              GlowButton(
                label: 'SIGN IN',
                icon: Icons.login_outlined,
                fullWidth: false,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
              ),
            ],
          ),
        ),
      );
    }

    final joinedDate = _user!['joinedDate'] != null
        ? DateFormat('MMM d, yyyy')
            .format(DateTime.parse(_user!['joinedDate']))
        : 'Unknown';
    final name = _user!['name'] ?? 'User';
    final email = _user!['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
        child: Column(
          children: [
            // ── Avatar ───────────────────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.electricBlue.withOpacity(0.3),
                    AppTheme.lavender.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                    color: AppTheme.electricBlue.withOpacity(0.5), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: GoogleFonts.outfit(
                  color: AppTheme.electricBlue,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Name (editable) ──────────────────────────────────────────
            if (_editing) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.frostCard,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.electricBlue.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _saveName,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.safeGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.safeGreen.withOpacity(0.4)),
                        ),
                        child: Text('Save',
                            style: GoogleFonts.outfit(
                                color: AppTheme.safeGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                name,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              email,
              style: GoogleFonts.outfit(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),

            // ── Stats ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    title: 'TESTS RUN',
                    value: '$_totalTests',
                    color: AppTheme.electricBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfileStat(
                    title: 'JOINED',
                    value: joinedDate,
                    color: AppTheme.lavender,
                    small: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Actions ──────────────────────────────────────────────────
            GlowButton(
              label: _editing ? 'CANCEL EDIT' : 'EDIT PROFILE',
              icon: _editing ? Icons.close : Icons.edit_outlined,
              color: AppTheme.electricBlue,
              onTap: () => setState(() {
                _editing = !_editing;
                _nameCtrl.text = _user!['name'] ?? '';
              }),
            ),
            const SizedBox(height: 12),
            GlowButton(
              label: 'LOG OUT',
              icon: Icons.logout_outlined,
              color: AppTheme.dangerRed,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool small;

  const _ProfileStat({
    required this.title,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: small ? 13 : 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
