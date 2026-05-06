import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/api_service.dart';
import 'server_detail_screen.dart';

class InfrastructureScreen extends StatefulWidget {
  const InfrastructureScreen({super.key});
  @override
  State<InfrastructureScreen> createState() =>
      _InfrastructureScreenState();
}

class _InfrastructureScreenState
    extends State<InfrastructureScreen> {
  List<dynamic> servers = [];
  bool loading          = true;
  String error          = '';
  Timer? _autoRefresh;
  int _countdown        = 30;

  @override
  void initState() {
    super.initState();
    loadServers();
    _autoRefresh = Timer.periodic(
        const Duration(seconds: 1), (t) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _countdown = 30;
          loadServers();
        }
      });
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  Future<void> loadServers() async {
    try {
      final data = await ApiService.getServers();
      setState(() {
        servers = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error   = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppTheme.textPrimary(context);
    final textMuted   = AppTheme.textMuted(context);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors:
                                  AppColors.primaryGradient),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                            Icons.storage_rounded,
                            color: Colors.white,
                            size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Servers',
                              style: GoogleFonts.inter(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold)),
                          Text(
                              '${servers.length} instances',
                              style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11)),
                        ],
                      ),
                    ]),
                    Row(children: [
                      GlassCard(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6),
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
                          loadServers();
                        },
                        child: GlassCard(
                          padding:
                              const EdgeInsets.all(8),
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

              // Content
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent))
                    : error.isNotEmpty
                        ? Center(
                            child: Text(error,
                                style: const TextStyle(
                                    color:
                                        AppColors.critical)))
                        : RefreshIndicator(
                            onRefresh: loadServers,
                            color: AppColors.accent,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.all(16),
                              itemCount: servers.length,
                              itemBuilder: (ctx, i) =>
                                  _serverCard(
                                      servers[i], ctx),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serverCard(
      dynamic server, BuildContext context) {
    double cpu    = double.tryParse(
        server['cpu'].toString()) ?? 0;
    double memory = double.tryParse(
        server['memory'].toString()) ?? 0;
    String status = server['status'] ?? 'unknown';
    String name   =
        server['name'] ?? server['serverId'];

    final textPrimary   = AppTheme.textPrimary(context);
    final textMuted     = AppTheme.textMuted(context);
    final progressBg    = AppTheme.cardBorder(context);

    Color statusColor = status == 'healthy'
        ? AppColors.success
        : status == 'critical'
            ? AppColors.critical
            : status == 'stopped'
                ? AppTheme.textMuted(context)
                : AppColors.warning;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServerDetailScreen(
            server: Map<String, dynamic>.from(server)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          borderColor: statusColor.withValues(alpha: 0.3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor
                              .withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Icon(
                            Icons.computer_rounded,
                            color: statusColor,
                            size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: GoogleFonts.inter(
                                    color: textPrimary,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 14),
                                overflow:
                                    TextOverflow.ellipsis),
                            Text(
                              '${server['instanceType'] ?? 'N/A'} · '
                              '${server['publicIp'] ?? 'N/A'}',
                              style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor
                            .withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor
                                .withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                        Icons.chevron_right_rounded,
                        color: textMuted,
                        size: 20),
                  ]),
                ],
              ),
              const SizedBox(height: 14),

              // CPU and Memory bars
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('CPU',
                              style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11)),
                          Text('${cpu.toInt()}%',
                              style: TextStyle(
                                  color: cpu > 70
                                      ? AppColors.critical
                                      : AppColors.accent,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: cpu / 100,
                          backgroundColor: progressBg,
                          color: cpu > 70
                              ? AppColors.critical
                              : AppColors.accent,
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('RAM',
                              style: TextStyle(
                                  color: textMuted,
                                  fontSize: 11)),
                          Text('${memory.toInt()}%',
                              style: TextStyle(
                                  color: memory > 80
                                      ? AppColors.warning
                                      : AppColors.purple,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: memory / 100,
                          backgroundColor: progressBg,
                          color: memory > 80
                              ? AppColors.warning
                              : AppColors.purple,
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.touch_app_rounded,
                    color: textMuted, size: 12),
                const SizedBox(width: 4),
                Text('Tap for full details',
                    style: TextStyle(
                        color: textMuted,
                        fontSize: 11)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
