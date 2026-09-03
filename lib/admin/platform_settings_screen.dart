import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

class PlatformSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const PlatformSettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<PlatformSettingsScreen> createState() =>
      _PlatformSettingsScreenState();
}

class _PlatformSettingsScreenState
    extends State<PlatformSettingsScreen> {

  bool autoUserApproval = true;
  bool autoCommunityApproval = false;

  String apiStrategy = "platform";
  bool obscureKey = true;
  final TextEditingController apiController =
      TextEditingController(
    text: "",
  );

  // App Settings Toggles (Consolidated from dashboard view)
  bool _isMaintenanceMode = false;
  bool _isAutoApproveVendors = true;
  bool _isEscrowEnabled = true;
  bool _isPushNotificationsEnabled = true;
  bool _isLoadingSettings = false;

  @override
  void initState() {
    super.initState();
    _loadGeminiKey();
    _fetchPlatformSettings();
  }

  Future<void> _fetchPlatformSettings() async {
    setState(() {
      _isLoadingSettings = true;
    });
    try {
      final response = await Database().getData({
        'action': 'fetch_settings',
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/platform_setting_API.php');
      
      if (response['success'] == true && response['data'] != null) {
        final site = response['data']['site'];
        if (site != null) {
          setState(() {
            _isMaintenanceMode = (int.tryParse(site['status']?.toString() ?? '1') ?? 1) == 0;
            _isAutoApproveVendors = (int.tryParse(site['need_approval']?.toString() ?? '1') ?? 1) == 0;
            _isEscrowEnabled = (int.tryParse(site['is_commission_split']?.toString() ?? '0') ?? 0) == 1;
            _isPushNotificationsEnabled = (int.tryParse(site['show_product_review']?.toString() ?? '0') ?? 0) == 1;
          });
        }
      }
    } catch (e) {
      print("Error fetching platform settings: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSettings = false;
        });
      }
    }
  }

  Future<void> _updatePlatformSetting(String key, dynamic value) async {
    try {
      final response = await Database().getData({
        'action': 'platform_setting',
        'update_action': 'update_single_setting',
        'key': key,
        'value': value.toString(),
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/platform_setting_API.php');

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Setting updated successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to update setting"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error updating platform setting: $e");
    }
  }

  Future<void> _loadGeminiKey() async {
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'get_gemini_key',
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/community_palatform_setting_api 2.php');

      if (response['success'] == true || response['status'] == 200) {
        final key = response['data']?['api_key']?.toString();
        if (key != null && key.isNotEmpty) {
          setState(() {
            apiController.text = key;
          });
        }
      }
    } catch (e) {
      print("Error loading Gemini key: $e");
    }
  }

  Future<void> _updateAutoApproval(bool isEnabled) async {
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'admin_update_auto_approval',
        'community_id': 10,
        'auto_approval': isEnabled ? 1 : 0,
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/community_palatform_setting_api 2.php');

      if (response['success'] == true || response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Auto-approval updated to ${isEnabled ? 'Enabled' : 'Disabled'}!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update auto-approval"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error updating auto-approval: $e");
    }
  }

  Future<void> _saveGeminiKey() async {
    final key = apiController.text.trim();
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'update_gemini_key',
        'api_key': key,
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/community_palatform_setting_api 2.php');

      if (response['success'] == true || response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gemini API key saved successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save Gemini API key"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error saving Gemini key: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabTheme = Theme.of(context).copyWith(
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xff006565),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xff006565),
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Theme(
        data: tabTheme,
        child: Scaffold(
          backgroundColor: const Color(0xfff5f7fa),
          appBar: widget.isEmbedded
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: const TabBar(
                      tabs: [
                        Tab(text: "App Settings"),
                        Tab(text: "API & Keys"),
                      ],
                    ),
                  ),
                )
              : AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: const Text(
                    "Platform Settings",
                    style: TextStyle(
                      color: Color(0xFF1C1B1B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Navigator.canPop(context)
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                          onPressed: () => Navigator.pop(context),
                        )
                      : const Icon(
                          Icons.menu,
                          color: Color(0xff006565),
                        ),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: "App Settings"),
                      Tab(text: "API & Keys"),
                    ],
                  ),
                ),
          body: TabBarView(
            children: [
              _buildAppSettingsTab(),
              _buildApiKeysTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppSettingsTab() {
    if (_isLoadingSettings) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006565)),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "App Configurations",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1B1B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Configure real-time app parameters and system states.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _buildSettingsSwitchTile(
            "Maintenance Mode",
            "Temporarily lock the platform for users",
            _isMaintenanceMode,
            (val) {
              setState(() => _isMaintenanceMode = val);
              _updatePlatformSetting('status', val ? 0 : 1);
            },
          ),
          _buildSettingsSwitchTile(
            "Auto-Approve Vendors",
            "Skip manual verification for new signups",
            _isAutoApproveVendors,
            (val) {
              setState(() => _isAutoApproveVendors = val);
              _updatePlatformSetting('need_approval', val ? 0 : 1);
            },
          ),
          _buildSettingsSwitchTile(
            "Enable Escrow Service",
            "Hold buyer payments until delivery confirmation",
            _isEscrowEnabled,
            (val) {
              setState(() => _isEscrowEnabled = val);
              _updatePlatformSetting('is_commission_split', val ? 1 : 0);
            },
          ),
          _buildSettingsSwitchTile(
            "Push Notifications",
            "Send instant transaction alerts to users",

            _isPushNotificationsEnabled,
            (val) {
              setState(() => _isPushNotificationsEnabled = val);
              _updatePlatformSetting('show_product_review', val ? 1 : 0);
            },
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          HoverableCard(
            borderRadius: 16.0,
            borderColor: const Color(0xff006565),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_mode,
                        color: Color(0xff006565),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Automation Controls",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "User Account Auto Approval",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Automatically approve new users based on trust score.",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Switch(
                        value: autoUserApproval,
                        activeColor: const Color(0xff006565),
                        activeTrackColor: const Color(0xff006565).withOpacity(0.3),
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.transparent,
                        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return null;
                          }
                          return Colors.black;
                        }),
                        onChanged: (value) {
                          setState(() {
                            autoUserApproval = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1, color: Color(0xFFE6E6F0)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Community Status Auto Approval",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Instant verification for trusted partners.",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Switch(
                        value: autoCommunityApproval,
                        activeColor: const Color(0xff006565),
                        activeTrackColor: const Color(0xff006565).withOpacity(0.3),
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.transparent,
                        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return null;
                          }
                          return Colors.black;
                        }),
                        onChanged: (value) {
                          setState(() {
                            autoCommunityApproval = value;
                          });
                          _updateAutoApproval(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeysTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "API Integration & Security",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1B1B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Manage credentials and authorization tokens.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xffD4E6E5),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.api,
                        color: Color(0xff006565),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Gemini API Strategy",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RadioListTile(
                    value: "platform",
                    groupValue: apiStrategy,
                    activeColor: const Color(0xff006565),
                    title: const Text(
                      "Platform Key",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      "Use a centralized billing account.",
                      style: TextStyle(fontSize: 11),
                    ),
                    onChanged: (value) {
                      setState(() {
                        apiStrategy = value!;
                      });
                    },
                  ),
                  RadioListTile(
                    value: "community",
                    groupValue: apiStrategy,
                    activeColor: const Color(0xff006565),
                    title: const Text(
                      "Community Admin Keys",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      "Communities manage their own API keys.",
                      style: TextStyle(fontSize: 11),
                    ),
                    onChanged: (value) {
                      setState(() {
                        apiStrategy = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.key,
                        color: Color(0xff006565),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Platform Gemini API Key",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Production level Gemini API key used globally.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: apiController,
                    obscureText: obscureKey,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.vpn_key,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureKey
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureKey = !obscureKey;
                          });
                        },
                      ),
                      hintText: "AIza...",
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Connection Active : Gemini 1.5 Pro",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff006565),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: _saveGeminiKey,
                      child: const Text(
                        "Save Settings",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff006565),
                  Color(0xff008080),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Usage Credits",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "1,248,500",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.75,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Current billing cycle ends in 12 days.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xffD4E6E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Color(0xff006565),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Data Encryption Active",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "All API keys are encrypted using AES-256. Rotation occurs every 90 days.",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
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
    );
  }

  Widget _buildSettingsSwitchTile(String title, String subtitle, bool isEnabled, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: HoverableCard(
        borderRadius: 16.0,
        borderColor: const Color(0xff006565),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: isEnabled,
                onChanged: onChanged,
                activeColor: const Color(0xff006565),
                activeTrackColor: const Color(0xff006565).withOpacity(0.3),
                inactiveThumbColor: Colors.black,
                inactiveTrackColor: Colors.transparent,
                trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return null;
                  }
                  return Colors.black;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
