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
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Confirm Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to log out of your session?',
                      style: TextStyle(
                        color: Color(0xFF3E4949),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF516161)),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBA1A1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(80, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await AuthService.logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
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
