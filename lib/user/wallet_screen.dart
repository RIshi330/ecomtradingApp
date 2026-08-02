import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../core/theme/app_theme.dart';

/* ================= MODEL ================= */

class WalletTransaction {
  final int id;
  final String description;
  final DateTime date;
  final double amount;
  final String nature;
  final String status;
  final String transactFrom;

  WalletTransaction({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    required this.nature,
    required this.status,
    required this.transactFrom,
  });

  bool get isCredit => nature == 'CREDIT' || nature == 'REFUND';

  IconData get icon {
    if (nature == 'REQUEST') {
      return Icons.account_balance;
    } else if (transactFrom == 'ewallet') {
      return Icons.payments;
    } else {
      return Icons.shopping_bag;
    }
  }
}

/* ================= SCREEN ================= */

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final Database db = Database();

  bool loading = true;
  double totalEcash = 0;
  double availableEcash = 0;
  double totalEwallet = 0;
  double pending = 0;
  List<WalletTransaction> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  /* ================= LOAD WALLET ================= */

  Future<void> _loadWallet() async {
    setState(() => loading = true);

    final res = await db.getData({
      "action": "get_wallet",
    });

    if (res['status'] == 200 && res['data'] != null) {
      final balances = res['data']['balances'];
      final txns = res['data']['transactions'] as List? ?? [];

      setState(() {
        totalEwallet = double.tryParse(balances['ewallet'].toString()) ?? 0;
        availableEcash = double.tryParse(balances['available_ebanking'].toString()) ?? 0;
        totalEcash = balances.containsKey('total_ebanking')
            ? (double.tryParse(balances['total_ebanking'].toString()) ?? 0)
            : availableEcash;
        pending = balances.containsKey('pending_requests')
            ? (double.tryParse(balances['pending_requests'].toString()) ?? 0)
            : 0;

        transactions = txns.map((t) {
          return WalletTransaction(
            id: int.tryParse(t['id'].toString()) ?? 0,
            description: t['description'] ?? '',
            date: DateTime.tryParse(t['date'] ?? '') ?? DateTime.now(),
            amount: double.tryParse(t['amount'].toString()) ?? 0,
            nature: t['nature'] ?? '',
            status: t['status'] ?? '',
            transactFrom: t['transact_from'] ?? '',
          );
        }).toList();

        loading = false;
      });
    } else {
      setState(() => loading = false);
      _showSnack("Failed to load wallet");
    }
  }

  /* ================= ADD MONEY ================= */

  Future<void> _addMoney(String amount) async {
    final res = await db.getData({
      "action": "add_money",
      "amount": amount,
      "description": "Wallet top-up",
      "addTo": "ewallet",
    });

    if (res['status'] == 200) {
      _showSnack("Money added successfully");
      _loadWallet();
    } else {
      _showSnack(res['message'] ?? "Failed to add money");
    }
  }

  /* ================= WITHDRAW ================= */

  Future<void> _withdraw(String amount, String description) async {
    final res = await db.getData({
      "action": "withdraw_request",
      "amount": amount,
      "description": description,
      "receiveTo": "bank",
    });

    if (res['status'] == 200) {
      _showSnack("Withdrawal request submitted");
      _loadWallet();
    } else {
      _showSnack(res['message'] ?? "Withdrawal failed");
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff006565),
          ),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          "Financial Overview",
          style: TextStyle(
            color: Color(0xff006565),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xff006565),
            ),
            onSelected: (value) {
              if (value == 'add') {
                _openAddMoneySheet();
              } else if (value == 'withdraw') {
                _showWithdrawalModal(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Color(0xff006565)),
                    SizedBox(width: 8),
                    Text('Add Money'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'withdraw',
                child: Row(
                  children: [
                    Icon(Icons.remove_circle_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Withdrawal Request'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWallet,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    /// BALANCE CARDS GRID
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          WalletBalanceCard(
                            title: "TOTAL ECASH",
                            amount: "₹ ${_formatCurrency(totalEcash)}",
                            color: const Color(0xff008080),
                          ),
                          WalletBalanceCard(
                            title: "AVAILABLE ECASH",
                            amount: "₹ ${_formatCurrency(availableEcash)}",
                            color: const Color(0xff006565),
                          ),
                          WalletBalanceCard(
                            title: "TOTAL EWALLET",
                            amount: "₹ ${_formatCurrency(totalEwallet)}",
                            color: Colors.white,
                          ),
                          WalletBalanceCard(
                            title: "PENDING",
                            amount: "₹ ${_formatCurrency(pending)}",
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Recent Transactions",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Latest financial activity",
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("View All"),
                          )
                        ],
                      ),
                    ),
                    if (transactions.isEmpty)
                      const EmptyTransactionView()
                    else
                      ListView.builder(
                        itemCount: transactions.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return TransactionCard(
                            transaction: transactions[index],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff006565),
        onPressed: () {
          _showWithdrawalModal(context);
        },
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: buildWalletBottomNav(context),
    );
  }

  /* ================= HELPERS ================= */

  String _formatCurrency(double amount) {
    String str = amount.toStringAsFixed(0);
    if (str.length <= 3) return str;
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
    return "$result,$lastThree";
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /* ================= BOTTOM SHEETS ================= */

  void _openAddMoneySheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Money",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: "₹ ",
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006565),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                Navigator.pop(context);
                _addMoney(controller.text);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalModal(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Withdrawal Request",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff006565),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: "₹ ",
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter amount";
                    }
                    final amt = double.tryParse(value);
                    if (amt == null) {
                      return "Enter valid number";
                    }
                    if (amt > availableEcash) {
                      return "Insufficient available balance";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Available: ₹ ${_formatCurrency(availableEcash)}",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Withdrawal Note",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter withdrawal description";
                    }
                    if (value.length < 5) {
                      return "Description too short";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006565),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            _withdraw(amountController.text, noteController.text);
                          }
                        },
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildWalletBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xff006565),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 3) {
          Navigator.pushReplacementNamed(context, '/user/profile');
        } else if (index == 1) {
          // Already on wallet
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/shell', (route) => false);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: "Shop",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: "Wallet",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}

class WalletBalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const WalletBalanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool darkCard = color != Colors.white;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: color == Colors.white
            ? Border.all(
                color: Colors.grey.shade300,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: darkCard ? Colors.white70 : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkCard ? Colors.white : const Color(0xff006565),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.account_balance_wallet,
              size: 24,
              color: darkCard ? Colors.white24 : Colors.teal.withOpacity(0.3),
            ),
          )
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final amountText = "${transaction.isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}";
    final formattedDate = _formatDate(transaction.date);
    final title = transaction.description.isEmpty ? "Wallet Transaction" : transaction.description;
    final txnId = "TXN${transaction.id}";
    final subtitle = transaction.transactFrom == 'ewallet' ? "E-Wallet Transaction" : "E-Banking Transaction";
    final displayStatus = transaction.status.isNotEmpty
        ? "${transaction.status[0].toUpperCase()}${transaction.status.substring(1).toLowerCase()}"
        : "";

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: transaction.isCredit ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.isCredit ? Colors.green : Colors.red,
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
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        txnId,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amountText,
                      style: TextStyle(
                        color: transaction.isCredit ? Colors.green : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      displayStatus,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class EmptyTransactionView extends StatelessWidget {
  const EmptyTransactionView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Transactions Found",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your financial activity will appear here.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    "${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}";



















/*import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/database.dart';
import '../../app_constants.dart';

/* ================= MODEL ================= */

class WalletTransaction {
  final String title;
  final String txnId;
  final DateTime date;
  final double amount;
  final bool isCredit;

  WalletTransaction({
    required this.title,
    required this.txnId,
    required this.date,
    required this.amount,
    required this.isCredit,
  });
}

/* ================= SCREEN ================= */

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final Database db = Database();

  bool loading = true;
  double eWalletBalance = 0;
  double eBankingBalance = 0;
  List<WalletTransaction> transactions = [];

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  /* ================= FETCH WALLET ================= */

  Future<void> loadWallet() async {
    final res = await db.getData({
      "module": "payment",
      "submodule": "utils",
      "functions":
          "ewallet,ebanking,income,expenditure,pending_request,transaction_history",
    });

    print("WALLET RESPONSE => $res");

    if (res['status'] == 200 && res['data'] != null) {
      final data = res['data'];

      setState(() {
        eWalletBalance = double.tryParse(
                data['ewallet']?['available']?.toString() ?? "0") ??
            0;

        eBankingBalance = double.tryParse(
                data['ebanking']?['available']?.toString() ?? "0") ??
            0;

        final historyWrapper = data['transaction_history'];

        if (historyWrapper != null &&
            historyWrapper['status'] == 200 &&
            historyWrapper['data'] is List) {
          transactions =
              (historyWrapper['data'] as List).map((t) {
            return WalletTransaction(
              title: t['description'] ?? 'Wallet Transaction',
              txnId: t['id']?.toString() ?? '-',
              date: DateTime.tryParse(t['date'] ?? '') ??
                  DateTime.now(),
              amount: double.tryParse(
                      t['amount']?.toString() ?? "0") ??
                  0,
              isCredit: t['nature'] == 'CREDIT',
            );
          }).toList();
        } else {
          transactions = [];
        }

        loading = false;
      });
    } else {
      loading = false;
    }
  }

  /* ================= GENERATE PAYMENT LINK ================= */

  Future<void> generatePaymentLink(String amount) async {
    final res = await db.getData({
      "module": "payment",
      "submodule": "utils",
      "functions": "generate_link",
      "marketplace": marketplaceId,
      "service_charge": amount,
      "item_id": "1",
      "client": "1",
    });

    print("GENERATE LINK RESPONSE => $res");

    if (res['status'] == 200 && res.containsKey('payment_link')) {
      await launchUrl(
        Uri.parse(res['payment_link']),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: const Color(0xFF014D4E),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "add",
            backgroundColor: const Color(0xFF014D4E),
            onPressed: () => _addMoney(context),
            icon: const Icon(Icons.add),
            label: const Text("Add Money"),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "withdraw",
            backgroundColor: Colors.orange,
            onPressed: () => _withdraw(context),
            icon: const Icon(Icons.account_balance),
            label: const Text("Withdraw"),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadWallet,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _walletSummary(),
              const SizedBox(height: 24),
              const Text(
                "Transaction History",
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (transactions.isEmpty)
                const Center(child: Text("No transactions found")),
              ...transactions.map(_transactionCard).toList(),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= SUMMARY ================= */

  Widget _walletSummary() => SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _summaryCard(
              "e-Wallet Available",
              "₹${eWalletBalance.toStringAsFixed(0)}",
              Icons.account_balance_wallet,
            ),
            _summaryCard(
              "e-Banking Available",
              "₹${eBankingBalance.toStringAsFixed(0)}",
              Icons.account_balance,
            ),
          ],
        ),
      );

  Widget _summaryCard(String title, String value, IconData icon) =>
      Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.teal.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.teal),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );

  /* ================= TRANSACTION CARD ================= */

  Widget _transactionCard(WalletTransaction t) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                t.isCredit ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              t.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: t.isCredit ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            t.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              "ID: ${t.txnId}\n${_formatDate(t.date)}"),
          trailing: Text(
            "${t.isCredit ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: t.isCredit ? Colors.green : Colors.red,
            ),
          ),
          isThreeLine: true,
        ),
      );

  String _formatDate(DateTime d) =>
      "${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}";

  /* ================= ADD MONEY ================= */

  void _addMoney(BuildContext context) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Money",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Amount"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await generatePaymentLink(
                    amountController.text);
              },
              child: const Text("Proceed to Pay"),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= WITHDRAW (BACKEND-DRIVEN) ================= */

  void _withdraw(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Withdraw Money",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Amount"),
            ),
            TextField(
              controller: descriptionController,
              decoration:
                  const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final res = await db.getData({
                  "module": "payment",
                  "submodule": "utils",
                  "functions": "withdraw_request",
                  "amount": amountController.text,
                  "description":
                      descriptionController.text,
                  "transfer_to": "1",
                });

                print("WITHDRAW RESPONSE => $res");

                final withdraw =
                    res['data']?['withdraw_request'];

                Navigator.pop(context);

                if (withdraw != null &&
                    withdraw['status'] == 200) {
                  loadWallet();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Withdrawal request submitted")),
                  );
                } else {
                  final error =
                      withdraw?['error'] ??
                          "Withdrawal failed";
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              },
              child: const Text("Submit Withdrawal"),
            ),
          ],
        ),
      ),
    );
  }
}
*/