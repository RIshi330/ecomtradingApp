import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';

class FinancialCommandCenterScreen extends StatefulWidget {
  final bool isEmbedded;
  const FinancialCommandCenterScreen({super.key, this.isEmbedded = false});

  @override
  State<FinancialCommandCenterScreen> createState() => _FinancialCommandCenterScreenState();
}

class _FinancialCommandCenterScreenState extends State<FinancialCommandCenterScreen> {
  // Styling Theme Constants (matching the app and HTML specs)
  static const Color primaryTeal = Color(0xFF006565);
  static const Color secondaryTeal = Color(0xFF296767);
  static const Color darkTeal = Color(0xFF001F1F);
  static const Color containerTeal = Color(0xFFE3FFFE);
  static const Color bgLight = Color(0xFFF9F9F9);
  static const Color surfaceWhite = Colors.white;
  static const Color borderTeal = Color(0xFFBDC9C8);
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textLight = Color(0xFF3E4949);
  static const Color statusNegotiation = Color(0xFFB45309);
  static const Color errorColor = Color(0xFFBA1A1A);

  String _selectedTrendRange = "Last 30 Days";

  // Mock list of pending withdrawal requests
  final List<Map<String, String>> _pendingWithdrawals = [
    {
      "id": "WR-9921",
      "vendor": "Luxe Logistics Group",
      "vendorId": "LOG-882",
      "amount": "12,450.00",
      "method": "ACH TRANSFER",
      "requestedTime": "Requested 2h ago"
    },
    {
      "id": "WR-9918",
      "vendor": "Vertex Media Agency",
      "vendorId": "VM-992",
      "amount": "8,200.00",
      "method": "WIRE TRANSFER",
      "requestedTime": "Requested 5h ago"
    }
  ];

  // Mock transaction history ledger
  final List<Map<String, dynamic>> _transactions = [
    {
      "type": "Credit",
      "txid": "TXN-001284",
      "method": "Stripe Connect",
      "amount": r"+$2,400.00",
      "dateTime": "Oct 24, 2023 14:22",
      "status": "COMPLETED",
      "comments": "Commission Settlement"
    },
    {
      "type": "Debit",
      "txid": "TXN-001282",
      "method": "Wire Transfer",
      "amount": r"-$10,000.00",
      "dateTime": "Oct 24, 2023 09:15",
      "status": "COMPLETED",
      "comments": "Wire Withdrawal #WR-9904"
    },
    {
      "type": "Credit",
      "txid": "TXN-001281",
      "method": "Card",
      "amount": r"+$850.25",
      "dateTime": "Oct 23, 2023 18:45",
      "status": "PENDING",
      "comments": "Platform Service Fee"
    },
    {
      "type": "Debit",
      "txid": "TXN-001279",
      "method": "ACH Transfer",
      "amount": r"-$1,200.00",
      "dateTime": "Oct 23, 2023 11:30",
      "status": "FAILED",
      "comments": "Insufficient Account Funds"
    }
  ];

