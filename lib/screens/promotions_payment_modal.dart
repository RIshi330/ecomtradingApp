import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Database/Database.dart';

class PromotionsPaymentModal extends StatefulWidget {
  final int packageId;
  final String packageTitle;
  final double totalRawPrice;
  final Color themeColor;

  const PromotionsPaymentModal({
    super.key,
    required this.packageId,
    required this.packageTitle,
    required this.totalRawPrice,
    this.themeColor = const Color(0xff006565),
  });

  @override
  State<PromotionsPaymentModal> createState() => _PromotionsPaymentModalState();
}

class _PromotionsPaymentModalState extends State<PromotionsPaymentModal> {
  bool _isLoadingBalances = true;
  bool _isPaying = false;

  // Wallet states
  bool useEcash = false;
  bool useEwallet = false;
  double ecashBalance = 0.0;
  double ewalletBalance = 0.0;

  final TextEditingController ecashController = TextEditingController();
  final TextEditingController ewalletController = TextEditingController();

  double remainingAmount = 0.0;
  dynamic _razorpay;

  @override
  void initState() {
    super.initState();
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
      
      // Fetch E-Banking (E-Cash) Balance
      final ecashRes = await db.getData({
        'get_available_ebanking_balance': '1',
      }, endpoint: 'new_apis/buy_promotion_package_api.php');

      // Fetch E-Wallet Balance
      final ewalletRes = await db.getData({
        'get_available_ewallet_balance': '1',
      }, endpoint: 'new_apis/buy_promotion_package_api.php');

      setState(() {
        ecashBalance = double.tryParse(ecashRes['available_balance']?.toString() ?? '0') ?? 0.0;
        ewalletBalance = double.tryParse(ewalletRes['available_balance']?.toString() ?? '0') ?? 0.0;
      });
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

  void _recalculateRemaining() {
    final double ecashUsed = useEcash ? (double.tryParse(ecashController.text) ?? 0.0) : 0.0;
    final double ewalletUsed = useEwallet ? (double.tryParse(ewalletController.text) ?? 0.0) : 0.0;

    setState(() {
      remainingAmount = widget.totalRawPrice - (ecashUsed + ewalletUsed);
      if (remainingAmount < 0) remainingAmount = 0;
    });
  }

  Future<void> _processPayment() async {
    if (_isPaying) return;

    final double ecashUsed = useEcash ? (double.tryParse(ecashController.text) ?? 0.0) : 0.0;
    final double ewalletUsed = useEwallet ? (double.tryParse(ewalletController.text) ?? 0.0) : 0.0;

    if (ecashUsed > ecashBalance) {
      _showErrorDialog("E-Banking balance insufficient.");
      return;
    }

    if (ewalletUsed > ewalletBalance) {
      _showErrorDialog("E-Wallet balance insufficient.");
      return;
    }

    if ((ecashUsed + ewalletUsed) > widget.totalRawPrice) {
      _showErrorDialog("Sum of balances cannot exceed package price.");
      return;
    }

    setState(() {
      _isPaying = true;
    });

    try {
      final db = Database();
      
      final buyRes = await db.getData({
        'make_payment': '1',
        'package_id': widget.packageId.toString(),
        'payFromEwallet': ewalletUsed.toString(),
        'payFromEbanking': ecashUsed.toString(),
      }, endpoint: 'new_apis/buy_promotion_package_api.php');

      if (buyRes['status'] == 'success') {
        final flow = buyRes['flow'];
        final orderId = buyRes['order_id'] ?? buyRes['order']?['id'] ?? 0;

        if (flow == 'wallet') {
          if (mounted) {
            Navigator.pop(context, orderId.toString()); // Close bottom sheet and return orderId
            _showSuccessSnackbar("Payment successful via Wallet balance!");
          }
          return;
        }

        if (flow == 'razorpay') {
          final String razorpayKey = buyRes['key']?.toString() ?? '';
          _openCheckout(orderId: orderId.toString(), amount: remainingAmount, razorpayKey: razorpayKey);
        } else {
          throw Exception("Unknown payment flow: $flow");
        }
      } else {
        throw Exception(buyRes['message'] ?? "Payment initialization failed.");
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
          'name': 'Marketplace Promotion',
          'description': widget.packageTitle,
          'order_id': 'promo_$orderId',
          'prefill': {
            'contact': '',
            'email': 'seller@idealvillage.in',
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
      final res = await db.getData({
        'verifyPayment': '1',
      }, endpoint: 'new_apis/buy_promotion_package_api.php');

      if (!mounted) return;
      Navigator.pop(context); // Pop loading spinner

      if (res['status'] == 'success') {
        final orderId = res['order_id']?.toString() ?? '';
        Navigator.pop(context, orderId); // Close bottom sheet and return orderId
        _showSuccessSnackbar("Payment verified and completed successfully!");
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

  void _handleExternalWallet(dynamic response) {}

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
            Text("Order ID: promo_$orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
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
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              _showLoadingDialog();
              try {
                final db = Database();
                final res = await db.getData({
                  'verifyPayment': '1',
                }, endpoint: 'new_apis/buy_promotion_package_api.php');

                if (!mounted) return;
                Navigator.pop(context); // Pop loading spinner

                if (res['status'] == 'success') {
                  Navigator.pop(context, orderId); // Close bottom sheet and return orderId
                  _showSuccessSnackbar("Payment verified and completed successfully!");
                } else {
                  _showErrorDialog("Payment verification failed.");
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showErrorDialog("Verification error: $e");
                }
              }
            },
            child: const Text("Pay & Verify"),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: widget.themeColor),
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

  void _showSuccessSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
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
              // Pull down bar
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
                          "Checkout Package",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.packageTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 32),

              if (_isLoadingBalances)
                const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                // Wallet 1: E-Banking (E-Cash)
                CheckboxListTile(
                  activeColor: widget.themeColor,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Pay using E-Banking", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text("Bal: ₹${ecashBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  value: useEcash,
                  onChanged: (val) {
                    setState(() {
                      useEcash = val ?? false;
                      if (!useEcash) ecashController.clear();
                      _recalculateRemaining();
                    });
                  },
                ),
                if (useEcash)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: ecashController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateRemaining(),
                      decoration: InputDecoration(
                        hintText: "Enter amount to deduct from E-Banking",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                // Wallet 2: E-Wallet
                CheckboxListTile(
                  activeColor: widget.themeColor,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Pay using E-Wallet", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text("Bal: ₹${ewalletBalance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  value: useEwallet,
                  onChanged: (val) {
                    setState(() {
                      useEwallet = val ?? false;
                      if (!useEwallet) ewalletController.clear();
                      _recalculateRemaining();
                    });
                  },
                ),
                if (useEwallet)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: ewalletController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateRemaining(),
                      decoration: InputDecoration(
                        hintText: "Enter amount to deduct from E-Wallet",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                const Divider(height: 32),

                // Summary Calculation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Package Price", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text("₹${widget.totalRawPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Wallet Deduction", style: TextStyle(fontSize: 14, color: Colors.black54)),
                    Text(
                      "- ₹${(widget.totalRawPrice - remainingAmount).toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Remaining Net Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      "₹${remainingAmount.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18, color: widget.themeColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52), // Overrides global theme infinite width safely
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isPaying ? null : _processPayment,
                    child: _isPaying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            remainingAmount == 0 ? "Complete Purchase" : "Pay with Razorpay",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
