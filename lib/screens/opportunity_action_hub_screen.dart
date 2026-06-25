import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app_constants.dart';
import '../services/auth_service.dart';
import '../Database/Database.dart';
import '../model/support_item.dart';
import '../widgets/action_hub_card.dart';
import '../widgets/support_item_card.dart';
import '../widgets/project_stats_card.dart';
import 'payment_confirmation_screen.dart';

class ActionHubApp extends StatelessWidget {
  const ActionHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Opportunity Action Hub',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF006565),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: const OpportunityActionHubScreen(),
    );
  }
}

class OpportunityActionHubScreen extends StatefulWidget {
  const OpportunityActionHubScreen({super.key});

  @override
  State<OpportunityActionHubScreen> createState() =>
      _OpportunityActionHubScreenState();
}

// Compatibility alias
typedef ActionHubScreen = OpportunityActionHubScreen;

class _OpportunityActionHubScreenState
    extends State<OpportunityActionHubScreen> {
  int currentIndex = 2;

  int selectedDonation = 1000;
  bool anonymousDonation = false;
  late final List<SupportItem> supportItems;

  // --- Logged in User Profile ---
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  int vendorId = 0;

  // --- Wallet Balances ---
  double ecashBalance = 0.0;
  double ewalletBalance = 0.0;
  bool _isLoadingBalances = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchBalances();
    supportItems = [
      SupportItem(
        name: "Solar Panels",
        price: 12500,
      ),
      SupportItem(
        name: "Seed Kits",
        price: 450,
        quantity: 2,
      ),
      SupportItem(
        name: "Water Pumps",
        price: 8900,
      ),
    ];
  }

  Future<void> _loadUserProfile() async {
    final cache = await AuthService.getCachedUserData();
    final vidStr = await AuthService.getVendorIdString();
    vendorId = int.tryParse(vidStr) ?? 0;
    if (cache != null) {
      setState(() {
        userName = cache['name']?.toString() ?? '';
        userEmail = cache['email']?.toString() ?? '';
        userPhone = cache['mobile']?.toString() ?? '';
      });
    }
  }

  Future<void> _fetchBalances() async {
    setState(() => _isLoadingBalances = true);
    try {
      final db = Database();
      final res = await db.getData(
        {"action": "get_wallet_and_cash_balance"},
        endpoint: "new_apis/opportunity_actions_api.php",
      );
      if (!mounted) return;
      if (res['success'] == true) {
        final data = res['data'];
        if (data != null) {
          setState(() {
            ecashBalance = double.tryParse(
                    data['cash']?['available_balance']?.toString() ?? '0') ??
                0.0;
            ewalletBalance = double.tryParse(
                    data['wallet']?['available_balance']?.toString() ?? '0') ??
                0.0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching balances: $e");
    } finally {
      if (mounted) setState(() => _isLoadingBalances = false);
    }
  }

  // =========================================================================
  //  API ACTION SUBMISSIONS
  // =========================================================================

  void _showRazorpaySimulateDialog(double amount, VoidCallback onSuccess) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Simulate Razorpay Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Online payment gateway simulated."),
            const SizedBox(height: 12),
            Text("Amount: ₹${amount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Confirm signature verification success?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006565),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onSuccess();
            },
            child: const Text("Verify Success"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDonation({
    required double amount,
    required double ecashUsed,
    required double ewalletUsed,
    required bool anonymous,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006565)),
        ),
      ),
    );

    try {
      final db = Database();
      final notes =
          "Payment Breakdown: Ecash ₹$ecashUsed, Ewallet ₹$ewalletUsed, Online: ₹${(amount - ecashUsed - ewalletUsed).toStringAsFixed(2)}";
      final response = await db.getData({
        'action': 'donate',
        'name': userName.isNotEmpty ? userName : 'Test Donor',
        'email': userEmail.isNotEmpty ? userEmail : 'donor@example.com',
        'phone': userPhone.isNotEmpty ? userPhone : '9876543210',
        'amount': amount,
        'notes': notes,
        'attachment': '',
        'anonymous': anonymous ? '1' : '0',
        'paid_from_ewallet': ewalletUsed,
        'paid_from_ebanking': ecashUsed,
      }, endpoint: 'new_apis/opportunity_actions_api.php');

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response['success'] == true) {
        Navigator.pop(context); // Close donation modal
        _fetchBalances(); // reload balances

        final orderId = response['data']?['id']?.toString() ??
            response['id']?.toString() ??
            'N/A';
        final List<String> methods = [];
        if (ecashUsed > 0)
          methods.add("E-Cash (₹${ecashUsed.toStringAsFixed(2)})");
        if (ewalletUsed > 0)
          methods.add("E-Wallet (₹${ewalletUsed.toStringAsFixed(2)})");
        final onlinePaid = amount - ecashUsed - ewalletUsed;
        if (onlinePaid > 0)
          methods.add("Razorpay Online (₹${onlinePaid.toStringAsFixed(2)})");
        final methodString =
            methods.isEmpty ? "Free Donation" : methods.join(" + ");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationScreen(
              amount: amount,
              transactionId: "#LAV-$orderId",
              paymentMethod: methodString,
              dateTime: DateTime.now(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to complete donation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error completing donation: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitSupportItems(String actionType) async {
    final selectedItemsText = supportItems
        .where((item) => item.quantity > 0)
        .map((item) =>
            "${item.name} (Qty: ${item.quantity}, Cost: ₹${item.price * item.quantity})")
        .join(", ");

    if (selectedItemsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select items to support"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final db = Database();
      final notes = "Support Items Request ($actionType): $selectedItemsText";
      final response = await db.getData({
        'action': 'callback',
        'name': userName.isNotEmpty ? userName : 'Test Sponsor',
        'email': userEmail.isNotEmpty ? userEmail : 'sponsor@example.com',
        'phone': userPhone.isNotEmpty ? userPhone : '9876543210',
        'preferred_time': 'Anytime',
        'notes': notes,
        'attachment': '',
        'item_id': 0,
        'marketplace_id': 0,
      }, endpoint: 'new_apis/opportunity_actions_api.php');

      if (!mounted) return;
      Navigator.pop(context); // close loader

      if (response['success'] == true) {
        Navigator.pop(context); // close modal
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("Support Submitted"),
              ],
            ),
            content: Text(
              "Your request to support with items has been recorded.\n"
              "Total Value: ₹${totalSupportCost.toStringAsFixed(0)}\n"
              "Items: $selectedItemsText",
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to submit request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error submitting request: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitCallbackRequest(
      String phone, String preferredTime) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final db = Database();
      final response = await db.getData({
        'action': 'callback',
        'name': userName.isNotEmpty ? userName : 'Client Callback',
        'email': userEmail.isNotEmpty ? userEmail : 'client@example.com',
        'phone': phone,
        'preferred_time': preferredTime,
        'notes': 'Requested callback via Hub Screen',
        'attachment': '',
        'item_id': 0,
        'marketplace_id': 0,
      }, endpoint: 'new_apis/opportunity_actions_api.php');

      if (!mounted) return;
      Navigator.pop(context); // pop loader

      if (response['success'] == true) {
        Navigator.pop(context); // close modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Callback request submitted for $preferredTime."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to request callback'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitAppointmentRequest(
      DateTime date, String slot, String notes) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final db = Database();
      final response = await db.getData({
        'action': 'appointment',
        'name': userName.isNotEmpty ? userName : 'Client Appointment',
        'email': userEmail.isNotEmpty ? userEmail : 'client@example.com',
        'phone': userPhone.isNotEmpty ? userPhone : '9876543210',
        'date': dateStr,
        'time': slot,
        'notes': notes,
        'attachment': '',
      }, endpoint: 'new_apis/opportunity_actions_api.php');

      if (!mounted) return;
      Navigator.pop(context); // pop loader

      if (response['success'] == true) {
        Navigator.pop(context); // close modal
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Appointment Confirmed"),
            content: Text(
              "Your appointment has been successfully booked for $dateStr at $slot.",
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to book appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error booking appointment: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double get totalSupportCost {
    return supportItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

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
            color: Color(0xFF006565),
          ),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          "Opportunity",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Color(0xFF006565),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Link copied to clipboard!")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO SECTION
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1441974231531-c6227db76b6e",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(178),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006565),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Sustainable Development",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Eco-Restore Initiative",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Empowering local communities to restore 500 hectares of native woodland ecosystems through innovative irrigation and planting techniques.",
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ACTION BUTTONS GRID
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                ActionHubCard(
                  title: "Donate Now",
                  subtitle: "Directly fund project resources",
                  icon: Icons.volunteer_activism,
                  onTap: () {
                    showDonateModal();
                  },
                ),
                ActionHubCard(
                  title: "Support With Items",
                  subtitle: "Provide specific equipment",
                  icon: Icons.inventory_2,
                  onTap: () {
                    showSupportModal();
                  },
                ),
                ActionHubCard(
                  title: "Request Callback",
                  subtitle: "Speak with an advisor",
                  icon: Icons.call,
                  onTap: () {
                    showCallbackModal();
                  },
                ),
                ActionHubCard(
                  title: "Book Appointment",
                  subtitle: "Schedule a meeting",
                  icon: Icons.calendar_month,
                  onTap: () {
                    showAppointmentModal();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // IMPACT SECTION
            const ProjectStatsCard(
              treesPlanted: "12.5k",
              amountRaised: "₹45L",
              volunteers: "150+",
            ),
            const SizedBox(height: 16),

            // VERIFIED PARTNER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF006565),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Verified Carbon Partner",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Certified for excellence in sustainable ecological restoration.",
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- MODALS ---

  void showDonateModal() {
    final amountController =
        TextEditingController(text: selectedDonation.toString());
    bool useEcash = false;
    bool useEwallet = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final totalAmount = double.tryParse(amountController.text) ?? 0.0;

            // Calculate breakdown
            double remaining = totalAmount;
            double ecashUsed = 0.0;
            double ewalletUsed = 0.0;

            if (useEcash) {
              ecashUsed = remaining > ecashBalance ? ecashBalance : remaining;
              remaining -= ecashUsed;
            }

            if (useEwallet) {
              ewalletUsed =
                  remaining > ewalletBalance ? ewalletBalance : remaining;
              remaining -= ewalletUsed;
            }

            Widget buildDonationChip(int amount) {
              return ChoiceChip(
                label: Text("₹$amount"),
                selected: selectedDonation == amount,
                onSelected: (selected) {
                  modalSetState(() {
                    selectedDonation = amount;
                    amountController.text = amount.toString();
                  });
                },
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Donate",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffe5f7f7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current Project",
                            style: TextStyle(
                              color: Color(0xFF006565),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Eco-Restore Initiative",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      children: [
                        buildDonationChip(500),
                        buildDonationChip(1000),
                        buildDonationChip(5000),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        modalSetState(() {
                          selectedDonation = int.tryParse(value) ?? 0;
                        });
                      },
                      decoration: const InputDecoration(
                        prefixText: "₹ ",
                        hintText: "Custom Amount",
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: anonymousDonation,
                      title: const Text("Donate Anonymously"),
                      onChanged: (value) {
                        modalSetState(() {
                          anonymousDonation = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Wallet Options",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: useEcash,
                      title: Text(
                          "Use Ecash (Available: ₹${ecashBalance.toStringAsFixed(2)})"),
                      subtitle: useEcash
                          ? Text("Applying: ₹${ecashUsed.toStringAsFixed(2)}")
                          : null,
                      onChanged: (value) {
                        modalSetState(() {
                          useEcash = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: useEwallet,
                      title: Text(
                          "Use Ewallet (Available: ₹${ewalletBalance.toStringAsFixed(2)})"),
                      subtitle: useEwallet
                          ? Text("Applying: ₹${ewalletUsed.toStringAsFixed(2)}")
                          : null,
                      onChanged: (value) {
                        modalSetState(() {
                          useEwallet = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Amount:"),
                              Text("₹${totalAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (ecashUsed > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Ecash Deduction:"),
                                Text("-₹${ecashUsed.toStringAsFixed(2)}",
                                    style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ],
                          if (ewalletUsed > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Ewallet Deduction:"),
                                Text("-₹${ewalletUsed.toStringAsFixed(2)}",
                                    style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Remaining to Pay Online:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("₹${remaining.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF006565))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (remaining > 0) ...[
                      const Center(
                        child: Text(
                          "Note: You will be redirected to Razorpay online payment simulator.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (totalAmount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Please enter a valid donation amount"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (remaining > 0) {
                            _showRazorpaySimulateDialog(remaining, () {
                              _submitDonation(
                                amount: totalAmount,
                                ecashUsed: ecashUsed,
                                ewalletUsed: ewalletUsed,
                                anonymous: anonymousDonation,
                              );
                            });
                          } else {
                            _submitDonation(
                              amount: totalAmount,
                              ecashUsed: ecashUsed,
                              ewalletUsed: ewalletUsed,
                              anonymous: anonymousDonation,
                            );
                          }
                        },
                        child: const Text("Complete Donation"),
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

  void showSupportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.80,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Support With Items",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: supportItems.length,
                      itemBuilder: (context, index) {
                        final item = supportItems[index];
                        return SupportItemCard(
                          item: item,
                          onIncrement: () {
                            modalSetState(() {
                              item.quantity++;
                            });
                            setState(() {}); // sync total cost state
                          },
                          onDecrement: () {
                            modalSetState(() {
                              if (item.quantity > 0) {
                                item.quantity--;
                              }
                            });
                            setState(() {}); // sync total cost state
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Total Cost",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "₹${totalSupportCost.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color(0xFF006565),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  if (totalSupportCost <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Add items to support"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  _submitSupportItems("Buy");
                                },
                                child: const Text("Buy for Items"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006565),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  if (totalSupportCost <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Add items to support"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  _submitSupportItems("Pay");
                                },
                                child: const Text("Pay for Items"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showCallbackModal() {
    final phoneController = TextEditingController(text: userPhone);
    String selectedTime = "Afternoon (12 PM - 4 PM)";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Close Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Request Callback",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1B1B),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Support Banner Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffe5f7f7),
                          ),
                          child: const Icon(
                            Icons.headset_mic_outlined,
                            color: Color(0xff006565),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "An initiative coordinator will reach out to you shortly.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Phone Number label
                    const Text(
                      "Phone Number",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Phone Number Text Field
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.smartphone_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        hintText: "+91 98765 43210",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xff006565)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Preferred Time label
                    const Text(
                      "Preferred Time",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Preferred Time Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedTime,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xff006565)),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Morning (9 AM - 12 PM)",
                          child: Text("Morning (9 AM - 12 PM)"),
                        ),
                        DropdownMenuItem(
                          value: "Afternoon (12 PM - 4 PM)",
                          child: Text("Afternoon (12 PM - 4 PM)"),
                        ),
                        DropdownMenuItem(
                          value: "Evening (4 PM - 7 PM)",
                          child: Text("Evening (4 PM - 7 PM)"),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedTime = value ?? "Afternoon (12 PM - 4 PM)";
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Request Call Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006565),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final phoneVal = phoneController.text.trim();
                          if (phoneVal.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a phone number"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          _submitCallbackRequest(phoneVal, selectedTime);
                        },
                        child: const Text(
                          "Request Call",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void showAppointmentModal() {
    DateTime selectedDate = DateTime.now();
    DateTime focusedDate = DateTime.now();
    String selectedSlot = "02:00 PM";
    final notesController = TextEditingController();

    final weekdaysAbbr = ["M", "T", "W", "T", "F", "S", "S"];
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    final monthsFull = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    String formatFriendlyDate(DateTime dt) {
      final weekdayName = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ][dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return "$weekdayName, ${dt.day} $monthName";
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final daysInMonth =
                DateTime(focusedDate.year, focusedDate.month + 1, 0).day;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Close Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Schedule Meeting",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1B1B),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Select Date label
                    const Text(
                      "Select Date",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Calendar card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xfffcfaf9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          // Month Selector Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    color: Colors.grey),
                                onPressed: () {
                                  setModalState(() {
                                    focusedDate = DateTime(focusedDate.year,
                                        focusedDate.month - 1, 1);
                                  });
                                },
                              ),
                              Text(
                                "${monthsFull[focusedDate.month - 1]} ${focusedDate.year}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right,
                                    color: Colors.grey),
                                onPressed: () {
                                  setModalState(() {
                                    focusedDate = DateTime(focusedDate.year,
                                        focusedDate.month + 1, 1);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Horizontal list of days in the month
                          SizedBox(
                            height: 64,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: daysInMonth,
                              itemBuilder: (context, index) {
                                final dayNum = index + 1;
                                final date = DateTime(focusedDate.year,
                                    focusedDate.month, dayNum);
                                final isSelected =
                                    selectedDate.year == date.year &&
                                        selectedDate.month == date.month &&
                                        selectedDate.day == date.day;

                                return InkWell(
                                  onTap: () {
                                    setModalState(() {
                                      selectedDate = date;
                                    });
                                  },
                                  child: Container(
                                    width: 44,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xff006565)
                                          : Colors.transparent,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          weekdaysAbbr[date.weekday - 1],
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSelected
                                                ? Colors.white70
                                                : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$dayNum",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Selected Date display
                          Text(
                            formatFriendlyDate(selectedDate),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff006565),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Available Slots label
                    const Text(
                      "Available Slots",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Time slots grid (custom buttons)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.8,
                      children: ["10:00 AM", "02:00 PM", "04:30 PM", "05:00 PM"]
                          .map((slot) {
                        final isSelected = selectedSlot == slot;
                        return OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xff006565)
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : const Color(0xff006565),
                            side: const BorderSide(color: Color(0xff006565)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setModalState(() {
                              selectedSlot = slot;
                            });
                          },
                          child: Text(
                            slot,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Request Message label
                    const Text(
                      "Request Message",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Text Field for notes
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Describe the purpose of your visit...",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xff006565)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Cancel & Confirm Booking Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff006565),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _submitAppointmentRequest(
                                selectedDate,
                                selectedSlot,
                                notesController.text.trim(),
                              );
                            },
                            child: const Text(
                              "Confirm Booking",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
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
    );
  }
}