  void _triggerAction(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openApproveModal(Map<String, String> request) {
    final txidCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);
    final timeCtrl = TextEditingController(
      text: "${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}",
    );
    String selectedMethod = "ACH";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: primaryTeal,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Approve Withdrawal",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Content Form
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Request Summary Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: containerTeal,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryTeal.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "REQUEST SUMMARY",
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              request['vendor'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "REFERENCE: ${request['id']}",
                                              style: const TextStyle(fontSize: 10, color: textLight, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "₹${request['amount']}",
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primaryTeal),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Transaction ID Input
                            const Text(
                              "TRANSACTION ID (TXID)",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: txidCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: "e.g., TXN-998273",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Date & Time Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "SETTLEMENT DATE",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight),
                                      ),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: dateCtrl,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "TIME",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight),
                                      ),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: timeCtrl,
                                        style: const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Payment Channel Dropdown
                            const Text(
                              "PAYMENT CHANNEL",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedMethod,
                              style: const TextStyle(fontSize: 13, color: textDark),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: const [
                                DropdownMenuItem<String>(value: "ACH", child: Text("ACH Transfer")),
                                DropdownMenuItem<String>(value: "WIRE", child: Text("Wire Transfer")),
                                DropdownMenuItem<String>(value: "STRIPE", child: Text("Stripe Connect")),
                                DropdownMenuItem<String>(value: "MANUAL", child: Text("Manual Settlement")),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  selectedMethod = val;
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            // Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("CANCEL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryTeal,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      if (txidCtrl.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Please fill in Transaction ID")),
                                        );
                                        return;
                                      }
                                      Navigator.pop(context);
                                      _approveRequest(request);
                                    },
                                    child: const Text("CONFIRM RELEASE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _approveRequest(Map<String, String> request) {
    setState(() {
      _pendingWithdrawals.removeWhere((item) => item['id'] == request['id']);
      // Add record dynamically to Transaction ledger simulation
      _transactions.insert(0, {
        "type": "Debit",
        "txid": "TXN-${request['id']?.split('-').last ?? '8841'}",
        "method": request['method'] ?? 'ACH Transfer',
        "amount": "-₹${request['amount']}",
        "dateTime": "Just Now",
        "status": "COMPLETED",
        "comments": "Released for ${request['vendor']}"
      });
    });

    _triggerAction("Funds released for ${request['vendor']} (₹${request['amount']})");
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 850;
    final bool isMobile = screenWidth < 700;

    Widget mainContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Global Ledger",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1.5),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Financial Command Center",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryTeal),
                              foregroundColor: primaryTeal,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              minimumSize: const Size(0, 36),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _triggerAction("Ledger Export Started"),
                            child: const Text("Export Ledger", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              minimumSize: const Size(0, 36),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _triggerAction("Bulk Payout Initiated"),
                            child: const Text("Bulk Payout", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Global Ledger",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1.5),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Financial Command Center",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryTeal),
                            foregroundColor: primaryTeal,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _triggerAction("Ledger Export Started"),
                          child: const Text("Export Ledger", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _triggerAction("Bulk Payout Initiated"),
                          child: const Text("Bulk Payout", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
          const SizedBox(height: 24),

          // 1. Stats Row (Horizontal Scroll Slider)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildStatCard("GROSS REVENUE", "₹1,240,500.00", "+18.2% vs prev. month", primaryTeal, Icons.trending_up),
                _buildStatCard("NET REVENUES", "₹982,300.00", "79.1% Gross Margin", secondaryTeal, Icons.show_chart),
                _buildStatCard("COMMISSIONS & PAYOUTS", "₹124,200.00", "Last processed: 12h ago", textLight, Icons.account_tree_rounded),
                _buildStatCard("PENDING WITHDRAWALS", "₹142,500.00", "24 Action Items", statusNegotiation, Icons.pending_actions_rounded),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Interactive Charts Section (Responsive Row/Column)
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSalesTrendsCard()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildOrderDistributionCard()),
                  ],
                )
              : Column(
                  children: [
                    _buildSalesTrendsCard(),
                    const SizedBox(height: 20),
                    _buildOrderDistributionCard(),
                  ],
                ),
          const SizedBox(height: 24),

          // 3. Withdrawal Requests Manager
          _buildWithdrawalRequestsSection(),
          const SizedBox(height: 24),

          // 4. Transaction History Ledger
          _buildTransactionHistoryLedger(),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return mainContent;
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text("Command Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: darkTeal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: mainContent),
    );
  }

  Widget _buildStatCard(String title, String val, String sub, Color accentColor, IconData icon) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      child: StatCard(
        title: title,
        value: val,
        borderColor: borderTeal.withOpacity(0.6),
        leftIndicatorColor: accentColor,
        footer: Row(
          children: [
            Icon(icon, color: accentColor, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                sub,
                style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTrendsCard() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTeal),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Sales Trends",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedTrendRange,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 12, color: textDark, fontWeight: FontWeight.w600),
                icon: const Icon(Icons.arrow_drop_down, color: textLight),
                items: const [
                  DropdownMenuItem<String>(value: "Last 30 Days", child: Text("Last 30 Days")),
                  DropdownMenuItem<String>(value: "Last Quarter", child: Text("Last Quarter")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedTrendRange = val;
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: LineChartPainter(primaryTeal),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Week 1", style: TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
              Text("Week 2", style: TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
              Text("Week 3", style: TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
              Text("Week 4", style: TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOrderDistributionCard() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTeal),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Type Distribution",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 360;
                final double size = isNarrow ? 130.0 : (constraints.maxHeight * 0.55);

                if (isNarrow) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: size,
                            height: size,
                            child: CustomPaint(
                              painter: DonutChartPainter(
                                slices: [
                                  SliceData(0.65, primaryTeal),
                                  SliceData(0.20, secondaryTeal),
                                  SliceData(0.15, borderTeal),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: size * 0.7,
                            height: size * 0.7,
                            decoration: const BoxDecoration(color: surfaceWhite, shape: BoxShape.circle),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("₹1.2M", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                                Text("TOTAL VAL", style: TextStyle(fontSize: 7, color: textLight, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow("Digital Services", "65%", primaryTeal),
                          const SizedBox(height: 8),
                          _buildLegendRow("Physical Goods", "20%", secondaryTeal),
                          const SizedBox(height: 8),
                          _buildLegendRow("Memberships", "15%", borderTeal),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: size,
                          height: size,
                          child: CustomPaint(
                            painter: DonutChartPainter(
                              slices: [
                                SliceData(0.65, primaryTeal),
                                SliceData(0.20, secondaryTeal),
                                SliceData(0.15, borderTeal),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: size * 0.7,
                          height: size * 0.7,
                          decoration: const BoxDecoration(color: surfaceWhite, shape: BoxShape.circle),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("₹1.2M", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                              Text("TOTAL VAL", style: TextStyle(fontSize: 8, color: textLight, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow("Digital Services", "65%", primaryTeal),
                          const SizedBox(height: 12),
                          _buildLegendRow("Physical Goods", "20%", secondaryTeal),
                          const SizedBox(height: 12),
                          _buildLegendRow("Memberships", "15%", borderTeal),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, String pct, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(pct, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
      ],
    );
  }

  Widget _buildWithdrawalRequestsSection() {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Withdrawal Requests",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusNegotiation.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusNegotiation.withOpacity(0.2)),
                        ),
                        child: Text(
                          "${_pendingWithdrawals.length} PENDING",
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusNegotiation),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.history_rounded, size: 14, color: primaryTeal),
                      label: const Text("VIEW ARCHIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 0.5)),
                      onPressed: () => _triggerAction("Loading Audit Logs..."),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Withdrawal Requests",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusNegotiation.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusNegotiation.withOpacity(0.2)),
                        ),
                        child: Text(
                          "${_pendingWithdrawals.length} PENDING",
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusNegotiation),
                        ),
                      )
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.history_rounded, size: 14, color: primaryTeal),
                    label: const Text("VIEW ARCHIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 0.5)),
                    onPressed: () => _triggerAction("Loading Audit Logs..."),
                  )
                ],
              ),
        const SizedBox(height: 12),
        if (_pendingWithdrawals.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceWhite,
              border: Border.all(color: borderTeal),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "No pending requests remaining for this period.",
                style: TextStyle(fontSize: 13, color: textLight, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          Column(
            children: [
              ..._pendingWithdrawals.map((req) {
                final bool isMobileItem = MediaQuery.of(context).size.width < 600;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceWhite,
                    border: Border.all(color: borderTeal),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: isMobileItem
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: bgLight,
                                    border: Border.all(color: borderTeal.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    req['method'] == 'WIRE TRANSFER' ? Icons.payment_rounded : Icons.account_balance_rounded,
                                    color: primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req['vendor'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "ID: ${req['id']} • ${req['method']} • VENDOR: ${req['vendorId']}",
                                        style: const TextStyle(fontSize: 10, color: textLight),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "₹${req['amount']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                                    ),
                                    Text(
                                      req['requestedTime'] ?? '',
                                      style: const TextStyle(fontSize: 9, color: statusNegotiation, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryTeal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: () => _openApproveModal(req),
                                  child: const Text("APPROVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            )
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: bgLight,
                                      border: Border.all(color: borderTeal.withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      req['method'] == 'WIRE TRANSFER' ? Icons.payment_rounded : Icons.account_balance_rounded,
                                      color: primaryTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          req['vendor'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "ID: ${req['id']} • ${req['method']} • VENDOR: ${req['vendorId']}",
                                          style: const TextStyle(fontSize: 10, color: textLight),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${req['amount']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                                    ),
                                    Text(
                                      req['requestedTime'] ?? '',
                                      style: const TextStyle(fontSize: 9, color: statusNegotiation, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryTeal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: () => _openApproveModal(req),
                                  child: const Text("APPROVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            )
                          ],
                        ),
                );
              }),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: outlineVariantStyle, style: BorderStyle.solid),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _triggerAction("Searching for more records..."),
                  child: const Text(
                    "LOAD MORE PENDING REQUESTS",
                    style: TextStyle(fontSize: 10, color: textLight, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }

  static const Color outlineVariantStyle = Color(0xFFBDC9C8);

  Widget _buildTransactionHistoryLedger() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Transaction History",
                style: TextStyle(fontSize: isMobile ? 15 : 16, fontWeight: FontWeight.bold, color: textDark),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_alt_rounded, color: textLight, size: 20),
                  onPressed: () => _triggerAction("Filter Panel Opened"),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: textLight, size: 20),
                  onPressed: () => _triggerAction("Search Interface Ready"),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: surfaceWhite,
            border: Border.all(color: borderTeal),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              // Transactions List matching Table Specs
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, idx) {
                  final tx = _transactions[idx];
                  final bool isCredit = tx['type'] == 'Credit';
                  final bool isFailed = tx['status'] == 'FAILED';
                  final bool isPending = tx['status'] == 'PENDING';

                  Color statusColor = primaryTeal;
                  if (isFailed) statusColor = errorColor;
                  if (isPending) statusColor = statusNegotiation;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: borderTeal.withOpacity(0.5), width: idx == _transactions.length - 1 ? 0 : 1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: (isCredit ? primaryTeal : (isFailed ? errorColor : statusNegotiation)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  isFailed
                                      ? Icons.error_outline_rounded
                                      : (isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
                                  color: isCredit ? primaryTeal : (isFailed ? errorColor : statusNegotiation),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx['method'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "TXID: ${tx['txid']} • ${tx['comments']}",
                                      style: const TextStyle(fontSize: 10, color: textLight),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              tx['amount'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCredit ? primaryTeal : (isFailed ? errorColor : textDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor.withOpacity(0.2)),
                              ),
                              child: Text(
                                tx['status'] ?? '',
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tx['dateTime'] ?? '',
                              style: const TextStyle(fontSize: 9, color: textLight),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),

              // Pagination Section
              Container(
                color: bgLight,
                padding: const EdgeInsets.all(16),
                child: screenWidth < 500
                    ? Column(
                        children: [
                          const Text("Showing 1-4 of 422 transactions", style: TextStyle(fontSize: 11, color: textLight, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () => _triggerAction("Loading Previous Page..."),
                                icon: const Icon(Icons.chevron_left_rounded, size: 16),
                                label: const Text("Previous", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(foregroundColor: textLight),
                              ),
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: () => _triggerAction("Loading Next Page..."),
                                icon: const Icon(Icons.chevron_right_rounded, size: 16),
                                label: const Text("Next", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(foregroundColor: primaryTeal),
                              ),
                            ],
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Showing 1-4 of 422 transactions", style: TextStyle(fontSize: 11, color: textLight, fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _triggerAction("Loading Previous Page..."),
                                icon: const Icon(Icons.chevron_left_rounded, size: 16),
                                label: const Text("Previous", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(foregroundColor: textLight),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _triggerAction("Loading Next Page..."),
                                icon: const Icon(Icons.chevron_right_rounded, size: 16),
                                label: const Text("Next", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(foregroundColor: primaryTeal),
                              ),
                            ],
                          )
                        ],
                      ),
              )
            ],
          ),
        )
      ],
    );
  }
}

// Custom Paint for rendering the smooth linear gradient Line Chart
class LineChartPainter extends CustomPainter {
  final Color chartColor;
  LineChartPainter(this.chartColor);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFBDC9C8).withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (double i = 0.2; i <= 0.8; i += 0.2) {
      canvas.drawLine(Offset(0, h * i), Offset(w, h * i), gridPaint);
    }

    final points = [
      Offset(0, h * 0.8),
      Offset(w * 0.25, h * 0.6),
      Offset(w * 0.5, h * 0.4),
      Offset(w * 0.75, h * 0.55),
      Offset(w, h * 0.2),
    ];

    // Build the curve path
    final Path linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    // Build area fill path
    final Path fillPath = Path()
      ..addPath(linePath, Offset.zero)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [chartColor.withOpacity(0.18), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, h * 0.2, w, h * 0.8));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = chartColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw point dots
    final Paint dotPaint = Paint()..color = chartColor;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var pt in points) {
      canvas.drawCircle(pt, 4.0, dotPaint);
      canvas.drawCircle(pt, 4.0, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data holder for Donut Chart Arcs
class SliceData {
  final double fraction;
  final Color color;
  SliceData(this.fraction, this.color);
}

// Custom Painter for rendering a Donut pie chart
class DonutChartPainter extends CustomPainter {
  final List<SliceData> slices;
  DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Rect rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    double startAngle = -3.14159265 / 2; // start from 12 o'clock

    for (var slice in slices) {
      final double sweepAngle = 2 * 3.14159265 * slice.fraction;
      final Paint paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
