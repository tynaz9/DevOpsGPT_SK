import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/app_logo.dart';
import '../../services/api_service.dart';
import '../../widgets/server_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen>
    with TickerProviderStateMixin {
  List<dynamic> servers = [];
  List<dynamic> alerts  = [];
  bool loading          = true;
  String error          = '';
  Timer? _autoRefresh;
  int _countdown        = 30;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    loadData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefresh = Timer.periodic(
        const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _countdown = 30;
          loadData();
        }
      });
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (!loading) {
      setState(() { loading = true; error = ''; });
    }
    try {
      final results = await Future.wait([
        ApiService.getServers(),
        ApiService.getAlerts(),
      ]);
      setState(() {
        servers = results[0];
        alerts  = results[1];
        loading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() {
        error   = e.toString();
        loading = false;
      });
    }
  }

  int get healthyCount =>
      servers.where((s) => s['status'] == 'healthy').length;
  int get criticalCount =>
      servers.where((s) => s['status'] == 'critical').length;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: loading && servers.isEmpty
              ? _buildLoading(context)
              : error.isNotEmpty && servers.isEmpty
                  ? _buildError(context)
                  : _buildContent(context, isDark),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLogo(size: 64),
          const SizedBox(height: 24),
          Text('Connecting to AWS...',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary(context),
                  fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              color: AppColors.accent,
              backgroundColor: AppTheme.cardBorder(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppColors.critical, size: 48),
              const SizedBox(height: 16),
              Text('Connection Failed',
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(error,
                  style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: loadData,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: AppColors.primaryGradient),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Text('Retry',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final textColor = AppTheme.textPrimary(context);
    final textMuted = AppTheme.textMuted(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [

          // ── App Bar ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + Title
                  Row(children: [
                    const AppLogo(size: 40),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('DevOpsGPT',
                            style: GoogleFonts.inter(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('AI Cloud Operations',
                            style: GoogleFonts.inter(
                              color: textMuted,
                              fontSize: 10,
                            )),
                      ],
                    ),
                  ]),

                  // Countdown + Refresh
                  Row(children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      borderRadius: 20,
                      child: Row(children: [
                        const Icon(Icons.timer_rounded,
                            color: AppColors.accent,
                            size: 14),
                        const SizedBox(width: 4),
                        Text('${_countdown}s',
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.bold)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _countdown = 30);
                        loadData();
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 20,
                        child: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.accent,
                            size: 18),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // ── Main Content ──────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Status Banner
                GlassCard(
                  gradient: criticalCount > 0
                      ? [AppColors.critical, AppColors.warning]
                      : [AppColors.success, AppColors.accent],
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Icon(
                        criticalCount > 0
                            ? Icons.warning_rounded
                            : Icons.verified_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            criticalCount > 0
                                ? '⚡ Auto-Healing Active'
                                : '✅ All Systems Healthy',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${servers.length} servers'
                            ' · ${alerts.length} alerts',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 16),

                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _glassStatCard(
                      'Total Servers',
                      '${servers.length}',
                      Icons.storage_rounded,
                      AppColors.accent,
                      AppColors.primaryGradient,
                    ),
                    _glassStatCard(
                      'Healthy',
                      '$healthyCount',
                      Icons.check_circle_rounded,
                      AppColors.success,
                      [AppColors.success,
                          const Color(0xFF059669)],
                    ),
                    _glassStatCard(
                      'Alerts',
                      '${alerts.length}',
                      Icons.notifications_rounded,
                      AppColors.warning,
                      [AppColors.warning,
                          const Color(0xFFD97706)],
                    ),
                    _glassStatCard(
                      'Critical',
                      '$criticalCount',
                      Icons.dangerous_rounded,
                      AppColors.critical,
                      [AppColors.critical,
                          const Color(0xFFDC2626)],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Server Metrics Charts
                Row(children: [
                  const Icon(Icons.bar_chart_rounded,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text('Server Metrics',
                      style: GoogleFonts.inter(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
                ServerChartsGrid(servers: servers),

                // Recent Alerts
                if (alerts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(children: [
                    const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.warning,
                        size: 18),
                    const SizedBox(width: 8),
                    Text('Recent Alerts',
                        style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 10),
                  ...alerts.take(3).map(
                      (alert) => _buildAlertCard(context, alert)),
                ],

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    List<Color> gradient,
  ) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textMuted   = AppTheme.textMuted(context);

      return GlassCard(
        padding: const EdgeInsets.all(14),
        borderColor: color.withValues(alpha: isDark ? 0.35 : 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon in a tinted circle
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(
                        alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                // Value in accent color
                Text(value,
                    style: GoogleFonts.inter(
                      color: color,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            Text(label,
                style: TextStyle(
                    color: isDark
                        ? textMuted
                        : const Color(0xFF4B5563),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    });
  }

  Widget _buildAlertCard(BuildContext context, dynamic alert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderColor: AppColors.warning.withValues(alpha: 0.3),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warningGlow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_rounded,
                color: AppColors.warning, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  alert['message'] ?? 'Alert',
                  style: TextStyle(
                      color: AppTheme.textPrimary(context),
                      fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${alert['serverId'] ?? ''}'
                  ' · ${alert['severity'] ?? ''}',
                  style: TextStyle(
                      color: AppTheme.textMuted(context),
                      fontSize: 10),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
