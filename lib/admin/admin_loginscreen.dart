import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/admin/test.dart';
import 'package:trading_ecommerce_admin/admin/wallet_admin_screen.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/services/location_service.dart';

import '../services/auth_User_and_Business_Session.dart';
import 'Admin_Dashboard.dart';
import 'business_user_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  static const Color accentColor = Color(0xFF006565);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessBanner(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: accentColor,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on,
                      color: Color(0xFF006565),
                      size: 38,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Enable Location",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

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

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF006565),
                      ),
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

  // ============================================================
  // ADMIN LOGIN
  // ============================================================

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(
        'Please enter email/username and password',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final database = Database();

      final response = await database.getData(
        {
          'action': 'admin_login_with_password',
          'email': email,
          'password': password,
          'rememberMe': _rememberMe ? 'true' : 'false',
        },
        endpoint: 'new_apis/sign_up_API.php',
      );

      if (!mounted) return;

      // ========================================================
      // LOGIN SUCCESS
      // ========================================================

      if (response['success'] == true ||
          response['status'] == 200) {

        // ======================================================
        // ADMIN LOGIN
        // ======================================================
        //
        // final int adminId =
        //     int.tryParse(
        //       response['admin_id']?.toString() ?? '',
        //     ) ?? 0;
        //
        // final String sessionId =
        //     response['SESSION_ID']?.toString() ?? '';
        //
        // if (adminId == 0 || sessionId.isEmpty) {
        //   _showError(
        //     'Login successful, but admin session information is missing.',
        //   );
        //   return;
        // }
        final vendorId = int.tryParse(
          response['admin_id']?.toString() ??
              response['data']?['admin_id']?.toString() ??
              '0',
        ) ??
            0;

        // Fetch full profile to get the actual vendor_type if missing
        Map<String, dynamic> fullUserData = Map<String, dynamic>.from(response);
        int? vendorType = int.tryParse(
          (response['vendor_type']?.toString() ??
              response['data']?['vendor_type']?.toString() ??
              response['full_data']?['vendor_type']?.toString() ??
              response['LOGIN_RESPONSE']?['vendor_type']?.toString() ??
              response['LOGIN_RESPONSE']?['full_data']?['vendor_type']?.toString() ??
              '')
              .replaceAll(',', ''),
        );
        final String sessionId =
            response['verify_code']?.toString() ?? '';
      print(vendorType);
      print(vendorId);
      print(sessionId);
        await UserSessionSet.instance.saveLoginData(sessionId: sessionId, vendorId: vendorId.toString(), vendorType: vendorType.toString());
        final String? adminId =
        await UserSessionSet.instance.vendorId;

        final vendorI =
        await UserSessionSet.instance.vendorType;
        print("0------");
        print(adminId);
        print(vendorI);
        // In LoginScreen._login, right after saveLoginData:

        // ------------------------------------------------------
        // Debug
        // ------------------------------------------------------


        _showSuccessBanner(
          'Login successful! Redirecting...',
        );

        await Future.delayed(
          const Duration(milliseconds: 1500),
        );

        if (!mounted) return;

        // ------------------------------------------------------
        // Location permission
        // ------------------------------------------------------

        await _showLocationPermissionDialog();

        if (!mounted) return;

        // ------------------------------------------------------
        // Navigate to Admin Dashboard
        // ------------------------------------------------------

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const SuperAdminDashboard(),
          ),
              (route) => false,
        );

        return;
      }

      // ========================================================
      // LOGIN FAILED
      // ========================================================

      _showError(
        response['message'] ??
            response['error'] ??
            'Invalid email or password',
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('ADMIN LOGIN ERROR: $e');

      _showError(
        'Network error: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE2EAE9),
              Color(0xFFD4DFDD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==================================================
              // BACK BUTTON
              // ==================================================

              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 16,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // ==================================================
              // MAIN CONTENT
              // ==================================================

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // ==================================================
                          // ICON
                          // ==================================================

                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius:
                              BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.storefront_outlined,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // TITLE
                          // ==================================================

                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Sign in to manage your vendor ecosystem",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ==================================================
                          // EMAIL
                          // ==================================================

                          TextField(
                            controller: _emailController,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.grey,
                              ),
                              hintText: "Email Address",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide:
                                const BorderSide(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // PASSWORD
                          // ==================================================

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                                },
                              ),
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                                borderSide:
                                const BorderSide(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // REMEMBER ME + FORGOT PASSWORD
                          // ==================================================

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [

                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: accentColor,
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                      onChanged: _isLoading
                                          ? null
                                          : (val) {
                                        setState(() {
                                          _rememberMe =
                                              val ?? false;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "Remember me",
                                    style: TextStyle(
                                      color:
                                      Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),

                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                  _showError(
                                    "Password reset is managed by the main platform admin.",
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight:
                                    FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // ==================================================
                          // LOGIN BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                accentColor,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed:
                              _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                                children: const [
                                  Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons
                                        .arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ==================================================
                          // SECURE ACCESS
                          // ==================================================

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),

                              Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "Secure Access",
                                  style: TextStyle(
                                    color:
                                    Colors.grey.shade500,
                                    fontWeight:
                                    FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // VERSION
                          // ==================================================

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.grey.shade500,
                                size: 6,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                "v2.1.0 • Secure Enterprise Suite",
                                style: TextStyle(
                                  color:
                                  Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}