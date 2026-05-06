import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cards/alert_card.dart';
import '../../services/api_service.dart';
import '../../widgets/app_logo.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<dynamic> alerts = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    setState(() { loading = true; error = ''; });
    try {
      final data = await ApiService.getAlerts();
      setState(() {
        alerts  = data;
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
    final bgColor       = AppTheme.bg(context);
    final textPrimary   = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);
    final textMuted     = AppTheme.textMuted(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(children: [
          const AppLogo(size: 32),
          const SizedBox(width: 10),
          Text("Alerts",
              style: TextStyle(color: textPrimary)),
        ]),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,
                color: AppColors.accent),
            onPressed: loadAlerts,
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.accent))
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error,
                          color: AppColors.critical),
                      const SizedBox(height: 8),
                      Text(error,
                          style: TextStyle(
                              color: textSecondary)),
                      ElevatedButton(
                        onPressed: loadAlerts,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadAlerts,
                  color: AppColors.accent,
                  child: alerts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No active alerts",
                                style: TextStyle(
                                    color: textPrimary),
                              ),
                              Text(
                                "All systems running normally",
                                style: TextStyle(
                                    color: textMuted),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.all(12),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                      bottom: 8),
                              child: AlertCard(
                                title: alert['message'] ??
                                    'Alert',
                                server:
                                    alert['serverId'] ??
                                        '',
                                severity:
                                    alert['severity'] ==
                                            'HIGH'
                                        ? 'Critical'
                                        : 'Warning',
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
