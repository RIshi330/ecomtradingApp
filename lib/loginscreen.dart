import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/seller/join_seller_screen.dart';
import 'package:trading_ecommerce_admin/services/auth_User_and_Business_Session.dart';
import 'package:trading_ecommerce_admin/services/location_service.dart';
import 'package:trading_ecommerce_admin/otp_screen.dart';
import 'Database/Database.dart';
import 'admin/admin_loginscreen.dart';
import 'businessDashboard/Roleselection_screen.dart';
import 'businessDashboard/Seller_dashboard.dart';
import 'businessDashboard/community Dashboard.dart';
import 'normaluser/UsermainScreen.dart';

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
  String selectedRole = 'Normal'; // 'Normal' or 'Business'
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
        'action': 'login_with_password',
        'email': email,
        'password': password,
        'rememberMe': _rememberMe ? 'true' : 'false',
      }, endpoint: 'new_apis/sign_up_API.php');

      if (!mounted) return;

      if (response['success'] != true && response['status'] != 200) {
        _showError(
          response['message'] ??
              response['error'] ??
              'Invalid email or password',
        );
        return;
      }

      final vendorId = int.tryParse(
        response['vendor_id']?.toString() ??
            response['data']?['vendor_id']?.toString() ??
            '0',
      ) ??
          0;

      // Fetch full profile to get the actual vendor_type if missing
      Map<String, dynamic> fullUserData = Map<String, dynamic>.from(response);
      String? vendorType = response['vendor_type']?.toString() ??
          response['data']?['vendor_type']?.toString() ??
          response['full_data']?['vendor_type']?.toString() ??
          response['LOGIN_RESPONSE']?['vendor_type']?.toString() ??
          response['LOGIN_RESPONSE']?['full_data']?['vendor_type']
              ?.toString();
      final String sessionId =
          response['verify_code']?.toString() ?? '';

      if (vendorType == null && vendorId != 0) {
        try {
          debugPrint(
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
          debugPrint('Error fetching profile for login check: $e');
        }
      }

      if (vendorType == null && response['redirect'] != null) {
        final redirect = response['redirect'].toString().toLowerCase();
        if (redirect.contains('dashboard')) {
          debugPrint(
              'loginscreen: Inferring vendor_type as 2 based on redirect dashboard: $redirect');
          vendorType = '2';
          fullUserData['vendor_type'] = '2';
        }
      }

      vendorType ??= '500'; // Default fallback
      print("---------------------------");
      await UserSessionSet.instance.saveLoginData(sessionId: sessionId, vendorId: vendorId.toString(), vendorType: vendorType.toString());

      _showSuccessBanner('Login successful! Redirecting...');

      // Wait to show the toast banner before navigating
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // // Role mismatch checks
      // if (selectedRole == 'Business' && vendorType == '500') {
      //   _showError('This account is not registered as a Business User.');
      //   await UserSessionSet.instance.logout();
      //   return;
      // }
      // if (selectedRole == 'Normal' && vendorType != '500') {
      //   _showError(
      //       'This is a Business User account. Please select Business User role.');
      //   await UserSessionSet.instance.logout();
      //   return;
      // }
      // Handle business users with multiple linked accounts/roles
      final bool hasMultipleAccounts = response['multiple_accounts'] == true &&
          response['accounts'] is List &&
          (response['accounts'] as List).isNotEmpty;

      if (hasMultipleAccounts) {
        final accounts = (response['accounts'] as List)
            .map((a) => VendorAccount.fromJson(Map<String, dynamic>.from(a)))
            .toList();

        final String sessionId = response['SESSION_ID']?.toString() ??
            response['ESSION_ID']?.toString() ??
            '';

        _showSuccessBanner('Login successful! Please select a role.');
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessRoleSelectionScreen(
              accounts: accounts,
              sessionId: sessionId,
            ),
          ),
              (route) => false,
        );
        return;
      }

      // Normal role → straight to user main screen
      if (selectedRole == 'Normal') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserMainScreen()),
              (route) => false,
        );
        return;
      }

      // Business role
      if (vendorType == '200') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CommunityDashboardScreen()),
              (route) => false,
        );
        return;
      }

      if (vendorType == '5') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SellerDashboard()),
              (route) => false,
        );
        return;
      }

      // Other/multiple business roles → let the user choose
      final vendorTypes =
      (fullUserData['vendor_type']?.toString().split(',') ?? <String>[]);
      _showBusinessRoleSelection(
        vendorId,
        fullUserData,
        vendorTypes.cast<String>(),
      );
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
        'action': 'send_login_otp',
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
        'action': 'verify_login_otp',
        'otp': otp,
        'rememberMe': _rememberMe ? 'true' : 'false',
      }, endpoint: 'new_apis/sign_up_API.php');

      if (!mounted) return;

      if (response['success'] != true && response['status'] != 200) {
        _showError(response['message'] ?? 'Invalid OTP');
        return;
      }

      final vendorId = int.tryParse(
        response['vendor_id']?.toString() ?? '0',
      ) ??
          0;

      // Fetch full profile to get the actual vendor_type if missing
      Map<String, dynamic> fullUserData = Map<String, dynamic>.from(response);
      String? vendorType = response['vendor_type']?.toString() ??
          response['data']?['vendor_type']?.toString() ??
          response['full_data']?['vendor_type']?.toString() ??
          response['LOGIN_RESPONSE']?['vendor_type']?.toString() ??
          response['LOGIN_RESPONSE']?['full_data']?['vendor_type']
              ?.toString();

      if (vendorType == null && vendorId != 0) {
        try {
          debugPrint(
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
          debugPrint('Error fetching profile for login check: $e');
        }
      }

      if (vendorType == null && response['redirect'] != null) {
        final redirect = response['redirect'].toString().toLowerCase();
        if (redirect.contains('dashboard')) {
          debugPrint(
              'loginscreen: Inferring vendor_type as 2 based on redirect dashboard: $redirect');
          vendorType = '2';
          fullUserData['vendor_type'] = '2';
        }
      }
      final String sessionId =
          response['SESSION_ID']?.toString() ?? '';

      vendorType ??= '500'; // Default fallback

      await UserSessionSet.instance.saveLoginData(sessionId: sessionId, vendorId: vendorId.toString(), vendorType: vendorType.toString());

      _showSuccessBanner('Login successful! Redirecting...');
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      if (selectedRole == 'Business' && vendorType == '500') {
        _showError('This account is not registered as a Business User.');
        await UserSessionSet.instance.logout();
        return;
      }
      if (selectedRole == 'Normal' && vendorType != '500') {
        _showError(
            'This is a Business User account. Please select Business User role.');
        await UserSessionSet.instance.logout();
        return;
      }

      if (vendorType != '500') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SellerDashboard()),
              (route) => false,
        );
        return;
      }

      //  final hasInterests = await _checkUserHasInterests(vendorId);
      // if (!mounted) return;
      // if (hasInterests) {
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (_) => const AppShell()),
      //         (route) => false,
      //   );
      //  }
      else {
        //   Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (_) => const IndustriesScreen()),
        //         (route) => false,
        //   );
      }
    }
    catch (e) {
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
              isRecruiter: false,
              name: name,
              mobile: mobile,
              password: password,
              vendorType: '20',
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

  // Kept for future use (currently not called from the login flows above).
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

  // ══════════════════════════════════════════════════════════
  // UI — restyled to match AdminLoginScreen (light gradient bg,
  // back button, accent icon badge, white filled inputs)
  // ══════════════════════════════════════════════════════════

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
              // MAIN CONTENT CARD
              // ==================================================
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTabBar(),
                              Padding(
                                padding: const EdgeInsets.all(28.0),
                                child: isSignUpTab
                                    ? _buildSignUpForm()
                                    : _buildSignInForm(),
                              ),
                            ],
                          ),
                        ),
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
                        ? accentColor
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
                  color: !isSignUpTab ? accentColor : Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap:
            _isLoading ? null : () => setState(() => isSignUpTab = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSignUpTab ? accentColor : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                "Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSignUpTab ? accentColor : Colors.grey.shade400,
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
        _buildIconBadge(Icons.lock_open_rounded),
        const SizedBox(height: 20),
        const Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join your community conversations today",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        _buildRoleSelector(),
        const SizedBox(height: 24),
        isPasswordLogin ? _buildPasswordLoginForm() : _buildOtpLoginForm(),
        const SizedBox(height: 28),
        _buildTermsAndPrivacy(),
      ],
    );
  }

  // Accent-filled icon badge with soft shadow, matching AdminLoginScreen.
  Widget _buildIconBadge(IconData icon) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 38,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _buildRoleItem('Normal', Icons.person_outline_rounded, 'Normal User'),
          _buildRoleItem(
              'Business', Icons.business_outlined, 'Business User'),
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
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
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
        _buildIconBadge(Icons.person_add_outlined),
        const SizedBox(height: 20),
        const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join our community today",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        _styledField(
          controller: signupNameController,
          icon: Icons.person_outline_rounded,
          hint: "Full Name",
        ),
        const SizedBox(height: 16),
        _styledField(
          controller: signupEmailController,
          icon: Icons.email_outlined,
          hint: "Email Address",
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _styledField(
          controller: signupMobileController,
          icon: Icons.phone_outlined,
          hint: "Mobile Number",
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _styledField(
          controller: signupPasswordController,
          icon: Icons.lock_outline_rounded,
          hint: "Password",
          obscureText: signupObscurePassword,
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
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SellOnLuxeScreen()),
            );
          },
          child: const Text(
            "Join as a Seller",
            style: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 54,
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
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Send OTP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        _buildTermsAndPrivacy(),
      ],
    );
  }

  Widget _buildPasswordLoginForm() {
    return Column(
      children: [
        _styledField(
          controller: usernameController,
          icon: Icons.person_outline_rounded,
          hint: "Username or Email",
        ),
        const SizedBox(height: 16),
        _styledField(
          controller: passwordController,
          icon: Icons.lock_outline_rounded,
          hint: "Password",
          obscureText: _obscurePassword,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
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
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen()),
              );
            },
            child: const Text(
              "Admin Login",
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 54,
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
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Sign In",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildOrDivider(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              backgroundColor: const Color(0xFFE5F5F5),
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
          _styledField(
            controller: otpEmailController,
            icon: Icons.email_outlined,
            hint: "Email or Mobile",
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
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
          _styledField(
            controller: otpController,
            icon: Icons.lock_outline_rounded,
            hint: "Enter OTP",
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
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
        const SizedBox(height: 24),
        _buildOrDivider(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              backgroundColor: const Color(0xFFE5F5F5),
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

  // Reusable "Secure Access"-style divider, matching AdminLoginScreen.
  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  // Reusable text field styled exactly like AdminLoginScreen's inputs:
  // filled white, no border, rounded 16, accentColor focus ring.
  Widget _styledField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFE5F5F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
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

  void _showBusinessRoleSelection(
      int vendorId,
      Map<String, dynamic> userData,
      List<String> vendorTypes,
      ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Business Role",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (vendorTypes.contains('200'))
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_rounded),
                  title: const Text("Community Admin Dashboard"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CommunityDashboardScreen()),
                          (route) => false,
                    );
                  },
                ),
              if (vendorTypes.contains('5'))
                ListTile(
                  leading: const Icon(Icons.storefront_rounded),
                  title: const Text("Seller Dashboard"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SellerDashboard()),
                          (route) => false,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}