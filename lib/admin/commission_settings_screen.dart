import 'package:flutter/material.dart';

// ADJUST THESE IMPORT PATHS to match where these files actually live in
// your project (they mirror the ones used inside database.dart).
import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';

class CommissionSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const CommissionSettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<CommissionSettingsScreen> createState() => _CommissionSettingsScreenState();
}

class _CommissionSettingsScreenState extends State<CommissionSettingsScreen> {
  // ══════════════════════════════════════════════════════════
  // API SETUP
  // ══════════════════════════════════════════════════════════
  final Database _db = Database();

  // TODO: set this to the actual relative path of the PHP file you shared
  // (it lives alongside social_feed_api.php etc. — same pattern used for
  // `feedEndpoint` in database.dart). Update the filename to match yours.
  static const String _commissionEndpoint = 'new_apis/membership_commission_api.php';

  String? _vendorId; // sent as vendor_id on every call, per the PHP auth check

  Future<Map> _call(Map<String, dynamic> body) async {
    final merged = {
      ...body,
      if (_vendorId != null && _vendorId!.isNotEmpty) 'vendor_id': _vendorId,
    };
    return _db.getData(merged, endpoint: _commissionEndpoint);
  }

  // Deliverable Type -> marketplace_id used by the API (5 = products, 16 = services).
  // There's no explicit "physical vs digital" field in the API you shared, so
  // both Digital and Physical map to marketplace 5 (products) here. Adjust if
  // your backend distinguishes them differently (e.g. via item_type).
  static const Map<String, int> _deliverableMarketplaceMap = {
    "Digital": 5,
    "Services": 16,
    "Physical": 5,
  };

  // Navigation/Step State
  int _activeStep = 1;

  // Form Values
  Map<String, dynamic>? _selectedSiteData; // Step 1 (host / membership site)
  final Set<int> _selectedStakeholderIds = {}; // Step 2 (vendor_type ids)
  Map<String, dynamic>? _selectedTierData; // Step 3 (membership)
  Map<String, dynamic>? _selectedProductSourceSiteData; // Step 4 (target site)
  String _selectedDeliverable = "Digital"; // Step 5
  Map<String, dynamic>? _selectedProductData; // Step 6
  String _commissionType = "fixed"; // fixed or slab
  String _fixedPaymentType = "PERCENTAGE"; // FLAT or PERCENTAGE
  final TextEditingController _fixedRateController = TextEditingController(text: "12.5");
  bool _confirmedCompliance = false;
  bool _isSubmitting = false;

  // Search controllers
  final TextEditingController _siteSearchController = TextEditingController();
  final TextEditingController _productSearchController = TextEditingController();

  // Fetched data
  bool _loadingSites = false;
  String? _sitesError;
  List<Map<String, dynamic>> _sites = [];

  bool _loadingStakeholders = false;
  String? _stakeholdersError;
  List<Map<String, dynamic>> _stakeholderGroups = []; // [{parent_title, vendor_types:[{id,title}]}]

  bool _loadingTiers = false;
  String? _tiersError;
  List<Map<String, dynamic>> _tiers = [];

  bool _loadingProducts = false;
  String? _productsError;
  List<Map<String, dynamic>> _products = [];

  // Scroll details for stepping
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _stepKeys = {
    1: GlobalKey(),
    2: GlobalKey(),
    3: GlobalKey(),
    4: GlobalKey(),
    5: GlobalKey(),
    6: GlobalKey(),
    7: GlobalKey(),
    8: GlobalKey(), // Final Review
  };

