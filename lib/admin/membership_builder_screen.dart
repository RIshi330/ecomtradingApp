import 'package:flutter/material.dart';
import '../Database/Database.dart';

class MembershipBuilderScreen extends StatefulWidget {
  final bool isEmbedded;
  const MembershipBuilderScreen({super.key, this.isEmbedded = false});

  @override
  State<MembershipBuilderScreen> createState() =>
      _MembershipBuilderScreenState();
}

class _MembershipBuilderScreenState
    extends State<MembershipBuilderScreen> {
  final TextEditingController searchController = TextEditingController();
  List<PlanModel> plans = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  void openAddMembershipSheet({Map<String, dynamic>? templateData, PlanModel? editPlan}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      builder: (context) {
        return AddMembershipBottomSheet(
          onPlanCreated: _fetchPlans,
          templateData: templateData,
          editPlan: editPlan,
        );
      },
    );
  }

  final List<TemplatePlan> templates = [
    TemplatePlan(
      title: "Basic Plan",
      price: "\$0",
      icon: Icons.person,
      description: "Perfect for individuals starting their journey.",
      features: [
        "30 Days Validity",
        "5 Marketplace Posts",
      ],
      vendorType: "Individual",
      validityDays: "30",
      includeWebsite: false,
      numberOfWebsites: "0",
    ),
    TemplatePlan(
      title: "Pro Professional",
      price: "\$29",
      icon: Icons.workspace_premium,
      description: "Advance features for growing businesses.",
      features: [
        "365 Days Validity",
        "Unlimited Marketplace Access",
      ],
      vendorType: "Individual",
      validityDays: "365",
      includeWebsite: false,
      numberOfWebsites: "0",
    ),
    TemplatePlan(
      title: "Enterprise Suite",
      price: "\$499",
      icon: Icons.business,
      description: "Tailored for large scale organizations.",
      features: [
        "Custom Validity",
        "Dedicated API & Support",
      ],
      vendorType: "Corporate",
      validityDays: "365",
      includeWebsite: true,
      numberOfWebsites: "5",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter plans locally
    final filteredPlans = plans.where((plan) {
      if (_searchQuery.isEmpty) return true;
      return plan.title.toLowerCase().contains(_searchQuery) ||
          plan.description.toLowerCase().contains(_searchQuery) ||
          plan.type.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                "Membership",
                style: TextStyle(
                  color: Color(0xFF1C1B1B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                      onPressed: () => Navigator.pop(context),
                    )
                  : IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.menu,
                        color: Color(0xff006565),
                      ),
                    ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.account_circle,
                    color: Color(0xff006565),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff006565),
        foregroundColor: Colors.white,
        onPressed: () => openAddMembershipSheet(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: widget.isEmbedded
          ? null
          : BottomNavigationBar(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    /// SEARCH
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: "Search plans by title...",
                              prefixIcon: const Icon(Icons.search, color: Color(0xff006565)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE6E6F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xff006565)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        filterButton(
                          Icons.filter_list,
                          "Filters",
                        ),
                        const SizedBox(width: 10),
                        filterButton(
                          Icons.sort,
                          "Sort",
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Choose from Templates",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1C1B1B),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Quick-start with pre-configured plan types",
                                style: TextStyle(color: Color(0xFF3E4949), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "See All",
                            style: TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// TEMPLATE CARDS
                    SizedBox(
                      height: 275,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: templates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return templateCard(
                            templates[index],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Active Membership Plans",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (_isLoading && plans.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006565)),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff006565),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _fetchPlans,
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (filteredPlans.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            "No membership plans found matching your search.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredPlans.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisExtent: 290,
                          mainAxisSpacing: 16,
                        ),
                        itemBuilder: (context, index) {
                          final plan = filteredPlans[index];

                          // Resolve specific color variations for categories to stay within the theme
                          Color categoryColor;
                          if (plan.type.toLowerCase() == "individual") {
                            categoryColor = const Color(0xff006565);
                          } else if (plan.type.toLowerCase() == "corporate") {
                            categoryColor = const Color(0xff0F4D4D);
                          } else {
                            categoryColor = const Color(0xff2A7F7F);
                          }

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffE6E6F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// TOP
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: categoryColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        plan.type,
                                        style: TextStyle(
                                          color: categoryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                                      onSelected: (value) {
                                        if (value == "edit") {
                                          openAddMembershipSheet(editPlan: plan);
                                        } else if (value == "delete") {
                                          _deletePlan(plan.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: "edit",
                                          child: Text("Edit"),
                                        ),
                                        const PopupMenuItem(
                                          value: "delete",
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF1C1B1B),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  plan.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),

                                const Spacer(),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (plan.discountAmount > 0) ...[
                                      Text(
                                        "\$${plan.price.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      "\$${plan.finalPrice.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff006565),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        plan.validity == -1
                                            ? "/ unlimited"
                                            : "/ ${plan.validity} days",
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: plan.status == 1 ? () => _changeStatus(plan.id, 0) : null,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.orange,
                                          side: BorderSide(
                                            color: plan.status == 1 ? Colors.orange : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: const Text("Suspend"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xff006565),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: Colors.grey.shade300,
                                          disabledForegroundColor: Colors.grey.shade500,
                                        ),
                                        onPressed: plan.status == 0 ? () => _changeStatus(plan.id, 1) : null,
                                        child: const Text("Approve"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: IconButton(
                                        onPressed: () => _deletePlan(plan.id),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget filterButton(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffE6E6F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xff006565)),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1C1B1B))),
        ],
      ),
    );
  }

  Widget templateCard(TemplatePlan plan) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffE6E6F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                plan.icon,
                color: const Color(0xff006565),
              ),
              Text(
                plan.price,
                style: const TextStyle(
                  color: Color(0xff006565),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            plan.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1C1B1B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            plan.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF3E4949), fontSize: 13),
          ),
          const Spacer(),
          ...plan.features.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(color: Color(0xFF3E4949), fontSize: 13),
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
              onPressed: () => openAddMembershipSheet(
                templateData: {
                  "title": plan.title,
                  "price": plan.price.replaceAll('\$', ''),
                  "validity": plan.validityDays,
                  "description": plan.description,
                  "vendorType": plan.vendorType,
                  "includeWebsite": plan.includeWebsite,
                  "numberOfWebsites": plan.numberOfWebsites,
                },
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006565),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Use Template"),
            ),
          ),
        ],
      ),
    );
  }
}

