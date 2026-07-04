import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class ScheduleCampaignScreen extends StatefulWidget {
  final bool isEmbedded;
  final int? initialOrderId;
  final String? initialPackageName;
  final String? initialBuyerName;

  const ScheduleCampaignScreen({
    super.key,
    this.isEmbedded = false,
    this.initialOrderId,
    this.initialPackageName,
    this.initialBuyerName,
  });

  @override
  State<ScheduleCampaignScreen> createState() => _ScheduleCampaignScreenState();
}

class _ScheduleCampaignScreenState extends State<ScheduleCampaignScreen> {
  // B2B Orders state
  List<Map<String, dynamic>> _orders = [];
  bool _isLoadingOrders = false;
  int? _selectedOrderId;
  final TextEditingController _manualOrderController = TextEditingController();

  // Campaign Scheduling form state
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _campaignTitleController;
  late final TextEditingController _clientNameController;
  final TextEditingController _packageTierController = TextEditingController(text: "Enterprise Elite");

  // Scheduling Timeline State
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now().add(const Duration(days: 30));
  bool _alwaysOnVisibility = false;

  // Placement Channels State
  bool _homepageHero = true;
  bool _pushBlast = true;
  bool _weeklyNewsletter = false; // Sold Out (Disabled)
  bool _homeFeed = true;
  bool _communityWall = false;
  bool _promoModal = false;

  // Selected Target Communities State
  final List<String> _allCommunities = [
    "Fintech Global",
    "Venture Lab",
    "AI Governance",
    "Strategic Growth Hub",
    "Digital Assets Forum"
  ];
  final Set<String> _selectedCommunities = {"Fintech Global", "Strategic Growth Hub"};
  String _communitySearchQuery = "";

  // Creative Assets State
  final TextEditingController _btnTextController = TextEditingController(text: "Explore Growth Plans");
  final TextEditingController _urlController = TextEditingController(text: "https://globalfintech.com/q4-accelerator");
  final List<String> _uploadedFiles = ["banner_design_q4.png"];

  // Campaign Priority State
  String _campaignPriority = "Medium"; // Low, Medium, High

  // Audience Target State
  final List<String> _allTargetSegments = [
    "Business Owners",
    "Financial Analysts",
    "C-Suite Executives",
    "Mid-Level Management",
    "Marketing Directors",
    "Venture Capitalists"
  ];
  final Set<String> _selectedTargetSegments = {
    "Business Owners",
    "Financial Analysts",
    "C-Suite Executives"
  };

  bool _isSubmittingCampaign = false;

  @override
  void initState() {
    super.initState();
    _campaignTitleController = TextEditingController(text: widget.initialPackageName ?? "Q4 Growth Accelerator");
    _clientNameController = TextEditingController(text: widget.initialBuyerName ?? "Global Fintech Partners");
    _selectedOrderId = widget.initialOrderId;
    _loadOrders();
  }

  @override
  void dispose() {
    _campaignTitleController.dispose();
    _clientNameController.dispose();
    _packageTierController.dispose();
    _btnTextController.dispose();
    _urlController.dispose();
    _manualOrderController.dispose();
    super.dispose();
  }

