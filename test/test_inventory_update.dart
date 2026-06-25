import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String loginApi = "${baseUrl}new_apis/sign_up_API.php";
  const String inventoryApi = "${baseUrl}new_apis/inventory_update.php";

  print("==================================================");
  print("Inventory Update Backend Integration Test");
  print("==================================================");

  // Authenticate
  print("\n--- Authentication ---");
  stdout.write("Enter email: ");
  final email = stdin.readLineSync()?.trim() ?? "";
  stdout.write("Enter password: ");
  final password = stdin.readLineSync()?.trim() ?? "";
  stdout.write("Login as Admin? (y/n): ");
  final isAdmin = (stdin.readLineSync()?.trim() ?? "n").toLowerCase() == "y";

  if (email.isEmpty || password.isEmpty) {
    print("❌ Email and password cannot be empty.");
    return;
  }

  final headers = <String, String>{};

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

    print("Login Status: ${loginResponse.statusCode}");
    print("Login Response: ${loginResponse.body}");

    final loginData = jsonDecode(loginResponse.body);
    if (loginData['success'] != true && loginData['status'] != 200) {
      print("❌ Login failed: ${loginData['message'] ?? 'Unknown error'}");
      return;
    }

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

  // 1. Fetch Low Stock List
  List<dynamic> products = [];
  print("\n--- 1. Testing stockList Action ---");
  try {
    final response = await http.post(
      Uri.parse(inventoryApi),
      headers: headers,
      body: {
        'action': 'stockList',
      },
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['ok'] == true && data['data'] is List) {
      products = data['data'];
      print("✅ Successfully fetched ${products.length} low stock items.");
    } else {
      print("❌ Failed to fetch stock list: ${data['error'] ?? 'Unknown error'}");
    }
  } catch (e) {
    print("❌ Error during stockList fetch: $e");
  }

  if (products.isEmpty) {
    print("\n⚠️ No low stock products found to test update stock action. Exiting.");
    return;
  }

  // 2. Select first product and update stock
  final testProduct = products.first;
  final variantId = testProduct['variant_id'];
  final currentStock = testProduct['a_stock'];
  final productTitle = testProduct['product_title'];

  print("\n--- 2. Testing update Action for Variant ID $variantId ($productTitle) ---");
  print("Current a_stock: $currentStock");
  stdout.write("Enter new stock count to set (e.g. 10): ");
  final newStockStr = stdin.readLineSync()?.trim() ?? "10";
  final newStock = int.tryParse(newStockStr) ?? 10;

  try {
    final response = await http.post(
      Uri.parse(inventoryApi),
      headers: headers,
      body: {
        'action': 'update',
        'id': variantId.toString(),
        'stock': newStock.toString(),
      },
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['ok'] == true) {
      print("✅ Successfully updated stock!");
    } else {
      print("❌ Failed to update stock: ${data['error'] ?? 'Unknown error'}");
    }
  } catch (e) {
    print("❌ Error during update action: $e");
  }

  // 3. Verify updated stock
  print("\n--- 3. Verifying updated stock via stockList ---");
  try {
    final response = await http.post(
      Uri.parse(inventoryApi),
      headers: headers,
      body: {
        'action': 'stockList',
      },
    );

    final data = jsonDecode(response.body);
    if (data['ok'] == true && data['data'] is List) {
      final updatedList = data['data'] as List;
      final match = updatedList.firstWhere(
        (element) => element['variant_id'] == variantId,
        orElse: () => null,
      );

      if (match != null) {
        print("Updated a_stock for variant $variantId: ${match['a_stock']}");
        if (match['a_stock'] == newStock) {
          print("🎉 VERIFICATION SUCCESS: Stock matches the new value ($newStock)!");
        } else {
          print("❌ VERIFICATION FAILURE: Stock is ${match['a_stock']}, expected $newStock.");
        }
      } else {
        print("ℹ️ Note: Variant $variantId is no longer in the low stock list (this is expected if updated stock $newStock >= 5).");
      }
    } else {
      print("❌ Failed to fetch stock list for verification.");
    }
  } catch (e) {
    print("❌ Error during verification: $e");
  }

  print("\n==============================================");
  print("🎉 Inventory Update Backend Integration Test Complete!");
  print("==============================================");
}
