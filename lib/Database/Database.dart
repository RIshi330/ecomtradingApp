import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';
import '../index.dart';
import '../services/auth_service.dart';

/// Database class for handling API communication
/// Centralized API client with session management and secure storage
class Database {
  int retry = 0;
  static String? _cachedSessionId;
  static final List<Map<String, dynamic>> apiLogs = [];

  /// Get Android options for secure storage
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  /// Main API communication method
  /// Handles all API calls with session management and error handling
  Future<Map> getData(Map postBody, {String? endpoint, int? appIdOverride}) async {
    var result = {};
    Map<String, String> stringBody = {}; // Initialize here

    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    if (_cachedSessionId == null || _cachedSessionId!.isEmpty) {
      _cachedSessionId = await _readSecureKey(storage, "SESSION_ID");
    }
    final existingSessionId = _cachedSessionId;

    try {
      // Convert all body values to strings to avoid type cast issues
      stringBody =
          postBody.map((key, value) => MapEntry(key, value?.toString() ?? ''));

      final targetUrl = endpoint != null
          ? Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'))
          : Uri.parse(baseUrl);

      final logEntry = {
        'timestamp': DateTime.now().toString(),
        'url': targetUrl.toString(),
        'body': stringBody.toString(),
        'headers': {
          'APP_ID': (appIdOverride ?? appId).toString(),
          'SESSION-ID': existingSessionId?.toString() ?? '',
        }.toString(),
        'response': '',
        'statusCode': 0,
        'error': '',
      };
      apiLogs.insert(0, logEntry);
      if (apiLogs.length > 100) {
        apiLogs.removeLast();
      }

      print('Database [getData]: Sending request to $targetUrl with SESSION-ID: $existingSessionId and BODY: $stringBody');

      final response = await http.post(
        targetUrl,
        body: stringBody,
        headers: {
          'APP_ID': (appIdOverride ?? appId).toString(),
          'SESSION-ID': existingSessionId?.toString() ?? '',
          if (existingSessionId != null && existingSessionId.isNotEmpty)
            'Cookie': 'PHPSESSID=$existingSessionId',
        },
      );

      logEntry['statusCode'] = response.statusCode;
      logEntry['response'] = response.body;

      var copy = response.body;
      print('RAW RESPONSE BODY: "${copy}"');
      print('RESPONSE STATUS CODE: ${response.statusCode}');
      print('RESPONSE HEADERS: ${response.headers}');

      if (copy.isEmpty) {
        print('EMPTY RESPONSE - Server returned no content');
        result = {
          "status": 300,
          "error": "Server returned empty response",
          "debug_info": {
            "status_code": response.statusCode,
            "headers": response.headers.toString(),
          },
        };
      } else {
        try {
          dynamic decodedResponse = jsonDecode(copy);

          // Handle both Map and List responses
          if (decodedResponse is Map) {
            result = Map<String, dynamic>.from(decodedResponse);
          } else if (decodedResponse is List) {
            // If it's a list, wrap it in a map for consistency
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          } else {
            // Scalar value (e.g., integer 1 from echo 1; die;)
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          }
        } catch (jsonError) {
          print('JSON DECODE ERROR: $jsonError');
          print('RAW RESPONSE THAT FAILED JSON DECODE: "${copy}"');
          result = {
            "status": 300,
            "error": "Invalid JSON response from server",
            "raw_response": copy,
            "json_error": jsonError.toString(),
            "debug_info": {
              "status_code": response.statusCode,
              "headers": response.headers.toString(),
            },
          };
        }
      }

      // Check for 401 Unauthorized or unauthorized messages in response
      bool isUnauthorized = false;
      if (response.statusCode == 401) {
        isUnauthorized = true;
      } else if (result is Map) {
        final message = result['message']?.toString() ?? '';
        final error = result['error']?.toString() ?? '';
        if (message.contains('Unauthorized') || error.contains('Unauthorized')) {
          isUnauthorized = true;
        }
      }

      if (isUnauthorized) {
        print('Database [getData]: Unauthorized response detected (401 or Unauthorized message). Logging out.');
        _cachedSessionId = null;
        final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
        await storage.deleteAll();
        await AuthService.clearSession();
        
        AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
        
        return {
          'success': false,
          'message': 'Session expired. Please log in again.',
          'status': 401,
          'data': [],
        };
      }

      // Store Razorpay key if present
      if (result.containsKey('RAZORPAY_KEY') &&
          result['RAZORPAY_KEY'] != null &&
          liveModeEnabled) {
        var razorpayKey = result['RAZORPAY_KEY'];
        await storage.write(key: "razorpay_key", value: razorpayKey.toString());
      } else {
        var razorpayKey = razorpayTestKey;
        await storage.write(key: "razorpay_key", value: razorpayKey.toString());
      }

      // Store admin email if present
      if (result.containsKey('admin_email') && result['admin_email'] != null) {
        await storage.write(
            key: 'admin_email', value: result['admin_email'].toString());
      }

      // Handle session management - FIXED NULL SAFETY
      if (result.containsKey('SESSION_ID') &&
          result['SESSION_ID'] != null &&
          result['SESSION_ID'].toString().isNotEmpty &&
          result['SESSION_ID'].toString() != existingSessionId) {
        _cachedSessionId = result['SESSION_ID'].toString();
        await storage.write(
            key: "SESSION_ID", value: result['SESSION_ID'].toString());
      } else if (result['status'] == 400 && result.containsKey("logged_out")) {
        if (retry == 0) {
          retry = 1;
          final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

          String? accessToken;
          String? validator;

          try {
            accessToken = await _readSecureKey(storage, "access_token");
            validator = await _readSecureKey(storage, "validator");
          } catch (e) {
            validator = accessToken = null;
          }

          if (accessToken != null && validator != null) {
            Map<String, String> postData = {
              "auto_login": "true",
              "access_token": accessToken,
              "validator": validator,
            };

            final res = await getData(postData);

            var result = res['LOGIN_RESPONSE'];

            if (result != null &&
                result['status'] == 200 &&
                result['long_term_access_token'] != null &&
                result['token_verifier'] != null) {
              final token = result['long_term_access_token'];
              final validator = result['token_verifier'];

              await storage.write(key: "access_token", value: token.toString());
              await storage.write(
                  key: "validator", value: validator.toString());
              await storage.write(
                  key: "user_data",
                  value: jsonEncode(result['full_data'] ?? {}));
              await storage.write(
                  key: "user_products",
                  value: jsonEncode(res['PRODUCTS'] ?? {}));
              await storage.write(
                  key: "filters", value: jsonEncode(res['filters'] ?? {}));

              return await getData(postBody, endpoint: endpoint);
            }
          }
        }
      }
    } catch (e) {
      if (apiLogs.isNotEmpty) {
        apiLogs.first['error'] = e.toString();
        apiLogs.first['statusCode'] = 500;
      }
      print('Database.dart - Network Error Details:');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('Base URL: $baseUrlLegacy');
      print('Request Body: $stringBody');

      result = {
        "status": 300,
        "error": "Server not reachable - ${e.toString()}",
        "debug_info": {
          "base_url": baseUrlLegacy,
          "error_type": e.runtimeType.toString(),
          "error_message": e.toString(),
        }
      };
    }

    return result;
  }

