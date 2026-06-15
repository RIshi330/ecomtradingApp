import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class PlatformSettingsScreen extends StatefulWidget {
  const PlatformSettingsScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadGeminiKey();
  }

  Future<void> _loadGeminiKey() async {
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'get_gemini_key',
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
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Platform Settings",
          style: TextStyle(
            color: Color(0xFF1C1B1B),
            fontWeight: FontWeight.bold,
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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Platform Settings",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1B1B),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Manage global automation and API integration policies.",
            ),

            const SizedBox(height: 24),

            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    SwitchListTile(
                      value: autoUserApproval,
                      activeColor: const Color(0xff006565),
                      title: const Text(
                        "User Account Auto Approval",
                      ),
                      subtitle: const Text(
                        "Automatically approve new users based on trust score.",
                      ),
                      onChanged: (value) {
                        setState(() {
                          autoUserApproval = value;
                        });
                      },
                    ),

                    const Divider(),

                    SwitchListTile(
                      value: autoCommunityApproval,
                      activeColor: const Color(0xff006565),
                      title: const Text(
                        "Community Status Auto Approval",
                      ),
                      subtitle: const Text(
                        "Instant verification for trusted partners.",
                      ),
                      onChanged: (value) {
                        setState(() {
                          autoCommunityApproval = value;
                        });
                        _updateAutoApproval(value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: const Color(0xffD4E6E5),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    RadioListTile(
                      value: "platform",
                      groupValue: apiStrategy,
                      activeColor: const Color(0xff006565),
                      title: const Text(
                        "Platform Key",
                      ),
                      subtitle: const Text(
                        "Use a centralized billing account.",
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
                      ),
                      subtitle: const Text(
                        "Communities manage their own API keys.",
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
            const SizedBox(height: 20),

            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Production level Gemini API key used globally.",
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: apiController,
                      obscureText: obscureKey,
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Connection Active : Gemini 1.5 Pro",
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006565),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                        onPressed: _saveGeminiKey,
                        child: const Text(
                          "Save Settings",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff006565),
                    Color(0xff008080),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Usage Credits",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "1,248,500",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      value: 0.75,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Current billing cycle ends in 12 days.",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xffD4E6E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Color(0xff006565),
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Data Encryption Active",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            "All API keys are encrypted using AES-256. Rotation occurs every 90 days.",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
