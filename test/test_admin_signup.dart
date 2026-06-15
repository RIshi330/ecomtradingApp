import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://127.0.0.1/SetupBackendCCBUL/android/";
  const String apiUrl = "${baseUrl}new_apis/sign_up_API.php";

  stdout.write("Enter email for admin signup test: ");
  final email = stdin.readLineSync()?.trim();
  if (email == null || email.isEmpty) {
    print("Email cannot be empty.");
    return;
  }

  print("\nStep 1: Sending Signup OTP to $email...");
  try {
    final response1 = await http.post(
      Uri.parse(apiUrl),
      body: {
        'action': 'send_signup_otp',
        'email': email,
      },
    );

    print("Status Code: ${response1.statusCode}");
    print("Raw Response: ${response1.body}");

    final data1 = jsonDecode(response1.body);
    if (data1['success'] != true) {
      print("Failed to send OTP: ${data1['message']}");
      return;
    }

    // Capture PHP Session Cookie from response headers to maintain session state
    final cookies = response1.headers['set-cookie'];
    final headers = <String, String>{};
    if (cookies != null) {
      headers['Cookie'] = cookies.split(';').first;
      print("Session Cookie Captured: ${headers['Cookie']}");
    }

    print("\nOTP Sent successfully!");
    stdout.write("Enter the 6-digit OTP received in mail: ");
    final otp = stdin.readLineSync()?.trim();
    if (otp == null || otp.isEmpty) {
      print("OTP cannot be empty.");
      return;
    }

    stdout.write("Enter Name: ");
    final name = stdin.readLineSync()?.trim() ?? "Test Admin";
    stdout.write("Enter Mobile: ");
    final mobile = stdin.readLineSync()?.trim() ?? "1234567890";
    stdout.write("Enter Password: ");
    final password = stdin.readLineSync()?.trim() ?? "admin123";

    print("\nStep 2: Verifying OTP and creating Admin account...");
    final response2 = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: {
        'action': 'verify_signup_otp',
        'otp': otp,
        'name': name,
        'mobile': mobile,
        'vendor_type': '1', // '1' indicates Admin vendor_type
        'password': password,
      },
    );

    print("Status Code: ${response2.statusCode}");
    print("Raw Response: ${response2.body}");

    final data2 = jsonDecode(response2.body);
    if (data2['success'] == true) {
      print("\n==============================================");
      print("🎉 SUCCESS: Admin account created successfully!");
      print("Admin Vendor ID: ${data2['vendor_id']}");
      print("Access Key: ${data2['access_key']}");
      print("SecretKey: ${data2['secret_key']}");
      print("Account Status: ${data2['status']}");
      print("==============================================");
    } else {
      print("\n❌ FAILED: ${data2['message']}");
    }
  } catch (e) {
    print("Error during testing: $e");
  }
}
