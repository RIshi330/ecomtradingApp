import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class WalletAdminScreen extends StatefulWidget {
  final bool isEmbedded;
  const WalletAdminScreen({super.key, this.isEmbedded = false});

  @override
  State<WalletAdminScreen> createState() => _WalletAdminScreenState();
}

class _WalletAdminScreenState extends State<WalletAdminScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  // Dynamic balances
  double _availableBalance = 24500.0;
  double _pendingBalance = 1250.0;
  double _totalEcash = 45200.0;
  double _totalWallet = 169700.0;

  @override
  void initState() {
    super.initState();
    _fetchWithdrawalHistory();
  }

  // API Call: Fetch withdrawal requests list and current wallet balances dynamically
  Future<void> _fetchWithdrawalHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final db = Database();
      
      // 1. Fetch withdrawal history
      final res = await db.getData({
        'action': 'getWithdrawRequests',
      }, endpoint: 'new_apis/withdrawl_request_api.php');

      // 2. Fetch current wallet balances dynamically from the payment modal API
      final balanceRes = await db.getJsonData({
        'action': 'get_balances',
      }, endpoint: 'new_apis/payment_modal_API 1.php');

      if (!mounted) return;

      setState(() {
        if (res['success'] == true || res['status'] == 200 || res.containsKey('data')) {
          _transactions = res['data'] ?? [];
          
          // Compute dynamic pending balance from list
          double pendingSum = 0.0;
          for (var item in _transactions) {
            final status = item['status']?.toString().toLowerCase();
            if (status == 'pending') {
              final amt = double.tryParse(item['requestedAmount']?.toString() ?? '0') ?? 0.0;
              pendingSum += amt;
            }
          }
          _pendingBalance = pendingSum;
        }

        if (balanceRes['success'] == true || balanceRes['status'] == 200 || balanceRes.containsKey('data')) {
          final data = balanceRes['data'];
          if (data != null) {
            final ecash = double.tryParse(data['ecash_balance']?.toString() ?? '0') ?? 0.0;
            final ewallet = double.tryParse(data['ewallet_balance']?.toString() ?? '0') ?? 0.0;
            
            _totalEcash = ecash;
            _availableBalance = ecash;
            _totalWallet = ewallet;
          }
        }
      });
    } catch (e) {
      print("Error fetching withdrawal history or balances: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // API Call: Submit a new withdrawal request
  Future<void> _submitWithdrawalRequest(String amount, String description, String receiveTo) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final db = Database();
      final res = await db.getData({
        'action': 'requestWithdraw',
        'requestedAmount': amount,
        'description': description,
        'receiveTo': receiveTo,
      }, endpoint: 'new_apis/withdrawl_request_api.php');

      if (res.containsKey('code') || res.containsKey('data')) {
        final code = int.tryParse(res['code']?.toString() ?? res['data']?['code']?.toString() ?? '0') ?? 0;
        if (code == -1) {
          _showErrorDialog("Insufficient balance. Please enter a lower amount.");
        } else if (code == -2) {
          _showErrorDialog("Minimum withdrawal amount is ₹2,000.");
        } else {
          _showErrorDialog(res['message']?.toString() ?? res['data']?['message']?.toString() ?? "Failed to request withdrawal.");
        }
      } else if (res['success'] == true || res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Withdrawal request submitted successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchWithdrawalHistory();
      } else {
        _showErrorDialog(res['error']?.toString() ?? "Failed to request withdrawal.");
      }
    } catch (e) {
      print("Error submitting withdrawal request: $e");
      _showErrorDialog("Connection error: unable to submit request.");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // API Call: Cancel pending request
  Future<void> _cancelWithdrawalRequest(String transactionId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final db = Database();
      final res = await db.getData({
        'action': 'cancelRequest',
        'transaction_id': transactionId,
      }, endpoint: 'new_apis/withdrawl_request_api.php');

      if (res['success'] == true || res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Withdrawal request cancelled successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchWithdrawalHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['error']?.toString() ?? "Failed to cancel withdrawal request."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error cancelling withdrawal request: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Withdrawal Failed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: Color(0xff006565))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final bool isFromAdmin = args == 'admin';

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: widget.isEmbedded ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.menu, color: Color(0xff006565)),
                onPressed: () {},
              ),
        title: const Text(
          "Financial Wallet",
          style: TextStyle(
            color: Color(0xff006565),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xff006565)),
            onPressed: _fetchWithdrawalHistory,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/user/bank-accounts');
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xff006565),
              child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xff006565),
        onPressed: _showWithdrawSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: widget.isEmbedded
          ? null
          : BottomNavigationBar(
              currentIndex: isFromAdmin ? 3 : 4, // Wallet is 3 for Admin, More is 4 for Business
              onTap: (index) {
                if (isFromAdmin) {
                  if (index == 3) {
                    // Already on wallet
                  } else if (index == 4) {
                    // Navigate back to Admin Dashboard and trigger drawer
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/admin/dashboard',
                      (route) => false,
                      arguments: 4, // More/Drawer
                    );
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/admin/dashboard',
                      (route) => false,
                      arguments: index,
                    );
                  }
                } else {
                  if (index == 4) {
                    // Already on more
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/business/dashboard',
                      (route) => false,
                      arguments: index,
                    );
                  }
                }
              },
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xff006565),
              unselectedItemColor: Colors.grey,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: isFromAdmin
                  ? const [
                      BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
                      BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Orders"),
                      BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: "Products"),
                      BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
                      BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: "More"),
                    ]
                  : const [
                      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
                      BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Orders"),
                      BottomNavigationBarItem(icon: Icon(Icons.business_center_rounded), label: "Opportunities"),
                      BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
                      BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: "More"),
                    ],
            ),

      body: RefreshIndicator(
        onRefresh: _fetchWithdrawalHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // Stats Cards
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Total Revenue",
                        value: "₹1,28,430",
                        icon: Icons.payments,
                        growth: "+12%",
                        positive: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Total Expenses",
                        value: "₹42,150",
                        icon: Icons.account_balance_wallet,
                        growth: "-5%",
                        positive: false,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Total Income",
                        value: "₹86,280",
                        icon: Icons.trending_up,
                        growth: "",
                        positive: true,
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Pending Dues",
                        value: "₹4,500",
                        icon: Icons.pending_actions,
                        growth: "",
                        positive: false,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "E-Wallet Overview",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  WalletCard(
                    title: "Total Ecash",
                    amount: "₹${_totalEcash.toStringAsFixed(0)}",
                    highlighted: false,
                  ),
                  WalletCard(
                    title: "Available Ecash",
                    amount: "₹${_availableBalance.toStringAsFixed(0)}",
                    highlighted: true,
                  ),
                  WalletCard(
                    title: "Total E-Wallet",
                    amount: "₹${_totalWallet.toStringAsFixed(0)}",
                    highlighted: false,
                  ),
                  WalletCard(
                    title: "Pending Withdrawal",
                    amount: "₹${_pendingBalance.toStringAsFixed(0)}",
                    highlighted: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Transaction History",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 8),
                      Icon(Icons.filter_list),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 16),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xff006565)))
                  : _transactions.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          alignment: Alignment.center,
                          child: const Text("No withdrawal history found.", style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _transactions.length,
                          itemBuilder: (context, idx) {
                            final item = _transactions[idx];
                            final String txId = item['transaction_id']?.toString() ?? item['id']?.toString() ?? "N/A";
                            final String desc = item['description']?.toString() ?? "Withdrawal";
                            final String amount = item['requestedAmount']?.toString() ?? "0";
                            final String receive = item['receiveTo']?.toString() ?? "Wallet";
                            final String status = item['status']?.toString() ?? "Pending";
                            final bool isPending = status.toLowerCase() == 'pending';
                            final bool isApproved = status.toLowerCase() == 'approved' || status.toLowerCase() == 'success';
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isApproved
                                      ? Colors.green.shade50
                                      : (isPending ? Colors.amber.shade50 : Colors.red.shade50),
                                  child: Icon(
                                    isApproved
                                        ? Icons.check
                                        : (isPending ? Icons.hourglass_empty : Icons.close),
                                    color: isApproved
                                        ? Colors.green
                                        : (isPending ? Colors.amber.shade800 : Colors.red),
                                  ),
                                ),
                                title: Text(
                                  "$desc (via $receive)",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text("#$txId • Status: $status"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "-₹$amount",
                                      style: TextStyle(
                                        color: isApproved ? Colors.green : (isPending ? Colors.amber.shade800 : Colors.red),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (isPending) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Cancel Withdrawal"),
                                              content: const Text("Are you sure you want to cancel this withdrawal request?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: const Text("No"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    _cancelWithdrawalRequest(txId);
                                                  },
                                                  child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _fetchWithdrawalHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD4E6E5),
                    foregroundColor: const Color(0xff006565),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Refresh Transactions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawSheet() {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String receiveTo = 'ewallet';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Withdraw Funds",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Funds will be credited to your chosen destination",
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: "₹ ",
                        labelText: "Amount",
                        hintText: "0.00",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: "Description",
                        hintText: "Withdrawal for personal use",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => receiveTo = 'bank'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: receiveTo == 'bank' ? const Color(0xffD4E6E5) : Colors.white,
                                border: Border.all(color: receiveTo == 'bank' ? const Color(0xff006565) : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_balance, color: receiveTo == 'bank' ? const Color(0xff006565) : Colors.grey),
                                  const SizedBox(width: 8),
                                  Text("Bank", style: TextStyle(color: receiveTo == 'bank' ? const Color(0xff006565) : Colors.black87, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => receiveTo = 'upi'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: receiveTo == 'upi' ? const Color(0xffD4E6E5) : Colors.white,
                                border: Border.all(color: receiveTo == 'upi' ? const Color(0xff006565) : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.payments, color: receiveTo == 'upi' ? const Color(0xff006565) : Colors.grey),
                                  const SizedBox(width: 8),
                                  Text("UPI", style: TextStyle(color: receiveTo == 'upi' ? const Color(0xff006565) : Colors.black87, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => receiveTo = 'ewallet'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: receiveTo == 'ewallet' ? const Color(0xffD4E6E5) : Colors.white,
                                border: Border.all(color: receiveTo == 'ewallet' ? const Color(0xff006565) : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.wallet, color: receiveTo == 'ewallet' ? const Color(0xff006565) : Colors.grey),
                                  const SizedBox(width: 8),
                                  Text("Wallet", style: TextStyle(color: receiveTo == 'ewallet' ? const Color(0xff006565) : Colors.black87, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006565),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          final amountText = amountCtrl.text.trim();
                          final descriptionText = descCtrl.text.trim().isEmpty ? "Withdrawal" : descCtrl.text.trim();
                          if (amountText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter amount")),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          _submitWithdrawalRequest(amountText, descriptionText, receiveTo);
                        },
                        child: const Text("Submit Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



class WalletCard extends StatelessWidget {
  final String title;
  final String amount;
  final bool highlighted;

  const WalletCard({
    super.key,
    required this.title,
    required this.amount,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xff006565)
            : const Color(0xffFCF9F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlighted ? Colors.white70 : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlighted ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool success;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              success ? Colors.green.shade50 : Colors.red.shade50,
          child: Icon(
            success ? Icons.arrow_downward : Icons.arrow_upward,
            color: success ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Text(
          amount,
          style: TextStyle(
            color: success ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
