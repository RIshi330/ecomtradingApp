import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../index.dart';

class CharityMarketplaceScreen extends StatefulWidget {
  final bool isEmbedded;
  const CharityMarketplaceScreen({super.key, this.isEmbedded = false});

  @override
  State<CharityMarketplaceScreen> createState() => _CharityMarketplaceScreenState();
}

class _CharityMarketplaceScreenState extends State<CharityMarketplaceScreen> {
  String _searchQuery = '';
  final List<Map<String, dynamic>> _cart = [];
  bool _isLoading = true;
  List<dynamic> _apiProducts = [];
  double _walletBalance = 0.0;
  double _bankingBalance = 0.0;

  // Razorpay
  dynamic _razorpay;
  VoidCallback? _pendingSuccessCallback;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchBalances();
    _initRazorpay();
  }

  void _initRazorpay() {
    try {
      _razorpay = _CharityRazorpayWrapper();
      _razorpay.onSuccess = _handleRazorpaySuccess;
      _razorpay.onError = _handleRazorpayError;
      _razorpay.onWallet = (r) => debugPrint("External wallet: $r");
    } catch (e) {
      debugPrint("Razorpay init skipped: $e");
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await Database().getJsonData({
        'action': 'get_charities',
      }, endpoint: 'new_apis/donation_shop_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _apiProducts = response['data']['charities'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchBalances() async {
    try {
      final response = await Database().getJsonData({
        'action': 'get_wallet_balance',
      }, endpoint: 'new_apis/donation_details_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _walletBalance = double.tryParse(response['data']['wallet_balance']?.toString() ?? '0') ?? 0.0;
          _bankingBalance = double.tryParse(response['data']['banking_balance']?.toString() ?? '0') ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching balances: $e");
    }
  }

  List<dynamic> get _filteredProducts {
    if (_searchQuery.isEmpty) return _apiProducts;
    return _apiProducts.where((p) {
      final name = (p['goods_name'] != null && p['goods_name'].toString().isNotEmpty)
          ? p['goods_name'].toString().toLowerCase()
          : (p['fundraiser_title'] ?? '').toString().toLowerCase();
      final ngo = (p['fundraiser_title'] ?? '').toString().toLowerCase();
      final category = (p['category'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || ngo.contains(query) || category.contains(query);
    }).toList();
  }

  void _addToCart(dynamic product) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item['product']['item_id'] == product['item_id']);
      if (existingIndex >= 0) {
        _cart[existingIndex]['qty']++;
      } else {
        _cart.add({'product': product, 'qty': 1});
      }
    });

    final name = (product['goods_name'] != null && product['goods_name'].toString().isNotEmpty)
        ? product['goods_name'].toString()
        : (product['fundraiser_title'] ?? 'Charity Product');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name added to charity support cart!"),
        backgroundColor: const Color(0xFF006565),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  int get _cartItemCount {
    return _cart.fold(0, (sum, item) => sum + (item['qty'] as int));
  }

  double get _cartTotal {
    return _cart.fold(0.0, (sum, item) {
      final price = double.tryParse(item['product']['expectation_amount']?.toString() ?? '0') ?? 0.0;
      final qty = item['qty'] as int;
      return sum + (price * qty);
    });
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Charity Support Cart",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_cart.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          "Your support cart is empty.\nAdd items to fund them for NGOs.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, height: 1.5),
                        ),
                      ),
                    )
                  else ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _cart.length,
                        itemBuilder: (context, idx) {
                          final item = _cart[idx];
                          final product = item['product'];
                          final qty = item['qty'];
                          final name = (product['goods_name'] != null && product['goods_name'].toString().isNotEmpty)
                              ? product['goods_name'].toString()
                              : (product['fundraiser_title'] ?? 'Charity Product');
                          final price = double.tryParse(product['expectation_amount']?.toString() ?? '0') ?? 0.0;
                          final ngo = product['fundraiser_title'] ?? 'Verified NGO';
                          final imageUrl = product['image_url'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: (imageUrl.isNotEmpty)
                                      ? Image.network(
                                          imageUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.shopping_bag),
                                          ),
                                        )
                                      : Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.shopping_bag),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text("₹${price.toStringAsFixed(2)} • $ngo", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF006565)),
                                      onPressed: () {
                                        setModalState(() {
                                          setState(() {
                                            if (qty > 1) {
                                              item['qty']--;
                                            } else {
                                              _cart.removeAt(idx);
                                            }
                                          });
                                        });
                                      },
                                    ),
                                    Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF006565)),
                                      onPressed: () {
                                        setModalState(() {
                                          setState(() {
                                            item['qty']++;
                                          });
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Funding amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("₹${_cartTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF006565))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final total = _cartTotal;
                          Navigator.pop(context);
                          _showFundingPaymentModal(total);
                        },
                        child: const Text("Confirm Support & Pay", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFundingPaymentModal(double totalAmount) {
    double walletSelect = 0.0;
    double bankingSelect = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double remainingOnline = totalAmount - walletSelect - bankingSelect;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Funding Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text("Total Fulfill Amount: ₹${totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  CheckboxListTile(
                    activeColor: const Color(0xFF006565),
                    title: const Text("Pay using E-Wallet"),
                    subtitle: Text("Available balance: ₹${_walletBalance.toStringAsFixed(2)}"),
                    value: walletSelect > 0,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          walletSelect = _walletBalance > totalAmount ? totalAmount : _walletBalance;
                        } else {
                          walletSelect = 0.0;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    activeColor: const Color(0xFF006565),
                    title: const Text("Pay using E-Banking"),
                    subtitle: Text("Available balance: ₹${_bankingBalance.toStringAsFixed(2)}"),
                    value: bankingSelect > 0,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          final double maxAllowable = totalAmount - walletSelect;
                          bankingSelect = _bankingBalance > maxAllowable ? maxAllowable : _bankingBalance;
                        } else {
                          bankingSelect = 0.0;
                        }
                      });
                    },
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Remaining Online payment:"),
                      Text("₹${remainingOnline.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, color: Color(0xFF006565), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006565),
                            side: const BorderSide(color: Color(0xFF006565)),
                          ),
                          child: const Text("CANCEL"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _processCartCheckout(totalAmount, walletSelect, bankingSelect);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("CONFIRM & PAY"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _processCartCheckout(double totalAmount, double walletUsed, double bankingUsed) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006565))),
      ),
    );

    double walletRemaining = walletUsed;
    double bankingRemaining = bankingUsed;
    bool allSuccess = true;
    String errorMessage = '';

    try {
      for (final item in _cart) {
        final product = item['product'];
        final qty = item['qty'] as int;
        final price = double.tryParse(product['expectation_amount']?.toString() ?? '0') ?? 0.0;
        final itemTotal = price * qty;

        final itemWallet = walletRemaining > itemTotal ? itemTotal : walletRemaining;
        walletRemaining -= itemWallet;

        final maxAllowableBanking = itemTotal - itemWallet;
        final itemBanking = bankingRemaining > maxAllowableBanking ? maxAllowableBanking : bankingRemaining;
        bankingRemaining -= itemBanking;

        final response = await Database().getJsonData({
          'action': 'make_donation',
          'item_id': product['item_id'] ?? '',
          'amount': itemTotal,
          'ewallet': itemWallet,
          'ebanking': itemBanking,
        }, endpoint: 'new_apis/donation_details_api.php');

        if (response['success'] == true) {
          final data = response['data'];
          if (data != null && data['razorpay'] == true) {
            // Razorpay payment needed for this item
            if (!mounted) return;
            Navigator.pop(context); // Close loading
            _pendingSuccessCallback = () {
              setState(() { _cart.clear(); });
              _showSuccessDialog(totalAmount);
              _fetchBalances();
            };
            _openRazorpay(
              key: data['key'] ?? 'rzp_test_pi2fEEfhC66GKs',
              orderId: data['razorpay_order_id'],
              amount: data['amount'] is int ? data['amount'] : int.tryParse(data['amount']?.toString() ?? '0') ?? 0,
              currency: data['currency'] ?? 'INR',
              description: 'Charity Support',
            );
            return; // Razorpay will handle callback
          }
          // Wallet-only item processed successfully, continue
        } else {
          allSuccess = false;
          errorMessage = response['message']?.toString() ?? 'Failed to complete support for some items.';
          break;
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (allSuccess) {
        setState(() { _cart.clear(); });
        _showSuccessDialog(totalAmount);
        _fetchBalances();
      } else {
        Fluttertoast.showToast(msg: errorMessage.isNotEmpty ? errorMessage : "Payment processing failed");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> _processQuickDonate(dynamic project, double amount, double walletUsed, double bankingUsed) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006565))),
      ),
    );

    try {
      final response = await Database().getJsonData({
        'action': 'make_donation',
        'item_id': project['item_id'] ?? '',
        'amount': amount,
        'ewallet': walletUsed,
        'ebanking': bankingUsed,
      }, endpoint: 'new_apis/donation_details_api.php');

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response['success'] == true) {
        final data = response['data'];
        if (data != null && data['razorpay'] == true) {
          // Real Razorpay checkout needed
          _pendingSuccessCallback = () {
            _showSuccessDialog(amount);
            _fetchBalances();
          };
          _openRazorpay(
            key: data['key'] ?? 'rzp_test_pi2fEEfhC66GKs',
            orderId: data['razorpay_order_id'],
            amount: data['amount'] is int ? data['amount'] : int.tryParse(data['amount']?.toString() ?? '0') ?? 0,
            currency: data['currency'] ?? 'INR',
            description: project['fundraiser_title'] ?? 'Charity Donation',
          );
        } else {
          _showSuccessDialog(amount);
          _fetchBalances();
        }
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to initiate donation");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF006565)),
              SizedBox(width: 8),
              Text("Support Confirmed"),
            ],
          ),
          content: Text(
            "Thank you! You funded ₹${amount.toStringAsFixed(0)} worth of materials for charity partners. NGOs will distribute these to beneficiaries.",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showQuickDonateModal(dynamic project, double amount) {
    double walletSelect = 0.0;
    double bankingSelect = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double remainingOnline = amount - walletSelect - bankingSelect;
            final name = project['goods_name'] ?? project['fundraiser_title'] ?? 'Charity Project';
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Quick Support", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Project: $name", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Text("Total Fulfill Amount: ₹${amount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  CheckboxListTile(
                    activeColor: const Color(0xFF006565),
                    title: const Text("Pay using E-Wallet"),
                    subtitle: Text("Available balance: ₹${_walletBalance.toStringAsFixed(2)}"),
                    value: walletSelect > 0,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          walletSelect = _walletBalance > amount ? amount : _walletBalance;
                        } else {
                          walletSelect = 0.0;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    activeColor: const Color(0xFF006565),
                    title: const Text("Pay using E-Banking"),
                    subtitle: Text("Available balance: ₹${_bankingBalance.toStringAsFixed(2)}"),
                    value: bankingSelect > 0,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          final double maxAllowable = amount - walletSelect;
                          bankingSelect = _bankingBalance > maxAllowable ? maxAllowable : _bankingBalance;
                        } else {
                          bankingSelect = 0.0;
                        }
                      });
                    },
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Remaining Online payment:"),
                      Text("₹${remainingOnline.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, color: Color(0xFF006565), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006565),
                            side: const BorderSide(color: Color(0xFF006565)),
                          ),
                          child: const Text("CANCEL"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _processQuickDonate(project, amount, walletSelect, bankingSelect);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("CONFIRM & PAY"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openRazorpay({
    required String key,
    required String orderId,
    required int amount,
    required String currency,
    String description = 'Charity Donation',
  }) {
    final options = {
      'key': key,
      'amount': amount,
      'currency': currency,
      'name': 'Charity Support',
      'order_id': orderId,
      'description': description,
      'prefill': {
        'contact': '9999999999',
        'email': 'donor@idealvillage.in',
      },
      'theme': {
        'color': '#006565',
      },
    };

    debugPrint("RAZORPAY OPTIONS (Charity Marketplace): $options");

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay open error: $e");
      Fluttertoast.showToast(msg: "Razorpay failed to launch: $e");
    }
  }

  void _handleRazorpaySuccess(dynamic response) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006565))),
      ),
    );

    try {
      final res = await Database().getJsonData({
        'action': 'verify_donation',
        'razorpay_payment_id': response.paymentId ?? '',
        'razorpay_order_id': response.orderId ?? '',
        'razorpay_signature': response.signature ?? '',
      }, endpoint: 'new_apis/donation_details_api.php');

      if (!mounted) return;
      Navigator.pop(context);

      if (res['success'] == true) {
        _pendingSuccessCallback?.call();
        _pendingSuccessCallback = null;
      } else {
        Fluttertoast.showToast(msg: res['message']?.toString() ?? 'Payment verification failed');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: "Verification failed: $e");
    }
  }

  void _handleRazorpayError(dynamic response) {
    Fluttertoast.showToast(msg: "Payment Cancelled / Failed.");
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              title: const Text("Charity Marketplace", style: TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold)),
              iconTheme: const IconThemeData(color: Color(0xFF006565)),
              actions: [
                IconButton(
                  icon: Badge(
                    label: Text("$_cartItemCount"),
                    isLabelVisible: _cartItemCount > 0,
                    child: const Icon(Icons.shopping_cart),
                  ),
                  onPressed: _showCartSheet,
                ),
              ],
              elevation: 0.5,
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isEmbedded)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDED),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Search products or NGOs...",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _showCartSheet,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E2E1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Badge(
                          label: Text("$_cartItemCount"),
                          isLabelVisible: _cartItemCount > 0,
                          child: const Icon(Icons.shopping_cart, color: Color(0xFF3E4949)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Drive banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&q=80&w=800"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "FEATURED DRIVE",
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Winter Support Drive",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Help provide kits for families in cold regions.",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF006565),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_apiProducts.isNotEmpty) {
                              _showQuickDonateModal(_apiProducts.first, 1500.0);
                            } else {
                              Fluttertoast.showToast(msg: "No active campaigns to donate to at this moment.");
                            }
                          },
                          child: const Text("Donate Now", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Impact Hub title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Impact Hub",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
              ),
            ),

            // Impact Hub metrics row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Row(
                children: [
                  _buildImpactCard(Icons.diversity_3, "12.5k", "Lives Impacted"),
                  _buildImpactCard(Icons.school, "480", "Children in School"),
                  _buildImpactCard(Icons.medical_services, "₹85k", "Medical Aid Supplied"),
                ],
              ),
            ),

            // All Impact Products title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "All Impact Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
              ),
            ),

            // Products Grid
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(color: Color(0xFF006565)),
                    ),
                  )
                : _filteredProducts.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text("No products match search queries."),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.70,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, idx) {
                          final prod = _filteredProducts[idx];
                          final name = (prod['goods_name'] != null && prod['goods_name'].toString().isNotEmpty)
                              ? prod['goods_name'].toString()
                              : (prod['fundraiser_title'] ?? 'Charity Product');
                          final category = prod['category'] ?? 'General';
                          final price = double.tryParse(prod['expectation_amount']?.toString() ?? '0') ?? 0.0;
                          final ngo = prod['fundraiser_title'] ?? 'Verified NGO';
                          final imageUrl = prod['image_url'] ?? '';
                          final impact = prod['fundraiser_desc'] ?? 'Fundraiser support';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image & NGO Owner Info
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: (imageUrl.isNotEmpty)
                                          ? Image.network(
                                              imageUrl,
                                              height: 95,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                height: 95,
                                                color: Colors.grey[200],
                                                child: const Icon(Icons.image),
                                              ),
                                            )
                                          : Container(
                                              height: 95,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.shopping_bag),
                                            ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          category.toUpperCase(),
                                          style: const TextStyle(color: Color(0xFF006565), fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.verified, color: Color(0xFF006565), size: 12),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                ngo,
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.trending_up, size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                impact,
                                                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "₹${price.toStringAsFixed(0)}",
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () => _addToCart(prod),
                                              child: const CircleAvatar(
                                                radius: 14,
                                                backgroundColor: Color(0xFF006565),
                                                child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
    return widget.isEmbedded ? content : SafeArea(child: content);
  }

  Widget _buildImpactCard(IconData icon, String count, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4E6E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF006565), size: 20),
            ),
            const SizedBox(height: 12),
            Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  RAZORPAY WRAPPER for Charity Marketplace screen
// =============================================================================
class _CharityRazorpayWrapper {
  dynamic _instance;

  Function(dynamic)? onSuccess;
  Function(dynamic)? onError;
  Function(dynamic)? onWallet;

  _CharityRazorpayWrapper() {
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
