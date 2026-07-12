import 'dart:async';
import 'package:flutter/material.dart';

/// Security Verification (OTP) screen.
///
/// `onVerify` and `onResend` should call your API and THROW (e.g.
/// `throw Exception("message")`) on failure. On success:
///  - `onVerify` completing without throwing auto-pops this screen
///    with `Navigator.pop(context, true)`, so the caller can `await`
///    the result of `Navigator.push`.
///  - `onResend` completing without throwing just resets the timer.
class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final int otpLength;
  final int resendSeconds;
  final Future<void> Function(String otp)? onVerify;
  final Future<void> Function()? onResend;
  final VoidCallback? onClose;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.otpLength = 6,
    this.resendSeconds = 59,
    this.onVerify,
    this.onResend,
    this.onClose,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color primaryTeal = Color(0xff006565);
  static const Color accentTeal = Color(0xff008080);
  static const Color containerTeal = Color(0xffe3fffe);
  static const Color textDark = Color(0xff1a1c1c);
  static const Color textMuted = Color(0xff6b7280);
  static const Color borderLight = Color(0xffe5e7eb);

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _timer;
  late int _secondsLeft;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(widget.otpLength, (_) => FocusNode());
    _secondsLeft = widget.resendSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = widget.resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  /// Strips the "Exception: " prefix Dart adds by default so the
  /// snackbar shows a clean message instead of "Exception: Invalid OTP".
  String _cleanError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ') ? msg.substring(11) : msg;
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _handleVerify() async {
    if (_otp.length < widget.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter the ${widget.otpLength}-digit OTP"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isVerifying = true);
    try {
      if (widget.onVerify != null) {
        await widget.onVerify!(_otp);
      }
      // Success: hand control back to the caller (e.g. Navigator.push<bool>
      // returns true) instead of leaving the user stuck on this screen.
      if (mounted) {
        Navigator.of(context).pop(true);
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _handleResend() async {
    if (_secondsLeft > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      if (widget.onResend != null) {
        await widget.onResend!();
      }
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_cleanError(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Security Verification",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: textDark),
                  onPressed: widget.onClose ?? () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: borderLight),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Shield icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: containerTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: primaryTeal,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Enter Verification Code",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 10),

                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 13, color: textMuted),
                    children: [
                      const TextSpan(text: "A 6-digit OTP has been sent to\n"),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(widget.otpLength, (index) {
                    return SizedBox(
                      width: 44,
                      height: 52,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        enabled: !_isVerifying,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: primaryTeal, width: 1.5),
                          ),
                        ),
                        onChanged: (value) => _onDigitChanged(index, value),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: (_secondsLeft == 0 && !_isResending) ? _handleResend : null,
                  child: _isResending
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal),
                  )
                      : Text(
                    _secondsLeft > 0 ? "Resend code in ${_secondsLeft}s" : "Resend code",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _secondsLeft == 0 ? primaryTeal : primaryTeal.withOpacity(0.55),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),

          // Verify button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isVerifying ? null : _handleVerify,
                child: _isVerifying
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                )
                    : const Text(
                  "Verify & Continue",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}