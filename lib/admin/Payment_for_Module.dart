import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Database/Database.dart';
import '../model/module_model.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_User_and_Business_Session.dart';

class PaymentScreenadminforModule extends StatefulWidget {
  final ModuleModel module;

  const PaymentScreenadminforModule({
    super.key,
    required this.module,
  });

  @override
  State<PaymentScreenadminforModule> createState() => _PaymentScreenadminforModuleState();
}

class _PaymentScreenadminforModuleState extends State<PaymentScreenadminforModule> {
  late ModuleModel module;
  late double subtotal;

  bool useEcash = false;
  bool useEwallet = false;
  bool _isPaying = false;
  bool _isLoadingBalances = false;
  dynamic _razorpay;

  bool _purchaseFinalized = false;

  late TextEditingController ecashController;
  late TextEditingController ewalletController;
  final TextEditingController couponController = TextEditingController();

  double ecashBalance = 0.0;
  double ewalletBalance = 0.0;

  double walletApplied = 0.0;
  double couponDiscount = 0.0;
  double remainingAmount = 0.0;

  double _parsePrice(String priceStr) {
    final clean = priceStr.split('/')[0].replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    module = widget.module;
    subtotal = _parsePrice(module.discountPrice);
    remainingAmount = subtotal;

    ecashController = TextEditingController(text: subtotal.toStringAsFixed(0));
    ewalletController = TextEditingController(text: subtotal.toStringAsFixed(0));

    _fetchBalances();
    _initRazorpay();
  }

  void _initRazorpay() {
    try {
      _razorpay = _RazorpayWrapper();
      _razorpay.onSuccess = _handleRazorpaySuccess;
      _razorpay.onError = _handleRazorpayError;
      _razorpay.onWallet = _handleExternalWallet;
    } catch (e) {
      debugPrint("Razorpay wrapper initialization error: $e");
    }
  }

