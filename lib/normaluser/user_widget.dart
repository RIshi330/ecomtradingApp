import 'dart:async';
import 'package:flutter/material.dart';

import '../app_constants.dart';

/// Shared helpers and widgets used across the BTC, BTB, and Branding
/// home screens. Keeping these in one place avoids duplicating the same
/// logic in every screen file.

// ---------------------------------------------------------------------
// Image URL Formatting Helper
// ---------------------------------------------------------------------
String getImageUrl(String? path) {
  const String defaultPlaceholder =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDSwMmsBMHeMd2kDxIgwmWexkAMVVed9KeDK6XifaTWlwqHKGzS-qHP5GrMbO0JdR6oSNLa5w8dexQSUr1MMQUNI6IAP8-cDUVfPDjN_kagUPqlZEdwTTlX4nKe2pcQvP2KifQNU77d8T1mKdHrDiBdGkfOIGZsZeDRNN_GckpotDZYnS_jOKm76Ujul8TPBDT936jjmbQ7mxn59aYuRs-pEWttBAQCDRpjXOvbFPDL8UinBTx0pmEMGm8TLCxwsy6Mxi6qQCcaUzM';
  if (path == null || path.isEmpty) {
    return defaultPlaceholder;
  }
  if (!path.startsWith('http')) {
    String base = baseUrl;
    if (base.contains('/Android/')) {
      base = base.replaceAll('/Android/', '/');
    }
    if (base.endsWith('/') && path.startsWith('/')) {
      return base + path.substring(1);
    } else if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    } else {
      return base + path;
    }
  }
  return path;
}

// ---------------------------------------------------------------------
// Price Formatting Helper
// ---------------------------------------------------------------------
String formatPrice(dynamic priceVal) {
  if (priceVal == null || priceVal.toString().isEmpty) {
    return '${priceVal ?? ''}0.00';
    // return '${rs}0.00';
  }
  final priceStr = priceVal.toString();
  if (priceStr.startsWith('₹') || priceStr.startsWith('\$') || priceStr.startsWith('£')) {
    return priceStr;
  }
  final parsed = double.tryParse(priceStr);
  if (parsed != null) {
    return '${parsed.toStringAsFixed(2)}';
  }
  return '$priceVal$priceStr';
  // return '$rs$priceStr';
}

// ---------------------------------------------------------------------
// Reusable Countdown Timer Widget
// ---------------------------------------------------------------------
class CountdownTimerWidget extends StatefulWidget {
  final Duration initialDuration;
  final bool darkStyle;
  const CountdownTimerWidget({
    super.key,
    required this.initialDuration,
    this.darkStyle = false,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration _currentDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_currentDuration.inSeconds <= 0) {
        _timer?.cancel();
      } else {
        setState(() {
          _currentDuration = _currentDuration - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _currentDuration.inHours.toString().padLeft(2, '0');
    final minutes = (_currentDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_currentDuration.inSeconds % 60).toString().padLeft(2, '0');

    if (widget.darkStyle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeBox(hours),
          const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          _buildTimeBox(minutes),
          const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          _buildTimeBox(seconds),
        ],
      );
    }

    return Text(
      "$hours:$minutes:$seconds",
      style: const TextStyle(
        fontFamily: 'Courier',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}