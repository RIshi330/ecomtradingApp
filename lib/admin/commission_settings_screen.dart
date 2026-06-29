import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class CommissionSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const CommissionSettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<CommissionSettingsScreen> createState() => _CommissionSettingsScreenState();
}

class _CommissionSettingsScreenState extends State<CommissionSettingsScreen> {
  // Navigation/Step State
  int _activeStep = 1;
  
  // Loading flags
  bool _loadingSites = false;
  bool _loadingStakeholders = false;
  bool _loadingMemberships = false;
  bool _loadingProducts = false;
  bool _submittingCommission = false;

  // Lists loaded from backend
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _stakeholdersList = [];
  List<Map<String, dynamic>> _membershipsList = [];
  List<Map<String, dynamic>> _productsList = [];

  // Form Values
  int? _selectedSiteId;
  String _selectedSite = "";
  
  final Set<String> _selectedStakeholders = {};
  
  int? _selectedMembershipId;
  String _selectedTier = "";
  
  int? _selectedProductSiteId;
  String _selectedProductSource = "";
  
  String _selectedDeliverable = "Digital"; // Digital (37), Services (16), Physical (5)
  
  int? _selectedProductId;
  String _selectedProduct = "";
  
  String _commissionType = "fixed"; // fixed or slab
  final TextEditingController _fixedRateController = TextEditingController(text: "12.5");
  bool _confirmedCompliance = false;
  
  // Search controllers
  final TextEditingController _siteSearchController = TextEditingController();
  final TextEditingController _productSearchController = TextEditingController();

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
  static const Color containerTeal = Color(0xFFE3FFFE);
  static const Color bgLight = Color(0xFFF9F9F9);
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textLight = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color secondaryContainer = Color(0xFFB0EEED);

  @override
  void initState() {
    super.initState();
    _fetchSites();
  }

