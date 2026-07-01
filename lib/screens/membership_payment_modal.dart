import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Database/Database.dart';

class MembershipPaymentModal extends StatefulWidget {
  final int planId;
  final String planTitle;
  final double totalRawPrice;
  final Color themeColor;

  const MembershipPaymentModal({
    super.key,
    required this.planId,
    required this.planTitle,
    required this.totalRawPrice,
    required this.themeColor,
  });

  @override
  State<MembershipPaymentModal> createState() => _MembershipPaymentModalState();
}

class _MembershipPaymentModalState extends State<MembershipPaymentModal> {
  bool _isLoadingBalances = true;
  bool _isPaying = false;

  // Wallet states
  bool useEcash = false;
  bool useEwallet = false;
  double ecashBalance = 0.0;
  double ewalletBalance = 0.0;

  final TextEditingController ecashController = TextEditingController();
  final TextEditingController ewalletController = TextEditingController();
  final TextEditingController couponController = TextEditingController();

  // Price breakdown states from API
  double basePrice = 0.0;
  double couponDiscount = 0.0;
  double appliedEcash = 0.0;
  double appliedEwallet = 0.0;
  double remainingAmount = 0.0;

  bool couponValid = false;
  String couponMessage = '';
  dynamic _razorpay;

  @override
  void initState() {
    super.initState();
    basePrice = widget.totalRawPrice;
    remainingAmount = widget.totalRawPrice;
    _fetchBalances();
    _initRazorpay();
  }

  @override
  void dispose() {
    ecashController.dispose();
    ewalletController.dispose();
    couponController.dispose();
    _razorpay?.clear();
    super.dispose();
  }

  void _initRazorpay() {
    try {
      _razorpay = _RazorpayWrapper();
      _razorpay.onSuccess = _handlePaymentSuccess;
      _razorpay.onError = _handlePaymentError;
      _razorpay.onWallet = _handleExternalWallet;
    } catch (e) {
      debugPrint("Razorpay wrapper initialization skipped: $e");
    }
  }