  @override
  void dispose() {
    ecashController.dispose();
    ewalletController.dispose();
    couponController.dispose();
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> _fetchBalances() async {
    setState(() => _isLoadingBalances = true);

    try {
      final db = Database();
      final res = await db.getJsonData(
        {"action": "get_balances",        'vendor_id': UserSessionSet.instance.vendorId,
        },
        endpoint: "new_apis/payment_modal_API.php",
      );

      if (!mounted) return;

      if (res['success'] == true || res['status'] == 200 || res.containsKey('data')) {
        final data = res['data'];
        if (data != null) {
          setState(() {
            ecashBalance = double.tryParse(data['ecash_balance']?.toString() ?? '0') ?? 0.0;
            ewalletBalance = double.tryParse(data['ewallet_balance']?.toString() ?? '0') ?? 0.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching balances: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingBalances = false);
      }
    }
  }

  Future<void> _recalculateRemaining() async {
    double ecashUsed = 0.0;
    double ewalletUsed = 0.0;

    if (useEcash) {
      ecashUsed = double.tryParse(ecashController.text) ?? 0.0;
      if (ecashUsed > ecashBalance) {
        ecashUsed = ecashBalance;
        ecashController.text = ecashUsed.toStringAsFixed(0);
      }
    }

    if (useEwallet) {
      ewalletUsed = double.tryParse(ewalletController.text) ?? 0.0;
      if (ewalletUsed > ewalletBalance) {
        ewalletUsed = ewalletBalance;
        ewalletController.text = ewalletUsed.toStringAsFixed(0);
      }
    }

    try {
      final db = Database();
      final body = {
        "action": "calculate_remaining",
        "total_price": subtotal,
        "ecash_used": ecashUsed,
        "ewallet_used": ewalletUsed,
        "coupon_code": couponController.text.trim(),
        "marketplace": "MODULE",

            'vendor_id': UserSessionSet.instance.vendorId,

    };

      final res = await db.getJsonData(
        body,
        endpoint: "new_apis/payment_modal_API.php",
      );

      if (!mounted) return;

      if (res['success'] == true || res['status'] == 200 || res.containsKey('data')) {
        final data = res['data'];
        if (data != null) {
          final double newCouponDiscount = double.tryParse(data['coupon_discount']?.toString() ?? '0') ?? 0.0;
          final double resEcash = double.tryParse(data['ecash_used']?.toString() ?? '0') ?? 0.0;
          final double resEwallet = double.tryParse(data['ewallet_used']?.toString() ?? '0') ?? 0.0;
          final double newWalletApplied = resEcash + resEwallet;
          final double newRemainingAmount = double.tryParse(data['remaining_amount']?.toString() ?? '0') ?? 0.0;

          final bool couponValid = data['coupon_valid'] == true || data['coupon_valid']?.toString() == 'true';
          final String couponMessage = data['coupon_message']?.toString() ?? '';

          setState(() {
            couponDiscount = newCouponDiscount;
            walletApplied = newWalletApplied;
            remainingAmount = newRemainingAmount;
          });

          if (couponController.text.trim().isNotEmpty && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(!couponValid
                    ? (couponMessage.isNotEmpty ? couponMessage : "Invalid coupon code.")
                    : (couponMessage.isNotEmpty ? couponMessage : "Coupon applied successfully")),
                backgroundColor: !couponValid ? Colors.red : Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error recalculating remaining: $e");
      if (mounted) {
        setState(() {
          walletApplied = ecashUsed + ewalletUsed;
          if (walletApplied > subtotal) {
            walletApplied = subtotal;
          }
          remainingAmount = subtotal - walletApplied;
        });
      }
    }
  }

  Future<void> _handlePayment() async {
    if (_purchaseFinalized || _isPaying) return;

    setState(() => _isPaying = true);

    try {
      final db = Database();

      final double ecashUsed = useEcash ? (double.tryParse(ecashController.text) ?? 0) : 0;
      final double ewalletUsed = useEwallet ? (double.tryParse(ewalletController.text) ?? 0) : 0;

      final res = await db.getData(
        {
          "purchaseCurrentModule": true,
          "module_id": module.id, // 👈 PASS MODULE ID HERE
          "ebanking": ecashUsed.toStringAsFixed(2),
          "ewallet": ewalletUsed.toStringAsFixed(2),
        },
        endpoint: "new_apis/buy_module_api.php",
      );
      print(module.id);
      if (res["wallet"] == true) {
        _purchaseFinalized = true;
        _showSuccessDialog("Module purchased successfully via Wallet.");
        return;
      }

      if (res["error"] != null) {
        _showErrorDialog(res["error"]);
        return;
      }

      final options = {
        "key": "rzp_test_pi2fEEfhC66GKs",
        "order_id": res["id"],
        "amount": res["amount"],
        "currency": res["currency"] ?? "INR",
        "name": "CCBUL",
        "description": module.title,
        "prefill": {
          "contact": "",
          "email": "",
        }
      };

      _razorpay.open(options);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }
  void _handleRazorpaySuccess(dynamic response) async {
    if (_purchaseFinalized) return;

    setState(() => _isPaying = true);

    try {
      final db = Database();


      // Send verification parameters to backend
      final res = await db.getData(
        {
          "verifyModulePurchase": true,
          "razorpay_payment_id": response.paymentId,
          "razorpay_order_id": response.orderId,
          "razorpay_signature": response.signature,
        },
        endpoint: "new_apis/buy_module_api.php",
      );

      if (res["success"] == true || res == 1) {
        _purchaseFinalized = true;
        _showSuccessDialog("Payment verified and module purchased successfully!");
      } else {
        _showErrorDialog(res["error"] ?? "Failed to verify transaction with backend.");
      }
    } catch (e) {
      _showErrorDialog("Error verifying payment: $e");
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  void _handleRazorpayError(dynamic response) {
    _showErrorDialog("Payment Cancelled / Failed: ${response.message ?? ''}");
  }

  void _handleExternalWallet(dynamic response) {
    debugPrint("External wallet payment: $response");
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text("Payment Success"),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/module_manager',
                    (route) => route.isFirst,
              );
            },
            child: const Text("Go to Module Manager", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Payment Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Complete Payment",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
            elevation: 0,
          ),
          onPressed: _isPaying ? null : _handlePayment,
          icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
          label: Text(
            _isPaying ? "Processing..." : "Pay ₹${remainingAmount.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: _isLoadingBalances
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        module.icon ?? Icons.school,
                        size: 30,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Standard License",
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.discountPrice,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "COUPON CODE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: "Enter coupon code",
                      hintStyle: TextStyle(fontSize: 12),
                      prefixIcon: Icon(Icons.sell, size: 16),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 42),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: _recalculateRemaining,
                  child: const Text("Apply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            WalletCard(
              title: "Ecash Balance",
              balance: "₹${ecashBalance.toStringAsFixed(2)}",
              icon: Icons.account_balance_wallet,
              enabled: useEcash,
              amountController: ecashController,
              onToggle: (value) {
                setState(() {
                  useEcash = value;
                  if (value) {
                    useEwallet = false;
                    final fill = subtotal < ecashBalance ? subtotal : ecashBalance;
                    ecashController.text = fill.toStringAsFixed(0);
                  }
                  _recalculateRemaining();
                });
              },
              onAmountChanged: (_) => _recalculateRemaining(),
            ),
            const SizedBox(height: 12),
            WalletCard(
              title: "Ewallet Balance",
              balance: "₹${ewalletBalance.toStringAsFixed(2)}",
              icon: Icons.payments,
              enabled: useEwallet,
              amountController: ewalletController,
              onToggle: (value) {
                setState(() {
                  useEwallet = value;
                  if (value) {
                    useEcash = false;
                    final fill = subtotal < ewalletBalance ? subtotal : ewalletBalance;
                    ewalletController.text = fill.toStringAsFixed(0);
                  }
                  _recalculateRemaining();
                });
              },
              onAmountChanged: (_) => _recalculateRemaining(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  SummaryRow(
                    title: "Subtotal",
                    value: "₹${subtotal.toStringAsFixed(0)}",
                  ),
                  SummaryRow(
                    title: "Coupon Discount",
                    value: "-₹${couponDiscount.toStringAsFixed(0)}",
                  ),
                  SummaryRow(
                    title: "Wallet Applied",
                    value: "-₹${walletApplied.toStringAsFixed(0)}",
                  ),
                  const Divider(height: 16),
                  SummaryRow(
                    title: "Total Payable",
                    value: "₹${remainingAmount.toStringAsFixed(0)}",
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 6),
                Text(
                  "256-bit SSL Encrypted Payment",
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  final String title;
  final String balance;
  final IconData icon;
  final bool enabled;
  final TextEditingController amountController;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onAmountChanged;

  const WalletCard({
    super.key,
    required this.title,
    required this.balance,
    required this.icon,
    required this.enabled,
    required this.amountController,
    required this.onToggle,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Icon(icon, color: AppTheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        balance,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: enabled,
                    onChanged: onToggle,
                    activeColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
            if (enabled)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onChanged: onAmountChanged,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: "Specify Amount",
                    labelStyle: TextStyle(fontSize: 11),
                    suffixText: "INR",
                    suffixStyle: TextStyle(fontSize: 11),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;

  const SummaryRow({
    super.key,
    required this.title,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 13 : 12,
              color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 15 : 12,
              color: isBold ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        ],
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