import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String loginApi = "${baseUrl}new_apis/sign_up_API.php";
  const String comboApi = "${baseUrl}new_apis/combo_vendor_api.php";

  print("==================================================");
  print("Combo Vendor API Backend Integration Test");
  print("==================================================");

  // Step 1: Select Session Mode
  print("Select Authentication Mode:");
  print("1. Authenticate with Login Credentials");
  print("2. Test without Authentication (Should return 401 Unauthorized)");
  stdout.write("Enter choice (1-2): ");
  final mode = stdin.readLineSync()?.trim() ?? "1";

  final headers = <String, String>{
    "Content-Type": "application/json",
  };

  if (mode == "1") {
    print("\n--- Authentication ---");
    stdout.write("Enter email: ");
    final email = stdin.readLineSync()?.trim();
    stdout.write("Enter password: ");
    final password = stdin.readLineSync()?.trim();
    stdout.write("Login as Admin? (y/n): ");
    final isAdmin = (stdin.readLineSync()?.trim() ?? "n").toLowerCase() == "y";

    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      print("Email and password cannot be empty.");
      return;
    }

    print("\nLogging in...");
    try {
      final loginResponse = await http.post(
        Uri.parse(loginApi),
        body: {
          'action': isAdmin ? 'admin_login_with_password' : 'login_with_password',
          'email': email,
          'password': password,
        },
      );

      print("Login Status Code: ${loginResponse.statusCode}");
      print("Login Response Body: ${loginResponse.body}");

      final loginData = jsonDecode(loginResponse.body);
      if (loginData['success'] != true && loginData['status'] != 200) {
        print("❌ Login failed: ${loginData['message'] ?? 'Unknown error'}");
        return;
      }

      // Capture session cookie
      final cookies = loginResponse.headers['set-cookie'];
      if (cookies != null) {
        headers['Cookie'] = cookies.split(';').first;
        print("✅ Session Cookie Captured: ${headers['Cookie']}");
      } else {
        print("⚠️ Warning: No session cookie returned by backend.");
      }
    } catch (e) {
      print("❌ Login connection error: $e");
      return;
    }
  }

  // Step 2: Fetch Combo Packages
  print("\n--- Step 2: Fetching Combo Packages ---");
  List<dynamic> comboList = [];
  try {
    final response = await http.post(
      Uri.parse(comboApi),
      headers: headers,
      body: jsonEncode({"action": "get_combo_packages"}),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      comboList = data['data'] is List ? data['data'] : [];
      print("✅ Retrieved ${comboList.length} combo packages.");
    } else {
      print("❌ Failed to fetch combo packages: ${data['message']}");
      if (mode == "2") {
        print("-> Test passed: API successfully protected from unauthenticated access!");
      }
      return;
    }
  } catch (e) {
    print("❌ Error fetching combos: $e");
    return;
  }

  if (comboList.isEmpty) {
    print("\nNo combo packages found in the database. Cannot test toggle/delete actions.");
    return;
  }

  // Display combos
  print("\nAvailable Combo Packages:");
  for (var i = 0; i < comboList.length; i++) {
    final item = comboList[i];
    print("[$i] ID: ${item['id']} | Title: ${item['combo_title']} | Price: ₹${item['combo_price']} | Status: ${item['status']}");
  }

  // Step 3: Toggle Combo Status
  print("\n--- Step 3: Toggling Combo Status ---");
  stdout.write("Select combo index to toggle status (0-${comboList.length - 1}): ");
  final idxStr = stdin.readLineSync()?.trim() ?? "0";
  final idx = int.tryParse(idxStr) ?? 0;
  if (idx < 0 || idx >= comboList.length) {
    print("Invalid index selection.");
    return;
  }

  final selectedCombo = comboList[idx];
  final currentStatus = selectedCombo['status']?.toString() ?? '0';
  final newStatus = currentStatus == '1' ? '0' : '1';
  final comboId = selectedCombo['id']?.toString() ?? '';

  print("Toggling Combo ID $comboId status from $currentStatus to $newStatus...");
  try {
    final response = await http.post(
      Uri.parse(comboApi),
      headers: headers,
      body: jsonEncode({
        "action": "update_combo_status",
        "id": comboId,
        "status": newStatus,
      }),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Status updated successfully!");
    } else {
      print("❌ Failed to update status: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error toggling status: $e");
  }

  // Step 4: Delete Combo Package
  print("\n--- Step 4: Deleting Combo Package (Optional) ---");
  stdout.write("Do you want to test deleting a combo package? (y/n): ");
  final wantDelete = (stdin.readLineSync()?.trim() ?? "n").toLowerCase() == "y";

  if (wantDelete) {
    stdout.write("Enter combo package ID to delete (pid): ");
    final deletePid = stdin.readLineSync()?.trim();
    if (deletePid == null || deletePid.isEmpty) {
      print("Package ID cannot be empty.");
      return;
    }

    print("Deleting Combo Package ID $deletePid...");
    try {
      final response = await http.post(
        Uri.parse(comboApi),
        headers: headers,
        body: jsonEncode({
          "action": "delete_combo_package",
          "pid": deletePid,
        }),
      );

      print("HTTP Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print("✅ Combo package deleted successfully!");
      } else {
        print("❌ Failed to delete combo package: ${data['message']}");
      }
    } catch (e) {
      print("❌ Error deleting package: $e");
    }
  }

  print("\n==============================================");
  print("🎉 Combo Vendor API Integration Test Finished!");
  print("==============================================");
}