  Future<void> _fetchBalances() async {
    setState(() {
      _isLoadingBalances = true;
    });

    try {
      final db = Database();
      final res = await db.getJsonData({
        'action': 'get_balances',
      }, endpoint: 'new_apis/payment_modal_API.php');

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        setState(() {
          ecashBalance = double.tryParse(data['ecash_balance']?.toString() ?? '0') ?? 0.0;
          ewalletBalance = double.tryParse(data['ewallet_balance']?.toString() ?? '0') ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching balances: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBalances = false;
        });
      }
    }
  }

  Future<void> _recalculateBreakdown() async {
    final double rawEcash = double.tryParse(ecashController.text) ?? 0.0;
    final double rawEwallet = double.tryParse(ewalletController.text) ?? 0.0;

    final double ecashUsed = useEcash ? rawEcash : 0.0;
    final double ewalletUsed = useEwallet ? rawEwallet : 0.0;

    try {
      final db = Database();
      final res = await db.getJsonData({
        'action': 'calculate_remaining',
        'total_price': widget.totalRawPrice,
        'ecash_used': ecashUsed,
        'ewallet_used': ewalletUsed,
        'coupon_code': couponController.text.trim(),
        'marketplace': 'MEMBERSHIP',
      }, endpoint: 'new_apis/payment_modal_API.php');

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        setState(() {
          couponDiscount = double.tryParse(data['coupon_discount']?.toString() ?? '0') ?? 0.0;
          couponValid = data['coupon_valid'] == true;
          couponMessage = data['coupon_message']?.toString() ?? '';
          remainingAmount = double.tryParse(data['remaining_amount']?.toString() ?? '0') ?? 0.0;
          appliedEcash = double.tryParse(data['ecash_used']?.toString() ?? '0') ?? 0.0;
          appliedEwallet = double.tryParse(data['ewallet_used']?.toString() ?? '0') ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint("Error recalculating breakdown: $e");
    }
  }

  void _onWalletInputChanged() {
    _recalculateBreakdown();
  }

  Future<void> _processCheckout() async {
    setState(() {
      _isPaying = true;
    });

    try {
      final db = Database();
      final double ecashUsed = useEcash ? (double.tryParse(ecashController.text) ?? 0.0) : 0.0;
      final double ewalletUsed = useEwallet ? (double.tryParse(ewalletController.text) ?? 0.0) : 0.0;

      // 1. If coupon code is valid, register it on backend session
      if (couponController.text.trim().isNotEmpty && couponValid) {
        await db.getJsonData({
          'action': 'check_coupon',
          'code': couponController.text.trim(),
          'price': widget.totalRawPrice,
        }, endpoint: 'new_apis/membership_plans_API.php');
      }

      // 2. Setup buy membership session
      final setupRes = await db.getJsonData({
        'action': 'buy_package',
        'item': widget.planId,
        'type': 'm',
      }, endpoint: 'new_apis/membership_plans_API.php');

      if (setupRes['success'] != true) {
        throw Exception(setupRes['message'] ?? "Failed to initialize purchase session.");
      }

      // 3. Initiate the buy transaction
      final buyRes = await db.getJsonData({
        'buyMembership': 1,
        'payFromEwallet': ewalletUsed,
        'payFromEbanking': ecashUsed,
      }, endpoint: 'new_apis/membership_n_package_buyer_API.php');

      if (buyRes.containsKey('wallet') && buyRes['wallet'] == true) {
        // Fully paid with ewallet / ebanking!
        if (mounted) {
          Navigator.pop(context, true); // Close bottom sheet
          _showSuccessDialog("Purchase successful! Your membership is active.");
        }
        return;
      }

      if (buyRes.containsKey('error')) {
        throw Exception(buyRes['error']);
      }

      // 4. Requires Razorpay payment
      final String? orderId = buyRes['id']?.toString();
      final String razorpayKey = buyRes['key']?.toString() ?? '';

      if (orderId != null && orderId.isNotEmpty) {
        _openCheckout(orderId: orderId, amount: remainingAmount, razorpayKey: razorpayKey);
      } else {
        throw Exception("Razorpay order generation failed.");
      }

    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll("Exception: ", ""));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  void _openCheckout({required String orderId, required double amount, required String razorpayKey}) {
    if (_razorpay != null && !kIsWeb) {
      try {
        var options = {
          'key': razorpayKey.isNotEmpty ? razorpayKey : 'rzp_test_mock',
          'amount': (amount * 100).toInt(),
          'name': 'Membership Plan',
          'description': widget.planTitle,
          'order_id': orderId,
          'prefill': {
            'contact': '',
            'email': 'customer@idealvillage.in',
          },
          'theme': {
            'color': '#${widget.themeColor.value.toRadixString(16).substring(2)}',
          }
        };
        _razorpay.open(options);
      } catch (e) {
        _showSimulateDialog(orderId);
      }
    } else {
      _showSimulateDialog(orderId);
    }
  }

  void _handlePaymentSuccess(dynamic response) async {
    _showLoadingDialog();
    try {
      final db = Database();
      final res = await db.getJsonData({
        'verifyPackagePayment': 1,
        'razorpay_payment_id': response.paymentId ?? '',
        'razorpay_order_id': response.orderId ?? '',
        'razorpay_signature': response.signature ?? '',
      }, endpoint: 'new_apis/membership_n_package_buyer_API.php');

      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      if (res.toString() == '1' || res['success'] == true) {
        Navigator.pop(context, true); // Close bottom sheet
        _showSuccessDialog("Payment verified! Membership activated.");
      } else {
        _showErrorDialog("Payment verification failed.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog("Verification error: $e");
      }
    }
  }

  void _handlePaymentError(dynamic response) {
    _showErrorDialog("Razorpay Payment Cancelled / Failed.");
  }

  void _handleExternalWallet(dynamic response) {
    debugPrint("External wallet payment: $response");
  }

  void _showSimulateDialog(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Simulate Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Simulated Razorpay Checkout environment:"),
            const SizedBox(height: 8),
            Text("Order ID: $orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Amount: ₹${remainingAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 12),
            const Text("Simulate successful payment verification on backend?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _verifySimulated(orderId);
            },
            child: const Text("Verify Success"),
          ),
        ],
      ),
    );
  }

  Future<void> _verifySimulated(String orderId) async {
    _showLoadingDialog();
    try {
      final db = Database();
      final mockResponse = {
        'paymentId': "pay_mock_${DateTime.now().millisecondsSinceEpoch}",
        'orderId': orderId,
        'signature': "mock_signature_verification_success_ccbul",
      };

      final res = await db.getJsonData({
        'verifyPackagePayment': 1,
        'razorpay_payment_id': mockResponse['paymentId'],
        'razorpay_order_id': mockResponse['orderId'],
        'razorpay_signature': mockResponse['signature'],
      }, endpoint: 'new_apis/membership_n_package_buyer_API.php');

      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      // API outputs 1 directly or json success
      if (res.toString() == '1' || res['success'] == true || res['data']?.toString() == '1') {
        Navigator.pop(context, true); // Close bottom sheet
        _showSuccessDialog("Payment verified! Membership activated.");
      } else {
        _showErrorDialog("Payment verification failed. Check server logs.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog("Verification error: $e");
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
        title: const Text("Success"),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: const Text("Error"),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header line
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title block
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Checkout",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.planTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${widget.totalRawPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              if (_isLoadingBalances)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                // Coupon Code section
                const Text(
                  "Have a Coupon?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: couponController,
                        decoration: InputDecoration(
                          hintText: "Enter Coupon Code",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _recalculateBreakdown();
                      },
                      child: const Text("Apply"),
                    ),
                  ],
                ),
                if (couponMessage.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        couponValid ? Icons.check_circle : Icons.error,
                        color: couponValid ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          couponMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: couponValid ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                // E-wallet Section
                Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance_wallet, color: Colors.blue),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "E-Wallet Balance",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "Available: ₹${ewalletBalance.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: useEwallet,
                              activeColor: widget.themeColor,
                              onChanged: (val) {
                                setState(() {
                                  useEwallet = val;
                                  if (val) {
                                    ewalletController.text = ewalletBalance.toString();
                                  } else {
                                    ewalletController.text = '';
                                  }
                                });
                                _recalculateBreakdown();
                              },
                            ),
                          ],
                        ),
                        if (useEwallet) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: ewalletController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Amount to use",
                              isDense: true,
                              prefixText: "₹ ",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (_) => _onWalletInputChanged(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // E-cash Section
                Card(
                  elevation: 0,
                  color: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.orange),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "E-Cash Balance (E-Banking)",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "Available: ₹${ecashBalance.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: useEcash,
                              activeColor: widget.themeColor,
                              onChanged: (val) {
                                setState(() {
                                  useEcash = val;
                                  if (val) {
                                    ecashController.text = ecashBalance.toString();
                                  } else {
                                    ecashController.text = '';
                                  }
                                });
                                _recalculateBreakdown();
                              },
                            ),
                          ],
                        ),
                        if (useEcash) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: ecashController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Amount to use",
                              isDense: true,
                              prefixText: "₹ ",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (_) => _onWalletInputChanged(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Order Summary Card
                const Text(
                  "Order Summary",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Base Price", style: TextStyle(color: Colors.grey)),
                          Text("₹${widget.totalRawPrice.toStringAsFixed(2)}"),
                        ],
                      ),
                      if (couponDiscount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Coupon Discount", style: TextStyle(color: Colors.green)),
                            Text("-₹${couponDiscount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      ],
                      if (appliedEwallet > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("E-Wallet Used", style: TextStyle(color: Colors.blue)),
                            Text("-₹${appliedEwallet.toStringAsFixed(2)}", style: const TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ],
                      if (appliedEcash > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("E-Cash Used", style: TextStyle(color: Colors.orange)),
                            Text("-₹${appliedEcash.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orange)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Payable Amount",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            "₹${remainingAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: widget.themeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isPaying ? null : _processCheckout,
                    child: _isPaying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            remainingAmount > 0
                                ? "Proceed to Pay ₹${remainingAmount.toStringAsFixed(2)}"
                                : "Activate Membership Now",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  RAZORPAY WRAPPER (isolates platform-specific import)
// =============================================================================
class _RazorpayWrapper {
  dynamic _instance;

  Function(dynamic)? onSuccess;
  Function(dynamic)? onError;
  Function(dynamic)? onWallet;

  _RazorpayWrapper() {
    try {
      _instance = _createInstance();
    } catch (e) {
      _instance = null;
    }
  }

  dynamic _createInstance() {
    if (kIsWeb) return null;
    try {
      final r = Razorpay();
      r.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
        onSuccess?.call(response);
      });
      r.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
        onError?.call(response);
      });
      r.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
        onWallet?.call(response);
      });
      return r;
    } catch (e) {
      debugPrint("Error creating Razorpay instance: $e");
      return null;
    }
  }

  void open(Map<String, dynamic> options) {
    if (_instance != null) {
      _instance.open(options);
    } else {
      throw UnsupportedError("Razorpay not available on this platform");
    }
  }

  void clear() {
    try {
      _instance?.clear();
    } catch (_) {}
  }
}
