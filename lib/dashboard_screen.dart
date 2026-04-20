import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../water_parameter.dart';
import '../water_analysis_service.dart';
import '../auth_service.dart';
import '../app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);

    // Get the currently logged-in user
    final user = await AuthService.getCurrentUser();
    _currentUserId = user?['email'] as String? ?? '';

    // Load all records, then filter to this user only
    final allData = await WaterAnalysisService.loadHistory();
    setState(() {
      _history = _currentUserId.isNotEmpty
          ? allData
              .where((h) => (h['userId'] as String?) == _currentUserId)
              .toList()
          : []; // Not logged in → show nothing
      _loading = false;
    });
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.frostCardMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)),
        title: Text('Clear My History?',
            style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete all your test records.',
          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    GoogleFonts.outfit(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed),
            onPressed: () async {
              Navigator.pop(ctx);
              // Only delete records belonging to the current user
              await WaterAnalysisService.clearHistoryForUser(
                  _currentUserId);
              _loadHistory();
            },
            child: Text('Clear',
                style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DASHBOARD'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.dangerRed),
              onPressed: _clearHistory,
              tooltip: 'Clear my history',
            ),
          IconButton(
            icon: const Icon(Icons.refresh,
                color: AppTheme.textSecondary),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.electricBlue))
          : _currentUserId.isEmpty
              ? _buildNotLoggedIn()
              : _history.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: AppTheme.electricBlue,
                      backgroundColor: AppTheme.frostCard,
                      onRefresh: _loadHistory,
                      child: ListView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: [
                          _buildSummaryCards(),
                          const SizedBox(height: 24),
                          if (_history.length >= 2) ...[
                            const SectionHeader(
                              title: 'SCORE TREND',
                              subtitle:
                                  'Safety score over your recent tests',
                            ),
                            _buildLineChart(),
                            const SizedBox(height: 24),
                          ],
                          const SectionHeader(
                            title: 'POTABILITY DISTRIBUTION',
                            subtitle: 'Safe vs unsafe test results',
                          ),
                          _buildPieChart(),
                          const SizedBox(height: 24),
                          const SectionHeader(
                            title: 'TEST HISTORY',
                            subtitle: 'Most recent first',
                          ),
                          ..._history.asMap().entries.map(
                                (e) => _HistoryCard(
                                  index: e.key,
                                  data: e.value,
                                  total: _history.length,
                                ),
                              ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline,
              color: AppTheme.textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            'Sign in to view your dashboard',
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your test history is private\nand linked to your account.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GlowButton(
            label: 'SIGN IN',
            icon: Icons.login_outlined,
            fullWidth: false,
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined,
              color: AppTheme.textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            'No tests yet',
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run your first water analysis\nto see results here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final int total = _history.length;
    final int safe = _history
        .where((h) =>
            (h['safetyLevel'] as int) == WaterSafetyLevel.safe.index)
        .length;
    final int unsafe = _history
        .where((h) =>
            (h['safetyLevel'] as int) == WaterSafetyLevel.unsafe.index)
        .length;
    final double avg = total == 0
        ? 0
        : _history.fold<double>(
                0,
                (sum, h) =>
                    sum + (h['safetyScore'] as num).toDouble()) /
            total;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
            title: 'TOTAL TESTS',
            value: '$total',
            color: AppTheme.electricBlue),
        _StatCard(
            title: 'SAFE',
            value: '$safe',
            color: AppTheme.safeGreen),
        _StatCard(
            title: 'UNSAFE',
            value: '$unsafe',
            color: AppTheme.dangerRed),
        _StatCard(
            title: 'AVG SCORE',
            value: avg.toStringAsFixed(1),
            color: AppTheme.warnAmber),
      ],
    );
  }

  Widget _buildLineChart() {
    final scores = _history.reversed
        .take(10)
        .map((h) => (h['safetyScore'] as num).toDouble())
        .toList();

    final spots = scores
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.textMuted.withOpacity(0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (val, _) => Text(
                  val.toInt().toString(),
                  style: GoogleFonts.outfit(
                      color: AppTheme.textMuted, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) => Text(
                  '${val.toInt() + 1}',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textMuted, fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.electricBlue,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.electricBlue,
                  strokeColor: AppTheme.iceWhite,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.electricBlue.withOpacity(0.25),
                    AppTheme.electricBlue.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            // Safe threshold line
            LineChartBarData(
              spots: [
                FlSpot(0, 75),
                FlSpot((spots.length - 1).toDouble(), 75),
              ],
              isCurved: false,
              color: AppTheme.safeGreen.withOpacity(0.4),
              barWidth: 1,
              dashArray: [6, 4],
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final int safe = _history
        .where((h) =>
            (h['safetyLevel'] as int) == WaterSafetyLevel.safe.index)
        .length;
    final int moderate = _history
        .where((h) =>
            (h['safetyLevel'] as int) ==
            WaterSafetyLevel.moderate.index)
        .length;
    final int unsafe = _history
        .where((h) =>
            (h['safetyLevel'] as int) == WaterSafetyLevel.unsafe.index)
        .length;
    final int total = safe + moderate + unsafe;
    if (total == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDim),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 30,
                sections: [
                  if (safe > 0)
                    PieChartSectionData(
                      value: safe.toDouble(),
                      color: AppTheme.safeGreen,
                      title: '$safe',
                      radius: 48,
                      titleStyle: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  if (moderate > 0)
                    PieChartSectionData(
                      value: moderate.toDouble(),
                      color: AppTheme.warnAmber,
                      title: '$moderate',
                      radius: 48,
                      titleStyle: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  if (unsafe > 0)
                    PieChartSectionData(
                      value: unsafe.toDouble(),
                      color: AppTheme.dangerRed,
                      title: '$unsafe',
                      radius: 48,
                      titleStyle: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                  color: AppTheme.safeGreen,
                  label: 'Safe',
                  count: safe,
                  total: total),
              const SizedBox(height: 10),
              _LegendItem(
                  color: AppTheme.warnAmber,
                  label: 'Moderate',
                  count: moderate,
                  total: total),
              const SizedBox(height: 10),
              _LegendItem(
                  color: AppTheme.dangerRed,
                  label: 'Unsafe',
                  count: unsafe,
                  total: total),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title, value;
  final Color color;
  const _StatCard(
      {required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.outfit(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

// ─── Legend Item ──────────────────────────────────────────────────────────────
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count, total;
  const _LegendItem(
      {required this.color,
      required this.label,
      required this.count,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final pct =
        total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.outfit(
                color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(width: 6),
        Text('$pct%',
            style: GoogleFonts.outfit(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final int index, total;
  final Map<String, dynamic> data;
  const _HistoryCard(
      {required this.index, required this.data, required this.total});

  Color get _color {
    final level = WaterSafetyLevel.values[data['safetyLevel'] as int];
    switch (level) {
      case WaterSafetyLevel.safe:     return AppTheme.safeGreen;
      case WaterSafetyLevel.moderate: return AppTheme.warnAmber;
      case WaterSafetyLevel.unsafe:   return AppTheme.dangerRed;
    }
  }

  String get _levelLabel {
    final level = WaterSafetyLevel.values[data['safetyLevel'] as int];
    switch (level) {
      case WaterSafetyLevel.safe:     return 'SAFE';
      case WaterSafetyLevel.moderate: return 'MODERATE';
      case WaterSafetyLevel.unsafe:   return 'UNSAFE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = (data['safetyScore'] as num).toDouble();
    final testedAt = DateTime.parse(data['testedAt'] as String);
    final formatted = DateFormat('MMM d, yyyy • HH:mm').format(testedAt);
    final mlPred = data['mlPrediction'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.frostCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  score.toStringAsFixed(0),
                  style: GoogleFonts.outfit(
                      color: _color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Test #${total - index}',
                        style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(formatted,
                        style: GoogleFonts.outfit(
                            color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _color.withOpacity(0.3)),
                ),
                child: Text(_levelLabel,
                    style: GoogleFonts.outfit(
                        color: _color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          if (mlPred != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.psychology_outlined,
                    color: AppTheme.lavender, size: 14),
                const SizedBox(width: 4),
                Text('ML: $mlPred',
                    style: GoogleFonts.outfit(
                        color: AppTheme.lavender,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
