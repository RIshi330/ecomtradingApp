import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String affiliateApi = "${baseUrl}new_apis/order_product_placement_API (1).php";

  print("==================================================");
  print("Affiliate Orders API Backend Integration Test");
  print("==================================================");

  // Step 1: Fetch all affiliate orders
  print("\n--- Step 1: Fetching Affiliate Orders ---");
  Map<String, dynamic> firstOrder = {};

  try {
    final response = await http.get(
      Uri.parse(affiliateApi),
    );

    print("HTTP Status Code: ${response.statusCode}");
    print("RAW JSON Response: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Successfully fetched affiliate orders!");
      final List<dynamic> orders = data['orders'] ?? [];
      print("Orders Count: ${orders.length}");

      for (var order in orders) {
        print(" - Order ID: ${order['order_id']} | Product: ${order['product_name']} | Price: ₹${order['price']} | Status: ${order['status_text']} (${order['status']})");
      }

      if (orders.isNotEmpty) {
        final order = orders.first;
        firstOrder = {
          'order_id': order['order_id']?.toString() ?? '',
          'item_id': order['item_id']?.toString() ?? '',
          'variant_id': order['variant_id']?.toString() ?? '0',
          'marketplace_id': order['marketplace_id']?.toString() ?? '',
          'current_status': order['status']?.toString() ?? '0',
        };
      }
    } else {
      print("❌ Failed to fetch orders: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error fetching orders: $e");
  }

  // If no orders were fetched, we simulate with mock values or skip the update part
  if (firstOrder.isEmpty) {
    print("\n⚠️ No affiliate orders in database. Skipping live status update check.");
    print("==============================================");
    print("🎉 Affiliate Orders Backend Test Finished!");
    print("==============================================");
    return;
  }

  // Step 2: Update status of first order
  print("\n--- Step 2: Updating Status for Order ${firstOrder['order_id']} to Shipped (6) ---");
  try {
    final response = await http.post(
      Uri.parse(affiliateApi),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        'action': 'update_status',
        'order_id': firstOrder['order_id'],
        'item_id': firstOrder['item_id'],
        'variant_id': firstOrder['variant_id'],
        'marketplace_id': firstOrder['marketplace_id'],
        'status_val': 6, // Shipped / In Transit
      }),
    );

    print("HTTP Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Status updated successfully on backend!");
    } else {
      print("❌ Failed to update status: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error updating status: $e");
  }

  // Step 3: Refetch and verify
  print("\n--- Step 3: Verifying Status Update ---");
  try {
    final response = await http.get(
      Uri.parse(affiliateApi),
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final List<dynamic> orders = data['orders'] ?? [];
      final updatedOrder = orders.firstWhere(
        (o) => o['order_id'] == firstOrder['order_id'],
        orElse: () => null,
      );

      if (updatedOrder != null) {
        print("✅ Refetched Order status: ${updatedOrder['status_text']} (${updatedOrder['status']})");
        if (updatedOrder['status']?.toString() == '6') {
          print("🎉 Verification Successful! Backend state correctly transitioned to Shipped.");
        } else {
          print("❌ Verification Failed. State is still ${updatedOrder['status']}.");
        }
      }
    }
  } catch (e) {
    print("❌ Error verifying status: $e");
  }

  print("\n==============================================");
  print("🎉 Affiliate Orders Backend Integration Test Finished!");
  print("==============================================");
}
