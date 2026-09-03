import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../screens/membership_payment_modal.dart';
import '../services/auth_User_and_Business_Session.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  int selectedIndex = 1;
  bool _isLoading = true;
  List<dynamic> _membershipPlans = [];

  static const Color primary = Color(0xFF006565); // Teal Primary
  static const Color primaryContainer = Color(0xFF008080); // Teal Container
  static const Color surfaceSoft = Color(0xFFFCF9F8); // Theme Background
  static const Color borderColor = Color(0xFFBDC9C8); // Theme outline/border
  static const Color textMuted = Color(0xFF3E4949); // Muted theme text

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = Database();
      final res = await db.getJsonData({
        'action': 'membership_list',
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/membership_plans_API.php');

      if (res['success'] == true && res['data'] != null) {
        setState(() {
          _membershipPlans = res['data'] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint("Error fetching membership plans: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openCheckoutSheet(Map<String, dynamic> plan) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MembershipPaymentModal(
        planId: plan['id'],
        planTitle: plan['title'] ?? 'Membership',
        totalRawPrice: double.tryParse(plan['final_price']?.toString() ?? '') ?? 0.0,
        themeColor: primary,
      ),
    ).then((success) {
      if (success == true) {
        _fetchPlans();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primary),
          onPressed: () {},
        ),
        title: const Text(
          "Membership",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: primary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : RefreshIndicator(
              onRefresh: _fetchPlans,
              color: primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Choose Your Plan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Unlock premium features and exclusive content.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_membershipPlans.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No active membership plans available right now.",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _membershipPlans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final plan = _membershipPlans[index] as Map<String, dynamic>;
                          final double price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0.0;
                          final double finalPrice = double.tryParse(plan['final_price']?.toString() ?? '0') ?? 0.0;
                          final double discount = double.tryParse(plan['discount']?.toString() ?? '0') ?? 0.0;
                          final bool isPurchased = plan['is_purchased'] == 1;

                          // Construct validity text
                          String validityText = '';
                          if (plan['validity'].toString() == 'Unlimited') {
                            validityText = 'Lifetime Validity';
                          } else {
                            validityText = '${plan['validity']} Days Validity';
                          }

                          // Gather features
                          final List<String> features = [];
                          final details = plan['details'] as List<dynamic>? ?? [];
                          for (var det in details) {
                            features.add("${det['posts']} posts on ${det['display_name']}");
                          }
                          if (plan['include_team_members'] == 1) {
                            features.add("Includes ${plan['team_member_count']} team members");
                            features.add("Add team member at ₹${plan['additional_member_price']}/member");
                          }

                          // Highlight the first plan or if it is marked as featured
                          final bool highlighted = index == 0;

                          return _buildPlanCard(
                            plan: plan,
                            title: plan['title'] ?? 'Plan',
                            validity: validityText,
                            oldPrice: discount > 0 ? "₹${price.toStringAsFixed(2)}" : "",
                            price: "₹${finalPrice.toStringAsFixed(2)}",
                            saveText: discount > 0 ? "You Save ₹${discount.toStringAsFixed(2)}" : "",
                            features: features,
                            highlighted: highlighted,
                            isPurchased: isPurchased,
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 44,
                            color: primary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Secure Checkout",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "All transactions are encrypted and 100% secure. Cancel anytime from your profile settings.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: .4,
                            child: Icon(Icons.credit_card),
                          ),
                          SizedBox(width: 16),
                          Opacity(
                            opacity: .4,
                            child: Icon(Icons.account_balance),
                          ),
                          SizedBox(width: 16),
                          Opacity(
                            opacity: .4,
                            child: Icon(Icons.payments),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      bottomNavigationBar: NavigationBar(
        height: 80,
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD4E6E5),
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.card_membership_outlined),
            selectedIcon: Icon(Icons.card_membership),
            label: "Plans",
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified),
            label: "Benefits",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required String title,
    required String validity,
    required String oldPrice,
    required String price,
    required String saveText,
    required List<String> features,
    required bool isPurchased,
    bool highlighted = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPurchased ? Colors.green : (highlighted ? primary : borderColor),
          width: (isPurchased || highlighted) ? 2 : 1,
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: primary.withOpacity(.08),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Stack(
        children: [
          if (isPurchased)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  "ACTIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (highlighted)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  "MOST POPULAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: (highlighted || isPurchased) ? 16 : 0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            validity,
                            style: const TextStyle(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (oldPrice.isNotEmpty)
                          Text(
                            oldPrice,
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: textMuted,
                            ),
                          ),
                        Text(
                          price,
                          style: const TextStyle(
                            color: primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                if (saveText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      saveText,
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPurchased
                          ? Colors.grey[300]
                          : (highlighted ? primary : primaryContainer),
                      foregroundColor: isPurchased ? Colors.grey[600] : Colors.white,
                      elevation: highlighted ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isPurchased ? null : () => _openCheckoutSheet(plan),
                    child: Text(
                      isPurchased ? "Active Plan" : "Buy Now",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}