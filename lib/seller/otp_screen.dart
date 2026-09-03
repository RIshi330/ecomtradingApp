import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../Database/Database.dart';
import '../app_constants.dart'; // Ensure 'baseUrl' and 'appId' are defined here
import '../services/auth_User_and_Business_Session.dart';
import 'Seller_profile_completion_screen.dart'; // UserSessionSet

class AuthApiService {
  // ⚠️ Verify this matches the real server path for auth_api.php.
  // Every other endpoint in this app is addressed the same way
  // (see Database.feedEndpoint / Database._sellerEndpoint), so this
  // one almost certainly needs the same '?endpoint=' routing + APP_ID
  // header — that's what was missing before.
  static const String _authEndpoint = 'new_apis/sign_up_API';

  static Uri _buildUri() =>
      Uri.parse(Uri.encodeFull('$baseUrl?endpoint=$_authEndpoint'));

  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'APP_ID': appId.toString(),
  };

  /// Shared post + decode + logging so every auth call behaves the same
  /// and failures are actually visible instead of silently falling back
  /// to a generic message.
  static Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    try {
      final uri = _buildUri();
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(body),
      );

      // Debug visibility — remove once this is confirmed working.
      print('AuthApiService -> $uri');
      print('AuthApiService body: $body');
      print('AuthApiService status: ${response.statusCode}');
      print('AuthApiService raw response: "${response.body}"');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message':
          'Server returned an empty response (status ${response.statusCode}). '
              'Check the endpoint path and APP_ID.',
        };
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        // Surface a useful message even if the server didn't set one,
        // instead of masking it with a generic fallback.
        if (decoded['success'] != true && decoded['message'] == null) {
          decoded['message'] =
          'Request failed (status ${response.statusCode}), no message from server.';
        }
        return decoded;
      }

      return {
        'success': false,
        'message': 'Unexpected response format from server.',
      };
    } catch (e) {
      print('AuthApiService network error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// 1. Send Signup OTP to user's email
  static Future<Map<String, dynamic>> sendSignupOtp(String email) {
    return _post({
      'action': 'send_signup_otp',
      'email': email,
    });
  }

  /// 2. Verify Signup OTP & Complete Registration
  static Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
    required String otpToken,
    required String name,
    required String mobile,
    required String vendorType,
    required String password,
  }) {
    return _post({
      'action': 'verify_signup_otp',
      'email': email,
      'otp': otp,
      'otp_token': otpToken,
      'name': name,
      'mobile': mobile,
      'vendor_type': vendorType,
      'password': password,
    });
  }

  /// 3. Send Login OTP
  static Future<Map<String, dynamic>> sendLoginOtp(String email) {
    return _post({
      'action': 'send_login_otp',
      'email': email,
    });
  }

  /// 4. Verify Login OTP
  static Future<Map<String, dynamic>> verifyLoginOtp({
    required String otp,
    required String otpToken,
    bool rememberMe = false,
    int? selectedVendorId,
    String selectedRole = '',
    String selectedVendorType = '',
  }) {
    final Map<String, dynamic> body = {
      'action': 'verify_login_otp',
      'otp': otp,
      'otp_token': otpToken,
      'rememberMe': rememberMe,
      'selected_role': selectedRole,
      'selected_vendor_type': selectedVendorType,
    };

    if (selectedVendorId != null) {
      body['selected_vendor_id'] = selectedVendorId;
    }

    return _post(body);
  }
}

class SellerSignUpOtpScreen extends StatefulWidget {
  const SellerSignUpOtpScreen({super.key});

  @override
  State<SellerSignUpOtpScreen> createState() => _SellerSignUpOtpScreenState();
}

class _SellerSignUpOtpScreenState extends State<SellerSignUpOtpScreen> {
  // Navigation & State Management
  bool _isOtpStep = false;
  bool _isLoading = false;
  String? _otpToken;

  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Timer state
  int _timeLeft = 30;
  Timer? _timer;
  bool _canResend = false;

  // Custom Palette
  static const Color primaryColor = Color(0xFF006565);
  static const Color surfaceColor = Color(0xFFFCF9F8);
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textMuted = Color(0xFF3E4949);
  static const Color cardBg = Colors.white;
  static const Color inputBg = Color(0xFFF9F9F9);
  static const Color borderColor = Color(0xFFBDC9C8);
  static const Color secondaryContainer = Color(0xFFD4E6E5);

