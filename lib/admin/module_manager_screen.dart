import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import '../Database/Database.dart';
import '../model/module_model.dart';
import '../core/theme/app_theme.dart';

class ModuleManagerScreen extends StatefulWidget {
  const ModuleManagerScreen({super.key});

  @override
  State<ModuleManagerScreen> createState() =>
      _ModuleManagerScreenState();
}

class _ModuleManagerScreenState
    extends State<ModuleManagerScreen> {

  bool _isLoading = false;
  List<ModuleModel> _installedModules = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchInstalledModules();
  }

  Future<void> _fetchInstalledModules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = Database();
      final res = await db.getData(
        {"action": "get_modules"},
        endpoint: "new_apis/module_manager_api.php",
      );

      if (res['success'] == true || res['status'] == 200 || res.containsKey('data')) {
        final rawModules = res['data'] ?? res['modules'] ?? [];
        if (rawModules is List) {
          _installedModules = rawModules.map((e) => ModuleModel.fromJson(Map<String, dynamic>.from(e))).toList();
        } else {
          _installedModules = [];
        }
      } else {
        _installedModules = [];
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load modules: $e";
      });
      // Fallback mock modules if network fails
      _installedModules = _getMockInstalledModules();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ModuleModel> _getMockInstalledModules() {
    return [
      ModuleModel(
        id: "1",
        title: "E-com Marketplace Engine",
        price: "₹3,999/mo",
        rating: "4.9",
        installs: "2.4k Installs",
        badge: "Active",
        icon: Icons.shopping_cart,
        iconName: "shopping_cart",
        features: ["Multi-vendor", "UPI/Cards Sync", "SEO Ready", "Admin Panel"],
        category: "E-commerce",
        developer: "Stitch Labs",
      ),
      ModuleModel(
        id: "2",
        title: "Job Portal Pro",
        price: "₹2,499/mo",
        rating: "4.8",
        installs: "1.8k Installs",
        badge: "Update Available",
        icon: Icons.work,
        iconName: "work",
        features: ["Resume Parsing", "ATS Integration", "Email Alerts", "Bulk Import"],
        category: "Job Board",
        developer: "Stitch Labs",
      ),
      ModuleModel(
        id: "3",
        title: "Event Hub Connect",
        price: "₹1,999/mo",
        rating: "5.0",
        installs: "940 Installs",
        badge: "Active",
        icon: Icons.event,
        iconName: "event",
        features: ["QR Ticketing", "Live Stream", "Zoom Sync", "Analytics"],
        category: "Events",
        developer: "Stitch Labs",
      ),
    ];
  }

  List<DashboardStat> get stats {
    final activeCount = _installedModules.where((m) => m.badge != 'Expired' && m.badge != 'Suspended').length;
    final updateCount = _installedModules.where((m) => m.badge.toLowerCase().contains('update')).length;
    return [
      DashboardStat(
        title: "Installed",
        value: _installedModules.length.toString(),
        icon: Icons.extension,
      ),
      DashboardStat(
        title: "Revenue",
        value: "₹48K",
        icon: Icons.payments,
      ),
      DashboardStat(
        title: "Updates",
        value: updateCount.toString(),
        icon: Icons.system_update,
      ),
      DashboardStat(
        title: "Active",
        value: activeCount.toString(),
        icon: Icons.check_circle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Module Manager",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInstalledModules,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard Overview",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary))),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: stats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final stat = stats[index];
                      return SizedBox(
                        width: 140,
                        child: StatCard(
                          title: stat.title,
                          value: stat.value,
                          icon: stat.icon,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                "Installed Modules",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
              else if (_errorMessage != null && _installedModules.isEmpty)
                Text(_errorMessage!, style: const TextStyle(color: AppTheme.error))
              else if (_installedModules.isEmpty)
                const Text("No modules are currently installed.", style: TextStyle(color: AppTheme.textSecondary))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _installedModules.length,
                  itemBuilder: (context, index) {
                    final module = _installedModules[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InstalledModuleCard(
                        title: module.title,
                        version: "v1.0.0",
                        status: module.badge.isNotEmpty ? module.badge : "Installed",
                        icon: module.icon,
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              const Text(
                "Revenue Analytics",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Revenue",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "₹48,750",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const ActivityTile(
                title: "Marketplace Engine Updated",
                subtitle: "Version 2.4.1 installed successfully",
                time: "2 hours ago",
              ),
              const ActivityTile(
                title: "New Module Installed",
                subtitle: "Event Hub Connect added",
                time: "Yesterday",
              ),
              const ActivityTile(
                title: "Subscription Renewed",
                subtitle: "Annual license renewed",
                time: "3 days ago",
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardStat {
  final String title;
  final String value;
  final IconData icon;

  DashboardStat({
    required this.title,
    required this.value,
    required this.icon,
  });
}



class InstalledModuleCard extends StatelessWidget {
  final String title;
  final String version;
  final String status;
  final IconData icon;

  const InstalledModuleCard({
    super.key,
    required this.title,
    required this.version,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUpdate = status.toLowerCase().contains("update");
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: AppTheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          version,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUpdate ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isUpdate ? AppTheme.error : AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const ActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: const CircleAvatar(
        backgroundColor: AppTheme.surfaceContainer,
        child: Icon(
          Icons.history,
          color: AppTheme.secondary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        time,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
    );
  }
}
