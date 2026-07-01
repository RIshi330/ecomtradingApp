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
  List<dynamic> _withdrawalRequests = [];
  List<dynamic> _allTransactions = [];
  bool _isLoading = false;
  int _txnTabIndex = 0; // 0 = All Transactions, 1 = Withdrawal Requests

  // Dynamic balances — start at 0, loaded from API
  double _availableBalance = 0;
  double _pendingBalance = 0;
  double _totalEcash = 0;
  double _totalWallet = 0;

  // Dynamic stat card values — computed from real transaction data
  double _totalRevenue = 0;
  double _totalExpenses = 0;
  double _totalIncome = 0;
  double _pendingDues = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllWalletData();
  }

  // Fetch all wallet data: balances, all transactions, and withdrawal requests
  Future<void> _fetchAllWalletData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final db = Database();

      // 1. Fetch wallet summary (balances + all transactions) from wallet_API.php
      final walletRes = await db.getData({
        'action': 'get_wallet',
      });

      // 2. Fetch withdrawal requests history
      final withdrawRes = await db.getData({
        'action': 'getWithdrawRequests',
      }, endpoint: 'new_apis/withdrawl_request_api.php');

      if (!mounted) return;

      setState(() {
        // Parse wallet balances and transactions
        if (walletRes != null && (walletRes['success'] == true || walletRes['status'] == 200) && walletRes['data'] != null) {
          final data = walletRes['data'];
          final balances = data['balances'];
          if (balances != null) {
            _totalEcash = double.tryParse(balances['total_ebanking']?.toString() ?? '0') ?? 0;
            _availableBalance = double.tryParse(balances['available_ebanking']?.toString() ?? '0') ?? 0;
            _totalWallet = double.tryParse(balances['ewallet']?.toString() ?? '0') ?? 0;
            _pendingBalance = double.tryParse(balances['pending_requests']?.toString() ?? '0') ?? 0;
          }

          // Parse all transactions
          final txns = data['transactions'];
          if (txns is List) {
            _allTransactions = txns;

            // Compute stat card values from real transaction data
            double credits = 0;
            double debits = 0;
            double pendingAmt = 0;
            for (var t in txns) {
              final nature = t['nature']?.toString().toUpperCase() ?? '';
              final status = t['status']?.toString().toUpperCase() ?? '';
              final amt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0;
              if (nature == 'CREDIT' || nature == 'REFUND') {
                credits += amt;
              } else if (nature == 'DEBIT') {
                debits += amt;
              }
              if (status == 'PENDING') {
                pendingAmt += amt;
              }
            }
            _totalRevenue = credits;
            _totalExpenses = debits;
            _totalIncome = credits - debits;
            _pendingDues = pendingAmt;
          }
        }

        // Parse withdrawal requests
        if (withdrawRes['success'] == true || withdrawRes['status'] == 200 || withdrawRes.containsKey('data')) {
          _withdrawalRequests = withdrawRes['data'] ?? [];

          // Override pending from withdrawal requests if available
          double pendingSum = 0.0;
          for (var item in _withdrawalRequests) {
            final status = item['status_label']?.toString().toLowerCase() ?? item['status']?.toString().toLowerCase() ?? '';
            if (status == 'pending' || status == '0') {
              final amt = double.tryParse(item['requested_amount']?.toString() ?? item['requestedAmount']?.toString() ?? '0') ?? 0.0;
              pendingSum += amt;
            }
          }
          if (pendingSum > 0) {
            _pendingDues = pendingSum;
          }
        }
      });
    } catch (e) {
      print("Error fetching wallet data: $e");
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
        _fetchAllWalletData();
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
        _fetchAllWalletData();
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
            onPressed: _fetchAllWalletData,
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
        onRefresh: _fetchAllWalletData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // Stats Cards — computed from real transaction data
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Total Revenue",
                        value: "₹${_formatCurrency(_totalRevenue)}",
                        icon: Icons.payments,
                        growth: "",
                        positive: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Total Expenses",
                        value: "₹${_formatCurrency(_totalExpenses)}",
                        icon: Icons.account_balance_wallet,
                        growth: "",
                        positive: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Net Income",
                        value: "₹${_formatCurrency(_totalIncome)}",
                        icon: Icons.trending_up,
                        growth: "",
                        positive: _totalIncome >= 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: StatCard(
                        title: "Pending Dues",
                        value: "₹${_formatCurrency(_pendingDues)}",
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

              // Transaction tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _txnTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _txnTabIndex == 0 ? const Color(0xff006565) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          "All Transactions",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _txnTabIndex == 0 ? const Color(0xff006565) : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _txnTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _txnTabIndex == 1 ? const Color(0xff006565) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          "Withdrawal Requests",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _txnTabIndex == 1 ? const Color(0xff006565) : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tab content
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xff006565)))
                  : _txnTabIndex == 0
                      ? _buildAllTransactionsList()
                      : _buildWithdrawalRequestsList(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _fetchAllWalletData,
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

  // Format currency with Indian comma style
  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    String str = amount.abs().toStringAsFixed(0);
    if (str.length <= 3) return isNegative ? '-$str' : str;
    String lastThree = str.substring(str.length - 3);
    String other = str.substring(0, str.length - 3);
    String result = "";
    int count = 0;
    for (int i = other.length - 1; i >= 0; i--) {
      result = other[i] + result;
      count++;
      if (count == 2 && i > 0) {
        result = ",$result";
        count = 0;
      }
    }
    final formatted = "$result,$lastThree";
    return isNegative ? '-$formatted' : formatted;
  }

  // Build the "All Transactions" list from wallet_API.php data
  Widget _buildAllTransactionsList() {
    if (_allTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: const Text("No transactions found.", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _allTransactions.length,
      itemBuilder: (context, idx) {
        final item = _allTransactions[idx];
        final String txnId = item['id']?.toString() ?? 'N/A';
        final String desc = item['description']?.toString() ?? 'Wallet Transaction';
        final String nature = item['nature']?.toString().toUpperCase() ?? '';
        final String status = item['status']?.toString() ?? '';
        final double amt = double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
        final String transactFrom = item['transact_from']?.toString() ?? '';
        final String dateStr = item['date']?.toString() ?? '';
        final bool isCredit = nature == 'CREDIT' || nature == 'REFUND';
        final bool isPending = status.toUpperCase() == 'PENDING';

        String sourceLabel;
        if (transactFrom == 'ebanking') {
          sourceLabel = 'E-Banking';
        } else if (transactFrom == 'ewallet' || transactFrom == 'EWALLET') {
          sourceLabel = 'E-Wallet';
        } else if (transactFrom == 'razorpay') {
          sourceLabel = 'Razorpay';
        } else {
          sourceLabel = transactFrom;
        }

        // Format date
        String formattedDate = '';
        if (dateStr.isNotEmpty) {
          final dt = DateTime.tryParse(dateStr);
          if (dt != null) {
            formattedDate = '${dt.day}/${dt.month}/${dt.year}';
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCredit ? Colors.green.shade50 : (isPending ? Colors.amber.shade50 : Colors.red.shade50),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : (isPending ? Colors.amber.shade800 : Colors.red),
              ),
            ),
            title: Text(
              desc,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '#TXN$txnId • $sourceLabel • $formattedDate',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}₹${_formatCurrency(amt)}',
                  style: TextStyle(
                    color: isCredit ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: isPending ? Colors.amber.shade800 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build the "Withdrawal Requests" list
  Widget _buildWithdrawalRequestsList() {
    if (_withdrawalRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: const Text("No withdrawal requests found.", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _withdrawalRequests.length,
      itemBuilder: (context, idx) {
        final item = _withdrawalRequests[idx];
        final String txId = item['transaction_id']?.toString() ?? item['id']?.toString() ?? "N/A";
        final String desc = item['description']?.toString() ?? "Withdrawal";
        final String amount = item['requested_amount']?.toString() ?? item['requestedAmount']?.toString() ?? "0";
        final String statusLabel = item['status_label']?.toString() ?? 'Pending';
        final bool isPending = statusLabel.toLowerCase() == 'pending';
        final bool isApproved = statusLabel.toLowerCase() == 'approved' || statusLabel.toLowerCase() == 'success';
        final String dateStr = item['requested_date']?.toString() ?? '';

        String formattedDate = '';
        if (dateStr.isNotEmpty) {
          final dt = DateTime.tryParse(dateStr);
          if (dt != null) {
            formattedDate = '${dt.day}/${dt.month}/${dt.year}';
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              desc,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('#$txId • $statusLabel • $formattedDate', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-₹$amount',
                  style: TextStyle(
                    color: isApproved ? Colors.green : (isPending ? Colors.amber.shade800 : Colors.red),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
