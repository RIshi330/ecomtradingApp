// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
//
// import '../app_constants.dart';
// import '../index.dart';
// import '../services/auth_service.dart';
//
// /// Database class for handling API communication
// /// Centralized API client with session management and secure storage
// class Database {
//   int retry = 0;
//   static String? _cachedSessionId;
//
//   // ADDED: some endpoints (e.g. admin_login_api.php) rely on PHP's native
//   // session_start()/PHPSESSID cookie rather than the custom SESSION_ID
//   // field the rest of the app uses. Previously nothing captured
//   // Set-Cookie from responses, so those sessions were silently dropped
//   // after the very first request. This caches the raw cookie separately
//   // from the custom SESSION_ID mechanism so both can coexist.
//   static String? _cachedRawCookie;
//
//   /// Get Android options for secure storage
//   AndroidOptions _getAndroidOptions() => const AndroidOptions(
//     encryptedSharedPreferences: true,
//   );
//
//   // ADDED: loads any previously-saved raw cookie (e.g. "PHPSESSID=abc123")
//   Future<String?> _getSavedRawCookie(FlutterSecureStorage storage) async {
//     if (_cachedRawCookie != null && _cachedRawCookie!.isNotEmpty) {
//       return _cachedRawCookie;
//     }
//     _cachedRawCookie = await _readSecureKey(storage, "RAW_COOKIE");
//     return _cachedRawCookie;
//   }
//
//   // ADDED: captures Set-Cookie from a response and persists it
//   Future<void> _saveRawCookieFromResponse(
//       http.Response response,
//       FlutterSecureStorage storage,
//       ) async {
//     final rawCookie = response.headers['set-cookie'];
//     if (rawCookie == null || rawCookie.isEmpty) return;
//
//     final cookiePart = rawCookie.split(';').first;
//     _cachedRawCookie = cookiePart;
//     await storage.write(key: "RAW_COOKIE", value: cookiePart);
//   }
//
//   // ADDED: builds the Cookie header value, preferring a captured raw
//   // cookie (native PHP session) and falling back to the app's custom
//   // SESSION_ID-as-PHPSESSID construction if no raw cookie is cached yet.
//   String? _buildCookieHeader(String? rawCookie, String? existingSessionId) {
//     List<String> cookies = [];
//
//     if (rawCookie != null && rawCookie.isNotEmpty) {
//       // Split rawCookie and filter out any temporary PHPSESSID cookies
//       final parts = rawCookie.split(';');
//       for (var part in parts) {
//         part = part.trim();
//         if (part.isNotEmpty && !part.startsWith('PHPSESSID=')) {
//           cookies.add(part);
//         }
//       }
//     }
//
//     // Always append the correct active logged-in session ID
//     if (existingSessionId != null && existingSessionId.isNotEmpty) {
//       cookies.add('PHPSESSID=$existingSessionId');
//     }
//
//     return cookies.isNotEmpty ? cookies.join('; ') : null;
//   }
//
//   /// Main API communication method
//   /// Handles all API calls with session management and error handling
//   Future<Map> getData(Map postBody, {String? endpoint, int? appIdOverride}) async {
//     var result = {};
//     Map<String, String> stringBody = {}; // Initialize here
//
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     if (_cachedSessionId == null || _cachedSessionId!.isEmpty) {
//       _cachedSessionId = await _readSecureKey(storage, "SESSION_ID");
//     }
//     final existingSessionId = _cachedSessionId;
//     final rawCookie = await _getSavedRawCookie(storage); // ADDED
//
//     try {
//       // Convert all body values to strings to avoid type cast issues
//       stringBody =
//           postBody.map((key, value) => MapEntry(key, value?.toString() ?? ''));
//
//       final targetUrl = endpoint != null
//           ? Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'))
//           : Uri.parse(baseUrl);
//
//       print('Database [getData]: Sending request to $targetUrl with SESSION-ID: $existingSessionId');
//
//       final response = await http.post(
//         targetUrl,
//         body: stringBody,
//         headers: {
//           'APP_ID': (appIdOverride ?? appId).toString(),
//           // SESSION-ID is omitted so standard Cookie-based PHPSESSID handles authentication.
//           // This avoids duplicate session_id() calls on the server which corrupts active sessions.
//           // CHANGED: use the shared cookie builder instead of only ever
//           // constructing "PHPSESSID=$existingSessionId" — this now also
//           // replays a captured native PHP session cookie if one exists.
//           if (_buildCookieHeader(rawCookie, existingSessionId) != null)
//             'Cookie': _buildCookieHeader(rawCookie, existingSessionId)!,
//         },
//       );
//
//       await _saveRawCookieFromResponse(response, storage); // ADDED
//
//       var copy = response.body;
//       print('RAW RESPONSE BODY: "${copy}"');
//       print('RESPONSE STATUS CODE: ${response.statusCode}');
//       print('RESPONSE HEADERS: ${response.headers}');
//
//       if (copy.isEmpty) {
//         print('EMPTY RESPONSE - Server returned no content');
//         result = {
//           "status": 300,
//           "error": "Server returned empty response",
//           "debug_info": {
//             "status_code": response.statusCode,
//             "headers": response.headers.toString(),
//           },
//         };
//       } else {
//         try {
//           dynamic decodedResponse = jsonDecode(copy);
//
//           // Handle both Map and List responses
//           if (decodedResponse is Map) {
//             result = Map<String, dynamic>.from(decodedResponse);
//           } else if (decodedResponse is List) {
//             // If it's a list, wrap it in a map for consistency
//             result = {
//               'success': true,
//               'data': decodedResponse,
//               'status': 200,
//             };
//           } else {
//             // Scalar value (e.g., integer 1 from echo 1; die;)
//             result = {
//               'success': true,
//               'data': decodedResponse,
//               'status': 200,
//             };
//           }
//         } catch (jsonError) {
//           print('JSON DECODE ERROR: $jsonError');
//           print('RAW RESPONSE THAT FAILED JSON DECODE: "${copy}"');
//           result = {
//             "status": 300,
//             "error": "Invalid JSON response from server",
//             "raw_response": copy,
//             "json_error": jsonError.toString(),
//             "debug_info": {
//               "status_code": response.statusCode,
//               "headers": response.headers.toString(),
//             },
//           };
//         }
//       }
//
//       // Check for 401 Unauthorized or unauthorized messages in response
//       bool isUnauthorized = false;
//       if (response.statusCode == 401) {
//         isUnauthorized = true;
//       } else if (result is Map) {
//         final message = result['message']?.toString() ?? '';
//         final error = result['error']?.toString() ?? '';
//         if (message.contains('Unauthorized') || error.contains('Unauthorized')) {
//           isUnauthorized = true;
//         }
//       }
//
//       /*
//       if (isUnauthorized) {
//         print('Database [getData]: Unauthorized response detected (401 or Unauthorized message). Logging out.');
//         _cachedSessionId = null;
//         _cachedRawCookie = null; // ADDED
//         final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//         await storage.deleteAll();
//         await AuthService.clearSession();
//
//         AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//           AppRoutes.login,
//               (route) => false,
//         );
//
//         return {
//           'success': false,
//           'message': 'Session expired. Please log in again.',
//           'status': 401,
//           'data': [],
//         };
//       }
//       */
//
//       // Store Razorpay key if present
//       if (result.containsKey('RAZORPAY_KEY') &&
//           result['RAZORPAY_KEY'] != null &&
//           liveModeEnabled) {
//         var razorpayKey = result['RAZORPAY_KEY'];
//         await storage.write(key: "razorpay_key", value: razorpayKey.toString());
//       } else {
//         var razorpayKey = razorpayTestKey;
//         await storage.write(key: "razorpay_key", value: razorpayKey.toString());
//       }
//
//       // Store admin email if present
//       if (result.containsKey('admin_email') && result['admin_email'] != null) {
//         await storage.write(
//             key: 'admin_email', value: result['admin_email'].toString());
//       }
//
//       // Handle session management - FIXED NULL SAFETY
//       if (result.containsKey('SESSION_ID') &&
//           result['SESSION_ID'] != null &&
//           result['SESSION_ID'].toString().isNotEmpty &&
//           result['SESSION_ID'].toString() != existingSessionId) {
//         _cachedSessionId = result['SESSION_ID'].toString();
//         await storage.write(
//             key: "SESSION_ID", value: result['SESSION_ID'].toString());
//       } else if (result['status'] == 400 && result.containsKey("logged_out")) {
//         if (retry == 0) {
//           retry = 1;
//           final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//
//           String? accessToken;
//           String? validator;
//
//           try {
//             accessToken = await _readSecureKey(storage, "access_token");
//             validator = await _readSecureKey(storage, "validator");
//           } catch (e) {
//             validator = accessToken = null;
//           }
//
//           if (accessToken != null && validator != null) {
//             Map<String, String> postData = {
//               "auto_login": "true",
//               "access_token": accessToken,
//               "validator": validator,
//             };
//
//             final res = await getData(postData);
//
//             var result = res['LOGIN_RESPONSE'];
//
//             if (result != null &&
//                 result['status'] == 200 &&
//                 result['long_term_access_token'] != null &&
//                 result['token_verifier'] != null) {
//               final token = result['long_term_access_token'];
//               final validator = result['token_verifier'];
//
//               await storage.write(key: "access_token", value: token.toString());
//               await storage.write(
//                   key: "validator", value: validator.toString());
//               await storage.write(
//                   key: "user_data",
//                   value: jsonEncode(result['full_data'] ?? {}));
//               await storage.write(
//                   key: "user_products",
//                   value: jsonEncode(res['PRODUCTS'] ?? {}));
//               await storage.write(
//                   key: "filters", value: jsonEncode(res['filters'] ?? {}));
//
//               return await getData(postBody, endpoint: endpoint);
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Database.dart - Network Error Details:');
//       print('Error: $e');
//       print('Error Type: ${e.runtimeType}');
//       print('Base URL: $baseUrlLegacy');
//       print('Request Body: $stringBody');
//
//       result = {
//         "status": 300,
//         "error": "Server not reachable - ${e.toString()}",
//         "debug_info": {
//           "base_url": baseUrlLegacy,
//           "error_type": e.runtimeType.toString(),
//           "error_message": e.toString(),
//         }
//       };
//     }
//
//     return result;
//   }
//
//   /// Main API communication method for JSON requests
//   /// Handles JSON body and Content-Type header
//   Future<Map> getJsonData(Map<String, dynamic> postBody, {String? endpoint}) async {
//     var result = {};
//
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     if (_cachedSessionId == null || _cachedSessionId!.isEmpty) {
//       _cachedSessionId = await _readSecureKey(storage, "SESSION_ID");
//     }
//     final existingSessionId = _cachedSessionId;
//     final rawCookie = await _getSavedRawCookie(storage); // ADDED
//
//     try {
//       final targetUrl = endpoint != null
//           ? Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'))
//           : Uri.parse(baseUrl);
//
//       print('Database [getJsonData]: Sending request to $targetUrl with SESSION-ID: $existingSessionId');
//
//       final response = await http.post(
//         targetUrl,
//         body: jsonEncode(postBody),
//         headers: {
//           'Content-Type': 'application/json',
//           'APP_ID': appId.toString(),
//           'SESSION-ID': existingSessionId?.toString() ?? '',
//           if (_buildCookieHeader(rawCookie, existingSessionId) != null)
//             'Cookie': _buildCookieHeader(rawCookie, existingSessionId)!,
//         },
//       );
//
//       await _saveRawCookieFromResponse(response, storage); // ADDED
//
//       var copy = response.body;
//       print('RAW JSON RESPONSE BODY: "${copy}"');
//       print('RESPONSE STATUS CODE: ${response.statusCode}');
//       print('RESPONSE HEADERS: ${response.headers}');
//
//       if (copy.isEmpty) {
//         print('EMPTY RESPONSE - Server returned no content');
//         result = {
//           "status": 300,
//           "error": "Server returned empty response",
//           "debug_info": {
//             "status_code": response.statusCode,
//             "headers": response.headers.toString(),
//           },
//         };
//       } else {
//         try {
//           dynamic decodedResponse = jsonDecode(copy);
//
//           // Handle both Map and List responses
//           if (decodedResponse is Map) {
//             result = Map<String, dynamic>.from(decodedResponse);
//           } else if (decodedResponse is List) {
//             // If it's a list, wrap it in a map for consistency
//             result = {
//               'success': true,
//               'data': decodedResponse,
//               'status': 200,
//             };
//           } else {
//             // Scalar value (e.g., integer 1 from echo 1; die;)
//             result = {
//               'success': true,
//               'data': decodedResponse,
//               'status': 200,
//             };
//           }
//         } catch (jsonError) {
//           print('JSON DECODE ERROR: $jsonError');
//           print('RAW RESPONSE THAT FAILED JSON DECODE: "${copy}"');
//           result = {
//             "status": 300,
//             "error": "Invalid JSON response from server",
//             "raw_response": copy,
//             "json_error": jsonError.toString(),
//             "debug_info": {
//               "status_code": response.statusCode,
//               "headers": response.headers.toString(),
//             },
//           };
//         }
//       }
//
//       // Check for 401 Unauthorized or unauthorized messages in response
//       bool isUnauthorized = false;
//       if (response.statusCode == 401) {
//         isUnauthorized = true;
//       } else if (result is Map) {
//         final message = result['message']?.toString() ?? '';
//         final error = result['error']?.toString() ?? '';
//         if (message.contains('Unauthorized') || error.contains('Unauthorized')) {
//           isUnauthorized = true;
//         }
//       }
//
//       if (isUnauthorized) {
//         print('Database [getJsonData]: Unauthorized response detected (401 or Unauthorized message). Logging out.');
//         _cachedSessionId = null;
//         _cachedRawCookie = null; // ADDED
//         final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//         await storage.deleteAll();
//         await AuthService.clearSession();
//
//         AppRoutes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//           AppRoutes.login,
//               (route) => false,
//         );
//
//         return {
//           'success': false,
//           'message': 'Session expired. Please log in again.',
//           'status': 401,
//           'data': [],
//         };
//       }
//
//       // Store Razorpay key if present
//       if (result.containsKey('RAZORPAY_KEY') &&
//           result['RAZORPAY_KEY'] != null &&
//           liveModeEnabled) {
//         var razorpayKey = result['RAZORPAY_KEY'];
//         await storage.write(key: "razorpay_key", value: razorpayKey.toString());
//       } else {
//         var razorpayKey = razorpayTestKey;
//         await storage.write(key: "razorpay_key", value: razorpayKey.toString());
//       }
//
//       // Store admin email if present
//       if (result.containsKey('admin_email') && result['admin_email'] != null) {
//         await storage.write(
//             key: 'admin_email', value: result['admin_email'].toString());
//       }
//
//       // Handle session management
//       if (result.containsKey('SESSION_ID') &&
//           result['SESSION_ID'] != null &&
//           result['SESSION_ID'].toString().isNotEmpty &&
//           result['SESSION_ID'].toString() != existingSessionId) {
//         _cachedSessionId = result['SESSION_ID'].toString();
//         await storage.write(
//             key: "SESSION_ID", value: result['SESSION_ID'].toString());
//       }
//     } catch (e) {
//       print('Database.dart (JSON) - Network Error Details:');
//       print('Error: $e');
//       print('Error Type: ${e.runtimeType}');
//       print('Base URL: $baseUrlLegacy');
//       print('Request Body: $postBody');
//
//       result = {
//         "status": 300,
//         "error": "Server not reachable - ${e.toString()}",
//         "debug_info": {
//           "base_url": baseUrlLegacy,
//           "error_type": e.runtimeType.toString(),
//           "error_message": e.toString(),
//         }
//       };
//     }
//
//     return result;
//   }
//
//   /// Get current session ID
//   Future<String?> getSessionId() async {
//     if (_cachedSessionId != null && _cachedSessionId!.isNotEmpty) {
//       return _cachedSessionId;
//     }
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     _cachedSessionId = await _readSecureKey(storage, "SESSION_ID");
//     return _cachedSessionId;
//   }
//
//   /// Get stored Razorpay key
//   Future<String?> getRazorpayKey() async {
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     return await _readSecureKey(storage, "razorpay_key");
//   }
//
//   /// Store user data securely
//   Future<void> storeUserData(Map<String, dynamic> userData) async {
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     await storage.write(key: "user_data", value: jsonEncode(userData));
//   }
//
//   /// Get stored user data
//   Future<Map<String, dynamic>?> getUserData() async {
//     try {
//       final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//       final userData = await _readSecureKey(storage, "user_data");
//       return userData != null ? jsonDecode(userData) : null;
//     } catch (e) {
//       print("Error reading user data: $e");
//       return null;
//     }
//   }
//
//   /// Clear all stored data (for logout)
//   Future<void> clearAllData() async {
//     _cachedSessionId = null;
//     _cachedRawCookie = null; // ADDED
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     await storage.deleteAll();
//   }
//
//   /// Store access token for auto-login
//   Future<void> storeAccessToken(String token, String validator) async {
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     await storage.write(key: "access_token", value: token);
//     await storage.write(key: "validator", value: validator);
//   }
//
//   /// Get stored access token
//   Future<String?> getAccessToken() async {
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     return await _readSecureKey(storage, "access_token");
//   }
//
//   /// Store user preferences
//   Future<void> storeUserPreferences(Map<String, dynamic> preferences) async {
//     final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//     await storage.write(
//         key: "user_preferences", value: jsonEncode(preferences));
//   }
//
//   /// Get user preferences
//   Future<Map<String, dynamic>?> getUserPreferences() async {
//     try {
//       final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
//       final preferences = await _readSecureKey(storage, "user_preferences");
//       return preferences != null ? jsonDecode(preferences) : null;
//     } catch (e) {
//       print("Error reading user preferences: $e");
//       return null;
//     }
//   }
//
//   /// Safe secure storage key reading helper
//   Future<String?> _readSecureKey(FlutterSecureStorage storage, String key) async {
//     try {
//       return await storage.read(key: key);
//     } catch (e) {
//       print("Secure storage read failed for key $key, clearing corrupted storage: $e");
//       try {
//         await storage.deleteAll();
//       } catch (clearError) {
//         print("Failed to delete corrupted storage: $clearError");
//       }
//       return null;
//     }
//   }
//
//   /// Get marketplace jobs with pagination and filtering
//   Future<Map<String, dynamic>> getJobs({
//     int page = 1,
//     String? category,
//     int perPage = 12,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'get_marketplace_jobs_with_counts',
//         'page': page - 1, // API uses 0-based pagination
//         'per_page': perPage,
//       };
//
//       if (category != null && category.isNotEmpty && category != 'All Categories') {
//         postBody['category'] = category;
//       }
//
//       final result = await getData(postBody);
//
//       if (result['success'] == true) {
//         final data = result['data'] as List? ?? [];
//
//         // Parse filters from the response if available
//         Map<String, dynamic> filters = {};
//         if (result['filters'] != null) {
//           filters = Map<String, dynamic>.from(result['filters']);
//         }
//
//         return {
//           'success': true,
//           'data': data,
//           'filters': filters,
//           'total': data.length,
//           'last_page': 1, // API doesn't return pagination metadata, so we assume 1 page
//           'message': result['message'] ?? 'Jobs fetched successfully',
//         };
//       } else {
//         return {
//           'success': false,
//           'data': [],
//           'filters': {},
//           'message': result['message'] ?? 'Failed to fetch jobs',
//           'error': result['error'] ?? 'Unknown error',
//         };
//       }
//     } catch (e) {
//       print('Error fetching jobs: $e');
//       return {
//         'success': false,
//         'data': [],
//         'filters': {},
//         'message': 'Network error: ${e.toString()}',
//         'error': e.toString(),
//       };
//     }
//   }
//
//   /// Get a single job by ID
//   Future<Map<String, dynamic>> getJobById(String jobId) async {
//     try {
//       final postBody = {
//         'action': 'get_marketplace_job',
//         'job_id': jobId,
//       };
//
//       final result = await getData(postBody);
//
//       if (result['success'] == true) {
//         return {
//           'success': true,
//           'data': result['data'],
//           'message': result['message'] ?? 'Job fetched successfully',
//         };
//       } else {
//         return {
//           'success': false,
//           'data': null,
//           'message': result['message'] ?? 'Failed to fetch job',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'data': null,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// Update job status
//   Future<Map<String, dynamic>> updateJobStatus({
//     required String jobId,
//     required String status,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'update_job_status',
//         'jid': jobId,
//         'status': status,
//       };
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'message': result['message'] ?? 'Status update failed',
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// Delete a job
//   Future<Map<String, dynamic>> deleteJob(String jobId) async {
//     try {
//       final postBody = {
//         'action': 'delete_marketplace_job',
//         'deleteid': jobId,
//       };
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'message': result['message'] ?? 'Deletion failed',
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// Update job share status
//   Future<Map<String, dynamic>> updateJobShareStatus({
//     required String jobId,
//     required String status,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'update_job_share_status',
//         'job_id': jobId,
//         'status': status,
//       };
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'message': result['message'] ?? 'Share status update failed',
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// Update job paid status
//   Future<Map<String, dynamic>> updateJobPaidStatus({
//     required String jobId,
//     required String paidStatus,
//     String? paidAmount,
//     String? rpaidAmount,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'update_job_paid_status',
//         'jobid': jobId,
//         'paid_status': paidStatus,
//       };
//
//       if (paidAmount != null) {
//         postBody['paid_amount'] = paidAmount;
//       }
//       if (rpaidAmount != null) {
//         postBody['rpaid_amount'] = rpaidAmount;
//       }
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'message': result['message'] ?? 'Paid status update failed',
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// ============================================================
//   /// JOB APPLICATIONS / RESPONSES API METHODS
//   /// ============================================================
//
//   /// Get job responses (applicants) for a specific job
//   Future<Map<String, dynamic>> getJobResponses({
//     required String jobId,
//     int page = 1,
//     int perPage = 20,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'get_job_responses',
//         'job_id': jobId,
//         'page': page - 1, // API uses 0-based pagination
//         'per_page': perPage,
//       };
//
//       final result = await getData(postBody);
//
//       if (result['success'] == true) {
//         final data = result['data'] as Map? ?? {};
//         final responses = data['responses'] as List? ?? [];
//
//         // Extract pagination info
//         final pagination = data['pagination'] as Map? ?? {};
//
//         return {
//           'success': true,
//           'data': {
//             'responses': responses,
//             'pagination': {
//               'current_page': page,
//               'per_page': perPage,
//               'total_responses': pagination['total_responses'] ?? responses.length,
//               'total_pages': pagination['total_pages'] ?? 1,
//             },
//             'job_title': data['job_title'] ?? '',
//           },
//           'message': result['message'] ?? 'Responses fetched successfully',
//         };
//       } else {
//         return {
//           'success': false,
//           'data': {
//             'responses': [],
//             'pagination': {
//               'total_responses': 0,
//               'total_pages': 1,
//             },
//             'job_title': '',
//           },
//           'message': result['message'] ?? 'Failed to fetch responses',
//           'error': result['error'] ?? 'Unknown error',
//         };
//       }
//     } catch (e) {
//       print('Error fetching job responses: $e');
//       return {
//         'success': false,
//         'data': {
//           'responses': [],
//           'pagination': {
//             'total_responses': 0,
//             'total_pages': 1,
//           },
//           'job_title': '',
//         },
//         'message': 'Network error: ${e.toString()}',
//         'error': e.toString(),
//       };
//     }
//   }
//
//   /// Update applicant status
//   Future<Map<String, dynamic>> updateApplicantStatus({
//     required String vendorId,
//     required String itemId,
//     required String status,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'update_response_status',
//         'vendor_id': vendorId,
//         'item_id': itemId,
//         'status': status,
//       };
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'message': result['message'] ?? 'Status update failed',
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// Schedule interview
//   Future<Map<String, dynamic>> scheduleInterview({
//     required String vendorId,
//     required String itemId,
//     required String schedule,
//     required String platform,
//     required String message,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'schedule_interview',
//         'vendor_id': vendorId,
//         'item_id': itemId,
//         'schedule': schedule,
//         'platform': platform,
//         'message': message,
//       };
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'message': result['message'] ?? 'Interview scheduling failed',
//         'data': result['data'],
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// Send message to applicant
//   Future<Map<String, dynamic>> sendMessage({
//     required String vendorId,
//     required String message,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'send_message_to_applicant',
//         'vendor_id': vendorId,
//         'message': message,
//       };
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'message': result['message'] ?? 'Failed to send message',
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
//
//   /// Get applicant details
//   Future<Map<String, dynamic>> getApplicantDetails({
//     required String vendorId,
//     required String itemId,
//   }) async {
//     try {
//       final postBody = {
//         'action': 'get_applicant_details',
//         'vendor_id': vendorId,
//         'item_id': itemId,
//       };
//
//       final result = await getData(postBody);
//
//       return {
//         'success': result['success'] ?? false,
//         'data': result['data'],
//         'message': result['message'] ?? 'Failed to get applicant details',
//       };
//     } catch (e) {
//       return {
//         'success': false,
//         'data': null,
//         'message': 'Network error: ${e.toString()}',
//       };
//     }
//   }
// }
import 'dart:convert';
import 'dart:io';

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

  // ADDED: some endpoints (e.g. admin_login_api.php) rely on PHP's native
  // session_start()/PHPSESSID cookie rather than the custom SESSION_ID
  // field the rest of the app uses. Previously nothing captured
  // Set-Cookie from responses, so those sessions were silently dropped
  // after the very first request. This caches the raw cookie separately
  // from the custom SESSION_ID mechanism so both can coexist.
  static String? _cachedRawCookie;

  /// Get Android options for secure storage
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  // ADDED: loads any previously-saved raw cookie (e.g. "PHPSESSID=abc123")
  Future<String?> _getSavedRawCookie(FlutterSecureStorage storage) async {
    if (_cachedRawCookie != null && _cachedRawCookie!.isNotEmpty) {
      return _cachedRawCookie;
    }
    _cachedRawCookie = await _readSecureKey(storage, "RAW_COOKIE");
    return _cachedRawCookie;
  }

  // ADDED: captures Set-Cookie from a response and persists it
  Future<void> _saveRawCookieFromResponse(
      http.Response response,
      FlutterSecureStorage storage,
      ) async {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie == null || rawCookie.isEmpty) return;

    final cookiePart = rawCookie.split(';').first;
    _cachedRawCookie = cookiePart;
    await storage.write(key: "RAW_COOKIE", value: cookiePart);
  }

  // ADDED: builds the Cookie header value, preferring a captured raw
  // cookie (native PHP session) and falling back to the app's custom
  // SESSION_ID-as-PHPSESSID construction if no raw cookie is cached yet.
  String? _buildCookieHeader(String? rawCookie, String? existingSessionId) {
    List<String> cookies = [];

    if (rawCookie != null && rawCookie.isNotEmpty) {
      // Split rawCookie and filter out any temporary PHPSESSID cookies
      final parts = rawCookie.split(';');
      for (var part in parts) {
        part = part.trim();
        if (part.isNotEmpty && !part.startsWith('PHPSESSID=')) {
          cookies.add(part);
        }
      }
    }

    // Always append the correct active logged-in session ID
    if (existingSessionId != null && existingSessionId.isNotEmpty) {
      cookies.add('PHPSESSID=$existingSessionId');
    }

    return cookies.isNotEmpty ? cookies.join('; ') : null;
  }

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
    final rawCookie = await _getSavedRawCookie(storage); // ADDED

    try {
      // Convert all body values to strings to avoid type cast issues
      stringBody =
          postBody.map((key, value) => MapEntry(key, value?.toString() ?? ''));

      final targetUrl = endpoint != null
          ? Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'))
          : Uri.parse(baseUrl);

      print('Database [getData]: Sending request to $targetUrl with SESSION-ID: $existingSessionId');

      final response = await http.post(
        targetUrl,
        body: stringBody,
        headers: {
          'APP_ID': (appIdOverride ?? appId).toString(),
          // SESSION-ID is omitted so standard Cookie-based PHPSESSID handles authentication.
          // This avoids duplicate session_id() calls on the server which corrupts active sessions.
          // CHANGED: use the shared cookie builder instead of only ever
          // constructing "PHPSESSID=$existingSessionId" — this now also
          // replays a captured native PHP session cookie if one exists.
          if (_buildCookieHeader(rawCookie, existingSessionId) != null)
            'Cookie': _buildCookieHeader(rawCookie, existingSessionId)!,
        },
      );

      await _saveRawCookieFromResponse(response, storage); // ADDED

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

      /*
      if (isUnauthorized) {
        print('Database [getData]: Unauthorized response detected (401 or Unauthorized message). Logging out.');
        _cachedSessionId = null;
        _cachedRawCookie = null; // ADDED
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
      */

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
    final rawCookie = await _getSavedRawCookie(storage); // ADDED

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
          if (_buildCookieHeader(rawCookie, existingSessionId) != null)
            'Cookie': _buildCookieHeader(rawCookie, existingSessionId)!,
        },
      );

      await _saveRawCookieFromResponse(response, storage); // ADDED

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
        _cachedRawCookie = null; // ADDED
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
    _cachedRawCookie = null; // ADDED
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

  // ══════════════════════════════════════════════════════════════
  // COMMUNITY FEED API METHODS
  // These all target the PHP file you shared (get_feed / create_post /
  // add_comment / post_engagement actions). CHANGE `feedEndpoint` below
  // to whatever that .php file is actually named/routed as on your
  // server (it's passed as `?endpoint=` to baseUrl, same as every other
  // call in this class).
  // ══════════════════════════════════════════════════════════════
  static const String feedEndpoint = 'new_apis/social_feed_api.php';

  /// Fetch the combined home feed (admin posts, personalized, following,
  /// community, self posts and sponsored posts, already interleaved by
  /// the backend's get_feed action).
  Future<Map<String, dynamic>> getFeed() async {
    try {
      final result = await getData({'action': 'get_feed'}, endpoint: feedEndpoint);

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'] as List? ?? [],
          'message': result['message'] ?? 'Feed fetched successfully',
        };
      }
      return {
        'success': false,
        'data': [],
        'message': result['message'] ?? result['error'] ?? 'Failed to fetch feed',
      };
    } catch (e) {
      print('Error fetching feed: $e');
      return {
        'success': false,
        'data': [],
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Create a new post. Text-only posts just pass contentType: 'text' and
  /// an empty images list. Image/gallery/video posts attach files.
  ///
  /// NOTE: the PHP action reads uploads from $_FILES['postImage1'],
  /// $_FILES['postImage2']... and an `image_count` field, so this uses
  /// http.MultipartRequest instead of the JSON/form helpers above (those
  /// can't carry binary files).
  Future<Map<String, dynamic>> createPost({
    required String contentType, // 'text' | 'image' | 'gallery' | 'video'
    String visibility = 'public',
    String label = '',
    String tags = '',
    String location = '',
    List<File> images = const [],
  }) async {
    try {
      final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
      if (_cachedSessionId == null || _cachedSessionId!.isEmpty) {
        _cachedSessionId = await _readSecureKey(storage, "SESSION_ID");
      }
      final existingSessionId = _cachedSessionId;
      final rawCookie = await _getSavedRawCookie(storage);

      final targetUrl = Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$feedEndpoint'));
      final request = http.MultipartRequest('POST', targetUrl);

      request.headers.addAll({
        'APP_ID': appId.toString(),
        if (_buildCookieHeader(rawCookie, existingSessionId) != null)
          'Cookie': _buildCookieHeader(rawCookie, existingSessionId)!,
      });

      request.fields.addAll({
        'action': 'create_post',
        'content_type': contentType,
        'visibility': visibility,
        'label': label,
        'tags': tags,
        'location': location,
        'image_count': images.length.toString(),
      });

      for (var i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('postImage${i + 1}', images[i].path),
        );
      }

      print('Database [createPost]: Sending to $targetUrl with ${images.length} image(s)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      await _saveRawCookieFromResponse(response, storage);

      print('CREATE_POST RESPONSE (${response.statusCode}): "${response.body}"');

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Server returned empty response'};
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final result = Map<String, dynamic>.from(decoded);
        return {
          'success': result['success'] ?? false,
          'message': result['message'] ?? (result['success'] == true ? 'Post created' : 'Failed to create post'),
          'data': result['data'],
        };
      }
      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      print('Database [createPost] error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Add a comment (optionally carrying an emoji/GIF reaction or media)
  /// to a post.
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String message,
    String reactionValue = '',
    String mediaUrl = '',
  }) async {
    try {
      final result = await getData({
        'action': 'add_comment',
        'post_id': postId,
        'message': message,
        'reaction_value': reactionValue,
        'media_url': mediaUrl,
      }, endpoint: feedEndpoint);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Failed to add comment',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Toggle like on a post (the backend flips like/unlike automatically).
  Future<Map<String, dynamic>> toggleLike({required String postId}) {
    return _postEngagement(postId: postId, engagementType: 'like');
  }

  /// Add or update an emoji/GIF reaction on a post.
  Future<Map<String, dynamic>> sendReaction({
    required String postId,
    required String reactionValue,
  }) {
    return _postEngagement(
      postId: postId,
      engagementType: 'reaction',
      reactionValue: reactionValue,
    );
  }

  /// Share / repost a post.
  Future<Map<String, dynamic>> sharePost({required String postId}) {
    return _postEngagement(postId: postId, engagementType: 'share');
  }

  Future<Map<String, dynamic>> _postEngagement({
    required String postId,
    required String engagementType,
    String? reactionValue,
  }) async {
    try {
      final result = await getData({
        'action': 'post_engagement',
        'post_id': postId,
        'engagement_type': engagementType,
        if (reactionValue != null) 'reaction_value': reactionValue,
      }, endpoint: feedEndpoint);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Engagement action failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get marketplace jobs with pagination and filtering
  Future<Map<String, dynamic>> getJobs({
    int page = 1,
    String? category,
    int perPage = 12,
  }) async {
    try {
      final postBody = {
        'action': 'get_marketplace_jobs_with_counts',
        'page': page - 1, // API uses 0-based pagination
        'per_page': perPage,
      };

      if (category != null && category.isNotEmpty && category != 'All Categories') {
        postBody['category'] = category;
      }

      final result = await getData(postBody);

      if (result['success'] == true) {
        final data = result['data'] as List? ?? [];

        // Parse filters from the response if available
        Map<String, dynamic> filters = {};
        if (result['filters'] != null) {
          filters = Map<String, dynamic>.from(result['filters']);
        }

        return {
          'success': true,
          'data': data,
          'filters': filters,
          'total': data.length,
          'last_page': 1, // API doesn't return pagination metadata, so we assume 1 page
          'message': result['message'] ?? 'Jobs fetched successfully',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'filters': {},
          'message': result['message'] ?? 'Failed to fetch jobs',
          'error': result['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      return {
        'success': false,
        'data': [],
        'filters': {},
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Get a single job by ID
  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final postBody = {
        'action': 'get_marketplace_job',
        'job_id': jobId,
      };

      final result = await getData(postBody);

      if (result['success'] == true) {
        return {
          'success': true,
          'data': result['data'],
          'message': result['message'] ?? 'Job fetched successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': result['message'] ?? 'Failed to fetch job',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Update job status
  Future<Map<String, dynamic>> updateJobStatus({
    required String jobId,
    required String status,
  }) async {
    try {
      final postBody = {
        'action': 'update_job_status',
        'jid': jobId,
        'status': status,
      };

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Status update failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Delete a job
  Future<Map<String, dynamic>> deleteJob(String jobId) async {
    try {
      final postBody = {
        'action': 'delete_marketplace_job',
        'deleteid': jobId,
      };

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Deletion failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Update job share status
  Future<Map<String, dynamic>> updateJobShareStatus({
    required String jobId,
    required String status,
  }) async {
    try {
      final postBody = {
        'action': 'update_job_share_status',
        'job_id': jobId,
        'status': status,
      };

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Share status update failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Update job paid status
  Future<Map<String, dynamic>> updateJobPaidStatus({
    required String jobId,
    required String paidStatus,
    String? paidAmount,
    String? rpaidAmount,
  }) async {
    try {
      final postBody = {
        'action': 'update_job_paid_status',
        'jobid': jobId,
        'paid_status': paidStatus,
      };

      if (paidAmount != null) {
        postBody['paid_amount'] = paidAmount;
      }
      if (rpaidAmount != null) {
        postBody['rpaid_amount'] = rpaidAmount;
      }

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Paid status update failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// ============================================================
  /// JOB APPLICATIONS / RESPONSES API METHODS
  /// ============================================================

  /// Get job responses (applicants) for a specific job
  Future<Map<String, dynamic>> getJobResponses({
    required String jobId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final postBody = {
        'action': 'get_job_responses',
        'job_id': jobId,
        'page': page - 1, // API uses 0-based pagination
        'per_page': perPage,
      };

      final result = await getData(postBody);

      if (result['success'] == true) {
        final data = result['data'] as Map? ?? {};
        final responses = data['responses'] as List? ?? [];

        // Extract pagination info
        final pagination = data['pagination'] as Map? ?? {};

        return {
          'success': true,
          'data': {
            'responses': responses,
            'pagination': {
              'current_page': page,
              'per_page': perPage,
              'total_responses': pagination['total_responses'] ?? responses.length,
              'total_pages': pagination['total_pages'] ?? 1,
            },
            'job_title': data['job_title'] ?? '',
          },
          'message': result['message'] ?? 'Responses fetched successfully',
        };
      } else {
        return {
          'success': false,
          'data': {
            'responses': [],
            'pagination': {
              'total_responses': 0,
              'total_pages': 1,
            },
            'job_title': '',
          },
          'message': result['message'] ?? 'Failed to fetch responses',
          'error': result['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      print('Error fetching job responses: $e');
      return {
        'success': false,
        'data': {
          'responses': [],
          'pagination': {
            'total_responses': 0,
            'total_pages': 1,
          },
          'job_title': '',
        },
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Update applicant status
  Future<Map<String, dynamic>> updateApplicantStatus({
    required String vendorId,
    required String itemId,
    required String status,
  }) async {
    try {
      final postBody = {
        'action': 'update_response_status',
        'vendor_id': vendorId,
        'item_id': itemId,
        'status': status,
      };

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Status update failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Schedule interview
  Future<Map<String, dynamic>> scheduleInterview({
    required String vendorId,
    required String itemId,
    required String schedule,
    required String platform,
    required String message,
  }) async {
    try {
      final postBody = {
        'action': 'schedule_interview',
        'vendor_id': vendorId,
        'item_id': itemId,
        'schedule': schedule,
        'platform': platform,
        'message': message,
      };

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Interview scheduling failed',
        'data': result['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Send message to applicant
  Future<Map<String, dynamic>> sendMessage({
    required String vendorId,
    required String message,
  }) async {
    try {
      final postBody = {
        'action': 'send_message_to_applicant',
        'vendor_id': vendorId,
        'message': message,
      };

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Failed to send message',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get applicant details
  Future<Map<String, dynamic>> getApplicantDetails({
    required String vendorId,
    required String itemId,
  }) async {
    try {
      final postBody = {
        'action': 'get_applicant_details',
        'vendor_id': vendorId,
        'item_id': itemId,
      };

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'data': result['data'],
        'message': result['message'] ?? 'Failed to get applicant details',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}