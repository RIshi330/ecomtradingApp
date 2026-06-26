import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/common/industries_screen.dart';
import 'package:trading_ecommerce_admin/admin/Community_Admin_Dashboard.dart';
import 'package:trading_ecommerce_admin/admin/business_user_dashboard_screen.dart';
import 'package:trading_ecommerce_admin/common/shell.dart';

void main() {
  runApp(const LuxeWelcomeApp());
}

class LuxeWelcomeApp extends StatelessWidget {
  const LuxeWelcomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUXE | Welcome',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: const WelcomeSplashScreen(),
    );
  }
}

class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({super.key});

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeSlideController;
  late AnimationController _floatPulseController;
  late AnimationController _progressController;
  late AnimationController _sheenController;

  @override
  void initState() {
    super.initState();

    // 1. Entry Stagger Animations
    _fadeSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 2. Continuous Floating, Pulsing, and Twinkling Animations
    _floatPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 3. Cyclic Minimal Loading Linear Bar Loop
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 4. Metallic Loop Sheen Gradient Shift
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Fire entry presentation delay
    _fadeSlideController.forward();

    // FIXED: Added a delay to let the splash play before navigating
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Waits 3 seconds so users can appreciate the entry animations
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    try {
      // 1. Check if Admin Session is active
      final isAdmin = await AuthService.isAdminSession();
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CommunityAdminDashboard()),
        );
        return;
      }

      // 2. Check if general user/vendor session is valid
      final isUserValid = await AuthService.isSessionValid();
      if (isUserValid) {
        final vendorId = await AuthService.getVendorId();
        if (vendorId != null && vendorId != 0) {
          final userData = await AuthService.getCachedUserData();
          final vendorType = userData?['vendor_type']?.toString() ??
              userData?['data']?['vendor_type']?.toString() ??
              userData?['full_data']?['vendor_type']?.toString() ??
              userData?['LOGIN_RESPONSE']?['vendor_type']?.toString() ??
              userData?['LOGIN_RESPONSE']?['full_data']?['vendor_type']?.toString() ??
              '500';

          if (vendorType != '500' && vendorType != '1') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BusinessUserDashboard()),
            );
            return;
          }

          final hasInterests = await AuthService.hasSelectedInterests();
          if (hasInterests) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AppShell()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TopicSelectionScreen(
                  vendorId: vendorId,
                  isEditing: false,
                ),
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint("Auto-login session check error: $e");
    }

    // Default fallback to login screen
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _fadeSlideController.dispose();
    _floatPulseController.dispose();
    _progressController.dispose();
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Radial Gradient Base Background Layer
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF009B9B),
                  Color(0xFF006565),
                ],
              ),
            ),
          ),

          // Environmental Specular Accents
          Positioned(
            top: -100,
            right: -100,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Ambient Background Floating E-Commerce Vectors
          _buildFloatingVectors(),

          // Centered Splash UI Matrix Column
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Item 1: Storefront Icon with continuous breath loop
                  _buildAnimatedStagger(
                    delayIndex: 0,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _floatPulseController,
                          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Item 2: Dynamic Metallic Brand Header
                  _buildAnimatedStagger(
                    delayIndex: 1,
                    child: AnimatedBuilder(
                      animation: _sheenController,
                      builder: (context, child) {
                        return ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              transform: GradientRotation(
                                  _sheenController.value * 2 * math.pi),
                              colors: const [
                                Colors.white,
                                Colors.white,
                                Color(0xFF93F2F2),
                                Colors.white,
                                Colors.white,
                              ],
                              stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'LUXE',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 18.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Item 3: Elegance Detail Slogan
                  _buildAnimatedStagger(
                    delayIndex: 2,
                    child: Text(
                      'Elegance in Every Detail',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2.5,
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Item 4: Linear Loading Loop Bar Track
                  _buildAnimatedStagger(
                    delayIndex: 3,
                    child: Container(
                      width: 160,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            widthFactor: _progressController.value,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Bottom Aesthetic Layout Footnotes
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: _buildAnimatedStagger(
              delayIndex: 3,
              child: Opacity(
                opacity: 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'CURATED EXCELLENCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'POWERED BY SERENE COMMERCE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Orchestrator supporting custom stagger transitions
  Widget _buildAnimatedStagger(
      {required int delayIndex, required Widget child}) {
    final startInterval = delayIndex * 0.15;
    final endInterval = math.min(startInterval + 0.6, 1.0);

    final Animation<double> opacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeSlideController,
        curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
      ),
    );

    final Animation<Offset> offset = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeSlideController,
        curve: Interval(startInterval, endInterval, curve: Curves.easeOutQuad),
      ),
    );

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: offset,
        child: child,
      ),
    );
  }

  // Synthesizes the scattered ecommerce backdrop floats
  Widget _buildFloatingVectors() {
    return AnimatedBuilder(
      animation: _floatPulseController,
      builder: (context, child) {
        final floatVal = _floatPulseController.value * 2 * math.pi;

        return Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15 +
                  (math.sin(floatVal) * 10),
              left: MediaQuery.of(context).size.width * 0.10,
              child: Transform.rotate(
                angle: math.sin(floatVal) * 0.05,
                child: Icon(Icons.shopping_bag_outlined,
                    size: 48, color: Colors.white.withOpacity(0.1)),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.20 +
                  (math.sin(floatVal + 1.5) * 8),
              right: MediaQuery.of(context).size.width * 0.15,
              child: Transform.rotate(
                angle: math.sin(floatVal + 1.5) * 0.04,
                child: Icon(Icons.sell_outlined,
                    size: 32, color: Colors.white.withOpacity(0.1)),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.25 +
                  (math.sin(floatVal + 0.8) * 12),
              left: MediaQuery.of(context).size.width * 0.12,
              child: Transform.rotate(
                angle: math.sin(floatVal + 0.8) * 0.06,
                child: Icon(Icons.card_giftcard_outlined,
                    size: 40, color: Colors.white.withOpacity(0.1)),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.15 +
                  (math.sin(floatVal + 2.2) * 14),
              right: MediaQuery.of(context).size.width * 0.10,
              child: Transform.rotate(
                angle: math.sin(floatVal + 2.2) * 0.05,
                child: Icon(Icons.redeem_outlined,
                    size: 56, color: Colors.white.withOpacity(0.1)),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45 +
                  (math.sin(floatVal + 3.0) * 6),
              right: MediaQuery.of(context).size.width * 0.05,
              child: Icon(Icons.star_outline_rounded,
                  size: 24, color: Colors.white.withOpacity(0.05)),
            ),
            _buildSparkleParticle(top: 0.30, left: 0.40, delayShift: 0.0),
            _buildSparkleParticle(top: 0.60, right: 0.30, delayShift: 1.0),
            _buildSparkleParticle(bottom: 0.40, left: 0.20, delayShift: 2.0),
          ],
        );
      },
    );
  }

  Widget _buildSparkleParticle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double delayShift,
  }) {
    final scaleAnimationVal =
        math.sin((_floatPulseController.value * 2 * math.pi) + delayShift);
    final opacity = (scaleAnimationVal + 1.0) / 2.0 * 0.6;

    return Positioned(
      top: top != null ? MediaQuery.of(context).size.height * top : null,
      left: left != null ? MediaQuery.of(context).size.width * left : null,
      right: right != null ? MediaQuery.of(context).size.width * right : null,
      bottom: bottom != null ? MediaQuery.of(context).size.height * bottom : null,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
          ),
        ),
      ),
    );
  }
}