  @override
  void dispose() {
    _fixedRateController.dispose();
    _siteSearchController.dispose();
    _productSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // BACKEND API CALLS
  // ══════════════════════════════════════════════════════════

  Future<void> _fetchSites() async {
    setState(() => _loadingSites = true);
    try {
      final response = await Database().getData({
        'api': '1',
        'loadSites': '1',
      }, endpoint: 'new_apis/membership-commission-helper.php');
      
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _sites = List<Map<String, dynamic>>.from(response['data']);
          if (_sites.isNotEmpty && _selectedSiteId == null) {
            _selectedSiteId = int.tryParse(_sites[0]['id'].toString());
            _selectedSite = _sites[0]['site_name'].toString();
            // Automatically pre-load stakeholders
            _fetchStakeholders();
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading sites: $e");
    } finally {
      if (mounted) setState(() => _loadingSites = false);
    }
  }

  Future<void> _fetchStakeholders() async {
    if (_selectedSiteId == null) return;
    setState(() => _loadingStakeholders = true);
    try {
      final response = await Database().getData({
        'api': '1',
        'loadSiteVendors': _selectedSiteId.toString(),
      }, endpoint: 'new_apis/membership-commission-helper.php');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as List;
        final List<Map<String, dynamic>> temp = [];
        for (var group in data) {
          final vendors = group['vendors'] as List;
          for (var v in vendors) {
            temp.add({
              'id': v['id'].toString(),
              'title': v['title'].toString(),
              'parent_title': group['parent_title'].toString(),
            });
          }
        }
        setState(() {
          _stakeholdersList = temp;
          _selectedStakeholders.clear();
        });
      }
    } catch (e) {
      debugPrint("Error loading stakeholders: $e");
    } finally {
      if (mounted) setState(() => _loadingStakeholders = false);
    }
  }

  Future<void> _fetchMemberships() async {
    if (_selectedStakeholders.isEmpty) return;
    setState(() => _loadingMemberships = true);
    try {
      final vendorIds = _selectedStakeholders.join(",");
      final response = await Database().getData({
        'api': '1',
        'loadVendorMemberships': '1',
        'vendor_ids': vendorIds,
      }, endpoint: 'new_apis/membership-commission-helper.php');
      
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _membershipsList = List<Map<String, dynamic>>.from(response['data']);
          if (_membershipsList.isNotEmpty) {
            _selectedMembershipId = int.tryParse(_membershipsList[0]['id'].toString());
            _selectedTier = _membershipsList[0]['title'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading memberships: $e");
    } finally {
      if (mounted) setState(() => _loadingMemberships = false);
    }
  }

  Future<void> _fetchProducts() async {
    if (_selectedSiteId == null || _selectedProductSiteId == null || _selectedMembershipId == null) return;
    setState(() => _loadingProducts = true);
    
    // Map deliverable visually selected back to backend marketplace_ids
    final int mkpId = _selectedDeliverable == "Digital" ? 37 : (_selectedDeliverable == "Services" ? 16 : 5);
    
    try {
      final Map<String, String> body = {
        'api': '1',
        'site_id': _selectedProductSiteId.toString(),
        'membership_site_id': _selectedSiteId.toString(),
        'membership_id': _selectedMembershipId.toString(),
        'marketplace_id': mkpId.toString(),
        'offset': '0',
        'limit': '50',
      };
      
      dynamic response;
      if (mkpId == 37) {
        body['loadProductMemberships'] = '1';
        body['stakeholder_types'] = _selectedStakeholders.join(",");
        response = await Database().getData(body, endpoint: 'new_apis/membership-commission-helper.php');
      } else {
        body['loadProductMkpProduct'] = '1';
        body['product_type'] = '3'; // Item level
        response = await Database().getData(body, endpoint: 'new_apis/membership-commission-helper.php');
      }
      
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _productsList = List<Map<String, dynamic>>.from(response['data']);
          if (_productsList.isNotEmpty) {
            _selectedProductId = int.tryParse(_productsList[0]['id'].toString());
            _selectedProduct = _productsList[0]['title']?.toString() ?? _productsList[0]['product_title']?.toString() ?? "";
          } else {
            _selectedProductId = null;
            _selectedProduct = "";
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading products: $e");
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _submitCommissionSetup() async {
    if (_selectedSiteId == null || _selectedProductSiteId == null || _selectedMembershipId == null || _selectedProductId == null) return;
    setState(() => _submittingCommission = true);
    
    final int mkpId = _selectedDeliverable == "Digital" ? 37 : (_selectedDeliverable == "Services" ? 16 : 5);
    
    try {
      final Map<String, String> body = {
        'api': '1',
        'setCommission': '1',
        'membership_site_id': _selectedSiteId.toString(),
        'product_site_id': _selectedProductSiteId.toString(),
        'membership_id': _selectedMembershipId.toString(),
        'marketplace_id': mkpId.toString(),
        'product_id': _selectedProductId.toString(),
        'commission_type': _commissionType.toUpperCase(),
        'inclusive_tax': '1',
      };
      
      if (_commissionType == 'fixed') {
        body['fixed_type'] = 'PERCENTAGE';
        body['fixed_rate'] = _fixedRateController.text;
      } else {
        body['comm_type'] = '["PERCENTAGE", "PERCENTAGE"]';
        body['min_order'] = '[0, 5000]';
        body['max_order'] = '[5000, 25000]';
        body['comm_rate'] = '[5, 8.5]';
        body['continue_commission'] = '1';
      }
      
      final response = await Database().getData(body, endpoint: 'new_apis/membership-commission-helper.php');
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Commission configuration successfully submitted!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${response['message'] ?? 'Submission failed'}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error submitting commission: $e");
    } finally {
      if (mounted) setState(() => _submittingCommission = false);
    }
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
              color: isActive ? primaryTeal : outlineVariant.withValues(alpha: 0.5),
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryTeal.withValues(alpha: 0.08),
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

  // Step 1: Select Membership Site
  Widget _buildSiteSelectionWidget() {
    if (_loadingSites && _sites.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(primaryTeal)),
        ),
      );
    }

    final filteredSites = _sites
        .where((s) => (s["site_name"] as String).toLowerCase().contains(_siteSearchController.text.toLowerCase()) ||
            (s["id"] as String).toLowerCase().contains(_siteSearchController.text.toLowerCase()))
        .toList();

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
        // Site list
        ...filteredSites.map((site) {
          final isSelected = _selectedSiteId == int.tryParse(site["id"].toString());
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSiteId = int.tryParse(site["id"].toString());
                _selectedSite = site["site_name"] as String;
              });
              _fetchStakeholders();
              _completeStep(1);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? containerTeal : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? primaryTeal : outlineVariant.withValues(alpha: 0.5),
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
                          site["site_name"] as String,
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
                  Radio<int>(
                    value: int.tryParse(site["id"].toString()) ?? 0,
                    groupValue: _selectedSiteId,
                    activeColor: primaryTeal,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      setState(() {
                        _selectedSiteId = val;
                        _selectedSite = site["site_name"] as String;
                      });
                      _fetchStakeholders();
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

  // Step 2: Choose Stakeholders
  Widget _buildStakeholdersWidget() {
    if (_loadingStakeholders && _stakeholdersList.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(primaryTeal)),
        ),
      );
    }

    if (_stakeholdersList.isEmpty) {
      return const Text(
        "No stakeholders available for the selected site.",
        style: TextStyle(fontSize: 11, color: textLight),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _stakeholdersList.map((s) {
            final id = s['id'] as String;
            final isSelected = _selectedStakeholders.contains(id);
            return FilterChip(
              label: Text(
                s['title'] as String,
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
                color: isSelected ? primaryTeal : outlineVariant.withValues(alpha: 0.8),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedStakeholders.add(id);
                  } else {
                    _selectedStakeholders.remove(id);
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
            onPressed: () {
              _fetchMemberships();
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

  // Step 3: Tier Selection
  Widget _buildTierSelectionWidget() {
    if (_loadingMemberships && _membershipsList.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(primaryTeal)),
        ),
      );
    }

    if (_membershipsList.isEmpty) {
      return const Text(
        "Please complete Step 2 first or no memberships were found.",
        style: TextStyle(fontSize: 11, color: textLight),
      );
    }

    return Column(
      children: _membershipsList.map((tier) {
        final id = int.tryParse(tier["id"].toString());
        final isSelected = _selectedMembershipId == id;
        final name = tier["title"] as String;
        final price = tier["price"]?.toString() ?? "0";

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMembershipId = id;
              _selectedTier = name;
            });
            _completeStep(3);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? primaryTeal : outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryTeal.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TIER",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.amber[800] : Colors.grey[400],
                              ),
                            ),
                            Text(
                              "₹ $price",
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
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
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

  // Step 4: Product Source
  Widget _buildProductSourceWidget() {
    if (_sites.isEmpty) {
      return const Text(
        "No sites loaded.",
        style: TextStyle(fontSize: 11, color: textLight),
      );
    }

    return Column(
      children: _sites.map((source) {
        final id = int.tryParse(source["id"].toString());
        final isSelected = _selectedProductSiteId == id;
        final name = source["site_name"] as String;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedProductSiteId = id;
              _selectedProductSource = name;
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
                color: isSelected ? primaryTeal : outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      Text(
                        "Internal ID: $id",
                        style: const TextStyle(fontSize: 10, color: textLight),
                      ),
                    ],
                  ),
                ),
                Radio<int>(
                  value: id ?? 0,
                  groupValue: _selectedProductSiteId,
                  activeColor: primaryTeal,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) {
                    setState(() {
                      _selectedProductSiteId = val;
                      _selectedProductSource = name;
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

  // Step 5: Deliverable Type
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
          onTap: () {
            setState(() {
              _selectedDeliverable = d["name"] as String;
            });
            _fetchProducts();
            _completeStep(5);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? primaryTeal : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? primaryTeal : outlineVariant.withValues(alpha: 0.5),
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

  // Step 6: Browse Products
  Widget _buildBrowseProductsWidget() {
    if (_loadingProducts && _productsList.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(primaryTeal)),
        ),
      );
    }

    if (_productsList.isEmpty) {
      return const Text(
        "No products available. Please ensure previous steps are completed.",
        style: TextStyle(fontSize: 11, color: textLight),
      );
    }

    final filteredProducts = _productsList
        .where((p) => (p["title"]?.toString() ?? p["product_title"]?.toString() ?? "").toLowerCase().contains(_productSearchController.text.toLowerCase()))
        .toList();

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
        // Grid view
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: filteredProducts.map((p) {
            final id = int.tryParse(p["id"].toString());
            final isSelected = _selectedProductId == id;
            final title = p["title"]?.toString() ?? p["product_title"]?.toString() ?? "";
            final price = p["price"]?.toString() ?? "0";
            final image = p["banner"]?.toString() ?? "";

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedProductId = id;
                  _selectedProduct = title;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? primaryTeal : outlineVariant.withValues(alpha: 0.5),
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
                              child: image.isNotEmpty
                                  ? Image.network(
                                      image,
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
                                    )
                                  : const Center(
                                      child: Icon(Icons.image, color: textLight, size: 24),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: textLight,
                          ),
                        ),
                        Text(
                          "₹ $price",
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
            onPressed: () => _completeStep(6),
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

  // Step 7: Configure Commission
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
                                color: Colors.black.withValues(alpha: 0.05),
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
                                color: Colors.black.withValues(alpha: 0.05),
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
              border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
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
        ] else ...[
          // Slab Based Table UI
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
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
            border: Border.all(color: primaryTeal.withValues(alpha: 0.15)),
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
          border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
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
                  _buildSummaryRow("Site:", _selectedSite),
                  const SizedBox(height: 6),
                  _buildSummaryRow("Membership:", "$_selectedTier Tier"),
                  if (_selectedProductSource.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow("Product Source:", _selectedProductSource),
                  ],
                  if (_selectedProduct.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow("Product:", _selectedProduct),
                  ],
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
            color: Colors.black.withValues(alpha: 0.04),
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
                onPressed: _submittingCommission
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
                                  _submitCommissionSetup();
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
                child: _submittingCommission
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
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
