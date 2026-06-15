import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../model/module_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late ModuleModel module;
  late double subtotal;

  bool useEcash = false;
  bool useEwallet = false;
  bool _isPaying = false;
  bool _isLoadingBalances = false;

  late TextEditingController ecashController;
  late TextEditingController ewalletController;
  final TextEditingController couponController = TextEditingController();

  double ecashBalance = 0.0;
  double ewalletBalance = 0.0;

  double walletApplied = 0.0;
  double couponDiscount = 0.0;
  double remainingAmount = 0.0;
  bool _initialized = false;

  double _parsePrice(String priceStr) {
    final clean = priceStr.split('/')[0].replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      module = ModalRoute.of(context)!.settings.arguments as ModuleModel;
      subtotal = _parsePrice(module.discountPrice);
      remainingAmount = subtotal;

      ecashController = TextEditingController(
        text: subtotal.toStringAsFixed(0),
      );
      ewalletController = TextEditingController(
        text: subtotal.toStringAsFixed(0),
      );

      _initialized = true;
      _fetchBalances();
    }
  }

  @override
  void dispose() {
    ecashController.dispose();
    ewalletController.dispose();
    couponController.dispose();
    super.dispose();
  }

  Future<void> _fetchBalances() async {
    setState(() {
      _isLoadingBalances = true;
    });

    try {
      final db = Database();
      final res = await db.getJsonData(
        {"action": "get_balances"},
        endpoint: "new_apis/payment_modal_API 1.php",
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
      print("Error fetching balances: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBalances = false;
        });
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
        "marketplace": "MODULE"
      };

      final res = await db.getJsonData(
        body,
        endpoint: "new_apis/payment_modal_API 1.php",
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
          
          if (couponController.text.trim().isNotEmpty) {
            if (!couponValid) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(couponMessage.isNotEmpty ? couponMessage : "Invalid coupon code."),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (couponMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(couponMessage),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print("Error recalculating remaining: $e");
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
    setState(() {
      _isPaying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7C83FD)),
        ),
      ),
    );

    final double ebankingVal = useEcash ? (double.tryParse(ecashController.text) ?? 0.0) : 0.0;
    final double ewalletVal = useEwallet ? (double.tryParse(ewalletController.text) ?? 0.0) : 0.0;

    try {
      final db = Database();
      final res = await db.getData(
        {
          "purchaseCurrentModule": module.id,
          "ebanking": ebankingVal.toString(),
          "ewallet": ewalletVal.toString(),
        },
        endpoint: "new_apis/buy_module_api.php",
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loader

      if (res['success'] == true || res['status'] == 200 || res.containsKey('razorpay_order_id') || res.containsKey('order_id')) {
        final String? orderId = res['razorpay_order_id']?.toString() ?? res['order_id']?.toString();
        
        if (orderId != null && remainingAmount > 0.0) {
          _showVerifyPurchaseDialog(orderId);
        } else {
          _showSuccessDialog("Payment completed successfully!");
        }
      } else {
        final errorMsg = res['error']?.toString() ?? "Payment transaction failed on server.";
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loader
        _showErrorDialog("Network error details: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  void _showVerifyPurchaseDialog(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Simulate Razorpay Verification"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Razorpay Order Created successfully on server."),
            const SizedBox(height: 8),
            Text("Order ID: $orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Simulate signature verification success?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff7C83FD)),
            onPressed: () {
              Navigator.pop(ctx);
              _verifyPurchaseOnBackend(orderId);
            },
            child: const Text("Verify Success", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPurchaseOnBackend(String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final db = Database();
      final res = await db.getData(
        {
          "verifyModulePurchase": "true",
          "razorpay_payment_id": "pay_mock_${DateTime.now().millisecondsSinceEpoch}",
          "razorpay_order_id": orderId,
          "razorpay_signature": "mock_signature_verification_success_ccbul",
        },
        endpoint: "new_apis/buy_module_api.php",
      );

      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      if (res['success'] == true || res['status'] == 200) {
        _showSuccessDialog("Payment verified & module purchased successfully!");
      } else {
        final errorMsg = res['error']?.toString() ?? "Verification failed on server.";
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog("Verification failed: $e");
      }
    }
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff7C83FD)),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Pop payment screen
              Navigator.pop(context); // Pop details screen
              Navigator.pushNamed(context, '/module_manager');
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
      backgroundColor: const Color(0xffF1F2FF),
      appBar: AppBar(
        title: const Text("Complete Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: const Color(0xff7C83FD),
          ),
          onPressed: _isPaying ? null : _handlePayment,
          icon: const Icon(
            Icons.lock,
            color: Colors.white,
          ),
          label: Text(
            _isPaying ? "Processing..." : "Pay Now",
            style: const TextStyle(color: Colors.white),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xffF1F2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              module.icon,
                              size: 40,
                              color: const Color(0xff7C83FD),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text("Standard License"),
                                const SizedBox(height: 6),
                                Text(
                                  module.discountPrice,
                                  style: const TextStyle(
                                    color: Color(0xff7C83FD),
                                    fontWeight: FontWeight.bold,
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponController,
                          decoration: const InputDecoration(
                            hintText: "Enter coupon code",
                            prefixIcon: Icon(Icons.sell),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _recalculateRemaining,
                        child: const Text("Apply"),
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
                          // Pre-fill with lower of subtotal or balance
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
                          // Pre-fill with lower of subtotal or balance
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
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
                        const Divider(),
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
                      Icon(
                        Icons.verified_user,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text("256-bit SSL Encrypted Payment"),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xffF1F2FF),
                  child: Icon(
                    icon,
                    color: const Color(0xff7C83FD),
                  ),
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
                        ),
                      ),
                      Text(balance),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (enabled)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onChanged: onAmountChanged,
                  decoration: const InputDecoration(
                    labelText: "Specify Amount",
                    suffixText: "INR",
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
