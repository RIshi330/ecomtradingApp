import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String loginApi = "${baseUrl}new_apis/sign_up_API.php";
  const String b2cApi = "${baseUrl}new_apis/product_vendors_API 3.php";
  const String b2bApi = "${baseUrl}new_apis/product_btb_vendors_API 3.php";
  const String comboApi = "${baseUrl}new_apis/combo_vendor_api.php";

  print("==================================================");
  print("Product Management End-to-End Integration Test");
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

  // ----------------------- B2C PRODUCTS TEST -----------------------
  print("\n==============================================");
  print("🛒 Testing B2C Products (product_vendors_API 3.php)");
  print("==============================================");
  
  String? b2cProductId;
  String? b2cVariantId;
  
  try {
    print("Action: get_managing_products");
    final response = await http.post(
      Uri.parse(b2cApi),
      headers: headers,
      body: jsonEncode({
        "action": "get_managing_products",
        "page": 1,
        "limit": 10,
      }),
    );
    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null && data['data']['products'] != null) {
      final List productsList = data['data']['products'];
      print("✅ Retrieved ${productsList.length} B2C products.");
      if (productsList.isNotEmpty) {
        b2cProductId = productsList[0]['product_id']?.toString();
        b2cVariantId = productsList[0]['variant_id']?.toString() ?? '0';
        print("-> Selecting first B2C Product ID: $b2cProductId, Variant ID: $b2cVariantId for sub-tests");
      }
    } else {
      print("❌ B2C Products fetching failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error testing B2C Fetch: $e");
  }

  if (b2cProductId != null) {
    // Test B2C Stats
    try {
      print("\nAction: get_product_stats (B2C)");
      final response = await http.post(
        Uri.parse(b2cApi),
        headers: headers,
        body: jsonEncode({
          "action": "get_product_stats",
          "product_id": b2cProductId,
        }),
      );
      print("HTTP Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    } catch (e) {
      print("❌ Error testing B2C Stats: $e");
    }

    // Test B2C Collateral
    try {
      print("\nAction: get_product_collateral (B2C)");
      final response = await http.post(
        Uri.parse(b2cApi),
        headers: headers,
        body: jsonEncode({
          "action": "get_product_collateral",
          "product_id": b2cProductId,
          "variant_id": b2cVariantId,
          "marketplace_id": 51,
        }),
      );
      print("HTTP Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    } catch (e) {
      print("❌ Error testing B2C Collateral: $e");
    }
  }

  // ----------------------- B2B PRODUCTS TEST -----------------------
  print("\n==============================================");
  print("💼 Testing B2B Products (product_btb_vendors_API 3.php)");
  print("==============================================");
  
  String? b2bProductId;
  String? b2bVariantId;
  
  try {
    print("Action: get_managing_products");
    final response = await http.post(
      Uri.parse(b2bApi),
      headers: headers,
      body: jsonEncode({
        "action": "get_managing_products",
        "page": 1,
        "limit": 10,
      }),
    );
    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");
    
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null && data['data']['products'] != null) {
      final List productsList = data['data']['products'];
      print("✅ Retrieved ${productsList.length} B2B products.");
      if (productsList.isNotEmpty) {
        b2bProductId = productsList[0]['product_id']?.toString();
        b2bVariantId = productsList[0]['variant_id']?.toString() ?? '0';
        print("-> Selecting first B2B Product ID: $b2bProductId, Variant ID: $b2bVariantId for sub-tests");
      }
    } else {
      print("❌ B2B Products fetching failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error testing B2B Fetch: $e");
  }

  if (b2bProductId != null) {
    // Test B2B Stats
    try {
      print("\nAction: get_product_stats (B2B)");
      final response = await http.post(
        Uri.parse(b2bApi),
        headers: headers,
        body: jsonEncode({
          "action": "get_product_stats",
          "product_id": b2bProductId,
        }),
      );
      print("HTTP Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    } catch (e) {
      print("❌ Error testing B2B Stats: $e");
    }

    // Test B2B Collateral
    try {
      print("\nAction: get_product_collateral (B2B)");
      final response = await http.post(
        Uri.parse(b2bApi),
        headers: headers,
        body: jsonEncode({
          "action": "get_product_collateral",
          "product_id": b2bProductId,
          "variant_id": b2bVariantId,
          "marketplace_id": 51,
        }),
      );
      print("HTTP Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    } catch (e) {
      print("❌ Error testing B2B Collateral: $e");
    }
  }

  // ----------------------- COMBO PRODUCTS TEST -----------------------
  print("\n==============================================");
  print("🎁 Testing Combo Packages (combo_vendor_api.php)");
  print("==============================================");
  
  List<dynamic> comboList = [];
  try {
    print("Action: get_combo_packages");
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
    }
  } catch (e) {
    print("❌ Error testing Combo Fetch: $e");
  }

  if (comboList.isNotEmpty) {
    final selectedCombo = comboList[0];
    final comboId = selectedCombo['id']?.toString() ?? '';
    final currentStatus = selectedCombo['status']?.toString() ?? '0';
    final newStatus = currentStatus == '1' ? '0' : '1';

    // Test Toggle Combo Status
    try {
      print("\nAction: update_combo_status");
      print("Toggling Combo ID $comboId status from $currentStatus to $newStatus...");
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
    } catch (e) {
      print("❌ Error testing Combo Status Toggle: $e");
    }

    // Test Delete Combo Package (Optional confirmation prompt)
    print("\nAction: delete_combo_package (Optional)");
    stdout.write("Do you want to test deleting a combo package? (y/n): ");
    final wantDelete = (stdin.readLineSync()?.trim() ?? "n").toLowerCase() == "y";

    if (wantDelete) {
      stdout.write("Enter combo package ID to delete (pid): ");
      final deletePid = stdin.readLineSync()?.trim();
      if (deletePid != null && deletePid.isNotEmpty) {
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
        } catch (e) {
          print("❌ Error testing Combo Deletion: $e");
        }
      }
    }
  }

  print("\n==============================================");
  print("🎉 Product Management Integration Test Complete!");
  print("==============================================");
}