  /// Main API communication method for JSON requests
  /// Handles JSON body and Content-Type header
  Future<Map> getJsonData(Map<String, dynamic> postBody, {String? endpoint}) async {
    var result = {};

    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    if (_cachedSessionId == null || _cachedSessionId!.isEmpty) {
      _cachedSessionId = await _readSecureKey(storage, "SESSION_ID");
    }
    final existingSessionId = _cachedSessionId;

    try {
      final targetUrl = endpoint != null
          ? Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'))
          : Uri.parse(baseUrl);

      print('Database [getJsonData]: Sending request to $targetUrl with SESSION-ID: $existingSessionId');

      final response = await http.post(
        targetUrl,
        body: jsonEncode(postBody),
        headers: {
          'Content-Type': 'application/json',
          'APP_ID': appId.toString(),
          'SESSION-ID': existingSessionId?.toString() ?? '',
          if (existingSessionId != null && existingSessionId.isNotEmpty)
            'Cookie': 'PHPSESSID=$existingSessionId',
        },
      );

      var copy = response.body;
      print('RAW JSON RESPONSE BODY: "${copy}"');
      print('RESPONSE STATUS CODE: ${response.statusCode}');
      print('RESPONSE HEADERS: ${response.headers}');

      if (copy.isEmpty) {
        print('EMPTY RESPONSE - Server returned no content');
        result = {
          "status": 300,
          "error": "Server returned empty response",
          "debug_info": {
            "status_code": response.statusCode,
            "headers": response.headers.toString(),
          },
        };
      } else {
        try {
          dynamic decodedResponse = jsonDecode(copy);

          // Handle both Map and List responses
          if (decodedResponse is Map) {
            result = Map<String, dynamic>.from(decodedResponse);
          } else if (decodedResponse is List) {
            // If it's a list, wrap it in a map for consistency
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          } else {
            // Scalar value (e.g., integer 1 from echo 1; die;)
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          }
        } catch (jsonError) {
          print('JSON DECODE ERROR: $jsonError');
          print('RAW RESPONSE THAT FAILED JSON DECODE: "${copy}"');
          result = {
            "status": 300,
            "error": "Invalid JSON response from server",
            "raw_response": copy,
            "json_error": jsonError.toString(),
            "debug_info": {
              "status_code": response.statusCode,
              "headers": response.headers.toString(),
            },
          };
        }
      }

      // Check for 401 Unauthorized or unauthorized messages in response
      bool isUnauthorized = false;
      if (response.statusCode == 401) {
        isUnauthorized = true;
      } else if (result is Map) {
        final message = result['message']?.toString() ?? '';
        final error = result['error']?.toString() ?? '';
        if (message.contains('Unauthorized') || error.contains('Unauthorized')) {
          isUnauthorized = true;
        }
      }

      if (isUnauthorized) {
        print('Database [getJsonData]: Unauthorized response detected (401 or Unauthorized message). Logging out.');
        _cachedSessionId = null;
        final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
        await storage.deleteAll();
        await AuthService.clearSession();
        
        AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
        
        return {
          'success': false,
          'message': 'Session expired. Please log in again.',
          'status': 401,
          'data': [],
        };
      }

      // Store Razorpay key if present
      if (result.containsKey('RAZORPAY_KEY') &&
          result['RAZORPAY_KEY'] != null &&
          liveModeEnabled) {
        var razorpayKey = result['RAZORPAY_KEY'];
        await storage.write(key: "razorpay_key", value: razorpayKey.toString());
      } else {
        var razorpayKey = razorpayTestKey;
        await storage.write(key: "razorpay_key", value: razorpayKey.toString());
      }

      // Store admin email if present
      if (result.containsKey('admin_email') && result['admin_email'] != null) {
        await storage.write(
            key: 'admin_email', value: result['admin_email'].toString());
      }

      // Handle session management
      if (result.containsKey('SESSION_ID') &&
          result['SESSION_ID'] != null &&
          result['SESSION_ID'].toString().isNotEmpty &&
          result['SESSION_ID'].toString() != existingSessionId) {
        _cachedSessionId = result['SESSION_ID'].toString();
        await storage.write(
            key: "SESSION_ID", value: result['SESSION_ID'].toString());
      }
    } catch (e) {
      print('Database.dart (JSON) - Network Error Details:');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('Base URL: $baseUrlLegacy');
      print('Request Body: $postBody');

      result = {
        "status": 300,
        "error": "Server not reachable - ${e.toString()}",
        "debug_info": {
          "base_url": baseUrlLegacy,
          "error_type": e.runtimeType.toString(),
          "error_message": e.toString(),
        }
      };
    }

    return result;
  }

