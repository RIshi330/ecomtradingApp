import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';

class CommunityMonetizationScreen extends StatefulWidget {
  final bool isEmbedded;
  const CommunityMonetizationScreen({super.key, this.isEmbedded = false});

  @override
  State<CommunityMonetizationScreen> createState() => _CommunityMonetizationScreenState();
}

class _CommunityMonetizationScreenState extends State<CommunityMonetizationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  final int _totalSteps = 6;
  bool _isLoading = false;
  bool _isLoadingCommunities = false;

  // STEP 1: Core Details
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationValController = TextEditingController(text: "14");
  String _selectedDurationUnit = "Days"; // Days, Weeks, Months
  List<dynamic> _communities = [];
  int _selectedCommunityId = 0;

  // STEP 2: Targeting
  final _interestsController = TextEditingController();
  final _locationValuesController = TextEditingController();
  String _locationType = "Global"; // Global, Regional, City-specific
  final Set<String> _selectedAudience = {};
  final Set<String> _applicableTo = {"Verified Vendors"};

  final List<String> _audienceSegments = [
    "C-Level Executives",
    "Product Managers",
    "Software Engineers",
    "Marketing Leads",
    "Agency Partners",
    "SaaS Founders"
  ];

  final List<String> _applicableRoles = [
    "Verified Vendors",
    "Agency Partners",
    "Individual Experts"
  ];

  // STEP 3: Placements Selection
  final Map<String, bool> _placements = {
    "homepage_banner": true,
    "featured_section": false,
    "search_top": true,
    "feed_ads": true,
    "push_notification": false,
    "email_campaign": false,
  };

  // STEP 4: Pricing Strategy
  String _pricingModel = "fixed"; // fixed, commission, action, hybrid
  final _basePriceController = TextEditingController(text: "499");
  final _commissionController = TextEditingController();
  final _actionTypeController = TextEditingController();
  final _pricePerActionController = TextEditingController();

  // STEP 5: Features & Addons
  final Map<String, bool> _features = {
    "featured_badge": false,
    "trending_tag": false,
    "ai_boost": false,
    "priority_ranking": false,
  };

  final Map<String, bool> _addons = {
    "push_blast": false,
    "influencer": false,
    "extra_reach": false,
  };

  // STEP 6: Reach Estimates
  final _reachController = TextEditingController(text: "15000");
  final _impressionsController = TextEditingController(text: "50000");
  final _clicksController = TextEditingController(text: "1200");

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationValController.dispose();
    _interestsController.dispose();
    _locationValuesController.dispose();
    _basePriceController.dispose();
    _commissionController.dispose();
    _actionTypeController.dispose();
    _pricePerActionController.dispose();
    _reachController.dispose();
    _impressionsController.dispose();
    _clicksController.dispose();
    super.dispose();
  }

  Future<void> _fetchCommunities() async {
    if (!mounted) return;
    setState(() => _isLoadingCommunities = true);
    try {
      final response = await Database().getData({
        'action': 'fetch_own_communities',
      }, endpoint: 'new_apis/create_community_API.php');

      if (response != null && (response['success'] == true || response['status'] == 200) && response['data'] != null) {
        setState(() {
          _communities = response['data'] ?? [];
          if (_communities.isNotEmpty) {
            _selectedCommunityId = int.tryParse(_communities.first['id']?.toString() ?? '0') ?? 0;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching communities: $e");
    } finally {
      if (mounted) setState(() => _isLoadingCommunities = false);
    }
  }

  Future<void> _submitPackage(bool isDraft) async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Package Name is required"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> body = {
        'action': isDraft ? 'add_package_draft' : 'add_package',
        'name': name,
        'description': _descriptionController.text.trim(),
        'duration_value': int.tryParse(_durationValController.text) ?? 14,
        'duration_type': _selectedDurationUnit.toLowerCase(),
        'community_id': _selectedCommunityId,
        'applicable_to': _applicableTo.toList(),
        'audience': _selectedAudience.toList(),
        'interests': _interestsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'location_type': _locationType.toLowerCase(),
        'locations': _locationValuesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'placements': _placements,
        'pricing_type': _pricingModel,
        'fixed_price': double.tryParse(_basePriceController.text) ?? 0.0,
        'commission': double.tryParse(_commissionController.text) ?? 0.0,
        'action_type': _actionTypeController.text.trim(),
        'price_per_action': double.tryParse(_pricePerActionController.text) ?? 0.0,
        'base_price': double.tryParse(_basePriceController.text) ?? 0.0,
        'features': _features,
        'addons': _addons,
        'estimated_reach': int.tryParse(_reachController.text) ?? 0,
        'impressions': int.tryParse(_impressionsController.text) ?? 0,
        'clicks': int.tryParse(_clicksController.text) ?? 0,
        'status': isDraft ? 'inactive' : 'active',
      };

      final response = await Database().getData(body, endpoint: 'new_apis/promotion_package_form_api.php');

      if (response != null && response['success'] == true) {
        final generatedId = response['data']?['id']?.toString() ?? 'PKG-${DateTime.now().millisecondsSinceEpoch % 100000}';
        _showSuccessDialog(generatedId, isDraft);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Failed to save monetization package"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Submission failed: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String packageId, bool isDraft) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 44,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isDraft ? "Draft Saved" : "Package Published",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isDraft
                      ? "Your monetization package has been saved as a draft configuration."
                      : "Your promotional monetization package has been deployed to the community catalog.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F3F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Package ID:",
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      Text(
                        "PKG-$packageId",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Pop dialog
                      _resetForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      _currentStep = 1;
      _nameController.clear();
      _descriptionController.clear();
      _durationValController.text = "14";
      _selectedDurationUnit = "Days";
      _interestsController.clear();
      _locationValuesController.clear();
      _locationType = "Global";
      _selectedAudience.clear();
      _applicableTo.clear();
      _applicableTo.add("Verified Vendors");
      _placements.updateAll((key, value) => key == "homepage_banner" || key == "search_top" || key == "feed_ads");
      _pricingModel = "fixed";
      _basePriceController.text = "499";
      _commissionController.clear();
      _actionTypeController.clear();
      _pricePerActionController.clear();
      _features.updateAll((key, value) => false);
      _addons.updateAll((key, value) => false);
      _reachController.text = "15000";
      _impressionsController.text = "50000";
      _clicksController.text = "1200";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final Widget body = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStepperIndicator(),
            const SizedBox(height: 24),
            _buildStepFormContent(),
            const SizedBox(height: 24),
            _buildStepNavigation(),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Community Monetization",
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primary),
      ),
      body: body,
    );
  }

  // Stepper Indicator Widget
  Widget _buildStepperIndicator() {
    final steps = ["Core", "Target", "Place", "Price", "Addons", "Reach"];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_totalSteps, (index) {
              final stepNum = index + 1;
              final isCurrent = stepNum == _currentStep;
              final isCompleted = stepNum < _currentStep;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primary
                          : (isCompleted ? Colors.white : Colors.white),
                      border: Border.all(
                        color: (isCurrent || isCompleted)
                            ? AppTheme.primary
                            : const Color(0xFFBDC9C8),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: AppTheme.primary)
                        : Text(
                            stepNum.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCurrent
                                  ? Colors.white
                                  : (isCompleted ? AppTheme.primary : AppTheme.textSecondary),
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: (isCurrent || isCompleted)
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Renders correct step view
  Widget _buildStepFormContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Core();
      case 2:
        return _buildStep2Targeting();
      case 3:
        return _buildStep3Placements();
      case 4:
        return _buildStep4Pricing();
      case 5:
        return _buildStep5FeaturesAddons();
      case 6:
        return _buildStep6ReachEstimates();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Core details
  Widget _buildStep1Core() {
    return _buildStepCard(
      title: "Core Details",
      subtitle: "Define the foundational identity of this promotional offer.",
      children: [
        _buildTextField("Package Name", _nameController, "e.g., Q4 Growth Accelerator"),
        _buildTextField("Description", _descriptionController, "Briefly describe the package value proposition...", maxLines: 4),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField("Duration Value", _durationValController, "14", isNumeric: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildDropdownField<String>(
                label: "Unit",
                value: _selectedDurationUnit,
                items: ["Days", "Weeks", "Months"],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDurationUnit = val);
                },
              ),
            ),
          ],
        ),
        if (_isLoadingCommunities)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          )
        else if (_communities.isNotEmpty)
          _buildDropdownField<int>(
            label: "Community Selection",
            value: _selectedCommunityId,
            items: _communities.map((c) => int.tryParse(c['id']?.toString() ?? '0') ?? 0).toList(),
            itemLabels: _communities.map((c) => c['title']?.toString() ?? 'Group').toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCommunityId = val);
            },
          )
        else
          _buildDropdownField<int>(
            label: "Community Selection",
            value: 0,
            items: [0],
            itemLabels: ["General Platform Feed"],
            onChanged: (val) {},
          ),
      ],
    );
  }

  // STEP 2: Audience targeting
  Widget _buildStep2Targeting() {
    return _buildStepCard(
      title: "Audience Targeting",
      subtitle: "Select the specific demographics and interest segments.",
      children: [
        const Text(
          "Audience Segments",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _audienceSegments.map((segment) {
            final isSelected = _selectedAudience.contains(segment);
            return FilterChip(
              label: Text(segment, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              selectedColor: AppTheme.primary.withOpacity(0.2),
              checkmarkColor: AppTheme.primary,
              side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.outline),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedAudience.add(segment);
                  } else {
                    _selectedAudience.remove(segment);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildTextField("Interest Tags", _interestsController, "AI, SaaS, FinTech (comma separated)"),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField<String>(
                label: "Location Type",
                value: _locationType,
                items: ["Global", "Regional", "City-specific"],
                onChanged: (val) {
                  if (val != null) setState(() => _locationType = val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField("Location Values", _locationValuesController, "US, UK, Germany"),
            ),
          ],
        ),
        const Text(
          "Applicable To",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _applicableRoles.map((role) {
            final isSelected = _applicableTo.contains(role);
            return FilterChip(
              label: Text(role, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              selectedColor: AppTheme.primary.withOpacity(0.2),
              checkmarkColor: AppTheme.primary,
              side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.outline),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _applicableTo.add(role);
                  } else {
                    _applicableTo.remove(role);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 3: Placements selection
  Widget _buildStep3Placements() {
    return _buildStepCard(
      title: "Placements Selection",
      subtitle: "Choose where the content will appear across the platform.",
      children: [
        _buildPlacementItem("homepage_banner", "Homepage Banner", Icons.view_quilt_rounded),
        _buildPlacementItem("featured_section", "Featured Section", Icons.star_border_purple500_rounded),
        _buildPlacementItem("search_top", "Search Top Result", Icons.search_rounded),
        _buildPlacementItem("feed_ads", "Native Feed Ads", Icons.dynamic_feed_rounded),
        _buildPlacementItem("push_notification", "Push Notification", Icons.notifications_active_outlined),
        _buildPlacementItem("email_campaign", "Email Campaign", Icons.email_outlined),
      ],
    );
  }

  Widget _buildPlacementItem(String key, String title, IconData icon) {
    final bool isChecked = _placements[key] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isChecked ? AppTheme.primary : AppTheme.outline),
      ),
      child: ListTile(
        leading: Icon(icon, color: isChecked ? AppTheme.primary : AppTheme.textSecondary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isChecked ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
        trailing: Checkbox(
          value: isChecked,
          activeColor: AppTheme.primary,
          onChanged: (val) {
            setState(() {
              _placements[key] = val ?? false;
            });
          },
        ),
        onTap: () {
          setState(() {
            _placements[key] = !isChecked;
          });
        },
      ),
    );
  }

  // STEP 4: Pricing strategy
  Widget _buildStep4Pricing() {
    return _buildStepCard(
      title: "Pricing Strategy",
      subtitle: "Configure the monetization model for this package.",
      children: [
        _buildDropdownField<String>(
          label: "Pricing Model",
          value: _pricingModel,
          items: ["fixed", "commission", "action", "hybrid"],
          itemLabels: ["Fixed Price", "Commission Based", "Action Based (CPA)", "Hybrid Model"],
          onChanged: (val) {
            if (val != null) setState(() => _pricingModel = val);
          },
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField("Base Price (₹)", _basePriceController, "499", isNumeric: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField("Commission (%)", _commissionController, "e.g. 10", isNumeric: true),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField("Action Type", _actionTypeController, "e.g. Sign up"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField("Price Per Action (₹)", _pricePerActionController, "e.g. 5.00", isNumeric: true),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 5: Features & Addons
  Widget _buildStep5FeaturesAddons() {
    return _buildStepCard(
      title: "Features & Addons",
      subtitle: "Include premium capabilities and visibility boosts.",
      children: [
        const Text(
          "CAPABILITIES & BADGES",
          style: TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        _buildSwitchItem(_features, "featured_badge", "Featured Badge", Icons.verified_rounded),
        _buildSwitchItem(_features, "trending_tag", "Trending Tag", Icons.trending_up_rounded),
        _buildSwitchItem(_features, "ai_boost", "AI Optimization Boost", Icons.smart_toy_rounded),
        _buildSwitchItem(_features, "priority_ranking", "Priority Feed Ranking", Icons.bolt_rounded),
        const SizedBox(height: 16),
        const Text(
          "MARKETING ADDONS",
          style: TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        _buildSwitchItem(_addons, "push_blast", "Push blast to active members", Icons.send_time_extension_rounded),
        _buildSwitchItem(_addons, "influencer", "Influencer shoutout placement", Icons.campaign_rounded),
        _buildSwitchItem(_addons, "extra_reach", "Extra reach extension boost", Icons.speed_rounded),
      ],
    );
  }

  Widget _buildSwitchItem(Map<String, bool> map, String key, String title, IconData icon) {
    final bool isChecked = map[key] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.outline),
      ),
      child: ListTile(
        leading: Icon(icon, color: isChecked ? AppTheme.primary : AppTheme.textSecondary, size: 20),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: Switch(
          value: isChecked,
          activeColor: AppTheme.primary,
          onChanged: (val) {
            setState(() {
              map[key] = val;
            });
          },
        ),
      ),
    );
  }

  // STEP 6: Reach estimates
  Widget _buildStep6ReachEstimates() {
    return _buildStepCard(
      title: "Reach Estimates",
      subtitle: "Project the potential impact of the package configuration.",
      children: [
        _buildTextField("Estimated Reach", _reachController, "15000", isNumeric: true),
        _buildTextField("Expected Impressions", _impressionsController, "50000", isNumeric: true),
        _buildTextField("Target Clicks", _clicksController, "1200", isNumeric: true),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.05),
            border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Targeting settings use JSON structures for precise vendor matching. Ensure reach estimates align with selected community indices.",
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Step Wrapper Card
  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.outline),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Custom Form Field Elements
  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1, bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    List<String>? itemLabels,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            value: value,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
              ),
            ),
            items: List.generate(items.length, (index) {
              final val = items[index];
              final labelStr = itemLabels != null ? itemLabels[index] : val.toString();
              return DropdownMenuItem<T>(
                value: val,
                child: Text(labelStr),
              );
            }),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Step Navigation Widget
  Widget _buildStepNavigation() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _currentStep > 1
                  ? () {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text("Back"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                minimumSize: const Size(100, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_currentStep < _totalSteps) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  _submitPackage(false);
                }
              },
              icon: Icon(_currentStep == _totalSteps ? Icons.send_rounded : Icons.arrow_forward_rounded),
              label: Text(_currentStep == _totalSteps ? "Publish Package" : "Continue"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 48),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppTheme.outline),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _submitPackage(true),
                icon: const Icon(Icons.drafts_outlined),
                label: const Text("Save as Draft Config"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary, width: 2),
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _submitPackage(false),
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text("Deploy & Publish"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}