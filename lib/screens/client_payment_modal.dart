import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../Database/Database.dart';
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

  @override
  void initState() {
    super.initState();
    basePrice = widget.totalRawPrice;
    remainingAmount = widget.totalRawPrice;
    _fetchBalances();
  }

  @override
  void dispose() {
    ecashController.dispose();
    ewalletController.dispose();
    super.dispose();
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
          Navigator.pop(context, true); // Close bottom sheet
          _showSuccessDialog("Purchase successful! Balance deducted from wallet.");
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
                    onPressed: _isPaying
                        ? null
                        : () {
                            if (remainingAmount > 0) {
                              _showSimulateDialog();
                            } else {
                              _processCheckout();
                            }
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
