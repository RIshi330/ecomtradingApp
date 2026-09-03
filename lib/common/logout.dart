import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/services/auth_User_and_Business_Session.dart';

import '../Database/Database.dart';
import '../app_constants.dart';

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevents closing by tapping outside while processing
    builder: (BuildContext dialogContext) {
      bool isLoggingOut = false;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent.shade700,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  "Confirm Logout",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Are you sure you want to log out of your vendor account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                if (isLoggingOut)
                  const CircularProgressIndicator(color: Color(0xff006565))
                else
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Logout Button
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            setModalState(() {
                              isLoggingOut = true;
                            });
                            await UserSessionSet.instance.logout();

                            await _performVendorLogout(dialogContext);
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

// API Call Handler — now routed through Database.getData()
Future<void> _performVendorLogout(BuildContext dialogContext) async {
  try {
    final database = Database();

    // Hits vendor_logout.php via the same endpoint-routing/session-cookie
    // machinery every other call in Database uses (APP_ID header, cached
    // PHPSESSID/raw cookie, JSON decoding, etc).
    final result = await database.getData(
      {'action': 'vendor_logout',        'vendor_id': UserSessionSet.instance.vendorId,
      },
      endpoint: 'new_apis/vendor_logout.php',
    );

    if (result['success'] == true) {
      // Clear cached session id / cookie / secure storage so the app
      // doesn't try to reuse a dead session on the next request.
      await database.clearAllData();

      // 1. Close the Dialog
      Navigator.of(dialogContext).pop();

      // 2. Navigate to Login screen & clear navigation history stack
      Navigator.of(dialogContext, rootNavigator: true).pushNamedAndRemoveUntil(
        '/login', // Replace with your login route
            (route) => false,
      );
    } else {
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? "Failed to log out."),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    Navigator.of(dialogContext).pop();
    ScaffoldMessenger.of(dialogContext).showSnackBar(
      SnackBar(
        content: Text("Error logging out: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}