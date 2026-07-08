import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Database/Database.dart';
import '../services/auth_service.dart';
import 'Community_Admin_Dashboard.dart';



// The admin_login_api.php endpoint, called through the same Database
// class the rest of the app uses (form-encoded body + session headers),
// instead of a separate hand-rolled http client.
const String _adminEndpoint = 'new_apis/admin_login_api.php';

// =====================================================================
// SPLASH SCREEN
// =====================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final database = Database();

      // 1. Is there already a live PHP session?
      final sessionCheck = await database.getData(
        {'action': 'check_session'},
        endpoint: _adminEndpoint,
      );
      if (sessionCheck['success'] == true) {
        await _saveAdminIdentity(sessionCheck);
        if (mounted) _goToDashboard();
        return;
      }

      // 2. No active session — try the remember-me cookie flow
      final rememberCheck = await database.getData(
        {'action': 'check_remember_login'},
        endpoint: _adminEndpoint,
      );
      if (rememberCheck['success'] == true) {
        await _saveAdminIdentity(rememberCheck);
        if (mounted) _goToDashboard();
        return;
      }
    } catch (e) {
      // Log the real reason instead of silently falling through —
      // check your debug console when the splash screen "randomly"
      // sends you to login.
      debugPrint('Splash admin session check failed: $e');
    }

    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _saveAdminIdentity(Map response) async {
    final data = response['data'];
    if (data is! Map) return;
    final adminId = int.tryParse(data['admin_id']?.toString() ?? '');
    final email = data['email']?.toString();
    if (adminId != null && email != null) {
      await AuthService.saveAdminSession(adminId: adminId, email: email);
    }
  }

  void _goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CommunityAdminDashboard()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006565), Color(0xFF004040)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 32),
              const Text(
                'Serene Commerce',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vendor Management Portal',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ADMIN LOGIN SCREEN
// =====================================================================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  static const String _savedEmailKey = 'saved_admin_email';

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_savedEmailKey);
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final database = Database();
      final result = await database.getData({
        'action': 'login',
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        if (_rememberMe) 'rememberMe': 'true',
      }, endpoint: _adminEndpoint);

      if (!mounted) return;

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString(_savedEmailKey, _emailController.text.trim());
        } else {
          await prefs.remove(_savedEmailKey);
        }

        final data = result['data'];
        final adminId = int.tryParse(data?['admin_id']?.toString() ?? '') ?? 0;
        final adminEmail = data?['email']?.toString() ?? _emailController.text.trim();
        await AuthService.saveAdminSession(adminId: adminId, email: adminEmail);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CommunityAdminDashboard()),
              (route) => false,
        );
      } else {
        // PHP returns messages like "Wrong password" / "Email not registered."
        _showError(
          result['message']?.toString() ??
              result['error']?.toString() ??
              'Login failed. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Admin login failed: $e');
      _showError('Network error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFBA1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF006565),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF006565).withOpacity(0.05),
              const Color(0xFFF9F9F9),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1C), size: 24),
                    tooltip: 'Go Back',
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF006565),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF006565).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.storefront, color: Colors.white, size: 50),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1C1C),
                            fontFamily: 'Manrope',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to manage your vendor ecosystem',
                          style: TextStyle(fontSize: 16, color: Color(0xFF3E4949), fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'admin@serenecommerce.com',
                            prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF3E4949), size: 22),
                            errorStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3E4949), size: 22),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFF3E4949),
                                size: 22,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                    activeColor: const Color(0xFF006565),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF3E4949), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showToast('Password reset link sent to your email'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF006565)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006565),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: const Color(0xFFBDC9C8))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Secure Access',
                                style: TextStyle(fontSize: 12, color: const Color(0xFF6E7979), fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(child: Container(height: 1, color: const Color(0xFFBDC9C8))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF6E7979)),
                            const SizedBox(width: 6),
                            Text(
                              'v2.1.0 • Secure Enterprise Suite',
                              style: TextStyle(fontSize: 12, color: const Color(0xFF6E7979), fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ],
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