import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/services/location_service.dart';
import 'package:trading_ecommerce_admin/common/shell.dart';
import 'package:trading_ecommerce_admin/common/industries_screen.dart';
import 'package:trading_ecommerce_admin/app_constants.dart';
import 'package:trading_ecommerce_admin/otp_screen.dart';
import 'package:trading_ecommerce_admin/admin/Community_Admin_Dashboard.dart';
import 'package:trading_ecommerce_admin/admin/business_user_dashboard_screen.dart';

import 'Database/Database.dart';
import 'admin/admin_login.dart';
import 'admin/admin_loginscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUpTab = false;
  bool isPasswordLogin = true;
  bool otpSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool signupIsAdmin = false;
  String selectedRole = 'Normal'; // 'Normal', 'Business', 'Admin'
  static const Color accentColor = Color(0xFF006565);

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final otpEmailController = TextEditingController();
  final otpController = TextEditingController();

  // Controllers for Sign Up Form
  bool signupObscurePassword = true;
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupMobileController = TextEditingController();
  final signupPasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    otpEmailController.dispose();
    otpController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupMobileController.dispose();
    signupPasswordController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // BACKEND: Sign In (Password Login)
  // ══════════════════════════════════════════════════════════
  Future<void> _login() async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email/username and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final database = Database();
      final response = await database.getData({
        'action': selectedRole == 'Admin'
            ? 'admin_login_with_password'
            : 'login_with_password',
        'email': email,
        'password': password,
        'rememberMe': _rememberMe ? 'true' : 'false',
      }, endpoint: 'new_apis/sign_up_API.php');

      if (!mounted) return;

      if (response['success'] == true || response['status'] == 200) {
        final vendorId = int.tryParse(
              response['vendor_id']?.toString() ??
                  response['data']?['vendor_id']?.toString() ??
                  '0',
            ) ??
            0;

        // Fetch full profile to get the actual vendor_type if missing
        Map<String, dynamic> fullUserData =
            response is Map ? Map<String, dynamic>.from(response) : {};
        String? vendorType = response['vendor_type']?.toString() ??
            response['data']?['vendor_type']?.toString() ??
            response['full_data']?['vendor_type']?.toString() ??
            response['LOGIN_RESPONSE']?['vendor_type']?.toString() ??
            response['LOGIN_RESPONSE']?['full_data']?['vendor_type']
                ?.toString();

        if (vendorType == null && vendorId != 0 && selectedRole != 'Admin') {
          try {
            print(
                'loginscreen: vendor_type missing from login response. Fetching profile for vendor $vendorId...');
            final profileRes = await database.getData({
              'action': 'profile',
              'vendor_id': vendorId.toString(),
            });
            if (profileRes['success'] == true || profileRes['status'] == 200) {
              final profile = profileRes['data']?['profile'];
              if (profile != null && profile is Map) {
                vendorType = profile['vendor_type']?.toString();
                fullUserData.addAll(Map<String, dynamic>.from(profile));
              }
            }
          } catch (e) {
            print('Error fetching profile for login check: $e');
          }
        }

        if (vendorType == null && response['redirect'] != null) {
          final redirect = response['redirect'].toString().toLowerCase();
          if (redirect.contains('dashboard')) {
            print(
                'loginscreen: Inferring vendor_type as 2 based on redirect dashboard: $redirect');
            vendorType = '2';
            fullUserData['vendor_type'] = '2';
          }
        }

        vendorType ??= '500'; // Default fallback

        await AuthService.saveLoginSession(
          vendorId: vendorId,
          userData: fullUserData,
        );
        _showSuccessBanner('Login successful! Redirecting...');

        // Wait 1.5 seconds to show the toast banner before navigating
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        // await _showLocationPermissionDialog();
        if (!mounted) return;

        if (selectedRole == 'Admin') {
          final adminId =
              int.tryParse(response['admin_id']?.toString() ?? '1') ?? 1;
          final adminEmail = email;

          await AuthService.saveAdminSession(
              adminId: adminId, email: adminEmail);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BusinessUserDashboard()),
            (route) => false,
          );
          return;
        }

        if (selectedRole == 'Business' &&
            (vendorType == '500' || vendorType == '1')) {
          _showError('This account is not registered as a Business User.');
          await AuthService.clearSession();
          return;
        }
        if (selectedRole == 'Normal' &&
            (vendorType != '500' && vendorType != '1')) {
          _showError(
              'This is a Business User account. Please select Business User role.');
          await AuthService.clearSession();
          return;
        }

        if (vendorType != '500' && vendorType != '1') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const CommunityAdminDashboard()),
            (route) => false,
          );
          return;
        }

        final hasInterests = await _checkUserHasInterests(vendorId);
        if (!mounted) return;
        if (hasInterests) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AppShell()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => TopicSelectionScreen(
                vendorId: vendorId,
                isEditing: false,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        _showError(
          response['message'] ??
              response['error'] ??
              'Invalid email or password',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════
  // BACKEND: Sign In (Send OTP)
  // ══════════════════════════════════════════════════════════
  Future<void> _sendOtp() async {
    final email = otpEmailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email or mobile');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final database = Database();
      final response = await database.getData({
        'action':
            selectedRole == 'Admin' ? 'send_admin_login_otp' : 'send_login_otp',
        'email': email,
      }, endpoint: 'new_apis/sign_up_API.php');

      if (!mounted) return;
      if (response['success'] == true || response['status'] == 200) {
        setState(() => otpSent = true);
        _showSuccessBanner('OTP sent successfully!');
      } else {
        _showError(response['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════
  // BACKEND: Sign In (Verify OTP)
  // ══════════════════════════════════════════════════════════
  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length < 4) {
      _showError('Enter a valid OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final database = Database();
      final response = await database.getData({
        'action': selectedRole == 'Admin'
            ? 'verify_admin_login_otp'
            : 'verify_login_otp',
        'otp': otp,
        'rememberMe': _rememberMe ? 'true' : 'false',
      }, endpoint: 'new_apis/sign_up_API.php');

      if (!mounted) return;
      if (response['success'] == true || response['status'] == 200) {
        if (selectedRole == 'Admin') {
          final adminId =
              int.tryParse(response['admin_id']?.toString() ?? '1') ?? 1;
          final adminEmail = otpEmailController.text.trim();
          await AuthService.saveAdminSession(
              adminId: adminId, email: adminEmail);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BusinessUserDashboard()),
            (route) => false,
          );
          return;
        }

        final vendorId = int.tryParse(
              response['vendor_id']?.toString() ?? '0',
            ) ??
            0;

        // Fetch full profile to get the actual vendor_type if missing
        Map<String, dynamic> fullUserData =
            response is Map ? Map<String, dynamic>.from(response) : {};
        String? vendorType = response['vendor_type']?.toString() ??
            response['data']?['vendor_type']?.toString() ??
            response['full_data']?['vendor_type']?.toString() ??
            response['LOGIN_RESPONSE']?['vendor_type']?.toString() ??
            response['LOGIN_RESPONSE']?['full_data']?['vendor_type']
                ?.toString();

        if (vendorType == null && vendorId != 0 && selectedRole != 'Admin') {
          try {
            print(
                'loginscreen: vendor_type missing from login response. Fetching profile for vendor $vendorId...');
            final profileRes = await database.getData({
              'action': 'profile',
              'vendor_id': vendorId.toString(),
            });
            if (profileRes['success'] == true || profileRes['status'] == 200) {
              final profile = profileRes['data']?['profile'];
              if (profile != null && profile is Map) {
                vendorType = profile['vendor_type']?.toString();
                fullUserData.addAll(Map<String, dynamic>.from(profile));
              }
            }
          } catch (e) {
            print('Error fetching profile for login check: $e');
          }
        }

        if (vendorType == null && response['redirect'] != null) {
          final redirect = response['redirect'].toString().toLowerCase();
          if (redirect.contains('dashboard')) {
            print(
                'loginscreen: Inferring vendor_type as 2 based on redirect dashboard: $redirect');
            vendorType = '2';
            fullUserData['vendor_type'] = '2';
          }
        }

        vendorType ??= '500'; // Default fallback

        await AuthService.saveLoginSession(
          vendorId: vendorId,
          userData: fullUserData,
        );
        _showSuccessBanner('Login successful! Redirecting...');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;
        //biswajit
        // await _showLocationPermissionDialog();
        if (!mounted) return;

        if (selectedRole == 'Business' &&
            (vendorType == '500' || vendorType == '1')) {
          _showError('This account is not registered as a Business User.');
          await AuthService.clearSession();
          return;
        }
        if (selectedRole == 'Normal' &&
            (vendorType != '500' && vendorType != '1')) {
          _showError(
              'This is a Business User account. Please select Business User role.');
          await AuthService.clearSession();
          return;
        }

        if (vendorType != '500' && vendorType != '1') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const CommunityAdminDashboard()),
            (route) => false,
          );
          return;
        }

        final hasInterests = await _checkUserHasInterests(vendorId);
        if (!mounted) return;
        if (hasInterests) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AppShell()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => TopicSelectionScreen(
                vendorId: vendorId,
                isEditing: false,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        _showError(response['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════
  // BACKEND: Sign Up (Send OTP & Navigate to OTP Screen)
  // ══════════════════════════════════════════════════════════
  Future<void> _signUpSendOtp() async {
    final name = signupNameController.text.trim();
    final email = signupEmailController.text.trim();
    final mobile = signupMobileController.text.trim();
    final password = signupPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
      _showError('Please fill out all fields');
      return;
    }
    if (!email.contains('@')) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await Database().getData({
        'action': 'send_signup_otp',
        'email': email,
      }, endpoint: 'new_apis/sign_up_API.php');

      if (!mounted) return;

      if (data['success'] == true || data['status'] == 200) {
        _showSuccessBanner('OTP sent successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: email,
              isRecruiter: signupIsAdmin,
              name: name,
              mobile: mobile,
              password: password,
              vendorType: signupIsAdmin ? '1' : '20',
            ),
          ),
        );
      } else {
        _showError(data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ));
  }

  void _showSuccessBanner(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF006565),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showLocationPermissionDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5F5F5), // Light teal circle background
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on,
                      color: Color(0xFF006565), // Dark teal pin
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  "Enable Location",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                const Text(
                  "Luxe requires access to your location to provide personalized delivery estimates, calculate taxes correctly, and display premium stores near you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Allow Access Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await LocationService.requestAndGetLocation();
                      } catch (_) {}
                    },
                    child: const Text(
                      "Allow Access",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Not Now Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF006565)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Not Now",
                      style: TextStyle(
                        color: Color(0xFF006565),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkUserHasInterests(int vendorId) async {
    try {
      final local = await AuthService.hasSelectedInterests();
      if (local) return true;
      final database = Database();
      final res = await database.getData({
        'action': 'get_user_interests',
        'vendor_id': vendorId.toString(),
      });
      if (res['success'] == true || res['status'] == 200) {
        final data = res['data'];
        if (data != null && data is List && data.isNotEmpty) {
          final ids = data
              .map((i) =>
                  int.tryParse(
                    i['interest_id']?.toString() ?? i['id']?.toString() ?? '0',
                  ) ??
                  0)
              .toList();
          await AuthService.saveUserInterests(ids.cast<int>());
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F1F),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF004D4D),
              Color(0xFF001F1F),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tab Bar at the top of the card
                  _buildTabBar(),
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child:
                        isSignUpTab ? _buildSignUpForm() : _buildSignInForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap:
                _isLoading ? null : () => setState(() => isSignUpTab = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: !isSignUpTab
                        ? const Color(0xFF006565)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                "Sign In",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !isSignUpTab
                      ? const Color(0xFF006565)
                      : Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading ? null : () => setState(() => isSignUpTab = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSignUpTab
                        ? const Color(0xFF006565)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                "Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSignUpTab
                      ? const Color(0xFF006565)
                      : Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered Unlock Padlock Graphic
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.lock_open_rounded,
            color: accentColor,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),

        // Welcome Back Title
        const Text(
          "Welcome back",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          "Join your community conversations today",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),

        // Custom Role Selector
        _buildRoleSelector(),
        const SizedBox(height: 24),

        // Password vs OTP Login inputs
        isPasswordLogin ? _buildPasswordLoginForm() : _buildOtpLoginForm(),
        const SizedBox(height: 28),

        _buildTermsAndPrivacy(),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _buildRoleItem('Normal', Icons.person_outline_rounded, 'Normal User'),
          _buildRoleItem('Business', Icons.business_outlined, 'Business User'),
          // _buildRoleItem('Admin', Icons.shield_outlined, 'Admin'),
        ],
      ),
    );
  }

  Widget _buildRoleItem(String roleType, IconData icon, String label) {
    final bool isSelected = selectedRole == roleType;
    return Expanded(
      child: GestureDetector(
        onTap:
            _isLoading ? null : () => setState(() => selectedRole = roleType),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? accentColor : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? accentColor : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered Add User Graphic
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.person_add_outlined,
            color: accentColor,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join our community today",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),
        _buildSignUpRoleTabs(),
        const SizedBox(height: 24),

        // Full Name field
        TextField(
          controller: signupNameController,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.person_outline_rounded, color: Colors.grey),
            hintText: "Full Name",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF0F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Email Input field
        TextField(
          controller: signupEmailController,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.black),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
            hintText: "Email Address",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF0F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Mobile Number field
        TextField(
          controller: signupMobileController,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.black),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
            hintText: "Mobile Number",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF0F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password field
        TextField(
          controller: signupPasswordController,
          obscureText: signupObscurePassword,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.lock_outline_rounded, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                signupObscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: () => setState(
                  () => signupObscurePassword = !signupObscurePassword),
            ),
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF0F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _signUpSendOtp,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Send OTP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 28),
        _buildTermsAndPrivacy(),
      ],
    );
  }

  Widget _buildSignUpRoleTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => setState(() => signupIsAdmin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !signupIsAdmin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !signupIsAdmin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  "Vendor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !signupIsAdmin ? accentColor : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => setState(() => signupIsAdmin = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: signupIsAdmin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: signupIsAdmin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  "Admin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: signupIsAdmin ? accentColor : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordLoginForm() {
    return Column(
      children: [
        // Username / Email Field
        TextField(
          controller: usernameController,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.person_outline_rounded, color: Colors.grey),
            hintText: "Username or Email",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF0F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password Field
        TextField(
          controller: passwordController,
          obscureText: _obscurePassword,
          enabled: !_isLoading,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.lock_outline_rounded, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF0F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: accentColor,
                onChanged: _isLoading
                    ? null
                    : (val) {
                        setState(() {
                          _rememberMe = val ?? false;
                        });
                      },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Remember me for 7 days",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLoginScreen(),));
        }, child: Text("Admin Login")),
        // Main Sign In Button
        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Signing in...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // OR Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),

        // Sign In with OTP button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              backgroundColor: const Color(0xFFF0F7F7),
              side: const BorderSide(color: accentColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () => setState(() {
                      isPasswordLogin = false;
                      otpSent = false;
                    }),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.phonelink_lock_rounded,
                    color: accentColor, size: 20),
                SizedBox(width: 8),
                Text(
                  "Sign In with OTP",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpLoginForm() {
    return Column(
      children: [
        if (!otpSent) ...[
          // Email or Mobile input
          TextField(
            controller: otpEmailController,
            enabled: !_isLoading,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
              hintText: "Email or Mobile",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF0F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _sendOtp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Send OTP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ] else ...[
          // OTP input
          TextField(
            controller: otpController,
            enabled: !_isLoading,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.lock_outline_rounded, color: Colors.grey),
              hintText: "Enter OTP",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF0F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Verify & Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
        const SizedBox(height: 20),

        // OR Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),

        // Sign In with Password Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              backgroundColor: const Color(0xFFF0F7F7),
              side: const BorderSide(color: accentColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () => setState(() => isPasswordLogin = true),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline_rounded, color: accentColor, size: 20),
                SizedBox(width: 8),
                Text(
                  "Sign In with Password",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            height: 1.5,
          ),
          children: const [
            TextSpan(text: "By continuing, you agree to our "),
            TextSpan(
              text: "Terms of Service",
              style: TextStyle(
                color: Color(0xFF006565),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: Color(0xFF006565),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: "."),
          ],
        ),
      ),
    );
  }
}
