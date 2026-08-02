import 'package:flutter/material.dart';

class FinancialOverviewScreen extends StatefulWidget {
  final VoidCallback onMenuPressed;

  const FinancialOverviewScreen({super.key, required this.onMenuPressed});

  @override
  State<FinancialOverviewScreen> createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  int _selectedCardIndex = 0;

  // Harmonized account card gradients anchored around the main Teal theme
  final List<Map<String, dynamic>> _accounts = [
    {
      'title': 'eCash Balance',
      'amount': '₹ 4,85,290.00',
      'subtitle': 'Total Balance: ₹ 5,12,000.00',
      'gradient': [
        const Color(0xFF004D40), // Deep Teal
        const Color(0xFF00796B), // Primary Dark Teal
        const Color(0xFF009688), // Teal Accent
      ],
      'accountNo': '••• 8291',
    },
    {
      'title': 'eWallet Account',
      'amount': '₹ 12,450.00',
      'subtitle': 'Instant Spend Active',
      'gradient': [
        const Color(0xFF005B52), // Deep Slate Teal
        const Color(0xFF00897B), // Rich Teal
        const Color(0xFF26A69A), // Soft Light Teal
      ],
      'accountNo': '••• 4402',
    },
    {
      'title': 'Pending Withdrawals',
      'amount': '₹ 45,000.00',
      'subtitle': '2 requests processing',
      'gradient': [
        const Color(0xFF1A535C), // Deep Steel Teal
        const Color(0xFF2E7270), // Soft Teal-Grey
        const Color(0xFF4ECDC4), // Fresh Aqua Accent
      ],
      'accountNo': 'HDFC Bank',
    },
  ];

  void _showWithdrawalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GPayWithdrawalBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), // Soft neutral teal tint
      appBar: AppBar(
        backgroundColor: Colors.teal, // Unchanged as requested
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: widget.onMenuPressed,
        ),
        title: const Text(
          'Financial Overview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Harmonized Hero Account Cards
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: _accounts.length,
                controller: PageController(viewportFraction: 0.94),
                onPageChanged: (index) {
                  setState(() => _selectedCardIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = _accounts[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item['gradient'],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: (item['gradient'][1] as Color).withOpacity(0.30),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['accountNo'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['amount'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['subtitle'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Indicator Dots matching current card theme
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _accounts.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _selectedCardIndex == index ? 22 : 6,
                  decoration: BoxDecoration(
                    color: _selectedCardIndex == index
                        ? Colors.teal
                        : Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Harmonized Light Teal Quick Actions Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorfulActionButton(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Withdraw',
                  bgColor: const Color(0xFFE0F2F1), // Soft Light Teal
                  iconColor: const Color(0xFF00695C), // Dark Teal
                  onTap: () => _showWithdrawalModal(context),
                ),
                _buildColorfulActionButton(
                  icon: Icons.add_rounded,
                  label: 'Top-up',
                  bgColor: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00695C),
                  onTap: () {},
                ),
                _buildColorfulActionButton(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan QR',
                  bgColor: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00695C),
                  onTap: () {},
                ),
                _buildColorfulActionButton(
                  icon: Icons.insights_rounded,
                  label: 'Analytics',
                  bgColor: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00695C),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F292E),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal.shade700,
                  ),
                  child: const Text(
                    'See All',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Harmonized Transactions Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: const [
                  GPayTransactionTile(
                    title: 'Serene Boutique',
                    subtitle: 'Merchant Sale • TXN88294',
                    date: 'Today, 2:20 PM',
                    amount: '+₹12,400.00',
                    isCredit: true,
                    icon: Icons.shopping_bag_outlined,
                    iconBg: Color(0xFFE0F2F1),
                    iconColor: Color(0xFF00695C),
                  ),
                  Divider(height: 1, indent: 68, endIndent: 20),
                  GPayTransactionTile(
                    title: 'HDFC Bank ****8221',
                    subtitle: 'Withdrawal • TXN88293',
                    date: 'Yesterday, 9:15 AM',
                    amount: '-₹25,000.00',
                    isCredit: false,
                    isPending: true,
                    icon: Icons.account_balance_rounded,
                    iconBg: Color(0xFFECEFF1), // Light Neutral Grey-Teal
                    iconColor: Color(0xFF455A64),
                  ),
                  Divider(height: 1, indent: 68, endIndent: 20),
                  GPayTransactionTile(
                    title: 'UPI Top-Up',
                    subtitle: 'Wallet Credit • TXN88292',
                    date: '21 Oct, 6:45 PM',
                    amount: '+₹5,000.00',
                    isCredit: true,
                    icon: Icons.account_balance_wallet_rounded,
                    iconBg: Color(0xFFE0F2F1),
                    iconColor: Color(0xFF00695C),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWithdrawalModal(context),
        backgroundColor: Colors.teal,
        elevation: 3,
        icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
        label: const Text(
          'Withdraw',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildColorfulActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37474F),
          ),
        ),
      ],
    );
  }
}

// Transaction Tile Component
class GPayTransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final bool isCredit;
  final bool isPending;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const GPayTransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.isPending = false,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isCredit
                      ? const Color(0xFF00796B) // Teal Dark Green for credit
                      : const Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (isPending)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PROCESSING',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                      ),
                    ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Payment/Withdrawal Bottom Sheet Modal
class GPayWithdrawalBottomSheet extends StatefulWidget {
  const GPayWithdrawalBottomSheet({super.key});

  @override
  State<GPayWithdrawalBottomSheet> createState() =>
      _GPayWithdrawalBottomSheetState();
}

class _GPayWithdrawalBottomSheetState
    extends State<GPayWithdrawalBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transfer to Bank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1), // Soft Teal Tint
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HDFC Bank Primary',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      'Account ending in •••• 8221',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _amountController,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F1F),
            ),
            decoration: const InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1F1F),
              ),
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
          Text(
            'Available balance: ₹ 4,85,290.00',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickChip('₹ 1,000'),
              const SizedBox(width: 8),
              _buildQuickChip('₹ 5,000'),
              const SizedBox(width: 8),
              _buildQuickChip('Max Balance'),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.teal.shade800,
                    content: const Text('Withdrawal request submitted!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Proceed to Transfer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade900),
      ),
      backgroundColor: const Color(0xFFE0F2F1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        if (label == 'Max Balance') {
          _amountController.text = '485290.00';
        } else {
          _amountController.text =
              label.replaceAll('₹ ', '').replaceAll(',', '');
        }
      },
    );
  }
}