import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';
import '../index.dart';
import '../services/auth_User_and_Business_Session.dart';
import '../services/auth_service.dart';

/// Database class for handling API communication
/// Centralized API client with session management and secure storage.
///
/// SESSION STRATEGY (CHANGED):
/// This app no longer relies on PHP's native Set-Cookie/PHPSESSID
/// mechanism at all — mobile HTTP clients don't maintain a cookie jar
/// automatically, so that approach was fragile and caused endpoints like
/// vendor_details_api.php to see a fresh anonymous session (401
/// Unauthorized) even right after a successful login.
///
/// Instead, every request now sends the session id explicitly as a
/// `SESSION-ID` HTTP header, and the PHP side is expected to do:
///
///   $sessionId = $_SERVER['HTTP_SESSION_ID'] ?? null;
///   if ($sessionId) { session_id($sessionId); }
///   session_start();
///
/// before touching $_SESSION. The single source of truth for "what is
/// the current session id" is `UserSessionSet.instance`, which is
/// populated at login time (see LoginScreen._login / _verifyOtp).
class Database {
  int retry = 0;

  /// Get Android options for secure storage
  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  /// Main API communication method (form-encoded body)
  /// Handles all API calls with session management and error handling
  Future<Map> getData(Map postBody, {String? endpoint, int? appIdOverride}) async {
    var result = {};
    Map<String, String> stringBody = {};

    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

    // CHANGED: single source of truth for the session id — matches what
    // LoginScreen actually saves via UserSessionSet.saveLoginData(...).
    final sessionId = await UserSessionSet.instance.sessionId;

    try {
      stringBody =
          postBody.map((key, value) => MapEntry(key, value?.toString() ?? ''));

      final targetUrl = endpoint != null
          ? Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'))
          : Uri.parse(baseUrl);

      print('Database [getData]: Sending request to $targetUrl with SESSION-ID: $sessionId');

      final response = await http.post(
        targetUrl,
        body: stringBody,
        headers: {
          'APP_ID': (appIdOverride ?? appId).toString(),
          // CHANGED: header-based session instead of a replayed cookie.
          'SESSION-ID': sessionId ?? '',
        },
      );

      var copy = response.body;
      print('RAW RESPONSE BODY: "$copy"');
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

          if (decodedResponse is Map) {
            result = Map<String, dynamic>.from(decodedResponse);
          } else if (decodedResponse is List) {
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          } else {
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          }
        } catch (jsonError) {
          print('JSON DECODE ERROR: $jsonError');
          print('RAW RESPONSE THAT FAILED JSON DECODE: "$copy"');
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
        print('Database [getData]: Unauthorized response detected. Logging out.');
        await UserSessionSet.instance.logout();

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

      // CHANGED: if the server rotates/returns a new SESSION_ID, push it
      // into UserSessionSet (the single source of truth) instead of the
      // old private secure-storage key.
      if (result.containsKey('SESSION_ID') &&
          result['SESSION_ID'] != null &&
          result['SESSION_ID'].toString().isNotEmpty &&
          result['SESSION_ID'].toString() != sessionId) {
        final newSessionId = result['SESSION_ID'].toString();
        final vendorId = await UserSessionSet.instance.vendorId;
        final vendorType = await UserSessionSet.instance.vendorType;
        await UserSessionSet.instance.saveLoginData(
          sessionId: newSessionId,
          vendorId: vendorId ?? '',
          vendorType: vendorType ?? '',
        );
      } else if (result['status'] == 400 && result.containsKey("logged_out")) {
        if (retry == 0) {
          retry = 1;

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
            var autoLoginResult = res['LOGIN_RESPONSE'];

            if (autoLoginResult != null &&
                autoLoginResult['status'] == 200 &&
                autoLoginResult['long_term_access_token'] != null &&
                autoLoginResult['token_verifier'] != null) {
              final token = autoLoginResult['long_term_access_token'];
              final newValidator = autoLoginResult['token_verifier'];

              await storage.write(key: "access_token", value: token.toString());
              await storage.write(key: "validator", value: newValidator.toString());
              await storage.write(
                  key: "user_data",
                  value: jsonEncode(autoLoginResult['full_data'] ?? {}));
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

    // CHANGED: single source of truth, matches what login actually saves
    final sessionId = await UserSessionSet.instance.sessionId;

    try {
      final targetUrl = endpoint != null
          ? Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'))
          : Uri.parse(baseUrl);

      print('Database [getJsonData]: Sending request to $targetUrl with SESSION-ID: $sessionId');

      final response = await http.post(
        targetUrl,
        body: jsonEncode(postBody),
        headers: {
          'Content-Type': 'application/json',
          'APP_ID': appId.toString(),
          'SESSION-ID': sessionId ?? '',
        },
      );

      var copy = response.body;
      print('RAW JSON RESPONSE BODY: "$copy"');
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

          if (decodedResponse is Map) {
            result = Map<String, dynamic>.from(decodedResponse);
          } else if (decodedResponse is List) {
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          } else {
            result = {
              'success': true,
              'data': decodedResponse,
              'status': 200,
            };
          }
        } catch (jsonError) {
          print('JSON DECODE ERROR: $jsonError');
          print('RAW RESPONSE THAT FAILED JSON DECODE: "$copy"');
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
        print('Database [getJsonData]: Unauthorized response detected. Logging out.');
        await UserSessionSet.instance.logout();
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

      // CHANGED: rotate session id through UserSessionSet, not a private key
      if (result.containsKey('SESSION_ID') &&
          result['SESSION_ID'] != null &&
          result['SESSION_ID'].toString().isNotEmpty &&
          result['SESSION_ID'].toString() != sessionId) {
        final newSessionId = result['SESSION_ID'].toString();
        final vendorId = await UserSessionSet.instance.vendorId;
        final vendorType = await UserSessionSet.instance.vendorType;
        await UserSessionSet.instance.saveLoginData(
          sessionId: newSessionId,
          vendorId: vendorId ?? '',
          vendorType: vendorType ?? '',
        );
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

  /// Get current session ID (delegates to UserSessionSet — the single
  /// source of truth for auth state in this app).
  Future<String?> getSessionId() async {
    return UserSessionSet.instance.sessionId;
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
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.deleteAll();
    await UserSessionSet.instance.logout();
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
  // ══════════════════════════════════════════════════════════════
  static const String feedEndpoint = 'new_apis/social_feed_api.php';



  Future<Map<String, dynamic>> getFeed() async {
    final Vendorid=await UserSessionSet.instance.vendorId;

    try {
      final result = await getData({'action': 'get_feed',
          'vendor_id': Vendorid,

          }, endpoint: feedEndpoint);

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

  /// Create a new post. Uses MultipartRequest for file uploads — this is
  /// the one legitimate case where a plain form/json body isn't enough.
  /// CHANGED: session now goes as a 'SESSION-ID' header, same as every
  /// other method, instead of a replayed cookie.
  Future<Map<String, dynamic>> createPost({
    required String contentType, // 'text' | 'image' | 'gallery' | 'video'
    String visibility = 'public',
    String label = '',
    String tags = '',
    String location = '',
    List<File> images = const [],
  }) async {

    try {

      final sessionId = await UserSessionSet.instance.sessionId;

      final targetUrl = Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$feedEndpoint'));
      final request = http.MultipartRequest('POST', targetUrl);

      request.headers.addAll({
        'APP_ID': appId.toString(),
        'SESSION-ID': sessionId ?? '',
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

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String message,
    String reactionValue = '',
    String mediaUrl = '',
  }) async {
    final Vendorid=await UserSessionSet.instance.vendorId;
    try {
      final result = await getData({
        'action': 'add_comment',
        'post_id': postId,
        'message': message,
        'reaction_value': reactionValue,
        'media_url': mediaUrl,
        'vendor_id': Vendorid,

      }, endpoint: feedEndpoint);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Failed to add comment',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> toggleLike({required String postId}) {
    return _postEngagement(postId: postId, engagementType: 'like');
  }

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

  Future<Map<String, dynamic>> sharePost({required String postId}) {
    return _postEngagement(postId: postId, engagementType: 'share');
  }

  Future<Map<String, dynamic>> _postEngagement({
    required String postId,
    required String engagementType,
    String? reactionValue,
  }) async {
    final Vendorid=await UserSessionSet.instance.vendorId;
    try {
      final result = await getData({
        'action': 'post_engagement',
        'post_id': postId,
        'engagement_type': engagementType,
        'vendor_id': Vendorid,

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
    final Vendorid=await UserSessionSet.instance.vendorId;
    try {
      final postBody = {
        'action': 'get_marketplace_jobs_with_counts',
        'page': page - 1,
        'per_page': perPage,
        'vendor_id': Vendorid,

      };

      if (category != null && category.isNotEmpty && category != 'All Categories') {
        postBody['category'] = category;
      }

      final result = await getData(postBody);

      if (result['success'] == true) {
        final data = result['data'] as List? ?? [];
        Map<String, dynamic> filters = {};
        if (result['filters'] != null) {
          filters = Map<String, dynamic>.from(result['filters']);
        }

        return {
          'success': true,
          'data': data,
          'filters': filters,
          'total': data.length,
          'last_page': 1,
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

  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final Vendorid=await UserSessionSet.instance.vendorId;
      final result = await getData({
        'action': 'get_marketplace_job',
        'job_id': jobId,
        'vendor_id': Vendorid,

      });

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

  Future<Map<String, dynamic>> updateJobStatus({
    required String jobId,
    required String status,
  }) async {
    final Vendorid=await UserSessionSet.instance.vendorId;
    try {
      final result = await getData({
        'action': 'update_job_status',
        'jid': jobId,
        'status': status,
        'vendor_id': Vendorid,

      });

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Status update failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteJob(String jobId) async {
    try {
      final result = await getData({
        'action': 'delete_marketplace_job',
        'deleteid': jobId,
      });

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Deletion failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateJobShareStatus({
    required String jobId,
    required String status,
  }) async {
    final Vendorid=await UserSessionSet.instance.vendorId;
    try {
      final result = await getData({
        'action': 'update_job_share_status',
        'job_id': jobId,
        'status': status,
        'vendor_id': Vendorid,
      });

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Share status update failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateJobPaidStatus({
    required String jobId,
    required String paidStatus,
    String? paidAmount,
    String? rpaidAmount,
  }) async {
    final Vendorid=await UserSessionSet.instance.vendorId;
    try {
      final postBody = {
        'action': 'update_job_paid_status',
        'jobid': jobId,
        'paid_status': paidStatus,
        'vendor_id': Vendorid,

      };

      if (paidAmount != null) postBody['paid_amount'] = paidAmount;
      if (rpaidAmount != null) postBody['rpaid_amount'] = rpaidAmount;

      final result = await getData(postBody);

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Paid status update failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// ============================================================
  /// JOB APPLICATIONS / RESPONSES API METHODS
  /// ============================================================

  Future<Map<String, dynamic>> getJobResponses({
    required String jobId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final result = await getData({
        'action': 'get_job_responses',
        'job_id': jobId,
        'page': page - 1,
        'per_page': perPage,
      });

      if (result['success'] == true) {
        final data = result['data'] as Map? ?? {};
        final responses = data['responses'] as List? ?? [];
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
            'pagination': {'total_responses': 0, 'total_pages': 1},
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
          'pagination': {'total_responses': 0, 'total_pages': 1},
          'job_title': '',
        },
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateApplicantStatus({
    required String vendorId,
    required String itemId,
    required String status,
  }) async {
    try {
      final result = await getData({
        'action': 'update_response_status',
        'vendor_id': vendorId,
        'item_id': itemId,
        'status': status,
      });

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Status update failed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> scheduleInterview({
    required String vendorId,
    required String itemId,
    required String schedule,
    required String platform,
    required String message,
  }) async {
    try {
      final result = await getData({
        'action': 'schedule_interview',
        'vendor_id': vendorId,
        'item_id': itemId,
        'schedule': schedule,
        'platform': platform,
        'message': message,
      });

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Interview scheduling failed',
        'data': result['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String vendorId,
    required String message,
  }) async {
    try {
      final result = await getData({
        'action': 'send_message_to_applicant',
        'vendor_id': vendorId,
        'message': message,
      });

      return {
        'success': result['success'] ?? false,
        'message': result['message'] ?? 'Failed to send message',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Upload a physical file via multipart request.
  /// CHANGED: session goes via 'SESSION-ID' header, no cookie replay.
  Future<Map<String, dynamic>> uploadFile({
    required String endpoint,
    required File file,
    required Map<String, String> body,
    String fileFieldName = 'file',
  }) async {
    try {
      final sessionId = await UserSessionSet.instance.sessionId;

      final targetUrl = Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$endpoint'));
      final request = http.MultipartRequest('POST', targetUrl);

      request.headers.addAll({
        'APP_ID': appId.toString(),
        'SESSION-ID': sessionId ?? '',
      });

      request.fields.addAll(body);

      request.files.add(
        await http.MultipartFile.fromPath(fileFieldName, file.path),
      );

      print('Database [uploadFile]: Uploading ${file.path} to $targetUrl');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('UPLOAD_FILE RESPONSE (${response.statusCode}): "${response.body}"');

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Server returned empty response'};
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      } else {
        return {
          'success': true,
          'data': decoded,
          'status': response.statusCode,
        };
      }
    } catch (e) {
      print('Database [uploadFile] Error: $e');
      return {
        'success': false,
        'message': 'Network upload error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getApplicantDetails({
    required String vendorId,
    required String itemId,
  }) async {
    try {
      final result = await getData({
        'action': 'get_applicant_details',
        'vendor_id': vendorId,
        'item_id': itemId,
      });

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