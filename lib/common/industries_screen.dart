import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/loginscreen.dart';

class IndustriesScreen extends StatelessWidget {
  const IndustriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Industries Screen')),
      body: const Center(child: Text('Industries Screen')),
    );
  }
}

class TopicSelectionScreen extends StatelessWidget {
  final dynamic vendorId;
  final bool isEditing;

  const TopicSelectionScreen({
    super.key,
    required this.vendorId,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic Selection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (BuildContext sheetContext) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        
                        // Header Row (Icon + Title & Subtitle)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE), // Light red background
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.power_settings_new_rounded,
                                color: Color(0xFFC62828), // Dark red icon
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1C1B1B),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Confirm account log out",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Body message
                        const Text(
                          "Are you sure you want to sign out of your account?\nYou will need to enter your credentials to log back in.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3E4949),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  foregroundColor: const Color(0xFF1C1B1B),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(sheetContext);
                                  await AuthService.logout();
                                  if (context.mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      (route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFEBEE), // Light red background
                                  foregroundColor: const Color(0xFFC62828), // Red text
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Topic Selection Screen\nVendor ID: $vendorId\nEditing: $isEditing',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class TopicSelectionScreen2 extends StatelessWidget {
  const TopicSelectionScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Topic Selection 2')),
      body: const Center(
        child: Text('Topic Selection Screen 2'),
      ),
    );
  }
}