  @override
  void dispose() {
    _emailController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : primaryColor,
      ),
    );
  }

  void _startTimer() {
    setState(() {
      _timeLeft = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        setState(() => _canResend = true);
        _timer?.cancel();
      }
    });
  }

  // --- API Handling: Send OTP ---
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email address.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final res = await AuthApiService.sendSignupOtp(email);

    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _otpToken = res['otp_token'];
      setState(() => _isOtpStep = true);
      _startTimer();
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      _showSnackBar(res['message'] ?? 'OTP sent to your email.');
    } else {
      // res['message'] is now always populated by AuthApiService._post,
      // so this will show the real reason instead of a generic string.
      _showSnackBar(res['message'] ?? 'Failed to send OTP', isError: true);
    }
  }

  // --- API Handling: Verify OTP ---
  Future<void> _handleVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join().trim();
    if (otp.length < 6) {
      _showSnackBar('Please enter the complete 6-digit code.', isError: true);
      return;
    }

    if (_otpToken == null) {
      _showSnackBar('Invalid session. Please request OTP again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final res = await AuthApiService.verifySignupOtp(
      email: _emailController.text.trim(),
      otp: otp,
      otpToken: _otpToken!,
      name: 'Seller Account',
      mobile: '0000000000',
      vendorType: '5',
      password: 'TemporaryPassword123!',
    );

    setState(() => _isLoading = false);

    if (res['success'] != true) {
      _showSnackBar(res['message'] ?? 'Verification failed', isError: true);
      return;
    }

    // The unmodified auth_api.php returns vendor_id, vendor_type,
    // access_key, secret_key, status — no SESSION_ID. Persist what's
    // actually there instead of assuming a session exists.
    final vendorId = res['vendor_id']?.toString() ?? '';
    final vendorType = res['vendor_type']?.toString() ?? '5';
    final accessKey = res['access_key']?.toString() ?? '';
    final secretKey = res['secret_key']?.toString() ?? '';

    if (vendorId.isEmpty || accessKey.isEmpty || secretKey.isEmpty) {
      _showSnackBar(
        'Signup succeeded but the server did not return credentials. '
            'Please contact support.',
        isError: true,
      );
      return;
    }

    // Store the long-lived credential pair.
    await Database().storeAccessToken(accessKey, secretKey);

    // Store vendor identity. NOTE: this app's other services
    // (Database.getData / SellerProfileService) send a 'SESSION-ID'
    // header sourced from UserSessionSet.getSessionId(). Since this API
    // doesn't issue one, we use access_key as that value for now so
    // downstream calls have *something* non-empty to send — confirm
    // with your backend whether seller_profile_api.php actually expects
    // this, or expects access_key/secret_key headers instead.
    await UserSessionSet.instance.saveLoginData(
      sessionId: accessKey,
      vendorId: vendorId,
      vendorType: vendorType,
    );

    if (!mounted) return;

    _showSnackBar('Signup Successful!');

    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(
    //     builder: (_) => const SellerProfileCompletionScreen(),
    //   ),
    //       (route) => false,
    // );biswajit
  }

  void _goToEmailStep() {
    _timer?.cancel();
    setState(() => _isOtpStep = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: borderColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Serene Commerce',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'HELP CENTER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Branding Header
                        const Text(
                          'Become a Seller',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join our curated marketplace of premium brands.',
                          style: TextStyle(
                            fontSize: 16,
                            color: textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Main Form Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated Step Switcher
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 0.05),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _isOtpStep
                                    ? _buildOtpStep()
                                    : _buildEmailStep(),
                              ),
                              const SizedBox(height: 24),
                              Divider(
                                  color: borderColor.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),

                              // Back to Login Action
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back,
                                        size: 20, color: textMuted),
                                    SizedBox(width: 8),
                                    Text(
                                      'Back to Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Features Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildFeatureItem(
                                icon: Icons.payments_outlined,
                                title: 'INSTANT PAYOUTS',
                                subtitle: 'Get paid within 24 hours.',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFeatureItem(
                                icon: Icons.verified_user_outlined,
                                title: 'SECURE SALES',
                                subtitle: 'Fraud protection enabled.',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Email Input View
  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EMAIL ADDRESS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 16, color: textDark),
          decoration: InputDecoration(
            hintText: 'seller@example.com',
            hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.5)),
            prefixIcon: const Icon(Icons.email_outlined, color: textMuted),
            filled: true,
            fillColor: inputBg,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Send Verification Code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // OTP Verification View
  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey('otp_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ENTER 6-DIGIT CODE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: textMuted,
              ),
            ),
            TextButton(
              onPressed: (_canResend && !_isLoading) ? _handleSendOtp : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _canResend ? 'Resend Code' : 'Resend in ${_timeLeft}s',
                style: TextStyle(
                  fontSize: 14,
                  color: _canResend ? primaryColor : borderColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // OTP Input Row
        LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double itemWidth =
            ((availableWidth - 40) / 6).clamp(36.0, 48.0);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: itemWidth,
                  height: 56,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 16),

        // Subtext with edit email option
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                "We've sent a code to ",
                style: TextStyle(fontSize: 14, color: textMuted),
              ),
              Text(
                _emailController.text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _goToEmailStep,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Verify & Proceed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // Auxiliary feature widgets
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}