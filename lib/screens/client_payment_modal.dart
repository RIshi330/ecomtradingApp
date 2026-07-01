import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Database/Database.dart';
import '../index.dart';
import 'selected_items_screen.dart';

class ClientPaymentModal extends StatefulWidget {
  final SelectedProduct product;
  final int quantity;
  final double totalRawPrice;
  final Color themeColor;
  final String clientName;
  final String clientPhone;

  const ClientPaymentModal({
    super.key,
    required this.product,
    required this.quantity,
    required this.totalRawPrice,
    required this.themeColor,
    required this.clientName,
    required this.clientPhone,
  });

  @override
  State<ClientPaymentModal> createState() => _ClientPaymentModalState();
}

class _ClientPaymentModalState extends State<ClientPaymentModal> {
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

    // Clamp available limits to 0 if negative
    final double limitEcash = ecashBalance > 0 ? ecashBalance : 0.0;
    final double limitEwallet = ewalletBalance > 0 ? ewalletBalance : 0.0;

    // Constrain to available positive balances
    if (ecashUsed > limitEcash) ecashUsed = limitEcash;
    if (ecashUsed < 0) ecashUsed = 0.0;
    if (ewalletUsed > limitEwallet) ewalletUsed = limitEwallet;
    if (ewalletUsed < 0) ewalletUsed = 0.0;

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

      final response = await db.getJsonData({
        'action': 'process_client_purchase',
        'total_price': basePrice,
        'use_from_ebanking': ecashUsed,
        'use_from_ewallet': ewalletUsed,
        'product_name': widget.product.name,
        'client_name': widget.clientName,
        'client_phone': widget.clientPhone,
        'quantity': widget.quantity,
      }, endpoint: 'new_apis/payment_modal_API.php');

      if (response['success'] == true) {
        if (mounted) {
          final data = response['data'];
          if (data != null && data['razorpay'] == true) {
            _openRazorpay(data);
          } else {
            final String orderId = response['order_id']?.toString() ?? "#SER-${1000 + (DateTime.now().millisecond % 9000)}";
            Navigator.pop(context, true); // Close bottom sheet
            _showSuccessDialog(orderId: orderId);
          }
        }
        return;
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

  void _openRazorpay(Map<String, dynamic> razorpayData) {
    final String contactPhone = widget.clientPhone.isNotEmpty
        ? widget.clientPhone
        : '9999999999';

    final options = {
      'key': razorpayData['key'],
      'amount': razorpayData['amount'],
      'currency': razorpayData['currency'] ?? 'INR',
      'name': 'Ideal Village Client Purchase',
      'order_id': razorpayData['razorpay_order_id'],
      'description': widget.product.name,
      'prefill': {
        'contact': contactPhone,
        'email': 'customer@idealvillage.in',
      },
      'theme': {
        'color': '#006565',
      },
    };

    debugPrint("RAZORPAY OPTIONS: $options");

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay open error: $e");
      _showErrorDialog("Razorpay failed to launch: $e");
    }
  }

  void _handlePaymentSuccess(dynamic response) async {
    _showLoadingDialog();
    try {
      final db = Database();
      final res = await db.getJsonData({
        'action': 'verify_client_purchase',
        'razorpay_payment_id': response.paymentId ?? '',
        'razorpay_order_id': response.orderId ?? '',
        'razorpay_signature': response.signature ?? '',
      }, endpoint: 'new_apis/payment_modal_API.php');

      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      if (res['success'] == true) {
        Navigator.pop(context, true); // Close bottom sheet
        _showSuccessDialog(orderId: response.orderId ?? '');
      } else {
        _showErrorDialog(res['message'] ?? "Payment verification failed.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loader
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showSimulateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Simulate Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Simulate online/Razorpay checkout payment:"),
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
              _processCheckout(); // Proceed to deduct wallet parts and finalize
            },
            child: const Text("Verify Success"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog({required String orderId}) {
    String paymentMethod = "Online Payment";
    IconData paymentIcon = Icons.payment;
    if (useEcash && useEwallet) {
      paymentMethod = "e-Wallet & e-Cash";
      paymentIcon = Icons.account_balance_wallet;
    } else if (useEcash) {
      paymentMethod = "e-Cash";
      paymentIcon = Icons.monetization_on;
    } else if (useEwallet) {
      paymentMethod = "e-Wallet";
      paymentIcon = Icons.account_balance_wallet;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4E6E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF006565),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Payment Successful!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006565),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Hooray! Your order has been placed\nsuccessfully.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "ORDER ID",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              orderId,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "AMOUNT PAID",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "₹${widget.totalRawPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006565),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "PAYMENT METHOD",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  paymentIcon,
                                  size: 14,
                                  color: const Color(0xFF006565),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  paymentMethod,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Order Details",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.product.image.isNotEmpty
                              ? Image.network(
                                  widget.product.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Quantity: ${widget.quantity.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${widget.product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF006565),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Recipient",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.clientName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.clientPhone.isNotEmpty ? widget.clientPhone : "No phone provided",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, AppRoutes.affiliateOrders);
                      },
                      icon: const Icon(Icons.local_shipping, size: 18),
                      label: const Text(
                        "Track Order",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF006565),
                        side: const BorderSide(color: Color(0xFF006565), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, AppRoutes.manageOpportunities);
                      },
                      child: const Text(
                        "Continue Shopping",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Client Buy Checkout",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "For client: ${widget.clientName}",
                          style: const TextStyle(
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
                                    ewalletController.text = ewalletBalance > 0 ? ewalletBalance.toString() : '0';
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
                                    ecashController.text = ecashBalance > 0 ? ecashBalance.toString() : '0';
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
                    onPressed: _isPaying
                        ? null
                        : () {
                            _processCheckout();
                          },
                    child: _isPaying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            remainingAmount > 0
                                ? "Proceed to Pay ₹${remainingAmount.toStringAsFixed(2)}"
                                : "Proceed to Purchase",
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
