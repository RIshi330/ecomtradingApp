import 'package:flutter/material.dart';
import 'dart:async';

class AuthProduction extends StatefulWidget {
  const AuthProduction({super.key});

  @override
  State<AuthProduction> createState() => _AuthProductionState();
}

class _AuthProductionState extends State<AuthProduction> {
  bool isSignUp = false;
  bool useOtpLogin = false;
  bool showOtp = false;
  bool loading = false;

  String role = "Normal";
  String? error;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  List<TextEditingController> otp = List.generate(6, (_) => TextEditingController());
  List<FocusNode> focus = List.generate(6, (_) => FocusNode());

  int resendTimer = 30;
  Timer? timer;

  final Color primary = const Color(0xFF7C83FD);

  /// 🔐 EMAIL VALIDATION
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 🚀 SUBMIT
  void handleSubmit() async {
    setState(() {
      error = null;
    });

    String email = emailController.text.trim();

    if (!isValidEmail(email)) {
      setState(() => error = "Invalid email address");
      return;
    }

    if (!isSignUp && !useOtpLogin) {
      /// PASSWORD LOGIN
      if (passwordController.text.isEmpty) {
        setState(() => error = "Password required");
        return;
      }

      await _fakeLoading();
      return;
    }

    /// OTP FLOW
    setState(() {
      showOtp = true;
      startTimer();
    });
  }

  /// 🔁 OTP VERIFY
  void verifyOtp() async {
    String code = otp.map((e) => e.text).join();

    if (code.length != 6) {
      setState(() => error = "Enter complete OTP");
      return;
    }

    await _fakeLoading();
  }

  /// ⏳ LOADING SIMULATION
  Future<void> _fakeLoading() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => loading = false);
  }

  /// ⏱ TIMER
  void startTimer() {
    resendTimer = 30;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendTimer == 0) {
        t.cancel();
      } else {
        setState(() => resendTimer--);
      }
    });
  }

  /// 📲 OTP PASTE
  void handlePaste(String value) {
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        otp[i].text = value[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FF),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.15),
                    blurRadius: 30,
                  )
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: showOtp ? _otpUI() : _formUI(),
              ),
            ),
          ),

          if (loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }

  /// 🔐 FORM UI
  Widget _formUI() {
    return Column(
      key: const ValueKey("form"),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(isSignUp ? "Create Account" : "Sign In",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),

        if (!isSignUp)
          Row(
            children: ["Normal", "Business"].map((r) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(r),
                  selected: role == r,
                  onSelected: (_) => setState(() => role = r),
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 20),

        TextField(
          controller: emailController,
          decoration: _input("Email"),
        ),

        if (!isSignUp && !useOtpLogin)
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: _input("Password"),
          ),

        if (!isSignUp)
          TextButton(
            onPressed: () => setState(() => useOtpLogin = !useOtpLogin),
            child: Text(useOtpLogin
                ? "Use Password Instead"
                : "Login with OTP"),
          ),

        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),

        const SizedBox(height: 20),

        ElevatedButton(
          style: _btn(),
          onPressed: loading ? null : handleSubmit,
          child: Text(isSignUp || useOtpLogin ? "Send OTP" : "Sign In"),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          icon: const Icon(Icons.g_mobiledata),
          label: const Text("Continue with Google"),
          onPressed: () {},
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() {
                isSignUp = !isSignUp;
                useOtpLogin = false;
              }),
              child: Text(isSignUp ? "Login" : "Create account"),
            ),
            if (!isSignUp)
              TextButton(
                onPressed: () {
                  /// NAVIGATE ADMIN
                },
                child: const Text("Admin Login"),
              )
          ],
        )
      ],
    );
  }

  /// 🔢 OTP UI
  Widget _otpUI() {
    return Column(
      key: const ValueKey("otp"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Verify OTP",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),
        const Text("Enter 6-digit code"),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 45,
              child: TextField(
                controller: otp[i],
                focusNode: focus[i],
                maxLength: 1,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(counterText: ""),
                onChanged: (v) {
                  if (v.length > 1) handlePaste(v);

                  if (v.isNotEmpty && i < 5) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            );
          }),
        ),

        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),

        const SizedBox(height: 20),

        ElevatedButton(
          style: _btn(),
          onPressed: verifyOtp,
          child: const Text("Verify"),
        ),

        TextButton(
          onPressed: resendTimer == 0 ? startTimer : null,
          child: Text(resendTimer == 0
              ? "Resend OTP"
              : "Resend in $resendTimer s"),
        ),

        TextButton(
          onPressed: () => setState(() => showOtp = false),
          child: const Text("Back"),
        )
      ],
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F4FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  ButtonStyle _btn() {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}