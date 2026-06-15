import 'package:flutter/material.dart';
import '../Database/Database.dart';

class MembershipBuilderScreen extends StatefulWidget {
  const MembershipBuilderScreen({super.key});

  @override
  State<MembershipBuilderScreen> createState() =>
      _MembershipBuilderScreenState();
}

class _MembershipBuilderScreenState
    extends State<MembershipBuilderScreen> {
  List<PlanModel> plans = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final db = Database();
      final res = await db.getData(
        {"action": "membership_list"},
        endpoint: "new_apis/membership_builder_api.php",
      );
      
      if (res['success'] == true || res['status'] == 200 || res.containsKey('data')) {
        final rawList = res['data'] ?? [];
        if (rawList is List) {
          setState(() {
            plans = rawList
                .map((e) => PlanModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          });
        }
      } else {
        setState(() {
          _errorMessage = res['message']?.toString() ?? "Failed to load plans";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network or server error: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeStatus(int id, int status) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final db = Database();
      final res = await db.getJsonData(
        {
          "action": "change_membership_status",
          "membership_id": id,
          "status": status,
        },
        endpoint: "new_apis/membership_builder_api.php",
      );
      if (!mounted) return;
      if (res['success'] == true || res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? "Status updated successfully",
            ),
          ),
        );
        _fetchPlans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? "Failed to update status",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePlan(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final db = Database();
      final res = await db.getJsonData(
        {
          "action": "delete_membership",
          "membership_id": id,
        },
        endpoint: "new_apis/membership_builder_api.php",
      );
      if (!mounted) return;
      if (res['success'] == true || res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? "Plan deleted successfully",
            ),
          ),
        );
        _fetchPlans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? "Failed to delete plan",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Membership Builder",
          style: TextStyle(
            color: Color(0xFF1C1B1B),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                onPressed: () => Navigator.pop(context),
              )
            : const Icon(
                Icons.menu,
                color: Color(0xff006565),
              ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.account_circle,
              color: Color(0xff006565),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff006565),
        foregroundColor: Colors.white,
        onPressed: () => showCreatePlanSheet(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xff006565),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index != 1 && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: "Plans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: "Benefits",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search plans...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list),
                    label: const Text("Filters"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort),
                    label: const Text("Sort"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Choose From Templates",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1B1B),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 315,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  TemplateCard(
                    title: "Basic Plan",
                    price: r"$0",
                    icon: Icons.person,
                    description: "Perfect for individuals starting their journey.",
                    features: const [
                      "30 Days Validity",
                      "5 Marketplace Posts",
                    ],
                    onUse: () => showCreatePlanSheet(
                      templateData: {
                        "title": "Basic Plan",
                        "price": "0",
                        "validity": "30",
                        "description":
                            "Perfect for individuals starting their journey.",
                        "vendorType": "Individual",
                        "includeWebsite": false,
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  TemplateCard(
                    title: "Pro Professional",
                    price: r"$29",
                    icon: Icons.workspace_premium,
                    description: "Advanced features for growing businesses.",
                    features: const [
                      "365 Days Validity",
                      "Unlimited Marketplace Access",
                    ],
                    highlighted: true,
                    onUse: () => showCreatePlanSheet(
                      templateData: {
                        "title": "Pro Professional",
                        "price": "29",
                        "validity": "365",
                        "description":
                            "Advanced features for growing businesses.",
                        "vendorType": "Individual",
                        "includeWebsite": false,
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  TemplateCard(
                    title: "Enterprise Suite",
                    price: r"$499",
                    icon: Icons.corporate_fare,
                    description: "Tailored for large organizations.",
                    features: const [
                      "Custom Validity",
                      "Dedicated API Support",
                    ],
                    onUse: () => showCreatePlanSheet(
                      templateData: {
                        "title": "Enterprise Suite",
                        "price": "499",
                        "validity": "365",
                        "description": "Tailored for large organizations.",
                        "vendorType": "Corporate",
                        "includeWebsite": true,
                        "numberOfWebsites": 5,
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Active Membership Plans",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1B1B),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading && plans.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xff006565)),
                  ),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _fetchPlans,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            else if (plans.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "No active or draft membership plans found.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plans.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.25,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return PlanCard(
                    plan: plans[index],
                    onApprove: () => _changeStatus(plans[index].id, 1),
                    onSuspend: () => _changeStatus(plans[index].id, 0),
                    onDelete: () => _deletePlan(plans[index].id),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void showCreatePlanSheet({Map<String, dynamic>? templateData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => CreateMembershipSheet(
        onPlanCreated: _fetchPlans,
        templateData: templateData,
      ),
    );
  }
}

class PlanModel {
  final int id;
  final String title;
  final String type;
  final double price;
  final double discountAmount;
  final double finalPrice;
  final String discountType;
  final int validity;
  final String description;
  final int status;
  final int numberOfWebsites;
  final int websiteValidity;
  final int includeTeamMembers;
  final int teamMemberCount;
  final double additionalMemberPrice;

  PlanModel({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.discountAmount,
    required this.finalPrice,
    required this.discountType,
    required this.validity,
    required this.description,
    required this.status,
    required this.numberOfWebsites,
    required this.websiteValidity,
    required this.includeTeamMembers,
    required this.teamMemberCount,
    required this.additionalMemberPrice,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    String resolvedType = "Individual";
    if (json['vendor_types'] is List) {
      final list = json['vendor_types'] as List;
      if (list.isNotEmpty) {
        final first = list.first;
        if (first == 1) {
          resolvedType = "Individual";
        } else if (first == 2) {
          resolvedType = "Corporate";
        } else if (first == 3) {
          resolvedType = "Service Provider";
        }
      }
    }

    int parsedValidity = 0;
    if (json['validity'] != null) {
      if (json['validity'].toString().toLowerCase() == 'unlimited') {
        parsedValidity = -1;
      } else {
        parsedValidity = int.tryParse(json['validity'].toString()) ?? 0;
      }
    }

    return PlanModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      title: json['title']?.toString() ?? '',
      type: resolvedType,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      discountAmount: json['discount_amount'] != null
          ? double.tryParse(json['discount_amount'].toString()) ?? 0.0
          : 0.0,
      finalPrice: json['final_price'] != null
          ? double.tryParse(json['final_price'].toString()) ?? 0.0
          : 0.0,
      discountType: json['discount_type']?.toString() ?? '',
      validity: parsedValidity,
      description: json['additional_details']?.toString() ?? '',
      status: json['status'] != null
          ? int.tryParse(json['status'].toString()) ?? 0
          : 0,
      numberOfWebsites: json['number_of_websites'] != null
          ? int.tryParse(json['number_of_websites'].toString()) ?? 0
          : 0,
      websiteValidity: json['website_validity'] != null
          ? int.tryParse(json['website_validity'].toString()) ?? 0
          : 0,
      includeTeamMembers: json['include_team_members'] != null
          ? int.tryParse(json['include_team_members'].toString()) ?? 0
          : 0,
      teamMemberCount: json['team_member_count'] != null
          ? int.tryParse(json['team_member_count'].toString()) ?? 0
          : 0,
      additionalMemberPrice: json['additional_member_price'] != null
          ? double.tryParse(json['additional_member_price'].toString()) ?? 0.0
          : 0.0,
    );
  }
}

class TemplateCard extends StatelessWidget {
  final String title;
  final String price;
  final IconData icon;
  final String description;
  final List<String> features;
  final bool highlighted;
  final VoidCallback? onUse;

  const TemplateCard({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
    required this.description,
    required this.features,
    this.highlighted = false,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? const Color(0xff006565) : Colors.grey.shade300,
          width: highlighted ? 2 : 1,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: const Color(0xff006565),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006565),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1C1B1B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF3E4949)),
          ),
          const Spacer(),
          ...features.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(color: Color(0xFF3E4949)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006565),
                foregroundColor: Colors.white,
              ),
              onPressed: onUse,
              child: const Text("Use Template"),
            ),
          ),
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback? onApprove;
  final VoidCallback? onSuspend;
  final VoidCallback? onDelete;

  const PlanCard({
    super.key,
    required this.plan,
    this.onApprove,
    this.onSuspend,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = plan.discountAmount > 0;

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    if (plan.status == 1) {
      statusBgColor = const Color(0xffE2F9F3);
      statusTextColor = const Color(0xff10B981);
      statusLabel = "Active";
    } else if (plan.status == 0) {
      statusBgColor = const Color(0xffFFF3CD);
      statusTextColor = const Color(0xffD99B00);
      statusLabel = "Draft/Suspended";
    } else {
      statusBgColor = Colors.grey.shade200;
      statusTextColor = Colors.grey.shade700;
      statusLabel = "Inactive";
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffD4E6E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.type,
                    style: const TextStyle(
                      color: Color(0xff006565),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                if (plan.numberOfWebsites > 0)
                  Tooltip(
                    message: "Includes ${plan.numberOfWebsites} website(s)",
                    child: Chip(
                      labelPadding: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 0),
                      avatar: const Icon(Icons.language,
                          size: 14, color: Color(0xff006565)),
                      label: Text(
                        " ${plan.numberOfWebsites} Web",
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xff006565)),
                      ),
                      backgroundColor: const Color(0xffE6F6F6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              plan.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1B1B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              plan.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF3E4949), fontSize: 13),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount) ...[
                  Text(
                    "\$${plan.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  "\$${plan.finalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff006565),
                  ),
                ),
                Text(
                  plan.validity == -1
                      ? " / Unlimited"
                      : " / ${plan.validity} Days",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${plan.discountAmount.toStringAsFixed(0)}% OFF",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Divider(),
            Row(
              children: [
                if (plan.status == 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSuspend,
                      child: const Text(
                        "Suspend",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                if (plan.status == 0)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff006565),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onApprove,
                      child: const Text(
                        "Approve",
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateMembershipSheet extends StatefulWidget {
  final VoidCallback? onPlanCreated;
  final Map<String, dynamic>? templateData;

  const CreateMembershipSheet({
    super.key,
    this.onPlanCreated,
    this.templateData,
  });

  @override
  State<CreateMembershipSheet> createState() => _CreateMembershipSheetState();
}

class _CreateMembershipSheetState extends State<CreateMembershipSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _validityController;
  late final TextEditingController _websitesController;
  late final TextEditingController _infoController;

  String _vendorType = "Individual";
  bool includeWebsite = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final template = widget.templateData;
    _titleController =
        TextEditingController(text: template?['title']?.toString() ?? '');

    String initialPrice = '';
    if (template?['price'] != null) {
      initialPrice = template!['price'].toString().replaceAll('\$', '');
    }
    _priceController = TextEditingController(text: initialPrice);
    _discountController = TextEditingController(text: '0');

    String initialValidity = '30';
    if (template?['validity'] != null) {
      initialValidity = template!['validity'].toString();
    }
    _validityController = TextEditingController(text: initialValidity);
    _websitesController = TextEditingController(text: '1');
    _infoController = TextEditingController(
        text: template?['description']?.toString() ?? '');

    _vendorType = template?['vendorType']?.toString() ?? 'Individual';
    includeWebsite = template?['includeWebsite'] as bool? ?? false;
    if (template?['numberOfWebsites'] != null) {
      _websitesController.text = template!['numberOfWebsites'].toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _validityController.dispose();
    _websitesController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      int vendorTypeId = 1;
      if (_vendorType == "Individual") {
        vendorTypeId = 1;
      } else if (_vendorType == "Corporate") {
        vendorTypeId = 2;
      } else if (_vendorType == "Service Provider") {
        vendorTypeId = 3;
      }

      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final double discount = double.tryParse(_discountController.text) ?? 0.0;
      final int validity = int.tryParse(_validityController.text) ?? 30;

      final Map<String, dynamic> requestBody = {
        "action": "save_membership",
        "title": _titleController.text,
        "price": price,
        "validity": validity,
        "discount_type": "percentage",
        "discount_amount": discount,
        "additional_details": _infoController.text,
        "inc_free_website": includeWebsite ? 1 : 0,
        "number_of_websites":
            includeWebsite ? (int.tryParse(_websitesController.text) ?? 0) : 0,
        "website_validity": includeWebsite ? validity : 0,
        "vendorTypes": [vendorTypeId],
      };

      final db = Database();
      final res = await db.getJsonData(
        requestBody,
        endpoint: "new_apis/membership_builder_api.php",
      );
      if (!mounted) return;
      if (res['success'] == true || res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res['message']?.toString() ?? "Plan created successfully",
            ),
          ),
        );
        if (widget.onPlanCreated != null) {
          widget.onPlanCreated!();
        }
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(res['message']?.toString() ?? "Failed to create plan"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Add Membership",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1B1B),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Plan Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Title is required"
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _vendorType,
                  items: const [
                    DropdownMenuItem(
                      value: "Individual",
                      child: Text("Individual"),
                    ),
                    DropdownMenuItem(
                      value: "Corporate",
                      child: Text("Corporate"),
                    ),
                    DropdownMenuItem(
                      value: "Service Provider",
                      child: Text("Service Provider"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _vendorType = val;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Vendor Type",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: r"Price ($)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Price is required";
                          }
                          if (double.tryParse(v) == null) {
                            return "Invalid price";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Discount %",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            final pct = int.tryParse(v);
                            if (pct == null || pct < 0 || pct > 100) {
                              return "Must be 0-100%";
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _validityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Validity (in days)",
                    helperText: "Use -1 for unlimited validity",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Validity is required";
                    }
                    if (int.tryParse(v) == null) {
                      return "Invalid validity";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: includeWebsite,
                  activeThumbColor: const Color(0xff006565),
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Inclusive of Website",
                  ),
                  onChanged: (value) {
                    setState(() {
                      includeWebsite = value;
                    });
                  },
                ),
                if (includeWebsite) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _websitesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "No. of Websites",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (includeWebsite) {
                        if (v == null || v.isEmpty) {
                          return "Website count is required";
                        }
                        final count = int.tryParse(v);
                        if (count == null || count <= 0) {
                          return "Must be greater than 0";
                        }
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _infoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Additional Information",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006565),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text("Create Plan"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