  /// Get current session ID
  Future<String?> getSessionId() async {
    if (_cachedSessionId != null && _cachedSessionId!.isNotEmpty) {
      return _cachedSessionId;
    }
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    _cachedSessionId = await _readSecureKey(storage, "SESSION_ID");
    return _cachedSessionId;
  }

  /// Get stored Razorpay key
  Future<String?> getRazorpayKey() async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    return await _readSecureKey(storage, "razorpay_key");
  }

  /// Store user data securely
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.write(key: "user_data", value: jsonEncode(userData));
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
      final userData = await _readSecureKey(storage, "user_data");
      return userData != null ? jsonDecode(userData) : null;
    } catch (e) {
      print("Error reading user data: $e");
      return null;
    }
  }

  /// Clear all stored data (for logout)
  Future<void> clearAllData() async {
    _cachedSessionId = null;
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.deleteAll();
  }

  /// Store access token for auto-login
  Future<void> storeAccessToken(String token, String validator) async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.write(key: "access_token", value: token);
    await storage.write(key: "validator", value: validator);
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    return await _readSecureKey(storage, "access_token");
  }

  /// Store user preferences
  Future<void> storeUserPreferences(Map<String, dynamic> preferences) async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.write(
        key: "user_preferences", value: jsonEncode(preferences));
  }

  /// Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
      final preferences = await _readSecureKey(storage, "user_preferences");
      return preferences != null ? jsonDecode(preferences) : null;
    } catch (e) {
      print("Error reading user preferences: $e");
      return null;
    }
  }

  /// Safe secure storage key reading helper
  Future<String?> _readSecureKey(FlutterSecureStorage storage, String key) async {
    try {
      return await storage.read(key: key);
    } catch (e) {
      print("Secure storage read failed for key $key, clearing corrupted storage: $e");
      try {
        await storage.deleteAll();
      } catch (clearError) {
        print("Failed to delete corrupted storage: $clearError");
      }
      return null;
    }
  }
}