  // Load orders for current B2B vendor
  Future<void> _loadOrders() async {
    _isLoadingOrders = true;
    try {
      final response = await Database().getData({
        'action': 'fetch_vendor_orders',
      }, endpoint: 'new_apis/schedule_campaign_api.php');

      if (response['success'] == true && response['data'] != null) {
        final List listData = response['data'] is List ? response['data'] : [];
        if (mounted) {
          setState(() {
            _orders = listData.map((item) => Map<String, dynamic>.from(item)).toList();
            if (_orders.isNotEmpty) {
              _selectedOrderId = widget.initialOrderId ?? _orders.first['id'];
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading orders: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
      }
    }
  }

  // Submit/Schedule Campaign
  Future<void> _submitCampaign(int statusValue) async {
    final int? finalOrderId = _selectedOrderId ?? int.tryParse(_manualOrderController.text.trim());
    if (finalOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: A valid numeric Order ID is required."),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingCampaign = true;
    });

    try {
      // Build placements
      final List<String> placements = [];
      if (_homepageHero) placements.add("homepage_hero");
      if (_pushBlast) placements.add("push_notification");
      if (_homeFeed) placements.add("home_feed");
      if (_communityWall) placements.add("community_wall");
      if (_promoModal) placements.add("promotional_modal");

      // Build community numeric IDs
      final List<int> targetCommunityIds = [];
      for (var comm in _selectedCommunities) {
        final idx = _allCommunities.indexOf(comm);
        if (idx != -1) {
          targetCommunityIds.add(idx + 1); // 1-indexed mock community IDs
        }
      }

      final response = await Database().getData({
        'action': 'create_campaign_schedule',
        'order_id': finalOrderId,
        'title': _campaignTitleController.text.trim(),
        'client_name': _clientNameController.text.trim(),
        'package_tier': _packageTierController.text.trim(),
        'start_date': _startDate != null ? _formatDate(_startDate) : '',
        'end_date': _endDate != null ? _formatDate(_endDate) : '',
        'schedule_time': '09:00:00',
        'always_on': _alwaysOnVisibility ? 1 : 0,
        'frequency': '1',
        'duration': 1,
        'placements': jsonEncode(placements),
        'target_communities': jsonEncode(targetCommunityIds),
        'cta_text': _btnTextController.text.trim(),
        'cta_url': _urlController.text.trim(),
        'media_assets': jsonEncode(_uploadedFiles),
        'priority': _campaignPriority.toLowerCase(),
        'target_segments': jsonEncode(_selectedTargetSegments.toList()),
        'target_region': 'North America, European Union',
        'status': statusValue, // 1 for active/published, 0 for draft
      }, endpoint: 'new_apis/schedule_campaign_api.php');

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusValue == 1 ? "Campaign activated successfully!" : "Draft campaign saved successfully!"),
            backgroundColor: AppTheme.primary,
          ),
        );
        Navigator.pushNamed(context, AppRoutes.campaignScheduler);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response['message'] ?? 'Failed to schedule campaign'}"),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error submitting campaign: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingCampaign = false;
      });
    }
  }

  // Date selection helper
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Formatted date string
  String _formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: _isSubmittingCampaign
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text("Scheduling campaign, please wait...", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Calendar Navigation Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Schedule Campaigns",
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Configure and distribute client campaigns across Serene Commerce platforms",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Top Calendar Shortcut Icon
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.campaignScheduler);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.outline),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                                        SizedBox(width: 8),
                                        Text(
                                          "View Scheduler",
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Order Specification Section (dropdown or manual field)
                          _buildOrderSpecificationSection(),
                          const SizedBox(height: 24),

                          // Main Content Layout
                          isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: Column(
                                        children: [
                                          _buildSchedulingTimelineCard(),
                                          const SizedBox(height: 24),
                                          _buildPlacementChannelsCard(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        children: [
                                          _buildCreativeAssetsCard(),
                                          const SizedBox(height: 24),
                                          _buildPriorityCard(),
                                          const SizedBox(height: 24),
                                          _buildAudienceTargetCard(),
                                          const SizedBox(height: 24),
                                          _buildPerformanceProjectionCard(),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildSchedulingTimelineCard(),
                                    const SizedBox(height: 24),
                                    _buildPlacementChannelsCard(),
                                    const SizedBox(height: 24),
                                    _buildCreativeAssetsCard(),
                                    const SizedBox(height: 24),
                                    _buildPriorityCard(),
                                    const SizedBox(height: 24),
                                    _buildAudienceTargetCard(),
                                    const SizedBox(height: 24),
                                    _buildPerformanceProjectionCard(),
                                  ],
                                ),

                          const SizedBox(height: 40),

                          // Action Buttons Footer
                          _buildActionBar(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // 1. Order Specification Section (linked to actual database orders)
  Widget _buildOrderSpecificationSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppTheme.primary, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "ORDER SPECIFICATION",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Campaign Order Allocation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Awaiting Schedule",
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            if (_isLoadingOrders)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else if (_orders.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "No active orders found for your account. You can manually enter an Order ID for mock simulation below:",
                    style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _manualOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Order ID (Numeric)",
                      hintText: "Enter a valid order ID",
                    ),
                    validator: (val) {
                      if (_selectedOrderId == null && (val == null || val.trim().isEmpty)) {
                        return 'Please enter a valid numeric Order ID';
                      }
                      return null;
                    },
                  ),
                ],
              )
            else
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Select Client Order",
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: _selectedOrderId,
                items: _orders.map((order) {
                  return DropdownMenuItem<int>(
                    value: order['id'] as int,
                    child: Text(
                      "${order['name'] ?? 'Order'} (ID: ${order['id']}) - ₹${order['amount']}",
                      style: const TextStyle(fontSize: 13, overflow: TextOverflow.ellipsis),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedOrderId = val;
                    final selected = _orders.firstWhere((o) => o['id'] == val);
                    _campaignTitleController.text = "${selected['item_type'] ?? 'Ad'} Campaign";
                    _clientNameController.text = selected['name'] ?? 'B2B Client';
                    _packageTierController.text = "B2B Standard Package";
                  });
                },
              ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            MediaQuery.of(context).size.width > 900
                ? Row(
                    children: [
                      Expanded(
                        child: _buildInputCol("Campaign Title", _campaignTitleController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputCol("Client Name", _clientNameController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputCol("Package Tier", _packageTierController),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildInputCol("Campaign Title", _campaignTitleController),
                      const SizedBox(height: 12),
                      _buildInputCol("Client Name", _clientNameController),
                      const SizedBox(height: 12),
                      _buildInputCol("Package Tier", _packageTierController),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // 2. Scheduling Timeline Card
  Widget _buildSchedulingTimelineCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.event_note_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  "Scheduling Timeline",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "START DATE",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.outline),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF9F9F9),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_startDate),
                                style: const TextStyle(color: AppTheme.textPrimary),
                              ),
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textSecondary),
                            ],
                          ),
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
                        "END DATE",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.outline),
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF9F9F9),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_endDate),
                                style: const TextStyle(color: AppTheme.textPrimary),
                              ),
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.update_rounded, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Always-On Visibility",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                          ),
                          Text(
                            "Priority queue bypass enabled",
                            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _alwaysOnVisibility,
                    onChanged: (val) {
                      setState(() {
                        _alwaysOnVisibility = val;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: AppTheme.primary,
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Placement Channels Checklist Card
  Widget _buildPlacementChannelsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.layers_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  "Placement Channels",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPlacementItem(
              title: "Homepage Hero Banner (homepage_hero)",
              value: _homepageHero,
              badge: "PREMIUM",
              onChanged: (val) {
                setState(() {
                  _homepageHero = val ?? false;
                });
              },
            ),
            _buildPlacementItem(
              title: "Push Notification Blast (push_notification)",
              value: _pushBlast,
              onChanged: (val) {
                setState(() {
                  _pushBlast = val ?? false;
                });
              },
            ),
            _buildPlacementItem(
              title: "Weekly Community Newsletter (weekly_newsletter)",
              value: _weeklyNewsletter,
              badge: "SOLD OUT",
              disabled: true,
              onChanged: null,
            ),
            _buildPlacementItem(
              title: "Home Feed Placement (home_feed)",
              value: _homeFeed,
              onChanged: (val) {
                setState(() {
                  _homeFeed = val ?? false;
                });
              },
            ),
            _buildPlacementItem(
              title: "Community Wall Placement (community_wall)",
              value: _communityWall,
              onChanged: (val) {
                setState(() {
                  _communityWall = val ?? false;
                  if (_communityWall) {
                    _showCommunitiesDialog();
                  }
                });
              },
            ),
            _buildPlacementItem(
              title: "Promotional Modal Reveal (promotional_modal)",
              value: _promoModal,
              onChanged: (val) {
                setState(() {
                  _promoModal = val ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacementItem({
    required String title,
    required bool value,
    String? badge,
    bool disabled = false,
    required void Function(bool?)? onChanged,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: value,
                    onChanged: disabled ? null : onChanged,
                    activeColor: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badge == "PREMIUM" ? AppTheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badge == "PREMIUM" ? AppTheme.primary : AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 4. Creative Assets Card
  Widget _buildCreativeAssetsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.cloud_upload_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  "Creative Assets",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: _showUploadModal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.outline,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFFCFBFB),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.add_photo_alternate_rounded, size: 40, color: AppTheme.textSecondary),
                    const SizedBox(height: 12),
                    const Text(
                      "Click to upload assets",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Supports JPG, PNG, MP4 (Max 50MB)",
                      style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    ),
                    if (_uploadedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: _uploadedFiles.map((file) {
                          return Chip(
                            label: Text(file, style: const TextStyle(fontSize: 11)),
                            onDeleted: () {
                              setState(() {
                                _uploadedFiles.remove(file);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "CTA CONFIGURATION",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _btnTextController,
              decoration: const InputDecoration(
                labelText: "Button Text",
                hintText: "e.g. Learn More",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "Destination URL",
                hintText: "https://...",
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Media Library is empty")),
                );
              },
              child: const Text("Browse Media Library"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showSubmissionsDialog,
              icon: const Icon(Icons.collections_rounded, size: 18),
              label: const Text("View Client Submissions"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8E8E8),
                foregroundColor: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Campaign Priority Card
  Widget _buildPriorityCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.priority_high_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  "Campaign Priority",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Set priority for overlapping schedules",
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPriorityOption("Low"),
                const SizedBox(width: 12),
                _buildPriorityOption("Medium"),
                const SizedBox(width: 12),
                _buildPriorityOption("High"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String label) {
    final bool isSelected = _campaignPriority == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _campaignPriority = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 6. Audience Target Card
  Widget _buildAudienceTargetCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.gps_fixed_rounded, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      "Audience Target",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _showAudienceTargetDialog,
                  child: const Text(
                    "EDIT",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTargetSegments.map((segment) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.outline),
                  ),
                  child: Text(
                    segment,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "REGION",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "North America, European Union (Selected Regions)",
                          style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. Projected Performance Card
  Widget _buildPerformanceProjectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PROJECTED PERFORMANCE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Color(0xFF76D6D5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Est. Impressions",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "1.4M+",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Targeted Reach",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "420K",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 8. Action Bar Footer
  Widget _buildActionBar() {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    if (isDesktop) {
      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _submitCampaign(0), // Status = 0 (Draft)
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  "Save as Draft Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _submitCampaign(1), // Status = 1 (Active)
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text("Activate & Schedule Campaign"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(0, 52), // Overrides global double.infinity width
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => _submitCampaign(1), // Status = 1 (Active)
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text("Activate & Schedule Campaign"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _submitCampaign(0), // Status = 0 (Draft)
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "Save as Draft Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  // DIALOGS & MODALS

  void _showCommunitiesDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCommunities = _allCommunities
                .where((c) => c.toLowerCase().contains(_communitySearchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: const Text("Target Communities"),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search communities...",
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          _communitySearchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCommunities.length,
                        itemBuilder: (context, index) {
                          final communityName = filteredCommunities[index];
                          final isChecked = _selectedCommunities.contains(communityName);
                          return CheckboxListTile(
                            title: Text(communityName),
                            value: isChecked,
                            activeColor: AppTheme.primary,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedCommunities.add(communityName);
                                } else {
                                  _selectedCommunities.remove(communityName);
                                }
                              });
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: const Text("CONFIRM SELECTION"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSubmissionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: AlertDialog(
            title: const Text("Client Creative Assets"),
            content: SizedBox(
              width: 500,
              height: 400,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppTheme.primary,
                    indicatorColor: AppTheme.primary,
                    tabs: [
                      Tab(text: "Images"),
                      Tab(text: "Videos & Docs"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: List.generate(4, (index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.outline),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(Icons.image_rounded, size: 40, color: AppTheme.textSecondary),
                                  Positioned(
                                    bottom: 8,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        minimumSize: Size.zero,
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppTheme.primary,
                                      ),
                                      child: const Text("View Full", style: TextStyle(fontSize: 10)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        ListView(
                          children: [
                            _buildMediaListTile(
                              title: "Brand_Story_v2.mp4",
                              subtitle: "0:45 • 12.4 MB",
                              icon: Icons.play_circle_fill_rounded,
                              iconColor: AppTheme.primary,
                            ),
                            const SizedBox(height: 8),
                            _buildMediaListTile(
                              title: "Campaign_Guidelines.pdf",
                              subtitle: "2.1 MB",
                              icon: Icons.picture_as_pdf_rounded,
                              iconColor: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text("CLOSE"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text("Preview", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              if (icon == Icons.picture_as_pdf_rounded)
                TextButton(
                  onPressed: () {},
                  child: const Text("Download", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUploadModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Creative Assets"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.upload_file_rounded, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    const Text("Drag and drop creative assets here", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _uploadedFiles.add("banner_design_${_uploadedFiles.length + 1}.png");
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Mock file uploaded successfully!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                      child: const Text("Select Files"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("REQUIREMENTS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  _buildRequirementRow("Aspect Ratio 16:9 for Banners"),
                  _buildRequirementRow("Maximum file size 50MB"),
                  _buildRequirementRow("High resolution (min 1920x1080)"),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequirementRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 14),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _showAudienceTargetDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Audience Targeting"),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PROFESSIONAL SEGMENTS",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _allTargetSegments.length,
                        itemBuilder: (context, index) {
                          final segment = _allTargetSegments[index];
                          final isChecked = _selectedTargetSegments.contains(segment);
                          return CheckboxListTile(
                            title: Text(segment),
                            value: isChecked,
                            activeColor: AppTheme.primary,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedTargetSegments.add(segment);
                                } else {
                                  _selectedTargetSegments.remove(segment);
                                }
                              });
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: const Text("APPLY TARGETS"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputCol(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          decoration: const InputDecoration(contentPadding: EdgeInsets.all(8)),
        ),
      ],
    );
  }
}