  // Color constants (Theme aligned)
  static const Color primaryTeal = Color(0xFF006565);
  static const Color darkTeal = Color(0xFF004D40);
  static const Color containerTeal = Color(0xFFE3FFFE);
  static const Color bgLight = Color(0xFFF9F9F9);
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textLight = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color secondaryContainer = Color(0xFFB0EEED);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _vendorId = await UserSessionSet.instance.vendorId;
    await _loadSites();
  }

  @override
  void dispose() {
    _fixedRateController.dispose();
    _siteSearchController.dispose();
    _productSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _completeStep(int stepNumber) {
    setState(() {
      if (_activeStep == stepNumber) {
        _activeStep = stepNumber + 1;
      }
    });
    // Scroll to the next step after a tiny delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStep(_activeStep);
    });
  }

  void _scrollToStep(int stepNum) {
    final key = _stepKeys[stepNum];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // API CALLS
  // ══════════════════════════════════════════════════════════

  Future<void> _loadSites() async {
    setState(() {
      _loadingSites = true;
      _sitesError = null;
    });
    final result = await _call({'action': 'get_sites','vendor_id': UserSessionSet.instance.vendorId,
    });
    if (!mounted) return;
    if (result['success'] == true) {
      final data = (result['data'] as List? ?? []).cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _sites = data;
        _loadingSites = false;
      });
    } else {
      setState(() {
        _sitesError = result['message']?.toString() ?? 'Failed to load sites';
        _loadingSites = false;
      });
    }
  }

  Future<void> _loadStakeholders(int siteId) async {
    setState(() {
      _loadingStakeholders = true;
      _stakeholdersError = null;
      _stakeholderGroups = [];
      _selectedStakeholderIds.clear();
    });
    final result = await _call({
      'action': 'load_membership_stakeholders',
      'site_id': siteId,
      'vendor_id': UserSessionSet.instance.vendorId,

    });
    if (!mounted) return;
    if (result['success'] == true) {
      final data = (result['data'] as List? ?? []).cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _stakeholderGroups = data;
        _loadingStakeholders = false;
      });
    } else {
      setState(() {
        _stakeholdersError = result['message']?.toString() ?? 'Failed to load stakeholders';
        _loadingStakeholders = false;
      });
    }
  }

  Future<void> _loadTiers() async {
    if (_selectedStakeholderIds.isEmpty) return;
    setState(() {
      _loadingTiers = true;
      _tiersError = null;
      _tiers = [];
      _selectedTierData = null;
    });
    final result = await _call({
      'action': 'load_vendor_memberships',
      'vendor_id': UserSessionSet.instance.vendorId,

    });
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'];
      final memberships = data is Map ? (data['memberships'] as List? ?? []) : (data as List? ?? []);
      final list = memberships.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _tiers = list;
        _loadingTiers = false;
      });
    } else {
      setState(() {
        _tiersError = result['message']?.toString() ?? 'Failed to load tiers';
        _loadingTiers = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    if (_selectedSiteData == null ||
        _selectedProductSourceSiteData == null ||
        _selectedTierData == null) {
      return;
    }
    setState(() {
      _loadingProducts = true;
      _productsError = null;
      _products = [];
      _selectedProductData = null;
    });

    final marketplaceId = _deliverableMarketplaceMap[_selectedDeliverable] ?? 5;

    final result = await _call({
      'action': 'load_product_mkp_product',
      'site_id': _selectedProductSourceSiteData!['id'],
      'product_type': 3, // item-level listing
      'marketplace_id': marketplaceId,
      'membership_id': _selectedTierData!['id'],
      'membership_site_id': _selectedSiteData!['id'],
      'offset': 0,
      'limit': 20,
      'vendor_id': UserSessionSet.instance.vendorId,

    });

    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'];
      final items = data is Map ? (data['items'] as List? ?? []) : (data as List? ?? []);
      final list = items.cast<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _products = list;
        _loadingProducts = false;
      });
    } else {
      setState(() {
        _productsError = result['message']?.toString() ?? 'Failed to load products';
        _loadingProducts = false;
      });
    }
  }

  Future<void> _submitCommission() async {
    if (_selectedSiteData == null ||
        _selectedProductSourceSiteData == null ||
        _selectedTierData == null ||
        _selectedProductData == null) {
      _showError("Please complete all steps before finalizing.");
      return;
    }

    setState(() => _isSubmitting = true);

    final marketplaceId = _deliverableMarketplaceMap[_selectedDeliverable] ?? 5;

    final Map<String, dynamic> body = {
      'action': 'set_commission',
      'membership_site_id': _selectedSiteData!['id'],
      'product_site_id': _selectedProductSourceSiteData!['id'],
      'membership_id': _selectedTierData!['id'],
      'marketplace_id': marketplaceId,
      'product_id': _selectedProductData!['id'],
      'commission_type': _commissionType == 'fixed' ? 'FIXED' : 'SLAB',
      'inclusive_tax': 0,
      'vendor_id': UserSessionSet.instance.vendorId,

    };

    if (_commissionType == 'fixed') {
      body['fixed_type'] = _fixedPaymentType; // 'FLAT' or 'PERCENTAGE'
      body['fixed_rate'] = double.tryParse(_fixedRateController.text) ?? 0;
    } else {
      // NOTE: the Slab table in Step 7 is currently a static preview
      // ("$0–$5k" @ 5.0%, "$5k–$25k" @ 8.5%). Wiring these rows up to be
      // dynamically editable is a separate UI change — for now we submit
      // the same two rows shown on screen so SLAB mode still works.
      body['comm_type'] = ['PERCENTAGE', 'PERCENTAGE'];
      body['min_order'] = [0, 5000];
      body['max_order'] = [5000, 25000];
      body['comm_rate'] = [5.0, 8.5];
      body['continue_commission'] = 0;
    }

    final result = await _call(body);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Commission configuration successfully submitted!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showError(result['message']?.toString() ?? 'Failed to submit commission');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (only shown if not embedded)
          if (!widget.isEmbedded) ...[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: primaryTeal),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Commission Setup",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Step 1: Select Membership Site
          _buildStepCard(
            stepNumber: 1,
            title: "Select Membership Site",
            subtitle: "Choose the host entity for this commission profile.",
            child: _buildSiteSelectionWidget(),
          ),
          const SizedBox(height: 16),

          // Step 2: Choose Stakeholders
          _buildStepCard(
            stepNumber: 2,
            title: "Choose Stakeholders",
            subtitle: "Define who is involved in this profit sharing.",
            child: _buildStakeholdersWidget(),
          ),
          const SizedBox(height: 16),

          // Step 3: Tier Selection
          _buildStepCard(
            stepNumber: 3,
            title: "Tier Selection",
            subtitle: "Select the membership performance tier.",
            child: _buildTierSelectionWidget(),
          ),
          const SizedBox(height: 16),

          // Step 4: Product Source
          _buildStepCard(
            stepNumber: 4,
            title: "Select Product Site",
            subtitle: "Where are the products sourced from?",
            child: _buildProductSourceWidget(),
          ),
          const SizedBox(height: 16),

          // Step 5: Deliverable Type
          _buildStepCard(
            stepNumber: 5,
            title: "Deliverable Type",
            subtitle: "Define the nature of the goods.",
            child: _buildDeliverableTypeWidget(),
          ),
          const SizedBox(height: 16),

          // Step 6: Browse Products
          _buildStepCard(
            stepNumber: 6,
            title: "Browse Products",
            subtitle: "Verify eligible inventory items.",
            child: _buildBrowseProductsWidget(),
          ),
          const SizedBox(height: 16),

          // Step 7: Configure Commission
          _buildStepCard(
            stepNumber: 7,
            title: "Commission Structure",
            subtitle: "Finalize the financial logic.",
            child: _buildCommissionStructureWidget(),
          ),
          const SizedBox(height: 24),

          // Final Review
          _buildFinalReviewWidget(),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: bgLight,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
        title: const Text("Commission Setup"),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          content,
          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // Helper helper to build a consistent Step card layout
  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final bool isActive = _activeStep == stepNumber;
    final bool isCompleted = _activeStep > stepNumber;
    final key = _stepKeys[stepNumber];

    return IgnorePointer(
      ignoring: !isActive && !isCompleted,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : (isCompleted ? 0.7 : 0.35),
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: key,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? primaryTeal : outlineVariant.withOpacity(0.5),
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: primaryTeal.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Marker
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? secondaryContainer
                          : (isActive ? primaryTeal : Colors.grey[200]),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: primaryTeal)
                        : Text(
                      "$stepNumber",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : textLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Body (Only show if active or completed to save space and make it neat)
              if (isActive || isCompleted) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: outlineVariant),
                const SizedBox(height: 12),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STEP WIDGETS
  // ══════════════════════════════════════════════════════════

  // Step 1: Select Membership Site (from GET_SITES)
  Widget _buildSiteSelectionWidget() {
    if (_loadingSites) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal)),
      );
    }
    if (_sitesError != null) {
      return _buildRetryBlock(_sitesError!, _loadSites);
    }

    final filteredSites = _sites.where((s) {
      final name = (s["site_name"] ?? "").toString().toLowerCase();
      final id = (s["id"] ?? "").toString().toLowerCase();
      final q = _siteSearchController.text.toLowerCase();
      return name.contains(q) || id.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        TextField(
          controller: _siteSearchController,
          style: const TextStyle(fontSize: 12),
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            hintText: "Search sites...",
            hintStyle: const TextStyle(fontSize: 11, color: textLight),
            prefixIcon: const Icon(Icons.search, size: 16, color: textLight),
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: primaryTeal),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (filteredSites.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("No sites found.", style: TextStyle(fontSize: 11, color: textLight)),
          ),
        // Site list
        ...filteredSites.map((site) {
          final siteId = site["id"];
          final isSelected = _selectedSiteData != null && _selectedSiteData!["id"] == siteId;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSiteData = site;
              });
              _loadStakeholders(int.parse(siteId.toString()));
              _completeStep(1);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? containerTeal : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? primaryTeal : outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? secondaryContainer : Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.hub,
                      color: isSelected ? primaryTeal : textLight,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (site["site_name"] ?? "Untitled Site").toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                        Text(
                          "Internal ID: ${site["id"]}",
                          style: const TextStyle(fontSize: 10, color: textLight),
                        ),
                      ],
                    ),
                  ),
                  Radio<dynamic>(
                    value: siteId,
                    groupValue: _selectedSiteData?["id"],
                    activeColor: primaryTeal,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      setState(() {
                        _selectedSiteData = site;
                      });
                      _loadStakeholders(int.parse(siteId.toString()));
                      _completeStep(1);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // Step 2: Choose Stakeholders (from LOAD_MEMBERSHIP_STAKEHOLDERS)
  Widget _buildStakeholdersWidget() {
    if (_loadingStakeholders) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal)),
      );
    }
    if (_stakeholdersError != null) {
      return _buildRetryBlock(
        _stakeholdersError!,
            () => _selectedSiteData != null
            ? _loadStakeholders(int.parse(_selectedSiteData!["id"].toString()))
            : null,
      );
    }

    // Flatten all vendor_types across parent groups into chips.
    final List<Map<String, dynamic>> allTypes = [];
    for (final group in _stakeholderGroups) {
      final types = (group["vendor_types"] as List? ?? []).cast<Map>();
      for (final t in types) {
        allTypes.add(Map<String, dynamic>.from(t));
      }
    }

    if (allTypes.isEmpty) {
      return const Text(
        "No stakeholders available for this site yet.",
        style: TextStyle(fontSize: 11, color: textLight),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allTypes.map((t) {
            final id = int.parse(t["id"].toString());
            final title = (t["title"] ?? "").toString();
            final isSelected = _selectedStakeholderIds.contains(id);
            return FilterChip(
              label: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : textLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryTeal,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? primaryTeal : outlineVariant.withOpacity(0.8),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedStakeholderIds.add(id);
                  } else {
                    _selectedStakeholderIds.remove(id);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _selectedStakeholderIds.isEmpty
                ? null
                : () async {
              await _loadTiers();
              _completeStep(2);
            },
            icon: const Icon(Icons.arrow_downward, size: 14, color: primaryTeal),
            label: const Text(
              "CONTINUE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryTeal,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Tier Selection (from LOAD_VENDOR_MEMBERSHIPS)
  Widget _buildTierSelectionWidget() {
    if (_loadingTiers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal)),
      );
    }
    if (_tiersError != null) {
      return _buildRetryBlock(_tiersError!, _loadTiers);
    }
    if (_tiers.isEmpty) {
      return const Text(
        "No membership tiers found for the selected stakeholders.",
        style: TextStyle(fontSize: 11, color: textLight),
      );
    }

    return Column(
      children: _tiers.map((tier) {
        final tierId = tier["id"];
        final isSelected = _selectedTierData != null && _selectedTierData!["id"] == tierId;
        final price = tier["discounted_price"] ?? tier["price"] ?? 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTierData = tier;
            });
            _completeStep(3);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primaryTeal : outlineVariant.withOpacity(0.5),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: primaryTeal.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (tier["site_name"] ?? "").toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        "\$$price",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (tier["title"] ?? "Untitled Tier").toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Step 4: Product Source (reuses GET_SITES for the target site)
  Widget _buildProductSourceWidget() {
    if (_loadingSites) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal)),
      );
    }
    if (_sitesError != null) {
      return _buildRetryBlock(_sitesError!, _loadSites);
    }

    return Column(
      children: _sites.map((source) {
        final sourceId = source["id"];
        final isSelected = _selectedProductSourceSiteData != null &&
            _selectedProductSourceSiteData!["id"] == sourceId;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedProductSourceSiteData = source;
            });
            _completeStep(4);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? primaryTeal : outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (source["site_name"] ?? "Untitled Site").toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Text(
                        "Internal ID: ${source["id"]}",
                        style: const TextStyle(fontSize: 10, color: textLight),
                      ),
                    ],
                  ),
                ),
                Radio<dynamic>(
                  value: sourceId,
                  groupValue: _selectedProductSourceSiteData?["id"],
                  activeColor: primaryTeal,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) {
                    setState(() {
                      _selectedProductSourceSiteData = source;
                    });
                    _completeStep(4);
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Step 5: Deliverable Type (maps to marketplace_id; triggers product load)
  Widget _buildDeliverableTypeWidget() {
    final deliverables = [
      {"name": "Digital", "icon": Icons.download},
      {"name": "Services", "icon": Icons.medical_services},
      {"name": "Physical", "icon": Icons.local_shipping},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 1.2,
      children: deliverables.map((d) {
        final isSelected = _selectedDeliverable == d["name"];
        return GestureDetector(
          onTap: () async {
            setState(() {
              _selectedDeliverable = d["name"] as String;
            });
            _completeStep(5);
            await _loadProducts();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? primaryTeal : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? primaryTeal : outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  d["icon"] as IconData,
                  color: isSelected ? Colors.white : primaryTeal,
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  (d["name"] as String).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Step 6: Browse Products (from LOAD_PRODUCT_MKP_PRODUCT)
  Widget _buildBrowseProductsWidget() {
    if (_loadingProducts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal)),
      );
    }
    if (_productsError != null) {
      return _buildRetryBlock(_productsError!, _loadProducts);
    }

    final filteredProducts = _products.where((p) {
      final name = (p["title"] ?? "").toString().toLowerCase();
      return name.contains(_productSearchController.text.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search filter
        TextField(
          controller: _productSearchController,
          style: const TextStyle(fontSize: 12),
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            hintText: "Filter SKUs...",
            hintStyle: const TextStyle(fontSize: 11, color: textLight),
            prefixIcon: const Icon(Icons.search, size: 16, color: textLight),
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: primaryTeal),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (filteredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("No products found.", style: TextStyle(fontSize: 11, color: textLight)),
          ),
        // Grid view
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: filteredProducts.map((p) {
            final isSelected = _selectedProductData != null && _selectedProductData!["id"] == p["id"];
            final imageUrl = (p["banner"] ?? "").toString();
            final priceDisplay = (p["price_display"] ?? p["price"] ?? "").toString();
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProductData = p;
                  // Prefill the fixed rate from an existing commission if one is set.
                  final existingRate = p["comm_rate_array"];
                  if (p["commission_set"] == true && existingRate is List && existingRate.isNotEmpty) {
                    _fixedRateController.text = existingRate.first.toString();
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? primaryTeal : outlineVariant.withOpacity(0.5),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: Colors.grey[100],
                              width: double.infinity,
                              child: imageUrl.isEmpty
                                  ? const Center(child: Icon(Icons.image, color: textLight, size: 24))
                                  : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(Icons.image, color: textLight, size: 24),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (p["title"] ?? "").toString().toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: textLight,
                          ),
                        ),
                        Text(
                          "\$$priceDisplay",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isSelected ? primaryTeal : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? primaryTeal : outlineVariant,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isSelected
                            ? const Icon(Icons.check, size: 10, color: Colors.white)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 34,
          child: OutlinedButton(
            onPressed: _selectedProductData == null ? null : () => _completeStep(6),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryTeal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              foregroundColor: primaryTeal,
            ),
            child: const Text(
              "CONFIRM LIST",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Step 7: Configure Commission (submits via SET_COMMISSION on Finalize)
  Widget _buildCommissionStructureWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle buttons (FIXED RATE / SLAB BASED)
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _commissionType = "fixed"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _commissionType == "fixed" ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _commissionType == "fixed"
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "FIXED RATE",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _commissionType == "fixed" ? primaryTeal : textLight,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _commissionType = "slab"),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _commissionType == "slab" ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _commissionType == "slab"
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "SLAB BASED",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _commissionType == "slab" ? primaryTeal : textLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (_commissionType == "fixed") ...[
          // Fixed Rate UI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "STANDARD RATE",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textLight),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fixedRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryTeal,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      "%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Payment type toggle (PERCENTAGE vs FLAT), required by set_commission
          Row(
            children: [
              const Text("Rate type:", style: TextStyle(fontSize: 10, color: textLight)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Percentage", style: TextStyle(fontSize: 10)),
                selected: _fixedPaymentType == "PERCENTAGE",
                selectedColor: primaryTeal,
                labelStyle: TextStyle(
                  color: _fixedPaymentType == "PERCENTAGE" ? Colors.white : textLight,
                ),
                onSelected: (_) => setState(() => _fixedPaymentType = "PERCENTAGE"),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text("Flat", style: TextStyle(fontSize: 10)),
                selected: _fixedPaymentType == "FLAT",
                selectedColor: primaryTeal,
                labelStyle: TextStyle(
                  color: _fixedPaymentType == "FLAT" ? Colors.white : textLight,
                ),
                onSelected: (_) => setState(() => _fixedPaymentType = "FLAT"),
              ),
            ],
          ),
        ] else ...[
          // Slab Based Table UI (static preview — see note in _submitCommission)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: outlineVariant.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Revenue Range",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark),
                        ),
                      ),
                      Text(
                        "Rate",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: outlineVariant),
                _buildSlabRow("\$0 — \$5k", "5.0%"),
                const Divider(height: 1, color: outlineVariant),
                _buildSlabRow("\$5k — \$25k", "8.5%"),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),
        // Compliance Checkbox
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: containerTeal,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: primaryTeal.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: _confirmedCompliance,
                  activeColor: primaryTeal,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) {
                    setState(() {
                      _confirmedCompliance = val!;
                    });
                    if (val!) {
                      _completeStep(7);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "I confirm that these commission parameters meet compliance standards.",
                  style: TextStyle(
                    fontSize: 10,
                    color: textLight,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlabRow(String range, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              range,
              style: const TextStyle(fontSize: 11, color: textLight),
            ),
          ),
          Text(
            rate,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryTeal),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryBlock(String message, VoidCallback? onRetry) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 11, color: Colors.red)),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text("Retry", style: TextStyle(fontSize: 11, color: primaryTeal)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FINAL REVIEW WIDGET
  // ══════════════════════════════════════════════════════════

  Widget _buildFinalReviewWidget() {
    final bool showReview = _activeStep >= 8;
    final key = _stepKeys[8];

    return AnimatedOpacity(
      opacity: showReview ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: key,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Final Review",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    Text(
                      "Summary of configuration dossier",
                      style: TextStyle(fontSize: 10, color: textLight),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _buildSummaryRow("Site:", (_selectedSiteData?["site_name"] ?? "-").toString()),
                  const SizedBox(height: 6),
                  _buildSummaryRow("Membership:", "${(_selectedTierData?["title"] ?? "-")} Tier"),
                  const SizedBox(height: 6),
                  _buildSummaryRow(
                    "Commission:",
                    _commissionType == "fixed"
                        ? "${_fixedRateController.text}% Fixed"
                        : "Slab Based",
                    isCommission: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isCommission = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: textLight),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isCommission ? primaryTeal : textDark,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // FOOTER ACTION BAR
  // ══════════════════════════════════════════════════════════

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: outlineVariant, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // SAVE DRAFT
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Draft saved successfully!"),
                      backgroundColor: primaryTeal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  foregroundColor: primaryTeal,
                ),
                child: const Text(
                  "SAVE DRAFT",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // FINALIZE COMMISSION
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                  if (!_confirmedCompliance) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please confirm compliance standards checkbox to proceed."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: const Text(
                        "Confirm Commission Setup",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      content: const Text(
                        "Are you sure you want to finalize and submit this commission configuration?",
                        style: TextStyle(fontSize: 12, color: textLight),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: textLight, fontSize: 12),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _submitCommission();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text(
                            "Finalize",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text(
                  "FINALIZE COMMISSION",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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