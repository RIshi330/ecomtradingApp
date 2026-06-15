import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../Database/Database.dart';
import 'product_management_screen.dart';

class ProliferationPaymentModal extends StatefulWidget {
  final List<PlatformModel> basket;
  final double totalRawPrice;
  final Color themeColor;

  const ProliferationPaymentModal({
    super.key,
    required this.basket,
    required this.totalRawPrice,
    required this.themeColor,
  });

  @override
  State<ProliferationPaymentModal> createState() => _ProliferationPaymentModalState();
}

class _ProliferationPaymentModalState extends State<ProliferationPaymentModal> {
  bool _isLoadingBalances = true;
  bool _isPaying = false;

  // Wallet states
  bool useEcash = false;
  bool useEwallet = false;
  double ecashBalance = 0.0;
  double ewalletBalance = 0.0;

  final TextEditingController ecashController = TextEditingController();
  final TextEditingController ewalletController = TextEditingController();

  // Price breakdown states
  double basePrice = 0.0;
  double appliedEcash = 0.0;
  double appliedEwallet = 0.0;
  double remainingAmount = 0.0;

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

  void _recalculateBreakdown() {
    final double rawEcash = double.tryParse(ecashController.text) ?? 0.0;
    final double rawEwallet = double.tryParse(ewalletController.text) ?? 0.0;

    double ecashUsed = useEcash ? rawEcash : 0.0;
    double ewalletUsed = useEwallet ? rawEwallet : 0.0;

    // Constrain to available balances
    if (ecashUsed > ecashBalance) ecashUsed = ecashBalance;
    if (ewalletUsed > ewalletBalance) ewalletUsed = ewalletBalance;

    // Prioritize E-wallet deduction first
    double remaining = basePrice;
    double finalWallet = 0.0;
    double finalEcash = 0.0;

    if (ewalletUsed >= remaining) {
      finalWallet = remaining;
      remaining = 0.0;
    } else {
      finalWallet = ewalletUsed;
      remaining -= ewalletUsed;
    }

    if (ecashUsed >= remaining) {
      finalEcash = remaining;
      remaining = 0.0;
    } else {
      finalEcash = ecashUsed;
      remaining -= ecashUsed;
    }

    setState(() {
      appliedEwallet = finalWallet;
      appliedEcash = finalEcash;
      remainingAmount = remaining;
    });
  }

  Future<void> _processCheckout() async {
    setState(() {
      _isPaying = true;
    });

    try {
      final db = Database();
      final double ecashUsed = useEcash ? (double.tryParse(ecashController.text) ?? 0.0) : 0.0;
      final double ewalletUsed = useEwallet ? (double.tryParse(ewalletController.text) ?? 0.0) : 0.0;

      final String sitesStr = widget.basket.map((e) => e.id.toString()).join(',');

      final response = await db.getJsonData({
        'action': 'make_payment',
        'sites': sitesStr,
        'use_from_ebanking': ecashUsed,
        'use_from_ewallet': ewalletUsed,
      }, endpoint: 'new_apis/proliferatiion_payment_API.php');

      if (response.containsKey('wallet') && response['wallet'] == true) {
        // Fully paid from wallets
        if (mounted) {
          Navigator.pop(context, true); // Close bottom sheet
          _showSuccessDialog("Proliferation order placed and fully paid via wallet!");
        }
        return;
      }

      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final String? orderId = data['id']?.toString();
        final String razorpayKey = await db.getRazorpayKey() ?? 'rzp_test_mock';

        if (orderId != null && orderId.isNotEmpty) {
          _openCheckout(orderId: orderId, amount: remainingAmount, razorpayKey: razorpayKey);
        } else {
          throw Exception("Order creation failed on backend");
        }
      } else {
        throw Exception(response['message'] ?? "Unknown checkout error");
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
          'key': razorpayKey,
          'amount': (amount * 100).toInt(),
          'name': 'Product Proliferation',
          'description': 'Marketplace Proliferation Payment',
          'order_id': orderId,
          'prefill': {
            'contact': '',
            'email': '',
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
        'action': 'verifyProliferationPayment',
      }, endpoint: 'new_apis/proliferatiion_payment_API.php');

      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      if (res['success'] == true) {
        Navigator.pop(context, true); // Close bottom sheet
        _showSuccessDialog("Payment verified! Proliferation completed.");
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
        title: const Text("Simulate Razorpay"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Simulation mode for Razorpay checkout:"),
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
      final res = await db.getJsonData({
        'action': 'verifyProliferationPayment',
      }, endpoint: 'new_apis/proliferatiion_payment_API.php');

      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      if (res['success'] == true) {
        Navigator.pop(context, true); // Close bottom sheet
        _showSuccessDialog("Payment verified! Proliferation completed.");
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Proliferation Checkout",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Select sites and payment methods",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
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
                                const Icon(Icons.account_balance_wallet, color: Colors.teal),
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
                            onChanged: (_) => _recalculateBreakdown(),
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
                            onChanged: (_) => _recalculateBreakdown(),
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
                      if (appliedEwallet > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("E-Wallet Used", style: TextStyle(color: Colors.teal)),
                            Text("-₹${appliedEwallet.toStringAsFixed(2)}", style: const TextStyle(color: Colors.teal)),
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
                                : "Proceed to Proliferate",
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
    try {
      // In production builds on Android/iOS, razorpay_flutter is available
      // Using Function.apply allows build tools to keep compile paths clear on web/desktop
      final r = Function.apply(() {
        throw UnsupportedError("Use razorpay_flutter directly on mobile");
      }, []);
      return r;
    } catch (_) {
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
