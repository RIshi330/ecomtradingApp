import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../common/payment_screen.dart';
import '../model/module_model.dart';
import '../screens/membership_payment_modal.dart';
import '../services/auth_User_and_Business_Session.dart';

class MembershipPlansScreen extends StatefulWidget {
  final bool isEmbedded;
  const MembershipPlansScreen({super.key, this.isEmbedded = false});

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  bool _isLoading = true;
  List<dynamic> _membershipPlans = [];

  static const Color primaryColor = Color(0xff006565);
  static const Color secondaryColor = Color(0xff008080);
  static const Color surfaceSoft = Color(0xffD4E6E5);
  static const Color textMuted = Color(0xFF3E4949);

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
        totalRawPrice:
            double.tryParse(plan['final_price']?.toString() ?? '') ?? 0.0,
        themeColor: primaryColor,
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
      backgroundColor: const Color(0xffFCF9F8),
      appBar: widget.isEmbedded ? null : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Membership Plans",
          style: TextStyle(
            color: Color(0xFF1C1B1B),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => Navigator.pop(context),
              )
            : const Icon(
                Icons.menu,
                color: primaryColor,
              ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.account_circle,
              color: primaryColor,
            ),
          )
        ],
      ),
      // bottomNavigationBar: widget.isEmbedded ? null : BottomNavigationBar(
      //   currentIndex: 1,
      //   selectedItemColor: primaryColor,
      //   unselectedItemColor: Colors.grey,
      //   backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   onTap: (index) {
      //     if (index != 1 && Navigator.canPop(context)) {
      //       Navigator.pop(context);
      //     }
      //   },
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: "Home",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.card_membership),
      //       label: "Plans",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.verified),
      //       label: "Benefits",
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: "Profile",
      //     ),
      //   ],
      // ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchPlans,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Choose Your Plan",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Unlock premium features and exclusive content.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textMuted),
                    ),
                    const SizedBox(height: 24),
                    if (_membershipPlans.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No active membership plans available right now.",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _membershipPlans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final plan =
                              _membershipPlans[index] as Map<String, dynamic>;
                          final double price = double.tryParse(
                                  plan['price']?.toString() ?? '0') ??
                              0.0;
                          final double finalPrice = double.tryParse(
                                  plan['final_price']?.toString() ?? '0') ??
                              0.0;
                          final double discount = double.tryParse(
                                  plan['discount']?.toString() ?? '0') ??
                              0.0;
                          final bool isPurchased = plan['is_purchased'] == 1;

                          String validityText = '';
                          if (plan['validity'].toString() == 'Unlimited') {
                            validityText = 'Lifetime Validity';
                          } else {
                            validityText = '${plan['validity']} Days Validity';
                          }

                          final List<String> features = [];
                          final details =
                              plan['details'] as List<dynamic>? ?? [];
                          for (var det in details) {
                            features.add(
                                "${det['posts']} posts on ${det['display_name']}");
                          }
                          if (plan['include_team_members'] == 1) {
                            features.add(
                                "Includes ${plan['team_member_count']} team members");
                            features.add(
                                "Add team member at ₹${plan['additional_member_price']}/member");
                          }

                          final bool highlighted = index == 0;

                          return MembershipCard(
                            plan: plan,
                            planName: plan['title'] ?? 'Plan',
                            validity: validityText,
                            oldPrice: discount > 0
                                ? "₹${price.toStringAsFixed(2)}"
                                : "",
                            newPrice: "₹${finalPrice.toStringAsFixed(2)}",
                            savings: discount > 0
                                ? "You Save ₹${discount.toStringAsFixed(2)}"
                                : "",
                            features: features,
                            highlighted: highlighted,
                            isPurchased: isPurchased,
                            onBuyPressed: () => _openCheckoutSheet(plan),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            size: 50,
                            color: primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Secure Checkout",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1B1B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "All transactions are encrypted and 100% secure. Cancel anytime from your profile settings.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textMuted),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.credit_card, color: primaryColor),
                              SizedBox(width: 16),
                              Icon(Icons.account_balance, color: primaryColor),
                              SizedBox(width: 16),
                              Icon(Icons.payments, color: primaryColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

class MembershipCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final String planName;
  final String validity;
  final String oldPrice;
  final String newPrice;
  final String savings;
  final bool highlighted;
  final List<String> features;
  final bool isPurchased;
  final VoidCallback onBuyPressed;

  const MembershipCard({
    super.key,
    required this.plan,
    required this.planName,
    required this.validity,
    required this.oldPrice,
    required this.newPrice,
    required this.savings,
    required this.highlighted,
    required this.features,
    required this.isPurchased,
    required this.onBuyPressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff006565);
    const Color secondaryColor = Color(0xff008080);
    const Color surfaceSoft = Color(0xffD4E6E5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPurchased
              ? Colors.green
              : (highlighted ? primaryColor : Colors.grey.shade300),
          width: (isPurchased || highlighted) ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPurchased)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
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
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    Text(validity,
                        style: const TextStyle(color: Color(0xFF3E4949))),
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
                        color: Colors.grey,
                      ),
                    ),
                  Text(
                     newPrice,
                    style: const TextStyle(
                      fontSize: 22,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (savings.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                savings,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...features.map(
            (feature) => FeatureRow(
              text: feature,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 180,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPurchased
                      ? Colors.grey[300]
                      : (highlighted ? primaryColor : secondaryColor),
                  foregroundColor: isPurchased ? Colors.grey[600] : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isPurchased ? null : () {
                  final selectedModule = ModuleModel(
                    id: plan['id'].toString(),
                    title: planName,
                    price: oldPrice.isNotEmpty ? oldPrice : newPrice,
                    discountPrice: newPrice,
                    icon: Icons.card_giftcard,
                    badge: highlighted ? 'BESTSELLER' : '',
                    category: plan['category']?.toString() ?? 'Membership',
                    features: features,
                    iconName: 'school',
                    installs: '0',
                    rating: '0',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(module: selectedModule),
                    ),
                  );
                },
                child: Text(
                  isPurchased ? "Active Plan" : "Buy Now",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureRow extends StatelessWidget {
  final String text;

  const FeatureRow({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xff006565),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF3E4949)),
            ),
          ),
        ],
      ),
    );
  }
}
