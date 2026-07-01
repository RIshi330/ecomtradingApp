import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../index.dart';

class CharityProjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  const CharityProjectDetailScreen({super.key, required this.project});

  @override
  State<CharityProjectDetailScreen> createState() => _CharityProjectDetailScreenState();
}

class _CharityProjectDetailScreenState extends State<CharityProjectDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _charity;
  Map<String, dynamic>? _expectations;
  String _imageUrl = '';
  List<String> _fixedAmounts = [];
  bool _hasFlexibleAmount = false;

  // Balances
  double _walletBalance = 0.0;
  double _bankingBalance = 0.0;

  // User input states
  double _selectedAmount = 1000.0;
  int _quantity = 1;
  final TextEditingController _customAmountController = TextEditingController();
  final FocusNode _customAmountFocusNode = FocusNode();

  final Color primaryTeal = const Color(0xFF006565);
  final Color lightTeal = const Color(0xFFD4E6E5);
  final Color bgLight = const Color(0xFFFCF9F8);
  final Color textDark = const Color(0xFF1C1B1B);
  final Color textGrey = const Color(0xFF3E4949);

  // Razorpay
  dynamic _razorpay;
  VoidCallback? _pendingSuccessCallback;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _fetchBalances();
    _initRazorpay();
    _customAmountController.addListener(() {
      final val = double.tryParse(_customAmountController.text);
      if (val != null && val > 0) {
        setState(() {
          _selectedAmount = val;
        });
      }
    });
  }

  void _initRazorpay() {
    try {
      _razorpay = _DonationRazorpayWrapper();
      _razorpay.onSuccess = _handleRazorpaySuccess;
      _razorpay.onError = _handleRazorpayError;
      _razorpay.onWallet = (r) => debugPrint("External wallet: $r");
    } catch (e) {
      debugPrint("Razorpay init skipped: $e");
    }
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _customAmountFocusNode.dispose();
    _razorpay?.clear();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await Database().getJsonData({
        'action': 'get_charity_detail',
        'item_id': widget.project['item_id'] ?? widget.project['id']?.toString() ?? '',
        'var_id': widget.project['item_var_id'] ?? widget.project['var_id'] ?? '0',
        'mk_id': widget.project['mk_id'] ?? '',
      }, endpoint: 'new_apis/donation_details_api.php');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          _charity = data['charity'];
          _expectations = data['expectations'];
          _imageUrl = data['image_url'] ?? '';

          final fixed = _expectations?['fixed_amounts'];
          if (fixed is List) {
            _fixedAmounts = fixed.map((e) => e.toString()).toList();
            if (_fixedAmounts.isNotEmpty) {
              _selectedAmount = double.tryParse(_fixedAmounts.first) ?? 1000.0;
            }
          }
          _hasFlexibleAmount = _expectations?['has_flexible_amount'] == true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching charity details: $e");
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

  Future<void> _processDonation(double amount, double walletUsed, double bankingUsed) async {
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
        'item_id': widget.project['item_id'] ?? widget.project['id']?.toString() ?? '',
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
          _pendingSuccessCallback = () => _showSuccessDialog(amount);
          _openRazorpay(
            key: data['key'] ?? 'rzp_test_pi2fEEfhC66GKs',
            orderId: data['razorpay_order_id'],
            amount: data['amount'] is int ? data['amount'] : int.tryParse(data['amount']?.toString() ?? '0') ?? 0,
            currency: data['currency'] ?? 'INR',
          );
        } else {
          // Wallet-only payment completed
          _showSuccessDialog(amount);
        }
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to initiate donation");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _openRazorpay({
    required String key,
    required String orderId,
    required int amount,
    required String currency,
  }) {
    final options = {
      'key': key,
      'amount': amount,
      'currency': currency,
      'name': 'Charity Donation',
      'order_id': orderId,
      'description': _charity?['fundraiser_title'] ?? 'Donation',
      'prefill': {
        'contact': '9999999999',
        'email': 'donor@idealvillage.in',
      },
      'theme': {
        'color': '#006565',
      },
    };

    debugPrint("RAZORPAY OPTIONS (Donation): $options");

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

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: primaryTeal),
              const SizedBox(width: 8),
              const Text("Support Confirmed"),
            ],
          ),
          content: Text(
            "Thank you! You have funded ₹${amount.toStringAsFixed(0)} to support ${_charity?['vendor_name'] ?? 'NGO'}.\nWe will deliver materials or transfer funds to the beneficiaries.",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back to projects screen
              },
              child: const Text("OK"),
            ),
          ],
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
                      Text("₹${remainingOnline.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: primaryTeal, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CANCEL"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _processDonation(totalAmount, walletSelect, bankingSelect);
                          },
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _charity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading...")),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF006565))),
      );
    }

    final type = _expectations?['type'] ?? 'cash';
    final double expectationAmount = double.tryParse(_expectations?['expectation_amount']?.toString() ?? '0') ?? 0.0;
    final double raisedAmount = double.tryParse(_expectations?['raised_amount']?.toString() ?? '0') ?? 0.0;
    final double progress = expectationAmount > 0 ? (raisedAmount / expectationAmount) : 0.0;

    double checkoutTotal = 0.0;
    if (type == 'goods') {
      checkoutTotal = expectationAmount * _quantity;
    } else {
      checkoutTotal = _selectedAmount;
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: primaryTeal),
        title: Text(
          type == 'service' ? "Opportunity Details" : "Request Details",
          style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero area
            _buildHeroArea(type, progress),

            // Content body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _charity?['fundraiser_title'] ?? '',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.visibility, color: textGrey, size: 16),
                      const SizedBox(width: 4),
                      const Text("1.2k Views", style: TextStyle(color: Color(0xFF3E4949), fontSize: 13)),
                      const SizedBox(width: 16),
                      Icon(Icons.share, color: textGrey, size: 16),
                      const SizedBox(width: 4),
                      const Text("150 Shares", style: TextStyle(color: Color(0xFF3E4949), fontSize: 13)),
                    ],
                  ),
                  const Divider(height: 24),

                  // Poster/NGO Info
                  _buildPosterNGOInfo(),
                  const Divider(height: 24),

                  // Progress
                  if (type != 'service') ...[
                    _buildProgressSection(type, progress, expectationAmount, raisedAmount),
                    const SizedBox(height: 24),
                  ],

                  // Beneficiary / Story Section
                  _buildStorySection(type),
                  const SizedBox(height: 24),

                  // Amount selectors based on campaign type
                  if (type == 'goods')
                    _buildGoodsDescription()
                  else if (type == 'cash')
                    _buildCashAmountSelectorGrid()
                  else if (type == 'service')
                    _buildServiceSkillsSection(),

                  const SizedBox(height: 24),

                  // Trust banner
                  _buildTrustBanner(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(type, checkoutTotal),
    );
  }

  Widget _buildHeroArea(String type, double progress) {
    if (type == 'service') {
      return Container(
        height: 200,
        width: double.infinity,
        color: primaryTeal.withOpacity(0.08),
        child: Center(
          child: Icon(Icons.volunteer_activism, size: 80, color: primaryTeal),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _imageUrl.isNotEmpty
              ? Image.network(_imageUrl, fit: BoxFit.cover)
              : Container(
                  color: primaryTeal.withOpacity(0.08),
                  child: Icon(Icons.image, size: 50, color: primaryTeal),
                ),
        ],
      ),
    );
  }

  Widget _buildPosterNGOInfo() {
    final avatar = _charity?['profile_pic']?.toString() ?? '';
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lightTeal,
            image: avatar.isNotEmpty
                ? DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover)
                : null,
          ),
          child: avatar.isEmpty
              ? Icon(Icons.volunteer_activism, color: primaryTeal, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _charity?['vendor_name'] ?? 'NGO Fund',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.verified, color: primaryTeal, size: 16),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "Category: ${_charity?['category'] ?? ''}",
                style: TextStyle(color: textGrey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(String type, double progress, double total, double raised) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type == 'cash' ? "CURRENT STATUS" : "FULFILLMENT STATUS",
                    style: TextStyle(fontSize: 10, color: textGrey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      text: "₹${raised.toStringAsFixed(0)} ",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTeal),
                      children: [
                        TextSpan(
                          text: "of ₹${total.toStringAsFixed(0)}",
                          style: TextStyle(fontSize: 13, color: textGrey, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTeal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E2E1),
              valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: primaryTeal, width: 4)),
          ),
          child: Text(
            type == 'service' ? "The Opportunity" : "The Story",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _charity?['fundraiser_desc'] ?? '',
          style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildGoodsDescription() {
    final goodsName = _expectations?['goods_name'] ?? 'Materials';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_bag, color: primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Required Goods", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(goodsName, style: TextStyle(color: textGrey, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCashAmountSelectorGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: primaryTeal, width: 4)),
          ),
          child: Text(
            "Choose Amount",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
          ),
        ),
        const SizedBox(height: 16),
        if (_fixedAmounts.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _fixedAmounts.length,
            itemBuilder: (context, idx) {
              final amt = double.tryParse(_fixedAmounts[idx]) ?? 1000.0;
              final isSelected = _selectedAmount == amt;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedAmount = amt;
                    _customAmountController.clear();
                    _customAmountFocusNode.unfocus();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? primaryTeal : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryTeal : const Color(0xFFBDC9C8),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "₹${amt.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : textDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        if (_hasFlexibleAmount)
          TextField(
            controller: _customAmountController,
            focusNode: _customAmountFocusNode,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            decoration: InputDecoration(
              hintText: "Custom Amount",
              prefixText: "₹ ",
              prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textGrey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryTeal, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text("Support local NGO activities by joining this drive."),
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightTeal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightTeal.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                "Complete Transparency",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Every donation is directly registered and monitored. Transferred funds are distributed through secure banking integrations.",
            style: TextStyle(fontSize: 13, color: textGrey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(String type, double total) {
    if (type == 'service') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Fluttertoast.showToast(msg: "Successfully registered as volunteer!");
              Navigator.pop(context);
            },
            child: const Text("Join as Volunteer"),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (type == 'goods')
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EDED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.remove, color: primaryTeal, size: 18),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text("$_quantity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                      const SizedBox(width: 4),
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.add, color: primaryTeal, size: 18),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("TOTAL SUPPORT", style: TextStyle(fontSize: 10, color: textGrey, fontWeight: FontWeight.bold)),
                  Text("₹${total.toStringAsFixed(0)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showFundingPaymentModal(total),
              child: const Text("Support Now"),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  RAZORPAY WRAPPER for Donation Detail screen
// =============================================================================
class _DonationRazorpayWrapper {
  dynamic _instance;

  Function(dynamic)? onSuccess;
  Function(dynamic)? onError;
  Function(dynamic)? onWallet;

  _DonationRazorpayWrapper() {
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
