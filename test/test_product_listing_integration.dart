import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String loginApi = "${baseUrl}new_apis/sign_up_API.php";
  const String productListingApi = "${baseUrl}new_apis/product_listing_api.php";

  print("==================================================");
  print("Product Listing Backend Integration Test");
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

  final headers = <String, String>{
    "Content-Type": "application/json",
  };

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

  // 1. Check Service Posts
  print("\n--- 1. Testing checkServicePosts ---");
  try {
    final response = await http.post(
      Uri.parse(productListingApi),
      headers: headers,
      body: jsonEncode({"action": "checkServicePosts"}),
    );
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
  } catch (e) {
    print("❌ Error: $e");
  }

  // 2. Fetch Categories
  String? testCatId;
  print("\n--- 2. Testing getCategories ---");
  try {
    final response = await http.post(
      Uri.parse(productListingApi),
      headers: headers,
      body: jsonEncode({"action": "getCategories"}),
    );
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] is List && (data['data'] as List).isNotEmpty) {
      testCatId = data['data'][0]['id']?.toString();
      print("✅ First Category ID selected: $testCatId");
    }
  } catch (e) {
    print("❌ Error: $e");
  }

  if (testCatId != null) {
    // 3. Fetch Sub-Categories
    print("\n--- 3. Testing getSubCategories ---");
    try {
      final response = await http.post(
        Uri.parse(productListingApi),
        headers: headers,
        body: jsonEncode({"action": "getSubCategories", "parent_id": testCatId}),
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
    } catch (e) {
      print("❌ Error: $e");
    }

    // 4. Save Product Draft
    print("\n--- 4. Testing saveProduct (Draft) ---");
    try {
      final postData = {
        "action": "saveProduct",
        "cat_id": testCatId,
        "sub_cat_id": "",
        "child_cat_id": "",
        "item_type": "1",
        "product_title": "Integration Test Product ${DateTime.now().millisecondsSinceEpoch}",
        "brand_name": "IntegrationTest",
        "sku": "SKU-INTEG-${DateTime.now().millisecondsSinceEpoch}",
        "origin": "India",
        "product_type": "Physical",
        "brand_ownership": "Own",
        "label_type": "Private Label",
        "manufacturer_type": "Vendor",
        "brand_registration": "No",
        "tags": "integration,test",
        "short_description": "Integration test short description",
        "description": "Integration test detailed description",
        "features": ["Dynamic Feature 1", "Dynamic Feature 2"],
        "pkg_length": "12",
        "pkg_width": "8",
        "pkg_height": "5",
        "pkg_weight": "0.3",
        "packing_type": "Box",
        "units_per_box": "1",
        "gst_type": "Inclusive",
        "gst": "18%",
        "hsn_code": "HSN-987",
        "tax_category": "Standard",
        "product_highlights": "High Quality\nHighly Tested",
        "tech_specs": "Material: Cotton",
        "warranty_available": "Yes",
        "warranty_type": "Brand",
        "warranty_period": "1 Year",
        "warranty_service": "Service Center",
        "warranty_description": "Manufacturer warranty applies",
        "returnable": 1,
        "return_window": "7 Days",
        "cod": 1,
        "replacement": 1,
        "status": 0, // 0 = Draft
        "variants": [
          {
            "title": "Color - Blue",
            "size": "",
            "color": "Blue",
            "fabric": "",
            "measurement": "",
            "price": 899.0,
            "mrp": 1199.0,
            "a_stock": "100",
            "s_stock": "100",
            "sku": "SKU-VAR-BLUE"
          }
        ],
        "btb_pricing": [
          {
            "min_qty": "10",
            "max_qty": "100",
            "mrp": "1199",
            "price": "799",
            "unit": "Units"
          }
        ]
      };

      final response = await http.post(
        Uri.parse(productListingApi),
        headers: headers,
        body: jsonEncode(postData),
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  print("\n==============================================");
  print("🎉 Product Listing Backend Integration Test Complete!");
  print("==============================================");
}