class TemplatePlan {
  final String title;
  final String price;
  final IconData icon;
  final String description;
  final List<String> features;
  final String vendorType;
  final String validityDays;
  final bool includeWebsite;
  final String numberOfWebsites;

  TemplatePlan({
    required this.title,
    required this.price,
    required this.icon,
    required this.description,
    required this.features,
    required this.vendorType,
    required this.validityDays,
    required this.includeWebsite,
    required this.numberOfWebsites,
  });
}

class AddMembershipBottomSheet extends StatefulWidget {
  final VoidCallback? onPlanCreated;
  final Map<String, dynamic>? templateData;
  final PlanModel? editPlan;

  const AddMembershipBottomSheet({
    super.key,
    this.onPlanCreated,
    this.templateData,
    this.editPlan,
  });

  @override
  State<AddMembershipBottomSheet> createState() =>
      _AddMembershipBottomSheetState();
}

class _AddMembershipBottomSheetState
    extends State<AddMembershipBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _validityController;
  late final TextEditingController _cashbackController;
  late final TextEditingController _websitesController;
  late final TextEditingController _infoController;

  bool websiteIncluded = false;
  bool _isSubmitting = false;
  String _vendorType = "Individual";

  List<PostingLimitRow> postingRows = [
    PostingLimitRow(),
  ];

  List<ListingAccessRow> listingRows = [
    ListingAccessRow(),
  ];

  final List<String> marketplaceTypes = [
    "B2B Marketplace",
    "B2C Marketplace",
    "Service Marketplace",
    "Opportunity"
  ];

  final List<String> listingTypes = [
    "Global Directory",
    "Regional Listing",
    "Verified Partners"
  ];

  @override
  void initState() {
    super.initState();

    final template = widget.templateData;
    final editPlan = widget.editPlan;

    if (editPlan != null) {
      _titleController = TextEditingController(text: editPlan.title);
      _priceController = TextEditingController(text: editPlan.price.toStringAsFixed(0));
      _discountController = TextEditingController(text: editPlan.discountAmount.toStringAsFixed(0));
      _validityController = TextEditingController(text: editPlan.validity.toString());
      _cashbackController = TextEditingController(text: "0");
      websiteIncluded = editPlan.numberOfWebsites > 0;
      _websitesController = TextEditingController(text: editPlan.numberOfWebsites.toString());
      _infoController = TextEditingController(text: editPlan.description);
      _vendorType = editPlan.type;
    } else {
      _titleController = TextEditingController(text: template?['title']?.toString() ?? '');
      _priceController = TextEditingController(text: template?['price']?.toString() ?? '');
      _discountController = TextEditingController(text: '0');
      _validityController = TextEditingController(text: template?['validity']?.toString() ?? '30');
      _cashbackController = TextEditingController(text: '0');
      websiteIncluded = template?['includeWebsite'] as bool? ?? false;
      _websitesController = TextEditingController(text: template?['numberOfWebsites']?.toString() ?? '0');
      _infoController = TextEditingController(text: template?['description']?.toString() ?? '');
      _vendorType = template?['vendorType']?.toString() ?? 'Individual';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _validityController.dispose();
    _cashbackController.dispose();
    _websitesController.dispose();
    _infoController.dispose();
    for (var r in postingRows) {
      r.controller.dispose();
    }
    for (var r in listingRows) {
      r.controller.dispose();
    }
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
        "inc_free_website": websiteIncluded ? 1 : 0,
        "number_of_websites":
            websiteIncluded ? (int.tryParse(_websitesController.text) ?? 0) : 0,
        "website_validity": websiteIncluded ? validity : 0,
        "vendorTypes": [vendorTypeId],
      };

      if (widget.editPlan != null) {
        requestBody["membership_id"] = widget.editPlan!.id;
      }

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
              res['message']?.toString() ?? "Plan saved successfully",
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
            content: Text(res['message']?.toString() ?? "Failed to save plan"),
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: controller,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                top: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Text(
                        widget.editPlan != null ? "Edit Membership" : "Add Membership",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1B1B),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  buildTextField(
                    label: "Plan Title",
                    hint: "Executive Platinum",
                    controller: _titleController,
                    validator: (v) => v == null || v.trim().isEmpty ? "Title is required" : null,
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: _vendorType,
                    decoration: inputDecoration("Vendor Type"),
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
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          label: "Price",
                          hint: "0",
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            if (double.tryParse(v) == null) return "Invalid";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(
                          label: "Discount %",
                          hint: "0",
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final pct = int.tryParse(v);
                              if (pct == null || pct < 0 || pct > 100) return "0-100%";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          label: "Validity Days",
                          hint: "30",
                          controller: _validityController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "Required";
                            if (int.tryParse(v) == null) return "Invalid";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(
                          label: "Cashback",
                          hint: "0",
                          controller: _cashbackController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// POSTING LIMITS
                  Row(
                    children: [
                      const Text(
                        "Marketplace Posting Limits",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1B1B),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            postingRows.add(PostingLimitRow());
                          });
                        },
                        icon: const Icon(Icons.add, color: Color(0xff006565)),
                        label: const Text(
                          "Add Row",
                          style: TextStyle(color: Color(0xff006565)),
                        ),
                      )
                    ],
                  ),

                  ...List.generate(
                    postingRows.length,
                    (index) => postingLimitWidget(index),
                  ),

                  const SizedBox(height: 20),

                  /// LISTING ACCESS
                  Row(
                    children: [
                      const Text(
                        "Marketplace Listing Access",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1B1B),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            listingRows.add(ListingAccessRow());
                          });
                        },
                        icon: const Icon(Icons.add, color: Color(0xff006565)),
                        label: const Text(
                          "Add Row",
                          style: TextStyle(color: Color(0xff006565)),
                        ),
                      )
                    ],
                  ),

                  ...List.generate(
                    listingRows.length,
                    (index) => listingAccessWidget(index),
                  ),

                  const SizedBox(height: 20),

                  /// WEBSITE TOGGLE
                  SwitchListTile(
                    title: const Text(
                      "Inclusive of Website",
                      style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1C1B1B)),
                    ),
                    value: websiteIncluded,
                    activeThumbColor: const Color(0xff006565),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        websiteIncluded = value;
                      });
                    },
                  ),

                  if (websiteIncluded) ...[
                    const SizedBox(height: 10),
                    buildTextField(
                      label: "No. Of Websites",
                      hint: "0",
                      controller: _websitesController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (websiteIncluded) {
                          if (v == null || v.isEmpty) return "Required";
                          final count = int.tryParse(v);
                          if (count == null || count <= 0) return "Must be > 0";
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _infoController,
                    maxLines: 5,
                    decoration: inputDecoration("Additional Information"),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006565),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitForm,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(widget.editPlan != null ? "Save Changes" : "Create Plan"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget postingLimitWidget(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: postingRows[index].type,
              decoration: inputDecoration("Type"),
              items: marketplaceTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    postingRows[index].type = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: postingRows[index].controller,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Limit"),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                postingRows.removeAt(index);
              });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  Widget listingAccessWidget(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: listingRows[index].type,
              decoration: inputDecoration("Type"),
              items: listingTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    listingRows[index].type = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: listingRows[index].controller,
              keyboardType: TextInputType.number,
              decoration: inputDecoration("Access"),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                listingRows.removeAt(index);
              });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: inputDecoration(label).copyWith(
        hintText: hint,
      ),
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF3E4949)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffE6E6F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xff006565)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

class PostingLimitRow {
  String type;
  final TextEditingController controller;

  PostingLimitRow({
    this.type = "B2B Marketplace",
    String limit = "0",
  }) : controller = TextEditingController(text: limit);
}

class ListingAccessRow {
  String type;
  final TextEditingController controller;

  ListingAccessRow({
    this.type = "Global Directory",
    String limit = "0",
  }) : controller = TextEditingController(text: limit);
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
