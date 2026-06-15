import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final headers = <String, String>{
  "Content-Type": "application/json",
};

// Helper function to send requests and maintain cookies (for PHP sessions)
Future<http.Response> sendPostRequest(String url, String body) async {
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );

  final cookies = response.headers['set-cookie'];
  if (cookies != null) {
    headers['Cookie'] = cookies.split(';').first;
  }
  return response;
}

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String loginApi = "${baseUrl}new_apis/sign_up_API.php";
  const String selectSitesApi = "${baseUrl}new_apis/select_sites_API 1.php";

  print("==================================================");
  print("Select Sites API Backend Integration Test");
  print("==================================================");

  // Step 1: Authentication Mode
  print("Select Authentication Mode:");
  print("1. Authenticate with Login Credentials");
  print("2. Test without Authentication (Using mock session vendor_id)");
  stdout.write("Enter choice (1-2): ");
  final mode = stdin.readLineSync()?.trim() ?? "1";

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

  // Step 2: Fetch Categories
  print("\n--- Step 2: Fetching Distinct Categories ---");
  try {
    final response = await sendPostRequest(
      selectSitesApi,
      jsonEncode({"action": "get_categories"}),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final List<dynamic> categories = data['data'] ?? [];
      print("✅ Retrieved ${categories.length} categories:");
      for (var cat in categories) {
        print(" - ${cat['item_title']}");
      }
    } else {
      print("❌ Failed to fetch categories: ${data['message']}");
      return;
    }
  } catch (e) {
    print("❌ Error fetching categories: $e");
    return;
  }

  // Step 3: Fetch Site Cards
  print("\n--- Step 3: Fetching Site Cards ---");
  List<dynamic> sitesList = [];
  try {
    final response = await sendPostRequest(
      selectSitesApi,
      jsonEncode({
        "action": "get_site_cards",
        "marketplace_id": 0,
        "keyword": "",
        "approval_type": "",
        "payment_type": "",
        "categories": []
      }),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      sitesList = data['data'] is List ? data['data'] : [];
      print("✅ Retrieved ${sitesList.length} site cards.");
      for (var s in sitesList) {
        print(" - ID: ${s['site_id']} | Name: ${s['site_name']} | Price: ₹${s['avg_price']} | Approval: ${s['need_approval'] == 1 ? 'Manual' : 'Auto'}");
      }
    } else {
      print("❌ Failed to fetch site cards: ${data['message']}");
      return;
    }
  } catch (e) {
    print("❌ Error fetching site cards: $e");
    return;
  }

  if (sitesList.isEmpty) {
    print("\nNo sites found in database. Cannot proceed with modals/cart tests.");
    return;
  }

  // Step 4: Fetch Site Modals (T&C + Prices)
  print("\n--- Step 4: Fetching Site Modals (T&C + Prices) ---");
  try {
    final response = await sendPostRequest(
      selectSitesApi,
      jsonEncode({"action": "get_site_modals"}),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final List<dynamic> modals = data['data'] ?? [];
      print("✅ Retrieved modals for ${modals.length} sites.");
    } else {
      print("❌ Failed to fetch modals: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error fetching modals: $e");
  }

  // Step 5: Initialize Cart
  print("\n--- Step 5: Initializing Proliferation Cart ---");
  try {
    final response = await sendPostRequest(
      selectSitesApi,
      jsonEncode({"action": "initialise_cart"}),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Cart initialized successfully!");
    } else {
      print("❌ Failed to initialize cart: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error initializing cart: $e");
  }

  // Step 6: Test Adding Site to Proliferation Cart
  final selectedSite = sitesList.first;
  final siteId = selectedSite['site_id']?.toString() ?? '0';
  print("\n--- Step 6: Adding Site ID $siteId to Cart ---");
  try {
    final response = await sendPostRequest(
      selectSitesApi,
      jsonEncode({
        "action": "add_item_to_cart",
        "item_id": siteId,
        "type": "sites",
      }),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Site added to cart successfully!");
    } else {
      print("❌ Failed to add site to cart: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error adding site to cart: $e");
  }

  // Step 7: Test Removing Site from Proliferation Cart
  print("\n--- Step 7: Removing Site ID $siteId from Cart ---");
  try {
    final response = await sendPostRequest(
      selectSitesApi,
      jsonEncode({
        "action": "remove_from_proliferation_cart",
        "item_id": siteId,
        "type": "sites",
      }),
    );

    print("HTTP Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Site removed from cart successfully!");
    } else {
      print("❌ Failed to remove site from cart: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error removing site from cart: $e");
  }

  print("\n==============================================");
  print("🎉 Select Sites API Integration Test Finished!");
  print("==============================================");
}
