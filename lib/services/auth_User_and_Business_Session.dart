import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSessionSet {
  UserSessionSet._();

  static final UserSessionSet instance = UserSessionSet._();

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  static const String sessionKey = 'user_session_id';
  static const String vendorIdKey = 'vendor_id';
  static const String vendorTypeKey = 'vendor_type';

  // In-memory cache
  String? _sessionId;
  String? _vendorId;
  String? _vendorType;

  // Synchronous getters (Instant access without await everywhere)
  String get vendorId => _vendorId ?? '';
  String get sessionId => _sessionId ?? '';
  String get vendorType => _vendorType ?? '';

  /// Call this once when the app starts (e.g., in main.dart)
  Future<void> init() async {
    _sessionId = await _storage.read(key: sessionKey, aOptions: _androidOptions);
    _vendorId = await _storage.read(key: vendorIdKey, aOptions: _androidOptions);
    _vendorType = await _storage.read(key: vendorTypeKey, aOptions: _androidOptions);
  }

  // Save session & update cache
  Future<void> saveLoginData({
    required String sessionId,
    required String vendorId,
    required String vendorType,
  }) async {
    _sessionId = sessionId;
    _vendorId = vendorId;
    _vendorType = vendorType;

    await _storage.write(key: sessionKey, value: sessionId, aOptions: _androidOptions);
    await _storage.write(key: vendorIdKey, value: vendorId, aOptions: _androidOptions);
    await _storage.write(key: vendorTypeKey, value: vendorType, aOptions: _androidOptions);
  }

  bool get isLoggedIn =>
      (_sessionId?.isNotEmpty ?? false) &&
          (_vendorId?.isNotEmpty ?? false) &&
          (_vendorType?.isNotEmpty ?? false);

  // Clear session & cache
  Future<void> logout() async {
    _sessionId = null;
    _vendorId = null;
    _vendorType = null;

    await _storage.delete(key: sessionKey, aOptions: _androidOptions);
    await _storage.delete(key: vendorIdKey, aOptions: _androidOptions);
    await _storage.delete(key: vendorTypeKey, aOptions: _androidOptions);
  }
}