import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final headers = <String, String>{
  "Content-Type": "application/json",
};

// Helper function to send requests and maintain session cookies
Future<http.Response> sendPostRequest(String url, String body) async {
  final response = await http.post(
    Uri.parse(Uri.encodeFull(url)),
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
  const String paymentModalApi = "${baseUrl}new_apis/payment_modal_API.php";
  const String proliferationPaymentApi = "${baseUrl}new_apis/proliferatiion_payment_API.php";

  print("==================================================");
  print("Proliferation Payment API Backend Integration Test");
  print("==================================================");

  // Step 1: Authentication Mode
  print("Select Authentication Mode:");
  print("1. Authenticate with Login Credentials");
  print("2. Test with default session (uses default vendor_id)");
  stdout.write("Enter choice (1-2) [Default: 2]: ");
  final mode = stdin.readLineSync()?.trim() ?? "2";

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
  } else {
    print("Using default backend test session (vendor_id = 2).");
  }

  // Step 2: Fetch Sites to find a valid site ID
  print("\n--- Step 2: Fetching Site Cards ---");
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

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      sitesList = data['data'] is List ? data['data'] : [];
      print("✅ Retrieved ${sitesList.length} site cards.");
    } else {
      print("❌ Failed to fetch site cards: ${data['message']}");
      return;
    }
  } catch (e) {
    print("❌ Error fetching site cards: $e");
    return;
  }

  if (sitesList.isEmpty) {
    print("\n❌ No sites found in database. Cannot proceed with payment tests.");
    return;
  }

  var selectedSite = sitesList.first;
  for (var s in sitesList) {
    final double pr = double.tryParse(s['avg_price']?.toString() ?? '0') ?? 0.0;
    if (pr > 0) {
      selectedSite = s;
      break;
    }
  }
  final siteId = selectedSite['site_id']?.toString() ?? '0';

  // Step 3: Initialize Cart
  print("\n--- Step 3: Initializing Proliferation Cart ---");
  try {
    final response = await sendPostRequest(
      selectSitesApi,
      jsonEncode({"action": "initialise_cart"}),
    );
    print("Response: ${response.body}");
  } catch (e) {
    print("❌ Error initializing cart: $e");
  }

  // Step 4: Add multiple sites to Cart
  print("\n--- Step 4: Adding multiple sites to Cart ---");
  final List<String> addedSiteIds = ["2"];
  try {
    for (int i = 0; i < sitesList.length && i < 3; i++) {
      final sId = sitesList[i]['site_id']?.toString() ?? '0';
      if (sId == "2") continue; // Already added
      addedSiteIds.add(sId);
      final response = await sendPostRequest(
        selectSitesApi,
        jsonEncode({
          "action": "add_item_to_cart",
          "item_id": sId,
          "type": "sites",
        }),
      );
      print("Added Site ID $sId: ${response.body}");
    }
    // Explicitly call add_item_to_cart for ID 2 to ensure it is in the cart session
    final response2 = await sendPostRequest(
      selectSitesApi,
      jsonEncode({
        "action": "add_item_to_cart",
        "item_id": "2",
        "type": "sites",
      }),
    );
    print("Added Site ID 2: ${response2.body}");
  } catch (e) {
    print("❌ Error adding sites to cart: $e");
  }
  final String sitesStr = addedSiteIds.join(',');

  // Step 5: Fetch Balances
  print("\n--- Step 5: Retrieving Wallet/E-banking Balances ---");
  double ecash = 0.0;
  double ewallet = 0.0;
  try {
    final response = await sendPostRequest(
      paymentModalApi,
      jsonEncode({"action": "get_balances"}),
    );
    print("Balances Response: ${response.body}");
    final resBody = jsonDecode(response.body);
    if (resBody['success'] == true && resBody['data'] != null) {
      ecash = double.tryParse(resBody['data']['ecash_balance']?.toString() ?? '0') ?? 0.0;
      ewallet = double.tryParse(resBody['data']['ewallet_balance']?.toString() ?? '0') ?? 0.0;
      print("✅ E-Cash Balance: ₹$ecash");
      print("✅ E-Wallet Balance: ₹$ewallet");
    }
  } catch (e) {
    print("❌ Error fetching balances: $e");
  }

  // Step 6: Make Payment (Checkout)
  print("\n--- Step 6: Triggering make_payment Checkout ---");
  stdout.write("Use how much E-wallet balance? (Max ₹$ewallet) [Default: 0]: ");
  final walletInputStr = stdin.readLineSync()?.trim() ?? "0";
  final useEwallet = double.tryParse(walletInputStr) ?? 0.0;

  stdout.write("Use how much E-banking (E-cash) balance? (Max ₹$ecash) [Default: 0]: ");
  final ecashInputStr = stdin.readLineSync()?.trim() ?? "0";
  final useEcash = double.tryParse(ecashInputStr) ?? 0.0;

  bool requireRazorpay = false;
  try {
    final response = await sendPostRequest(
      proliferationPaymentApi,
      jsonEncode({
        "action": "make_payment",
        "sites": sitesStr,
        "use_from_ebanking": useEcash,
        "use_from_ewallet": useEwallet,
      }),
    );

    print("Checkout HTTP Status: ${response.statusCode}");
    print("Checkout Response: ${response.body}");

    final resBody = jsonDecode(response.body);
    if (resBody.containsKey('wallet') && resBody['wallet'] == true) {
      print("✅ Payment fully covered by wallet! Order completed on backend.");
    } else if (resBody.containsKey('error')) {
      print("❌ Backend returned error: ${resBody['error']}");
    } else if (resBody['success'] == true) {
      print("✅ Razorpay Order generated successfully.");
      requireRazorpay = true;
    } else {
      print("❌ Unknown checkout status.");
    }
  } catch (e) {
    print("❌ Error executing make_payment: $e");
  }

  // Step 7: Verify Payment (If Razorpay is triggered)
  if (requireRazorpay) {
    print("\n--- Step 7: Verifying Razorpay Order ---");
    try {
      final response = await sendPostRequest(
        proliferationPaymentApi,
        jsonEncode({
          "action": "verifyProliferationPayment",
        }),
      );
      print("Verify HTTP Status: ${response.statusCode}");
      print("Verify Response: ${response.body}");
      final resBody = jsonDecode(response.body);
      if (resBody['success'] == true) {
        print("✅ Proliferation Payment Verified successfully!");
      } else {
        print("❌ Proliferation Payment Verification failed.");
      }
    } catch (e) {
      print("❌ Error executing verification: $e");
    }
  }

  print("\n==============================================");
  print("🎉 Proliferation Payment Integration Test Done!");
  print("==============================================");
}
