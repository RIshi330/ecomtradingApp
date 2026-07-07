import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Database/Database.dart';
import '../services/auth_service.dart';

class DigitalProductPaymentModal extends StatefulWidget {
  final Map<String, dynamic> product;
  final Color themeColor;
  final String? clientName;
  final String? clientPhone;
  final int? clientId;
  final double serviceCharge;

  const DigitalProductPaymentModal({
    super.key,
    required this.product,
    required this.themeColor,
    this.clientName,
    this.clientPhone,
    this.clientId,
    this.serviceCharge = 0.0,
  });

  @override
  State<DigitalProductPaymentModal> createState() => _DigitalProductPaymentModalState();
}

class _DigitalProductPaymentModalState extends State<DigitalProductPaymentModal> {
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
    final double rawPrice = double.tryParse(widget.product['price']?.toString() ?? '') ?? 0.0;
    basePrice = rawPrice + widget.serviceCharge;
    remainingAmount = basePrice;
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
      final int? activeVendorId = await AuthService.getVendorId();
      final res = await db.getJsonData({
        'action': 'get_balances',
        'vendor_id': activeVendorId,
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

    final double limitEcash = ecashBalance > 0 ? ecashBalance : 0.0;
    final double limitEwallet = ewalletBalance > 0 ? ewalletBalance : 0.0;

    if (ecashUsed > limitEcash) ecashUsed = limitEcash;
    if (ecashUsed < 0) ecashUsed = 0.0;
    if (ewalletUsed > limitEwallet) ewalletUsed = limitEwallet;
    if (ewalletUsed < 0) ewalletUsed = 0.0;

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
      final int? activeVendorId = await AuthService.getVendorId();

      final response = await db.getJsonData({
        'make_payment': widget.product['id']?.toString() ?? '',
        'payFromEwallet': ewalletUsed,
        'payFromEbanking': ecashUsed,
        'initiative_id': -1,
        'vendor_id': activeVendorId,
      }, endpoint: 'libraries/razorpay/digital_product_pay.php');

      if (response.containsKey('wallet') && response['wallet'] == true) {
        if (mounted) {
          Navigator.pop(context, true); // Close bottom sheet
          _showSuccessDialog(orderId: "#DIG-${1000 + (DateTime.now().millisecond % 9000)}");
        }
        return;
      } else if (response.containsKey('id') && response['id'] != null) {
        _openRazorpay(response);
      } else {
        final String errorMsg = response['ERROR']?.toString() ?? response['error']?.toString() ?? 'Unknown checkout error';
        throw Exception(errorMsg);
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

  void _openRazorpay(Map<dynamic, dynamic> razorpayData) {
    final String contactPhone = widget.clientPhone ?? '9999999999';

    final options = {
      'key': razorpayData['key'] ?? 'rzp_test_mock',
      'amount': razorpayData['amount'],
      'currency': razorpayData['currency'] ?? 'INR',
      'name': 'Ideal Village Digital Product',
      'order_id': razorpayData['id'],
      'description': widget.product['title'] ?? 'Digital Product',
      'prefill': {
        'contact': contactPhone.isNotEmpty ? contactPhone : '9999999999',
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
      final int? activeVendorId = await AuthService.getVendorId();
      final res = await db.getJsonData({
        'payment_status': '1',
        'razorpay_payment_id': response.paymentId ?? '',
        'razorpay_order_id': response.orderId ?? '',
        'razorpay_signature': response.signature ?? '',
        'vendor_id': activeVendorId,
      }, endpoint: 'libraries/razorpay/digital_product_pay.php');

      if (!mounted) return;
      Navigator.pop(context); // Pop loader

      // digital_product_pay.php returns 1 on success
      if (res['success'] == true || res.toString().contains('1') || res['status'] == '1') {
        Navigator.pop(context, true); // Close bottom sheet
        _showSuccessDialog(orderId: response.orderId ?? "#DIG-${1000 + (DateTime.now().millisecond % 9000)}");
      } else {
        final errorMsg = res['message']?.toString() ?? res['error']?.toString() ?? 'Verification failed';
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loader
        _showErrorDialog("Verification error: $e");
      }
    }
  }

  void _handlePaymentError(dynamic response) {
    debugPrint("Payment Error: ${response.code} - ${response.message}");
    _showErrorDialog("Payment failed: ${response.message}");
  }

  void _handleExternalWallet(dynamic response) {
    debugPrint("External Wallet selected: ${response.walletName}");
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
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
                                  color: Colors.black87),
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
                              "₹${basePrice.toStringAsFixed(2)}",
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
                          child: (widget.product['banner'] != null && widget.product['banner'].toString().isNotEmpty)
                              ? Image.network(
                                  widget.product['banner'].toString(),
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
                                widget.product['title']?.toString() ?? 'Digital Product',
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
                                "₹${double.tryParse(widget.product['price']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",
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
                  if (widget.clientName != null && widget.clientName!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Recipient / Client",
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
                            widget.clientName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.clientPhone ?? "No phone provided",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
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
                      },
                      child: const Text(
                        "Close",
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
                          "Checkout",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.clientName != null && widget.clientName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Paying on behalf of: ${widget.clientName}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          const Text(
                            "Buying for Yourself",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    "₹${basePrice.toStringAsFixed(2)}",
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
                                      "E-Cash Balance",
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
                          Text("₹${(double.tryParse(widget.product['price']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}"),
                        ],
                      ),
                      if (widget.serviceCharge > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Service Charge", style: TextStyle(color: Colors.grey)),
                            Text("₹${widget.serviceCharge.toStringAsFixed(2)}"),
                          ],
                        ),
                      ],
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
