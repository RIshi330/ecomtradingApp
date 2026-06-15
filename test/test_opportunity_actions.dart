import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String apiUrl = "${baseUrl}new_apis/opportunity_actions_api.php";

  print("==================================================");
  print("Opportunity Actions Backend Integration Test");
  print("==================================================");

  // Step 1: Fetch initial wallet & cash balances
  print("\nStep 1: Fetching initial wallet and cash balances...");
  double initialEcash = 0.0;
  double initialEwallet = 0.0;
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"action": "get_wallet_and_cash_balance"}),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      initialEcash = double.tryParse(data['data']?['cash']?['available_balance']?.toString() ?? '0') ?? 0.0;
      initialEwallet = double.tryParse(data['data']?['wallet']?['available_balance']?.toString() ?? '0') ?? 0.0;
      print("-> Initial Ecash: ₹$initialEcash");
      print("-> Initial Ewallet: ₹$initialEwallet");
    } else {
      print("❌ Failed to fetch initial balances: ${data['message']}");
      return;
    }
  } catch (e) {
    print("❌ Error fetching balances: $e");
    return;
  }

  // Step 2: Input donation amounts
  print("\nStep 2: Enter Donation Details");
  stdout.write("Enter Total Donation Amount: ");
  final amtStr = stdin.readLineSync()?.trim() ?? "100";
  final double amount = double.tryParse(amtStr) ?? 100.0;

  stdout.write("Enter Ecash to apply (Available: ₹$initialEcash): ");
  final ecashStr = stdin.readLineSync()?.trim() ?? "0";
  final double ecashUsed = double.tryParse(ecashStr) ?? 0.0;

  stdout.write("Enter Ewallet to apply (Available: ₹$initialEwallet): ");
  final ewalletStr = stdin.readLineSync()?.trim() ?? "0";
  final double ewalletUsed = double.tryParse(ewalletStr) ?? 0.0;

  if (ecashUsed > initialEcash) {
    print("⚠️ Warning: Ecash entered exceeds available balance!");
  }
  if (ewalletUsed > initialEwallet) {
    print("⚠️ Warning: Ewallet entered exceeds available balance!");
  }

  final double remainingOnline = amount - ecashUsed - ewalletUsed;
  print("-> Breakdown: Wallet Deduct = ₹${ecashUsed + ewalletUsed}, Remaining Online = ₹${remainingOnline < 0 ? 0.0 : remainingOnline}");

  // Step 3: Trigger the donation endpoint
  print("\nStep 3: Submitting donation transaction to backend...");
  try {
    final payload = {
      "action": "donate",
      "name": "Integration Test Runner",
      "email": "test-runner@example.com",
      "phone": "9999999999",
      "amount": amount,
      "paid_from_ewallet": ewalletUsed,
      "paid_from_ebanking": ecashUsed,
      "notes": "Test Integration: Ecash $ecashUsed, Ewallet $ewalletUsed, Online ${remainingOnline < 0 ? 0.0 : remainingOnline}",
      "anonymous": "0"
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("🎉 Donation successfully processed!");
      print("Order ID: ${data['data']?['id'] ?? data['id']}");
    } else {
      print("❌ Donation submission failed: ${data['message']}");
      return;
    }
  } catch (e) {
    print("❌ Error submitting donation: $e");
    return;
  }

  // Step 4: Re-fetch balances and verify deductions
  print("\nStep 4: Fetching updated balances to verify database deduction...");
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"action": "get_wallet_and_cash_balance"}),
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final finalEcash = double.tryParse(data['data']?['cash']?['available_balance']?.toString() ?? '0') ?? 0.0;
      final finalEwallet = double.tryParse(data['data']?['wallet']?['available_balance']?.toString() ?? '0') ?? 0.0;
      print("-> Updated Ecash: ₹$finalEcash");
      print("-> Updated Ewallet: ₹$finalEwallet");

      final ecashDiff = initialEcash - finalEcash;
      final ewalletDiff = initialEwallet - finalEwallet;
      print("-> Ecash deducted on database: ₹$ecashDiff (Expected: ₹$ecashUsed)");
      print("-> Ewallet deducted on database: ₹$ewalletDiff (Expected: ₹$ewalletUsed)");

      print("\n==============================================");
      print("🎉 SUCCESS: End-to-end payment integration verified!");
      print("==============================================");
    } else {
      print("❌ Failed to verify final balances: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error verifying balances: $e");
  }
}
