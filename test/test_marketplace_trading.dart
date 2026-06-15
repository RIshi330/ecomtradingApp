import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String tradingApi = "${baseUrl}new_apis/marketplace_trading_API.php";

  print("==================================================");
  print("Marketplace Trading API Backend Integration Test");
  print("==================================================");

  // Step 1: Fetch all products and services
  print("\n--- Step 1: Fetching Marketplace Listings ---");
  Map<String, String> fetchedItem = {};

  try {
    final response = await http.post(
      Uri.parse(tradingApi),
      body: {
        'keyword': '',
      },
    );

    print("HTTP Status Code: ${response.statusCode}");
    print("RAW JSON Response: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      print("✅ Successfully fetched marketplace listings!");
      final dataMap = data['data'];

      // B2C / Org products
      final orgList = dataMap['org_products'] as List?;
      print("ORG Products Count: ${orgList?.length ?? 0}");
      if (orgList != null && orgList.isNotEmpty) {
        for (var item in orgList) {
          print(" - [ORG] Product ID: ${item['product_id']} | Variant: ${item['variant_id']} | Title: ${item['title']} | Price: ${item['price']} | Selected: ${item['is_selected']}");
        }
        final firstItem = orgList.first;
        fetchedItem = {
          'id': firstItem['product_id']?.toString() ?? '',
          'variantId': firstItem['variant_id']?.toString() ?? '',
          'marketplaceId': '5',
        };
      }

      // B2B / Btb products
      final btbList = dataMap['btb_products'] as List?;
      print("BTB Products Count: ${btbList?.length ?? 0}");
      if (btbList != null && btbList.isNotEmpty) {
        for (var item in btbList) {
          print(" - [BTB] Product ID: ${item['product_id']} | Variant: ${item['variant_id']} | Title: ${item['title']} | Price: ${item['price']}");
        }
        if (fetchedItem.isEmpty) {
          final firstItem = btbList.first;
          fetchedItem = {
            'id': firstItem['product_id']?.toString() ?? '',
            'variantId': firstItem['variant_id']?.toString() ?? '',
            'marketplaceId': '6',
          };
        }
      }

      // Services
      final servicesList = dataMap['services'] as List?;
      print("Services Count: ${servicesList?.length ?? 0}");
      if (servicesList != null && servicesList.isNotEmpty) {
        for (var item in servicesList) {
          print(" - [Service] ID: ${item['service_id']} | Name: ${item['name']} | Price: ${item['price']} | Selected: ${item['is_selected']}");
        }
        if (fetchedItem.isEmpty) {
          final firstItem = servicesList.first;
          fetchedItem = {
            'id': firstItem['service_id']?.toString() ?? '',
            'variantId': '0',
            'marketplaceId': '16',
          };
        }
      }
    } else {
      print("❌ Failed to fetch listings: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error fetching listings: $e");
  }

  // If no items were fetched from database, we construct a default item ID for select testing
  if (fetchedItem.isEmpty) {
    print("\n⚠️ No listings retrieved from database. Testing with mock product details.");
    fetchedItem = {
      'id': '1',
      'variantId': '1',
      'marketplaceId': '5',
    };
  }

  // Step 2: Post Selected Items to the API
  print("\n--- Step 2: Selecting Item (Adding to List) ---");
  final itemString = "${fetchedItem['id']}-${fetchedItem['variantId']}-${fetchedItem['marketplaceId']}";
  final itemsJson = jsonEncode([itemString]);
  print("Sending items selection format: $itemsJson");

  try {
    final response = await http.post(
      Uri.parse(tradingApi),
      body: {
        'keyword': '',
        'selectItems': 'true',
        'items': itemsJson,
      },
    );

    print("HTTP Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      print("✅ Successfully saved selection on the server!");
    } else {
      print("❌ Failed to save selection: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error saving selection: $e");
  }

  print("\n==============================================");
  print("🎉 Marketplace Trading API Integration Test Finished!");
  print("==============================================");
}
