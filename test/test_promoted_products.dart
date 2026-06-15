import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String promotedApi = "${baseUrl}new_apis/promoted_product_api.php";

  print("==================================================");
  print("Promoted Products API Backend Integration Test");
  print("==================================================");

  // Step 1: Fetch all promoted items
  print("\n--- Step 1: Fetching Promoted / Selected Items ---");
  Map<String, dynamic> firstItem = {};

  try {
    final response = await http.post(
      Uri.parse(promotedApi),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        'action': 'fetch',
      }),
    );

    print("HTTP Status Code: ${response.statusCode}");
    print("RAW JSON Response: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Successfully fetched selected items!");
      final dataMap = data['data'] as Map<String, dynamic>;

      dataMap.forEach((marketplaceId, list) {
        if (list is List && list.isNotEmpty) {
          print("\nMarketplace ID: $marketplaceId (${list.length} items)");
          for (var item in list) {
            print(" - Item ID: ${item['item_id']} | Name: ${item['name']} | Category: ${item['category']} | Price: ₹${item['price']} | Commission: ${item['commission']}");
          }
          if (firstItem.isEmpty) {
            final item = list.first;
            firstItem = {
              'id': item['item_id']?.toString() ?? '',
              'marketplaceId': item['marketplace_id']?.toString() ?? marketplaceId,
            };
          }
        }
      });
    } else {
      print("❌ Failed to fetch promoted items: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error fetching promoted items: $e");
  }

  // If no items were fetched, we use a mock item ID for placement testing
  if (firstItem.isEmpty) {
    print("\n⚠️ No selected items retrieved from database. Testing with mock details.");
    firstItem = {
      'id': '1',
      'marketplaceId': '5',
    };
  }

  // Step 2: Update site placement
  print("\n--- Step 2: Updating Site Placement for Item ID: ${firstItem['id']} ---");
  try {
    final response = await http.post(
      Uri.parse(promotedApi),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        'action': 'update_site',
        'ids': [firstItem['id']],
        'sites': ['1'], // Site ID 1
        'mks': [firstItem['marketplaceId']],
      }),
    );

    print("HTTP Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Successfully placed product on target website!");
    } else {
      print("❌ Failed to update site placement: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error updating site: $e");
  }

  print("\n==============================================");
  print("🎉 Promoted Products Backend Integration Test Finished!");
  print("==============================================");
}
