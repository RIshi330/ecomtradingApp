import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:trading_ecommerce_admin/widgets/personalize_feed_dialog.dart';
import 'package:trading_ecommerce_admin/widgets/create_post_dialog.dart';
import 'package:trading_ecommerce_admin/admin/explore_communities_screen.dart';
import 'package:trading_ecommerce_admin/admin/site_settings_screen.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/screens/membership_payment_modal.dart';
import 'package:trading_ecommerce_admin/admin/profile_screen.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/common/chat_screen.dart';
import 'package:trading_ecommerce_admin/common/community_inbox_screen.dart';
import 'package:trading_ecommerce_admin/widgets/account_actions.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/screens/manage_opportunities_screen.dart';
import 'package:trading_ecommerce_admin/screens/product_management_screen.dart';
import 'package:trading_ecommerce_admin/screens/low_stock_inventory_screen.dart';
import 'package:trading_ecommerce_admin/screens/trading_marketplace_screen.dart';
import 'package:trading_ecommerce_admin/screens/selected_items_screen.dart';
import 'package:trading_ecommerce_admin/screens/affiliate_orders_screen.dart';
import 'package:trading_ecommerce_admin/admin/seller_orders_screen.dart';
import 'package:trading_ecommerce_admin/admin/api_logs_screen.dart';
import 'package:trading_ecommerce_admin/screens/event_marketplace_screen.dart';
import 'package:trading_ecommerce_admin/screens/my_events_screen.dart';
import 'package:trading_ecommerce_admin/screens/event_opportunities_screen.dart';
import 'package:trading_ecommerce_admin/admin/schedule_campaign_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trading_ecommerce_admin/admin/taxonomy_manager_screen.dart';
import 'package:trading_ecommerce_admin/admin/manage_items_screen.dart';
import 'package:trading_ecommerce_admin/admin/platform_settings_screen.dart';
import 'package:trading_ecommerce_admin/admin/wallet_admin_screen.dart';
import 'package:trading_ecommerce_admin/admin/membership_plans_screen.dart';
import 'package:trading_ecommerce_admin/admin/membership_builder_screen.dart';
import 'package:trading_ecommerce_admin/admin/community_monetization_screen.dart';
import 'package:trading_ecommerce_admin/admin/manage_promotional_packages_screen.dart';
import 'package:trading_ecommerce_admin/admin/promotional_package_orders_screen.dart';
import 'package:trading_ecommerce_admin/common/chat_screen.dart';
import 'package:trading_ecommerce_admin/common/notification_screen.dart';
import 'package:trading_ecommerce_admin/admin/seller_dashboard_screen.dart';
import 'package:trading_ecommerce_admin/screens/promotional_packages_screen.dart';
import 'package:trading_ecommerce_admin/admin/seller_management_screen.dart';
import 'package:trading_ecommerce_admin/admin/marketplace_modules_screen.dart';
import 'package:trading_ecommerce_admin/admin/module_integration_screen.dart';
import 'package:trading_ecommerce_admin/admin/module_manager_screen.dart';
import 'package:trading_ecommerce_admin/screens/manage_team_screen.dart';
import 'package:trading_ecommerce_admin/screens/manage_tasks_screen.dart';
import 'package:trading_ecommerce_admin/screens/explore_partners_screen.dart';
import 'package:trading_ecommerce_admin/screens/explore_talent_screen.dart';
import 'package:trading_ecommerce_admin/screens/rewards_recognition_screen.dart';
import 'package:trading_ecommerce_admin/screens/logistics_screen.dart';
import 'package:trading_ecommerce_admin/screens/packaging_screen.dart';
import 'package:trading_ecommerce_admin/screens/promotions_screen.dart';
import 'package:trading_ecommerce_admin/screens/local_delivery_screen.dart';
import 'package:trading_ecommerce_admin/screens/combo_packages_screen.dart';
import 'package:trading_ecommerce_admin/screens/explore_charity_projects_screen.dart';
import 'package:trading_ecommerce_admin/screens/charity_marketplace_screen.dart';

class CommunityAdminDashboard extends StatefulWidget {
  const CommunityAdminDashboard({super.key});

  @override
  State<CommunityAdminDashboard> createState() => _CommunityAdminDashboardState();
}

class _CommunityAdminDashboardState extends State<CommunityAdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Navigation Index State
  // 0: Dashboard, 1: Users, 2: Products, 3: Orders,
  // 4: Category Management, 5: List Items, 6: Platform Settings,
  // 7: Wallet, 8: Withdrawal Requests, 9: Seller Bank Details,
  // 10: Membership Plans, 11: Profile, 15: Community Approvals
  // 12: Seller Dashboard (Default)
  int _currentIndex = 0;
  String _vendorType = '200';

  // Home Feed Interaction States
  int _sarahMitchellLikes = 24;
  bool _sarahMitchellLiked = false;
  int _davidChenLikes = 142;
  bool _davidChenLiked = false;
  bool _commentsExpanded = false;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _memberSearchController = TextEditingController();

  final List<Map<String, dynamic>> _activeMembers = [
    {
      "name": "Marcus Knight",
      "initials": "MK",
      "role": "Head of Operations",
      "status": "ACTIVE",
      "statusColor": const Color(0xFF008080),
      "progress": 0.82,
    },
    {
      "name": "Sarah Chen",
      "initials": "SC",
      "role": "Community Lead",
      "status": "GROWING",
      "statusColor": const Color(0xFF6750A4),
      "progress": 0.65,
    },
    {
      "name": "David Blake",
      "initials": "DB",
      "role": "Regional Director",
      "status": "MODERATED",
      "statusColor": const Color(0xFFB45309),
      "progress": 0.40,
    },
  ];

  final List<String> _sarahComments = [
    "Excellent insights on the governance shift. Looking forward to the full report."
  ];

  String? _extractYoutubeId(String text) {
    final RegExp regExp = RegExp(
      r'(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }

  String? _extractTwitterVideoUrl(String text) {
    final RegExp regExp = RegExp(
      r'(https?://(?:twitter\.com|x\.com)/[a-zA-Z0-9_]+/status/[0-9]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }

  Widget _buildYoutubePreview(String youtubeId) {
    final String thumbnailUrl = "https://img.youtube.com/vi/$youtubeId/0.jpg";
    final Uri youtubeUri = Uri.parse("https://www.youtube.com/watch?v=$youtubeId");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (await canLaunchUrl(youtubeUri)) {
            await launchUrl(youtubeUri, mode: LaunchMode.externalApplication);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black12,
                    child: const Icon(Icons.video_library_rounded, size: 48, color: Colors.grey),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black87,
                child: const Text(
                  "WATCH ON YOUTUBE",
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwitterPreview(String xUrl) {
    final Uri xUri = Uri.parse(xUrl);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: InkWell(
        onTap: () async {
          if (await canLaunchUrl(xUri)) {
            await launchUrl(xUri, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WATCH VIDEO ON X / TWITTER",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Tap to watch directly on the X application.",
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  // Colors
  static const Color primaryPurple = Color(0xFF006565); // Changed to Teal matching AppTheme.primary
  static const Color accentPurple = Color(0xFF008080);  // Changed to Teal Container matching AppTheme.primaryContainer
  static const Color bgDark = Color(0xFF1E1E2C);
  static const Color bgLight = Color(0xFFF4F6FC);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);

  // Dynamic Data & Loading States
  List<dynamic> _generalUsers = [];
  List<dynamic> _businessUsers = [];
  bool _isLoadingUsers = false;

  bool _isMaintenanceMode = false;
  bool _isAutoApproveVendors = true;
  bool _isEscrowEnabled = true;
  bool _isPushNotificationsEnabled = true;
  bool _isLoadingSettings = false;

  List<dynamic> _pendingApprovals = [];
  bool _isLoadingApprovals = false;

  List<dynamic> _withdrawalRequests = [];
  bool _isLoadingWithdrawals = false;

  List<dynamic> _realOpportunities = [];
  bool _isLoadingOpportunities = false;

  List<dynamic> _myListings = [];
  bool _isLoadingListings = false;

  List<dynamic> _mySubmissions = [];
  bool _isLoadingSubmissions = false;

  List<dynamic> _matchingMemberships = [];

  // Home Feed State
  List<dynamic> _feedPosts = [];
  bool _isLoadingFeed = false;
  final Set<int> _expandedPostComments = {};
  final Map<int, TextEditingController> _commentControllers = {};
  final TextEditingController _postController = TextEditingController();

  // Community Dashboard Stats & Info
  int _totalMembers = 42800;
  int _totalPaidMembers = 8500;
  double _totalRevenue = 52400.0;
  int _pendingApprovalsCount = 124;
  bool _isLoadingStats = false;
  int? _activeCommunityId;
  String _activeCommunityTitle = "Select Community";
  List<dynamic> _myCommunities = [];

  Future<void> _checkAndShowPersonalizeFeedModal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasPersonalized = prefs.getBool('has_personalized_feed') ?? false;
    if (!hasPersonalized) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PersonalizeFeedDialog(),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVendorType();
    _fetchMyCommunities();
    _fetchUsersList();
    _fetchHomeFeed();
    _fetchWithdrawals();
    _fetchOpportunities();
    _fetchMyListings();
    _fetchMySubmissions();
    _fetchPlatformSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAndShowPersonalizeFeedModal();
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          switch (args) {
            case 0: _currentIndex = 0; break;
            case 1: _currentIndex = 3; break;
            case 2: _currentIndex = 2; break;
          }
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          _checkMembershipStatus();
        }
      }
    });
  }

  Future<void> _checkMembershipStatus() async {
    try {
      final vendorId = await AuthService.getVendorIdString();
      final adminId = await AuthService.getAdminId();
      print("CHECK_MEMBERSHIP_STATUS community vendor_id: $vendorId, admin_id: $adminId");
      final response = await Database().getData({
        'action': 'check_membership_status',
        'vendor_id': vendorId,
        if (adminId != null) 'admin_id': adminId.toString(),
      }, endpoint: 'new_apis/menu_apis.php');

      if (response['success'] == true && response['data'] != null) {
        final showModal = response['data']['show_modal'] ?? false;
        final list = response['data']['memberships'] as List<dynamic>? ?? [];
        if (showModal && list.isNotEmpty) {
          setState(() {
            _matchingMemberships = list;
          });
          _showMembershipUpsellDialog();
        }
      }
    } catch (e) {
      debugPrint("Error checking membership status: $e");
    }
  }

  Color _getMembershipColor(String title) {
    final t = title.toUpperCase();
    if (t.contains("GOLD")) return const Color(0xFFB45309);
    if (t.contains("SILVER")) return const Color(0xff006565);
    if (t.contains("BRONZE")) return Colors.grey.shade400;
    return const Color(0xff006565);
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
        themeColor: const Color(0xff006565),
      ),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Membership purchased successfully!"),
            backgroundColor: Color(0xff006565),
          ),
        );
        _fetchMyCommunities();
      }
    });
  }

  void _showMembershipUpsellDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(Icons.verified, color: Color(0xff006565), size: 20),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Serene Membership",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff006565),
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "SKIP FOR NOW",
                          style: TextStyle(
                            color: Color(0xFF3E4949),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Hero & Bento Grid Scrollable Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          "Unlock your ecosystem's full potential with a Serene Membership.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1B1B),
                            fontFamily: 'Manrope',
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Get exclusive access to strategic partnerships, priority placement, and dedicated support designed for high-stakes administrative environments.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                        ),
                        const SizedBox(height: 32),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (_matchingMemberships.isEmpty) {
                              return const Center(
                                child: Text("No matching membership plans available"),
                              );
                            }
                            
                            bool isWide = constraints.maxWidth > 850;
                            final cards = _matchingMemberships.map<Widget>((plan) {
                              final title = plan['title']?.toString() ?? 'Plan';
                              final double price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0.0;
                              final double finalPrice = double.tryParse(plan['final_price']?.toString() ?? '0') ?? 0.0;
                              final double discount = double.tryParse(plan['discount']?.toString() ?? '0') ?? 0.0;

                              String validityText = '';
                              if (plan['validity'].toString() == 'Unlimited') {
                                validityText = 'Lifetime Validity';
                              } else {
                                validityText = '${plan['validity']} Days Validity';
                              }

                              final List<String> features = [];
                              final details = plan['details'] as List<dynamic>? ?? [];
                              for (var det in details) {
                                features.add("${det['posts']} posts on ${det['display_name']}");
                              }
                              if (plan['include_team_members'] == 1 || plan['include_team_members'].toString() == '1') {
                                features.add("Includes ${plan['team_member_count']} team members");
                                features.add("Add member at ₹${plan['additional_member_price']}");
                              }

                              final color = _getMembershipColor(title);

                              return _buildPlanCard(
                                plan: Map<String, dynamic>.from(plan),
                                title: title,
                                price: "₹${finalPrice.toStringAsFixed(0)}",
                                validity: validityText,
                                oldPrice: discount > 0 ? "₹${price.toStringAsFixed(0)}" : "",
                                features: features,
                                color: color,
                                isFeatured: plan == _matchingMemberships.first,
                              );
                            }).toList();

                            return isWide
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: cards.map((c) => Expanded(child: c)).toList(),
                                  )
                                : Column(
                                    children: cards.expand((c) => [c, const SizedBox(height: 16)]).toList()..removeLast(),
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Modal Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff006565),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Redirecting to all membership plans..."),
                                backgroundColor: Color(0xff006565),
                              ),
                            );
                          },
                          icon: const Text("View All Membership Plans", style: TextStyle(fontWeight: FontWeight.bold)),
                          label: const Icon(Icons.arrow_forward),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF3E4949)),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Not interested right now, take me to my dashboard",
                          textAlign: TextAlign.center,
                          style: TextStyle(decoration: TextDecoration.underline, fontSize: 13),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required String title,
    required String price,
    required String validity,
    required String oldPrice,
    required List<String> features,
    required Color color,
    bool isFeatured = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFeatured ? const Color(0xff006565) : Colors.grey.shade200, width: isFeatured ? 2.5 : 1),
        boxShadow: isFeatured
            ? [BoxShadow(color: const Color(0xff006565).withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xff006565), borderRadius: BorderRadius.circular(8)),
              child: const Text("MOST STRATEGIC CHOICE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              Icon(Icons.workspace_premium, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B))),
              if (oldPrice.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  oldPrice,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          Text(validity, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949), fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xff006565), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: Color(0xFF1C1B1B)))),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                foregroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: isFeatured ? color.withOpacity(0.05) : Colors.transparent,
              ),
              onPressed: () {
                Navigator.pop(context);
                _openCheckoutSheet(plan);
              },
              child: Text(plan['is_purchased'] == 1 || plan['is_purchased'].toString() == '1' ? "Purchased" : "Select $title", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _loadVendorType() async {
    final userData = await AuthService.getCachedUserData();
    if (userData != null) {
      final type = userData['vendor_type']?.toString();
      if (type != null) {
        setState(() {
          _vendorType = type;
          _currentIndex = (_vendorType == '200') ? 0 : 12;
        });
      }
    }
  }

  Future<void> _fetchOpportunities() async {
    setState(() {
      _isLoadingOpportunities = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_all_opportunities',
      }, endpoint: 'new_apis/marketplace_opportunity_api.php');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is Map && data.containsKey('opportunities')) {
          setState(() {
            _realOpportunities = data['opportunities'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching opportunities: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOpportunities = false;
        });
      }
    }
  }

  Future<void> _fetchMyListings() async {
    setState(() {
      _isLoadingListings = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_my_listings',
      }, endpoint: 'new_apis/marketplace_opportunity_api.php');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is Map && data.containsKey('listings')) {
          setState(() {
            _myListings = data['listings'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching my listings: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingListings = false;
        });
      }
    }
  }

  Future<void> _fetchMySubmissions() async {
    setState(() {
      _isLoadingSubmissions = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_my_submissions',
      }, endpoint: 'new_apis/marketplace_opportunity_api.php');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data is Map && data.containsKey('submissions')) {
          setState(() {
            _mySubmissions = data['submissions'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching my submissions: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSubmissions = false;
        });
      }
    }
  }

  // API Call: Fetch Users List
  Future<void> _fetchUsersList() async {
    setState(() {
      _isLoadingUsers = true;
    });
    try {
      final database = Database();
      final response = await database.getData({
        'action': 'get_users_list',
      }, endpoint: 'new_apis/manage_user_api.php');
      
      if (response['success'] == true || response['status'] == 200 || response.containsKey('general_users')) {
        setState(() {
          _generalUsers = response['general_users'] ?? [];
          _businessUsers = response['business_users'] ?? [];
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _fetchMyCommunities() async {
    try {
      final response = await Database().getData({
        'action': 'fetch_shared_invites_admin',
      }, endpoint: 'new_apis/community_dashboard_api.php');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _myCommunities = data;
          if (data.isNotEmpty) {
            _activeCommunityId = int.tryParse(data[0]['community_id']?.toString() ?? '');
            _activeCommunityTitle = data[0]['community_title']?.toString() ?? 'Community';
          }
        });
        if (_activeCommunityId != null) {
          _fetchCommunityStats(_activeCommunityId!);
          _fetchCommunityMembers(_activeCommunityId!);
        }
      }
    } catch (e) {
      print("Error fetching my communities: $e");
    }
  }

  Future<void> _fetchCommunityStats(int communityId) async {
    setState(() {
      _isLoadingStats = true;
    });
    try {
      final response = await Database().getData({
        'action': 'getCommunityStats',
        'community_id': communityId.toString(),
      }, endpoint: 'new_apis/community_dashboard_api.php');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          _totalMembers = int.tryParse(data['total_members']?.toString() ?? '0') ?? 0;
          _totalPaidMembers = int.tryParse(data['total_paid_members']?.toString() ?? '0') ?? 0;
          _totalRevenue = double.tryParse(data['total_revenue']?.toString() ?? '0.0') ?? 0.0;
        });
      }
    } catch (e) {
      print("Error fetching community stats: $e");
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _fetchCommunityMembers(int communityId) async {
    setState(() {
      _isLoadingApprovals = true;
    });
    try {
      final response = await Database().getData({
        'action': 'fetch_community_members',
        'community_id': communityId.toString(),
      }, endpoint: 'new_apis/community_dashboard_api.php');
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> members = data['members'] ?? [];
        
        setState(() {
          _pendingApprovals = members.where((m) => m['join_status']?.toString() == 'pending').toList();
          _pendingApprovalsCount = _pendingApprovals.length;
          
          final approved = members.where((m) => m['join_status']?.toString() == 'approved').toList();
          _activeMembers.clear();
          for (var m in approved) {
            final details = m['vendor_details'] ?? {};
            final name = details['name']?.toString() ?? 'Unknown Member';
            final role = m['member_id'].toString() == '1' ? 'Admin' : 'Member';
            _activeMembers.add({
              "name": name,
              "initials": name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "M",
              "role": role,
              "status": "ACTIVE",
              "statusColor": const Color(0xFF008080),
              "progress": 0.82,
            });
          }
        });
      }
    } catch (e) {
      print("Error fetching community members: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingApprovals = false;
        });
      }
    }
  }

  Future<void> _updateMemberStatus(int memberId, String status) async {
    try {
      final response = await Database().getData({
        'action': 'update_member_status',
        'member_id': memberId.toString(),
        'status': status,
      }, endpoint: 'new_apis/community_dashboard_api.php');
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Member status updated to $status successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (_activeCommunityId != null) {
          _fetchCommunityMembers(_activeCommunityId!);
          _fetchCommunityStats(_activeCommunityId!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to update member status"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error updating member status: $e");
    }
  }

  Future<void> _fetchHomeFeed() async {
    if (!mounted) return;
    setState(() {
      _isLoadingFeed = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_feed',
      }, endpoint: 'new_apis/social_feed_api.php');
      
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _feedPosts = response['data'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching home feed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFeed = false;
        });
      }
    }
  }

  Future<void> _toggleLike(int postId) async {
    try {
      final response = await Database().getData({
        'action': 'post_engagement',
        'post_id': postId.toString(),
        'engagement_type': 'like',
      }, endpoint: 'new_apis/social_app_api_v2_API.php');
      if (response['success'] == true) {
        _fetchHomeFeed();
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  Future<void> _addComment(int postId, String message) async {
    if (message.trim().isEmpty) return;
    try {
      final response = await Database().getData({
        'action': 'add_comment',
        'post_id': postId.toString(),
        'message': message,
      }, endpoint: 'new_apis/social_app_api_v2_API.php');
      if (response['success'] == true) {
        _fetchHomeFeed();
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  Future<void> _sharePost(int postId) async {
    try {
      final response = await Database().getData({
        'action': 'post_engagement',
        'post_id': postId.toString(),
        'engagement_type': 'share',
      }, endpoint: 'new_apis/social_app_api_v2_API.php');
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Post shared successfully!"),
              backgroundColor: Color(0xFF006565),
            ),
          );
        }
        _fetchHomeFeed();
      }
    } catch (e) {
      print("Error sharing post: $e");
    }
  }

  Future<void> _createPost(String content) async {
    if (content.trim().isEmpty) return;
    try {
      final response = await Database().getData({
        'action': 'create_post',
        'content_type': 'text',
        'visibility': 'public',
        'label': content,
      }, endpoint: 'new_apis/social_feed_api.php');
      
      if (response['success'] == true) {
        _postController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Post created successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchHomeFeed();
      }
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  // API Call: Fetch Payout Withdrawal Requests
  Future<void> _fetchWithdrawals() async {
    setState(() {
      _isLoadingWithdrawals = true;
    });
    try {
      final database = Database();
      final response = await database.getData({
        'action': 'getWithdrawRequests',
      }, endpoint: 'new_apis/withdrawl_request_api.php');
      
      if (response['success'] == true || response['status'] == 200 || response.containsKey('data')) {
        setState(() {
          _withdrawalRequests = response['data'] ?? [];
        });
      }
    } catch (e) {
      print('Error fetching withdrawals: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWithdrawals = false;
        });
      }
    }
  }

  Future<void> _updateUserStatus(int userId, String type) async {
    try {
      final response = await Database().getData({
        'action': 'manage_user',
        'vendor_id': userId.toString(),
        'type': type,
      }, endpoint: 'new_apis/manage_user_api.php');
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User successfully ${type == 'suspend' ? 'suspended' : 'activated'}!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchUsersList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Action failed"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error managing user: $e");
    }
  }

  // Details dialog showing user's joined communities and actions
  void _showUserDetailsDialog(Map<String, dynamic> user) {
    final joined = user["community_list"] ?? user["joined_communities"];
    List<dynamic> communities = [];
    if (joined is List) {
      communities = joined;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(user["name"] ?? "User Details", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: ${user['email'] ?? 'N/A'}", style: const TextStyle(color: textDark)),
              const SizedBox(height: 8),
              Text("Mobile: ${user['mobile'] ?? 'N/A'}", style: const TextStyle(color: textDark)),
              const SizedBox(height: 8),
              Text("Status: ${user['status'] ?? 'Active'}", style: TextStyle(fontWeight: FontWeight.bold, color: user['status'] == 'Active' ? Colors.green : Colors.red)),
              const SizedBox(height: 12),
              const Text("Joined Communities:", style: TextStyle(fontWeight: FontWeight.bold, color: primaryPurple)),
              const SizedBox(height: 8),
              if (communities.isEmpty)
                const Text("No joined communities.", style: TextStyle(fontStyle: FontStyle.italic, color: textLight))
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: communities.length,
                    itemBuilder: (context, i) {
                      final item = communities[i];
                      final String comName = item is Map ? (item["title"] ?? item["name"] ?? "") : item.toString();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.group, color: primaryPurple),
                        title: Text(comName, style: const TextStyle(fontSize: 14)),
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
              Navigator.pop(ctx);
              final int userId = int.tryParse(user['id']?.toString() ?? '0') ?? 0;
              if (userId > 0) {
                _updateUserStatus(userId, user['status'] == 'Active' ? 'suspend' : 'activate');
              }
            },
            child: Text(
              user['status'] == 'Active' ? "Suspend User" : "Activate User",
              style: TextStyle(color: user['status'] == 'Active' ? Colors.red : Colors.green),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: primaryPurple)),
          )
        ],
      ),
    );
  }

  // Mock Data (legacy placeholders)
  final List<Map<String, dynamic>> _mockProducts = [
    {"title": "Rolex Submariner", "price": "₹12,500", "stock": 4, "status": "Approved"},
    {"title": "Louis Vuitton Keepall", "price": "₹2,800", "stock": 12, "status": "Approved"},
    {"title": "Gucci Double G Belt", "price": "₹650", "stock": 45, "status": "Pending"},
    {"title": "Hermes Birkin 30", "price": "₹22,000", "stock": 2, "status": "Approved"},
  ];

  final List<Map<String, dynamic>> _mockOrders = [
    {"id": "LX-9082", "user": "Aditya Singh", "amount": "₹12,500", "status": "Delivered"},
    {"id": "LX-9083", "user": "Nehal Gupta", "amount": "₹650", "status": "Pending"},
    {"id": "LX-9084", "user": "Vikram Rathore", "amount": "₹2,800", "status": "Shipped"},
  ];

  final List<String> _mockCategories = ["Luxury Watches", "Leather Bags", "Fine Jewelry", "Designer Belts", "Apparel"];

  final List<Map<String, dynamic>> _mockBankDetails = [
    {"vendor": "Ananya Sharma", "bank": "HDFC Bank", "account": "******9824", "ifsc": "HDFC0001202"},
    {"vendor": "Siddharth Sen", "bank": "ICICI Bank", "account": "******4019", "ifsc": "ICIC0000047"},
  ];

  final List<Map<String, dynamic>> _mockOpportunities = [
    {
      "title": "Lead UX Designer",
      "company": "FinTech Pro",
      "budget": "₹50k-80k",
      "match": "85%",
      "tags": ["Immediate Start", "Fintech", "Full-time", "Remote"],
      "applicants": "12",
    },
    {
      "title": "Product Manager",
      "company": "E-com Hub",
      "budget": "₹90k-120k",
      "match": "72%",
      "tags": ["Tech", "Full-time", "Hybrid"],
      "applicants": "5",
    },
    {
      "title": "Flutter Developer",
      "company": "Mobile Studio",
      "budget": "₹40k-60k",
      "match": "90%",
      "tags": ["Flutter", "Immediate", "Remote"],
      "applicants": "18",
    },
  ];

  final List<Map<String, dynamic>> _mockMembershipPlans = [
    {"tier": "Basic (Free)", "price": "₹0", "duration": "Lifetime", "features": "List up to 5 items"},
    {"tier": "Silver Premium", "price": "₹29/mo", "duration": "1 Month", "features": "List up to 50 items, 5% commission"},
    {"tier": "Gold Elite", "price": "₹79/mo", "duration": "3 Months", "features": "Unlimited listings, 2.5% commission"},
    {"tier": "Platinum Royalty", "price": "₹249/yr", "duration": "1 Year", "features": "Unlimited listings, 0% commission, Priority Support"},
  ];

  // Helper method to get screen title
  String _getTitle() {
    switch (_currentIndex) {
      case 0: return "Admin Dashboard";
      case 1: return "User Management";
      case 2: return "Product Catalog";
      case 3: return "Order Management";
      case 4: return "Category Management";
      case 5: return "List Items";
      case 6: return "Platform Settings";
      case 7: return "Financial Wallet";
      case 8: return "Withdrawal Requests";
      case 9: return "Seller Bank Details";
      case 10: return "Membership Plans";
      case 11: return "Admin Profile";
      case 15: return "Community Approvals";
      case 18: return "Marketplace Opportunities";
      case 19: return "My Listings";
      case 20: return "My Submissions";
      case 22: return "Order Management";
      case 23: return "Trading Opportunities";
      case 24: return "My Selected Items";
      case 25: return "Affiliate Orders";
      case 28: return "Explore Partners";
      case 29: return "Explore Talent";
      case 40: return "Logistics Dashboard";
      case 41: return "Packaging Inventory";
      case 42: return "Promotions & Discounts";
      case 43: return "Local Delivery Logistics";
      case 44: return "Combo Packages";
      default: return "Admin Portal";
    }
  }

  // Handle Logout action
  void _handleLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header Row (Icon + Title & Subtitle)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE), // Light red background
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.power_settings_new_rounded,
                      color: Color(0xFFC62828), // Dark red icon
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Confirm account log out",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Body message
              const Text(
                "Are you sure you want to sign out of your account?\nYou will need to enter your credentials to log back in.",
                style: TextStyle(
                  fontSize: 13,
                  color: textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: textDark,
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await AuthService.logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE), // Light red background
                        foregroundColor: const Color(0xFFC62828), // Red text
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Exit App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              content: const Text(
                'Are you sure you want to exit the app?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actionsPadding: EdgeInsets.zero,
              actions: [
                Divider(height: 1, color: Colors.grey.shade200),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Exit',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 12) {
          setState(() {
            _currentIndex = 12;
          });
          return false;
        } else {
          return await _showExitConfirmation();
        }
      },
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgLight,
      floatingActionButton: (_vendorType == '200')
          ? _buildCommunityAdminFAB()
          : ((_currentIndex == 18 || _currentIndex == 19)
              ? FloatingActionButton.small(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.createOpportunity).then((didCreate) {
                      if (didCreate == true) {
                        _fetchOpportunities();
                        _fetchMyListings();
                      }
                    });
                  },
                  child: const Icon(Icons.add),
                )
              : null),
      appBar: (_currentIndex == 0 || _currentIndex == 12 || _currentIndex == 50)
          ? _buildSellerHeader()
              : AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
                onPressed: () {
                  setState(() {
                    _currentIndex = (_vendorType == '200') ? 0 : 12;
                  });
                },
              ),
              centerTitle: true,
                  title: Text(
                    _getAppBarTitle(),
                    style: const TextStyle(
                      color: Color(0xFF006565),
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
              actions: [
                if (_currentIndex == 27 && _vendorType == '200')
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF006565)),
                    tooltip: "Campaign Scheduler",
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.campaignScheduler),
                  ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Color(0xFF006565)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LocalNotificationsScreen()),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Color(0xFF006565)),
                  onPressed: () {
                    setState(() => _currentIndex = 11); // Navigates to Admin Profile
                  },
                ),
              ],
            ),

      // Left Navigation Drawer
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Elite Partner",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1C1B1B), // AppTheme.textPrimary
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.verified,
                                color: Color(0xFF006565), // AppTheme.primary
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Verified B2B",
                                style: TextStyle(
                                  color: Color(0xFF3E4949), // AppTheme.textSecondary
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Mumbai, India",
                            style: TextStyle(
                              color: Color(0xFF3E4949), // AppTheme.textSecondary
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Navigation Drawer Items List
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (_vendorType == '200') ...[
                      _buildDrawerItem(0, Icons.dashboard_rounded, "Community Dashboard"),
                      _buildDrawerItem(19, Icons.forum_rounded, "Manage Communities"),
                      _buildDrawerItem(51, Icons.explore_rounded, "Explore Communities"),
                      _buildDrawerItem(15, Icons.people_rounded, "Manage Members"),
                      _buildDrawerItem(20, Icons.post_add_rounded, "Manage Posts"),
                      _buildDrawerItem(10, Icons.monetization_on_rounded, "Community Monetization"),
                      _buildDrawerItem(52, Icons.card_membership_rounded, "Membership Plans"),
                      _buildDrawerItem(7, Icons.wallet_rounded, "Wallet"),
                      _buildDrawerItem(9, Icons.account_balance_rounded, "Bank Details"),
                      _buildDrawerItem(3, Icons.receipt_long_rounded, "Orders"),
                      _buildDrawerItem(27, Icons.campaign_rounded, "Schedule Campaigns"),
                      _buildDrawerItem(6, Icons.settings_rounded, "Settings"),
                      _buildDrawerItem(99, Icons.receipt_long_outlined, "API Transaction Logs"),
                    ] else ...[
                      // _buildDrawerItem(0, Icons.dashboard_rounded, "Dashboard"),
                      _buildDrawerItem(12, Icons.storefront_rounded, "Seller Dashboard"),
                    _buildDrawerItem(33, Icons.chat_bubble_outline_rounded, "Inbox"),
                    _buildDrawerItem(60, Icons.campaign_rounded, "Marketplace Promotions"),
                    // _buildDrawerItem(13, Icons.supervised_user_circle_rounded, "Seller Management"),
                    // _buildDrawerItem(1, Icons.people_rounded, "Users"),
                    // _buildDrawerItem(15, Icons.group_add_rounded, "Community Approvals"),
                    
                    // Collapsible Products (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Products menus",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(2, Icons.inventory_2_rounded, "Manage Listing", isSubItem: true),
                            _buildDrawerItem(3, Icons.receipt_long_rounded, "Manage Orders", isSubItem: true),
                            _buildDrawerItem(31, Icons.warning_amber_rounded, "Manage Inventory", isSubItem: true),
                            _buildDrawerItem(44, Icons.layers, "Combo Pack", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Operations (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.build_circle_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Operations",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(40, Icons.local_shipping_rounded, "Logistics", isSubItem: true),
                            _buildDrawerItem(41, Icons.inventory_rounded, "Packaging", isSubItem: true),
                            _buildDrawerItem(42, Icons.local_offer_rounded, "Promotions", isSubItem: true),
                            _buildDrawerItem(29, Icons.work_outline_rounded, "Talent", isSubItem: true),
                            _buildDrawerItem(28, Icons.handshake_rounded, "Partnerships", isSubItem: true),
                            _buildDrawerItem(43, Icons.electric_scooter_rounded, "Local Delivery", isSubItem: true),
                          ],
                        ),
                      ),
                    ),
                    
                    // Collapsible Memberships (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.card_membership_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Memberships",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(10, Icons.card_membership_rounded, "Membership Plans", isSubItem: true),
                            _buildDrawerItem(14, Icons.build_rounded, "Membership Builder", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Business Opportunities (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.business_center_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Business Opportunities",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(18, Icons.work_outline_rounded, "Marketplace Opportunities", isSubItem: true),
                            _buildDrawerItem(20, Icons.assignment_turned_in_rounded, "My Submissions", isSubItem: true),
                            _buildDrawerItem(19, Icons.list_alt_rounded, "My Listings", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Trading Opportunities (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Trading Opportunities",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(23, Icons.swap_horiz, "Explore Opportunities", isSubItem: true),
                            _buildDrawerItem(24, Icons.bookmark_border, "My Selected Items", isSubItem: true),
                            _buildDrawerItem(25, Icons.receipt_long, "Affiliate Orders", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Financial (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Financial",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(7, Icons.wallet_giftcard_rounded, "Wallet", isSubItem: true),
                            // _buildDrawerItem(8, Icons.monetization_on_rounded, "Withdrawal Requests", isSubItem: true),
                            _buildDrawerItem(9, Icons.account_balance_rounded, "Bank Details", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Module Integration (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.integration_instructions_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Module Integration",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(16, Icons.shopping_bag_rounded, "Module Marketplace", isSubItem: true),
                            _buildDrawerItem(32, Icons.extension_rounded, "Module Manager", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible General Settings (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.settings_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "General Settings",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(4, Icons.category_rounded, "Category management", isSubItem: true),
                            _buildDrawerItem(5, Icons.list_alt_rounded, "List Items", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Team Building (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.groups_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Team Building",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(26, Icons.people_outline_rounded, "Manage Team", isSubItem: true),
                            _buildDrawerItem(27, Icons.task_outlined, "Manage Task", isSubItem: true),
                            _buildDrawerItem(28, Icons.handshake_outlined, "Explore Partners", isSubItem: true),
                            _buildDrawerItem(29, Icons.work_outline_rounded, "Explore Talent", isSubItem: true),
                            _buildDrawerItem(30, Icons.emoji_events_outlined, "Rewards & Recognition", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Support a Cause (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Support a Cause",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(45, Icons.explore_outlined, "Explore Charity Projects", isSubItem: true),
                            _buildDrawerItem(46, Icons.storefront_outlined, "Charity Marketplace", isSubItem: true),
                          ],
                        ),
                      ),
                    ),

                    // Collapsible Events (aligned and borderless)
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                          horizontalTitleGap: 8,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.event_rounded, color: Color(0xFF3E4949)),
                          title: const Text(
                            "Events",
                            style: TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                          ),
                          iconColor: Color(0xFF1C1B1B),
                          collapsedIconColor: Color(0xFF3E4949),
                          children: [
                            _buildDrawerItem(47, Icons.storefront_outlined, "Event marketplace", isSubItem: true),
                            _buildDrawerItem(48, Icons.event_available_outlined, "My Events", isSubItem: true),
                            _buildDrawerItem(49, Icons.work_outline_rounded, "Event Opportunities", isSubItem: true),
                          ],
                        ),
                      ),
                    ),
                    
                      _buildDrawerItem(6, Icons.settings_input_component_rounded, "Platform Settings"),
                      // _buildDrawerItem(11, Icons.person_rounded, "Profile"),
                    ],
                  ],
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Color(0xFFBA1A1A),
                ),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(color: Color(0xFFBA1A1A)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AccountActions.showLogoutSheet(context);
                },
              ),
            ],
          ),
        ),
      ),

      // Page Contents
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: _buildBodyContent(),
        ),
      ),

      // Footer Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getBottomNavBarIndex(),
        onTap: (index) {
          if (_vendorType == '200') {
            _setTabFromBottomNav(index);
          } else {
            if (index == 4) {
              // Tapping 'More' opens Left Navigation Drawer
              _scaffoldKey.currentState?.openDrawer();
            } else {
              _setTabFromBottomNav(index);
            }
          }
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: _vendorType == '200'
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
                BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: "Members"),
                BottomNavigationBarItem(icon: Icon(Icons.card_membership_rounded), label: "Packages"),
                BottomNavigationBarItem(icon: Icon(Icons.forum_rounded), label: "Communities"),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Orders"),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: "Products"),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
                BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: "More"),
              ],
      ),
    ),);
  }

  // Map Drawer views to Bottom Nav indexes
  int _getBottomNavBarIndex() {
    if (_vendorType == '200') {
      if (_currentIndex == 0 || _currentIndex == 12) return 0;
      if (_currentIndex == 15) return 1; // Members
      if (_currentIndex == 10) return 2; // Packages
      if (_currentIndex == 19) return 3; // Communities
      if (_currentIndex == 11) return 4; // Profile
      return 0;
    }
    if (_currentIndex == 0 || _currentIndex == 12) return 0;
    if (_currentIndex == 3) return 1; // Orders
    if (_currentIndex == 2) return 2; // Products
    if (_currentIndex == 7) return 3; // Wallet
    return 4; // fallback for others
  }

  // Navigate from bottom bar tabs
  void _setTabFromBottomNav(int bottomIndex) {
    if (_vendorType == '200') {
      setState(() {
        switch (bottomIndex) {
          case 0: _currentIndex = 0; break; // Dashboard
          case 1: _currentIndex = 15; break; // Members
          case 2: _currentIndex = 10; break; // Packages
          case 3: _currentIndex = 19; break; // Communities
          case 4: _currentIndex = 11; break; // Profile
        }
      });
      return;
    }
    if (bottomIndex == 3) {
      Navigator.pushNamed(context, '/wallet', arguments: 'admin');
    } else {
      setState(() {
        switch (bottomIndex) {
          case 0: _currentIndex = 0; break; // Admin Dashboard
          case 1: _currentIndex = 3; break; // Orders
          case 2: _currentIndex = 2; break; // Products
        }
      });
    }
  }

  // Drawer list items builder helper
  Widget _buildDrawerItem(int index, IconData icon, String title, {bool isSubItem = false}) {
    final bool isSelected = _currentIndex == index;
    return Container(
      margin: EdgeInsets.only(left: isSubItem ? 16 : 8, right: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryPurple.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        horizontalTitleGap: 8,
        leading: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF3E4949), size: isSubItem ? 20 : 24),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1C1B1B),
            fontSize: isSubItem ? 13 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close Drawer
          if (index == 99) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApiLogsScreen()),
            );
          } else if (index == 21) {
            Navigator.pushNamed(context, AppRoutes.createOpportunity);
          } else if (index == 40) {
            Navigator.pushNamed(context, AppRoutes.logistics);
          } else if (index == 41) {
            Navigator.pushNamed(context, AppRoutes.packaging);
          } else if (index == 42) {
            Navigator.pushNamed(context, AppRoutes.promotions);
          } else if (index == 43) {
            Navigator.pushNamed(context, AppRoutes.localDelivery);
          } else if (index == 29) {
            Navigator.pushNamed(context, AppRoutes.exploreTalent);
          } else if (index == 28) {
            Navigator.pushNamed(context, AppRoutes.explorePartners);
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }

  String _getAppBarTitle() {
    if (_vendorType == '200') {
      switch (_currentIndex) {
        case 0:
        case 12: return "Community Intelligence";
        case 50: return "Community Intelligence";
        case 19: return "Manage Communities";
        case 51: return "Explore Communities";
        case 15: return "Manage Members";
        case 20: return "Manage Posts";
        case 10: return "Community Monetization";
        case 52: return "Membership Plans";
        case 7: return "Wallet";
        case 9: return "Bank Details";
        case 11: return "Profile";
        case 3: return "Orders";
        case 27: return "Schedule Campaigns";
        case 6: return "Settings";
        default: return "Serene Commerce";
      }
    }
    switch (_currentIndex) {
      case 50: return "Community Intelligence";
      case 4: return "Category Management";
      case 5: return "List Items";
      case 7: return "Wallet";
      case 10: return "Membership Plans";
      case 14: return "Membership Builder";
      case 16: return "Module Marketplace";
      case 17: return "Module Integration";
      case 18: return "Marketplace Opportunities";
      case 19: return "My Listings";
      case 20: return "My Submissions";
      case 23: return "Explore Opportunities";
      case 24: return "My Selected Items";
      case 25: return "Affiliate Orders";
      case 26: return "Manage Team";
      case 27: return "Manage Task";
      case 28: return "Explore Partners";
      case 29: return "Explore Talent";
      case 30: return "Rewards & Recognition";
      case 32: return "Module Manager";
      case 33: return "Inbox";
      case 40: return "Logistics Dashboard";
      case 41: return "Packaging Inventory";
      case 42: return "Promotions & Discounts";
      case 43: return "Local Delivery Logistics";
      case 44: return "Combo Packages";
      case 45: return "Explore Charity Projects";
      case 46: return "Charity Marketplace";
      case 47: return "Event Marketplace";
      case 48: return "My Events";
      case 49: return "Event Opportunities";
      case 60: return "Marketplace Promotions";
      default: return "Serene Commerce";
    }
  }

  // Render Body based on index
  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0: return _buildDashboardView(); // Render main Community dashboard statistics view
      case 12: return const SellerDashboardScreen(isEmbedded: true); // Render main Seller dashboard statistics view
      case 60: return const PromotionalPackagesScreen(isEmbedded: true);
      case 50: return _buildHomeFeedView();
      case 51: return const ExploreCommunitiesScreen(isEmbedded: true);
      case 52: return const MembershipPlansScreen(isEmbedded: true);
      case 11: return const ProfileScreen();
      case 1: return _buildTextUsersView(); // renamed custom users view helper below
      case 2: return const ProductManagementScreen(isEmbedded: true);
      case 31: return const LowStockInventoryScreen(isEmbedded: true);
      case 3: return _vendorType == '200'
          ? const PromotionalPackageOrdersScreen(isEmbedded: true)
          : const SellerOrderScreen(isEmbedded: true);
      case 4: return const TaxonomyManagerScreen(isEmbedded: true);
      case 5: return const ManageItemsScreen(isEmbedded: true);
      case 6: return const PersonalizeFeedDialog(isEmbedded: true);
      case 7: return const WalletAdminScreen(isEmbedded: true);
      case 8: return _buildWithdrawalRequestsView();
      case 9: return _buildBankDetailsView();
      case 10: return _vendorType == '200'
          ? const ManagePromotionalPackagesScreen(isEmbedded: true)
          : const MembershipPlansScreen(isEmbedded: true);
      case 11: return _buildProfileView();
      case 13: return const SellerManagementScreen(isEmbedded: true);
      case 14: return const MembershipBuilderScreen(isEmbedded: true);
      case 15: return _buildCommunityApprovalsView();
      case 16: return const MarketplaceModulesScreen(isEmbedded: true);
      case 17: return const ModuleIntegrationScreen(isEmbedded: true);
      case 18: return _buildMarketplaceOpportunitiesView();
      case 19: return const ManageOpportunitiesScreen(isTab: true);
      case 20: return _buildMySubmissionsView();
      case 23: return const TradingMarketplaceScreen(isEmbedded: true);
      case 24: return const SelectedItemsScreen(isEmbedded: true);
      case 25: return const AffiliateOrdersScreen(isEmbedded: true);
      case 26: return const ManageTeamScreen(isEmbedded: true);
      case 27: return _vendorType == '200'
          ? const ScheduleCampaignScreen(isEmbedded: true)
          : const ManageTasksScreen(isEmbedded: true);
      case 28: return const ExplorePartnersScreen(isEmbedded: true);
      case 29: return const ExploreTalentScreen(isEmbedded: true);
      case 30: return const RewardsRecognitionScreen(isEmbedded: true);
      case 32: return const ModuleManagerScreen();
      case 33: return const CommunityInboxScreen(isStandalone: false);
      case 40: return const LogisticsScreen(isEmbedded: true);
      case 41: return const PackagingScreen(isEmbedded: true);
      case 42: return const PromotionsScreen(isEmbedded: true);
      case 43: return const LocalDeliveryScreen(isEmbedded: true);
      case 44: return const ComboPackagesScreen(isEmbedded: true);
      case 45: return const ExploreCharityProjectsScreen(isEmbedded: true);
      case 46: return const CharityMarketplaceScreen(isEmbedded: true);
      case 47: return const EventMarketplaceScreen(isEmbedded: true);
      case 48: return const MyEventsScreen(isEmbedded: true);
      case 49: return const EventOpportunitiesScreen(isEmbedded: true);
      default: return _buildDashboardView();
    }
  }

  PreferredSizeWidget _buildSellerHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: Colors.black.withOpacity(0.08),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.black.withOpacity(0.04),
          height: 1,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xff006565)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff006565).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              (_currentIndex == 0 || _currentIndex == 50)
                  ? (_vendorType == '200' ? Icons.forum_rounded : Icons.group_work)
                  : Icons.storefront,
              color: const Color(0xff006565),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              (_currentIndex == 0 || _currentIndex == 50)
                  ? (_vendorType == '200' ? "Community Intelligence" : "Community Admin")
                  : "Seller Central",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xff006565),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (_vendorType == '200')
          IconButton(
            icon: Icon(
              Icons.home_rounded,
              color: _currentIndex == 50 ? const Color(0xff008080) : const Color(0xff006565),
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 50; // Navigate to Home Feed
              });
            },
            tooltip: "Home Feed",
          ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.02),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              );
            },
            tooltip: "Chat Messages",
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.02),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              )
            ],
          ),
        ),
        if (MediaQuery.of(context).size.width >= 600) ...[
          const SizedBox(width: 4),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Store Owner",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Premier Seller",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(width: 12),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context, rootNavigator: true).pushNamed('/user/profile');
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xff006565).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xffe5f7f7),
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150?img=33",
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  PreferredSizeWidget _buildCleanDashboardHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: Colors.black.withOpacity(0.08),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.black.withOpacity(0.04),
          height: 1,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xff006565)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff006565).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_outlined,
              color: Color(0xff006565),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              "Serene Commerce",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Color(0xff006565),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xff3e4949),
                  size: 24,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocalNotificationsScreen()),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xff006565).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pushNamed('/user/profile');
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xffe5f7f7),
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150?img=33",
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 1. Dashboard View
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_myCommunities.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBDC9C8)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _activeCommunityId,
                  items: _myCommunities.map((c) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(c['community_id']?.toString() ?? ''),
                      child: Text(
                        c['community_title']?.toString() ?? 'Community',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _activeCommunityId = val;
                        final selected = _myCommunities.firstWhere((c) => int.tryParse(c['community_id']?.toString() ?? '') == val);
                        _activeCommunityTitle = selected['community_title']?.toString() ?? 'Community';
                      });
                      _fetchCommunityStats(val);
                      _fetchCommunityMembers(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Section 1: Statistics Slider
          const Text(
            "CORE PERFORMANCE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDossierStatCard("Total Members", _totalMembers.toString(), trend: "", hasAccent: true),
                const SizedBox(width: 12),
                _buildDossierActiveCard("Paid Members", _totalPaidMembers.toString(), progress: 1.0),
                const SizedBox(width: 12),
                _buildDossierTextCard("Pending", _pendingApprovalsCount.toString(), "Review required", valColor: const Color(0xFFB45309)),
                const SizedBox(width: 12),
                _buildDossierTextCard("Net Revenue", "₹${_totalRevenue.toStringAsFixed(1)}", "Lifetime Earnings", valColor: const Color(0xFF1C1B1B)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section 2: Visitor Analytics Map
          _buildDossierCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Global Visitor Map",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF3E4949)),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEED),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuBKyWKzKAApID2AoWsIhWnAdfXvmMVtpWXIcqleHqvNo5cVgsYfMKwaR8OjzmTSQh-A_-umlsOzY6ZFOdKfVwlzfZ4_nLk6p4mE-cUL1rBMU8l0V9jBMVcB0P8K8OD4HHvn2LNkkfg28qMK2tDSlMwHOZc3DUNqzqkVsva3Oa1SByDJysgb8IDUP-YT-ro7Z_ZEGfwzhJMfESS19CE_F8qyj7CaxU8JFUC8VCT4pZlUed0CU6JY_Kxh",
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.6,
                          ),
                        ),
                      ),
                    ),
                    // Mock Map Markers
                    Positioned(
                      top: 40,
                      left: 80,
                      child: _buildMapPulseMarker(),
                    ),
                    Positioned(
                      top: 100,
                      left: 180,
                      child: _buildMapPulseMarker(size: 14),
                    ),
                    Positioned(
                      top: 60,
                      right: 90,
                      child: _buildMapPulseMarker(size: 8),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                        ),
                        child: const Text(
                          "Real-time Activity: 1,204 nodes",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section 3: Analytical Charts Slider
          const Text(
            "ANALYTICAL INSIGHTS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDemographicsChartCard(),
                const SizedBox(width: 12),
                _buildSalesTrendChartCard(),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section 4: Member Approvals
          const Text(
            "New Member Approvals",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMemberApprovalCard(
                  name: "Jordan Smith",
                  role: "Senior Architect",
                  avatarUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBU6C9nJEUf6OeahCGdO0Dq54LFMAAkDfJyyTT5HnNdMFh1U5Tk5gEw5x5Ybn9hjaWDQcVfz1GHfGI7OD_EyBLaN-5IDaVI5ERFYP6clT6jyYUcjQAPX3E5cRTW5nPlzVb2nq8RXOc7Lm6n7izg_ataQFkHt-B2Uti1tJPSkPXOFTDDTnqXG_UHVlxKgtm5xQ0LeT6phH-NhxUAORGrTxFlwtm9ROcnvYTdB7Y9O6uLgp4fQP0Z1xeN",
                ),
                const SizedBox(width: 12),
                _buildMemberApprovalCard(
                  name: "Sarah Chen",
                  role: "Product Lead",
                  avatarUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAJTrFHxrrETppbTZT7wfYief4z063tC9ynwUDfY0Zauhsm4wzu-QMoLFzssELj8jhQ3elurvFmovcp4WBvUcXFJ7Y9Holeb1zEbvI3rRg_HNJWs11jfqFO9hV6StzNUXjwAP-2olmk8iCp8D33m5WkLjR_osII-lgrvrlGu2xvlPMGmhEgXjW_4oum1mc40hjY8ah6M2V3QstbrVI4AnrPRq_PlQvfJoM6y302jZ8A_Tc42w1nnvKP",
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section 5: New Post Approvals
          const Text(
            "New Post Approvals",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          _buildPostApprovalItem("Tech Strategy for Q4", "Mike Donnovan", Icons.article_outlined),
          const SizedBox(height: 8),
          _buildPostApprovalItem("Upcoming Meetup FAQ", "Elena Rodriguez", Icons.forum_outlined),

          const SizedBox(height: 28),

          // Section 6: Promotional Package Orders
          const Text(
            "Promotional Package Orders",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPromoOrderCard(
                  title: "Premium Growth Pk",
                  orderId: "#782-901",
                  price: r"₹499.00",
                  client: "Alex Rivera",
                  company: "TechFlow Inc.",
                  isPaid: true,
                  accentColor: const Color(0xFF6750A4),
                ),
                const SizedBox(width: 12),
                _buildPromoOrderCard(
                  title: "Basic Engagement",
                  orderId: "#782-895",
                  price: r"₹199.00",
                  client: "Jamie Lee",
                  company: "Creative Co.",
                  isPaid: false,
                  accentColor: const Color(0xFF008080),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section 7: Articles & Blogs
          const Text(
            "Articles & Blogs",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 290,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildArticleBlogCard(
                  title: "Scaling Engagement in 2024",
                  category: "Community Strategy",
                  authorName: "Sarah Chen",
                  views: "1.2k",
                  likes: "84",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuALNKH8mgdlWgYCTWEeiKzMNRwdndqhgbL_Auuzpkopuk7kKzF53vbfi2ELgFOaXZbIC5OWlPAs0olk5ciM9YAOvVUmcyIhBP1HYFyuyvcUXJbz-8lqE_VE-Upt9vvoI3C_FXXmkmTmxegAW1Ugnab6Ywo6DuZ9GiWXRE_VjxJhFlAKtppocXK3v8uoy6Kl5j-s9yeVaAkSf6KwnB9eOGhixAWX3vw54s0ZA-hbThs9PwFyxnSOoY8N",
                  authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuAJTrFHxrrETppbTZT7wfYief4z063tC9ynwUDfY0Zauhsm4wzu-QMoLFzssELj8jhQ3elurvFmovcp4WBvUcXFJ7Y9Holeb1zEbvI3rRg_HNJWs11jfqFO9hV6StzNUXjwAP-2olmk8iCp8D33m5WkLjR_osII-lgrvrlGu2xvlPMGmhEgXjW_4oum1mc40hjY8ah6M2V3QstbrVI4AnrPRq_PlQvfJoM6y302jZ8A_Tc42w1nnvKP",
                ),
                const SizedBox(width: 12),
                _buildArticleBlogCard(
                  title: "The Rise of Niche Networks",
                  category: "Market Insights",
                  authorName: "Jordan Smith",
                  views: "850",
                  likes: "42",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDXGJfZscVmWLX6TJlMlsUcZBvaI-tI25XIIQVdfr-qy83rMuZAXK1WcMdfBZHNVq6hTTXdRFCGVxgZ3VJKsf2B15ZBY5YlaRDbyvZEB_E6KZYJccMf5z0yQMkjlwNsLv7MJJmicBBI4qJ4l9_tuGcy-H3M3amP6LjhEH-kDBT0WVYYb4NK1hjSTLWOrVF-MW23wCepUzXlw3nA6PiY__e5GGpkQbkhz1kLYhE0Of_zdmj4pU3P6U9x",
                  authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuBU6C9nJEUf6OeahCGdO0Dq54LFMAAkDfJyyTT5HnNdMFh1U5Tk5gEw5x5Ybn9hjaWDQcVfz1GHfGI7OD_EyBLaN-5IDaVI5ERFYP6clT6jyYUcjQAPX3E5cRTW5nPlzVb2nq8RXOc7Lm6n7izg_ataQFkHt-B2Uti1tJPSkPXOFTDDTnqXG_UHVlxKgtm5xQ0LeT6phH-NhxUAORGrTxFlwtm9ROcnvYTdB7Y9O6uLgp4fQP0Z1xeN",
                  isGrowing: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DASHBOARD HELPER WIDGETS ====================

  Widget _buildDossierCard({
    required Widget child,
    bool hasAccent = false,
    Color accentColor = const Color(0xFF008080),
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    final EdgeInsetsGeometry childPadding = hasAccent
        ? padding.add(const EdgeInsets.only(left: 4))
        : padding;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFBDC9C8)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: childPadding,
            child: child,
          ),
          if (hasAccent)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                color: accentColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDossierStatCard(String label, String value, {required String trend, bool hasAccent = false}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        hasAccent: hasAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 12, color: Color(0xFF15803D)),
                const SizedBox(width: 2),
                Text(
                  trend,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierActiveCard(String label, String value, {required double progress}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFEEEEED),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierTextCard(String label, String value, String description, {Color valColor = const Color(0xFF1A1C1C)}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valColor),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPulseMarker({double size = 10.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF006565),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008080).withOpacity(0.6),
            blurRadius: size,
            spreadRadius: size / 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsChartCard() {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Community Demographics",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(96, 96),
                        painter: _DemographicsPainter(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "42k",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
                          ),
                          Text(
                            "TOTAL",
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF008080), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text("18-24 (70%)", style: TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF6750A4), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text("25-34 (30%)", style: TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTrendChartCard() {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sales Trend (30d)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _buildTrendBar(0.5)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.67)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.5)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.75)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(1.0, isHighlight: true)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.67)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.8)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Day 01", style: TextStyle(fontSize: 8, color: Color(0xFF3E4949))),
                Text("Day 30", style: TextStyle(fontSize: 8, color: Color(0xFF3E4949))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBar(double fraction, {bool isHighlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF006565) : const Color(0xFF006565).withOpacity(0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      height: 70 * fraction,
    );
  }

  Widget _buildMemberApprovalCard({required String name, required String role, required String avatarUrl}) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBDC9C8)),
                image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(role, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4F3F3),
                      foregroundColor: const Color(0xFF1A1C1C),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () => _showActionAlert("Contact User: Hello $name, we've reviewed your request..."),
                    child: const Text("Contact", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4F3F3),
                      foregroundColor: const Color(0xFF1A1C1C),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () => _showActionAlert("Rejected $name membership"),
                    child: const Text("Reject", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () => _showActionAlert("Approved $name membership successfully!"),
                    child: const Text("Approve", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostApprovalItem(String title, String author, IconData icon) {
    return _buildDossierCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF006565)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("by $author", style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _showActionAlert("Post rejected"),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF006565)),
                onPressed: () => _showActionAlert("Post approved successfully!"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoOrderCard({
    required String title,
    required String orderId,
    required String price,
    required String client,
    required String company,
    required bool isPaid,
    required Color accentColor,
  }) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        hasAccent: true,
        accentColor: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPaid ? "PREMIUM ORDER" : "STANDARD ORDER",
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: accentColor),
                ),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("Order ID: $orderId", style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949))),
            const SizedBox(height: 8),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFBDC9C8))),
              ),
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Client: $client", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text("Company: $company", style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPaid ? "Paid" : "Pending",
                        style: TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.bold, 
                          color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF006565)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _showActionAlert("Order summary: $title for $client. Total: $price"),
                    child: const Text("View Details", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _showActionAlert("Reviewing order $orderId"),
                    child: const Text("Review", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleBlogCard({
    required String title,
    required String category,
    required String authorName,
    required String views,
    required String likes,
    required String imageUrl,
    required String authorAvatar,
    bool isGrowing = false,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEED),
                    image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGrowing ? const Color(0xFF6750A4) : const Color(0xFF006565),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(authorAvatar),
                      ),
                      const SizedBox(width: 6),
                      Text(authorName, style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined, size: 12, color: Color(0xFF3E4949)),
                          const SizedBox(width: 2),
                          Text(views, style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949))),
                          const SizedBox(width: 8),
                          const Icon(Icons.favorite_border, size: 12, color: Color(0xFF3E4949)),
                          const SizedBox(width: 2),
                          Text(likes, style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBDC9C8)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.share_outlined, size: 12, color: Color(0xFF1A1C1C)),
                              SizedBox(width: 4),
                              Text("Share", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {},
                          child: const Text("Read More", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF006565),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget? _buildCommunityAdminFAB() {
    if (_currentIndex == 0 || _currentIndex == 12 || _currentIndex == 50) {
      return FloatingActionButton.small(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.group_add_rounded, color: Color(0xFF006565)),
                    title: const Text("Create Community"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.createCommunity);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.post_add_rounded, color: Color(0xFF006565)),
                    title: const Text("Create Post"),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CreatePostDialog(
                          onPostCreated: () {
                            _fetchHomeFeed();
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 19) {
      return FloatingActionButton.small(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createCommunity),
        child: const Icon(Icons.group_add_rounded),
      );
    } else if (_currentIndex == 15) {
      return FloatingActionButton.extended(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () => _showActionAlert("Sent member invite successfully!"),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text("Invite Member"),
      );
    } else if (_currentIndex == 20) {
      return FloatingActionButton.small(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CreatePostDialog(
              onPostCreated: () {
                _fetchHomeFeed();
              },
            ),
          );
        },
        child: const Icon(Icons.post_add_rounded),
      );
    } else if (_currentIndex == 10) {
      return null;
    }
    return null;
  }

  // Tabbed view for User Management
  Widget _buildTextUsersView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: primaryPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryPurple,
            tabs: [
              Tab(text: "General Users"),
              Tab(text: "Business Users"),
            ],
          ),
          Expanded(
            child: _isLoadingUsers
                ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                : TabBarView(
                    children: [
                      _buildUsersList(_generalUsers, "General"),
                      _buildUsersList(_businessUsers, "Business"),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Helper builder for user lists
  Widget _buildUsersList(List<dynamic> users, String role) {
    if (users.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchUsersList,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400,
            alignment: Alignment.center,
            child: Text("No $role Users found.", style: const TextStyle(color: textLight)),
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _fetchUsersList,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, idx) {
          final user = users[idx];
          final String name = user["name"]?.toString() ?? "User";
          final String email = user["email"]?.toString() ?? "";
          final String status = user["status"]?.toString() ?? "Active";
          final String id = user["id"]?.toString() ?? "";
          final String pic = user["profile_pic"]?.toString() ?? "";
          
          return Card(
            color: cardColor,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: bgLight,
                    backgroundImage: pic.isNotEmpty ? NetworkImage(pic) : null,
                    child: pic.isEmpty 
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)) 
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (email.isNotEmpty) Text(email, style: const TextStyle(color: textLight, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: accentPurple.withAlpha(25), borderRadius: BorderRadius.circular(6)),
                              child: Text(role, style: const TextStyle(fontSize: 10, color: primaryPurple, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: status == "Active" ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status, 
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: status == "Active" ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chat button
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: primaryPurple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            user: ChatUser(
                              id: id,
                              name: name,
                              lastMessage: '',
                              time: '',
                              avatarUrl: pic,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Info button
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: textLight),
                    onPressed: () => _showUserDetailsDialog(user),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Products Catalog View
  // ignore: unused_element
  Widget _buildProductsView() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _mockProducts.length,
      itemBuilder: (context, idx) {
        final product = _mockProducts[idx];
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEFFF),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Center(child: Icon(Icons.image_rounded, size: 40, color: primaryPurple)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product["price"], style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                        Text("Stock: ${product['stock']}", style: const TextStyle(color: textLight, fontSize: 11)),
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
  }

  // 5. Category Management View
  Widget _buildCategoriesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Add new category",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  minimumSize: const Size(0, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _mockCategories.length,
            itemBuilder: (context, idx) {
              return Card(
                color: cardColor,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.label_outline_rounded, color: primaryPurple),
                  title: Text(_mockCategories[idx], style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 6. List Items View
  Widget _buildListItemsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _mockProducts.length,
      itemBuilder: (context, idx) {
        final item = _mockProducts[idx];
        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.list_alt_rounded, color: primaryPurple),
            title: Text(item["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Price: ${item['price']}"),
            trailing: Text("Qty: ${item['stock']}"),
          ),
        );
      },
    );
  }

  Future<void> _fetchPlatformSettings() async {
    setState(() {
      _isLoadingSettings = true;
    });
    try {
      final response = await Database().getData({
        'action': 'fetch_settings',
      }, endpoint: 'new_apis/platform_setting_API.php');
      
      if (response['success'] == true && response['data'] != null) {
        final site = response['data']['site'];
        if (site != null) {
          setState(() {
            _isMaintenanceMode = (int.tryParse(site['status']?.toString() ?? '1') ?? 1) == 0;
            _isAutoApproveVendors = (int.tryParse(site['need_approval']?.toString() ?? '1') ?? 1) == 0;
            _isEscrowEnabled = (int.tryParse(site['is_commission_split']?.toString() ?? '0') ?? 0) == 1;
            _isPushNotificationsEnabled = (int.tryParse(site['show_product_review']?.toString() ?? '0') ?? 0) == 1;
          });
        }
      }
    } catch (e) {
      print("Error fetching platform settings: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSettings = false;
        });
      }
    }
  }

  Future<void> _updatePlatformSetting(String key, dynamic value) async {
    try {
      final response = await Database().getData({
        'action': 'platform_setting',
        'update_action': 'update_single_setting',
        'key': key,
        'value': value.toString(),
      }, endpoint: 'new_apis/platform_setting_API.php');

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Setting updated successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchPlatformSettings(); // Reload
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to update setting"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error updating platform setting: $e");
    }
  }

  // 7. Platform Settings View
  Widget _buildPlatformSettingsView() {
    if (_isLoadingSettings) {
      return const Center(child: CircularProgressIndicator(color: primaryPurple));
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsSwitchTile(
          "Maintenance Mode",
          "Temporarily lock the platform for users",
          _isMaintenanceMode,
          (val) {
            setState(() => _isMaintenanceMode = val);
            _updatePlatformSetting('status', val ? 0 : 1);
          },
        ),
        const SizedBox(height: 12),
        _buildSettingsSwitchTile(
          "Auto-Approve Vendors",
          "Skip manual verification for new signups",
          _isAutoApproveVendors,
          (val) {
            setState(() => _isAutoApproveVendors = val);
            _updatePlatformSetting('need_approval', val ? 0 : 1);
          },
        ),
        const SizedBox(height: 12),
        _buildSettingsSwitchTile(
          "Enable Escrow Service",
          "Hold buyer payments until delivery confirmation",
          _isEscrowEnabled,
          (val) {
            setState(() => _isEscrowEnabled = val);
            _updatePlatformSetting('is_commission_split', val ? 1 : 0);
          },
        ),
        const SizedBox(height: 12),
        _buildSettingsSwitchTile(
          "Push Notifications",
          "Send instant transaction alerts to users",
          _isPushNotificationsEnabled,
          (val) {
            setState(() => _isPushNotificationsEnabled = val);
            _updatePlatformSetting('show_product_review', val ? 1 : 0);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSwitchTile(String title, String subtitle, bool isEnabled, ValueChanged<bool> onChanged) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        activeTrackColor: primaryPurple.withAlpha(120),
        activeThumbColor: primaryPurple,
        value: isEnabled,
        onChanged: onChanged,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: textLight, fontSize: 12)),
      ),
    );
  }

  // 8. Financial Wallet View
  Widget _buildWalletView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryPurple, bgDark]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("PLATFORM ESCROW BALANCE", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                const Text("₹184,350.00", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Commission Earned: ₹18,435.00", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text("Payouts Pending: ₹4,200", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Platform Bank Accounts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 12),
          const Card(
            color: cardColor,
            child: ListTile(
              leading: Icon(Icons.account_balance_rounded, color: primaryPurple),
              title: Text("Escrow Holding - HDFC Bank"),
              subtitle: Text("Account: ******1092 | IFSC: HDFC0001202"),
            ),
          ),
        ],
      ),
    );
  }

  // 9. Withdrawal Requests View
  Widget _buildWithdrawalRequestsView() {
    return _isLoadingWithdrawals
        ? const Center(child: CircularProgressIndicator(color: primaryPurple))
        : _withdrawalRequests.isEmpty
            ? RefreshIndicator(
                onRefresh: _fetchWithdrawals,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: 400,
                    alignment: Alignment.center,
                    child: const Text("No withdrawal requests found.", style: TextStyle(color: textLight)),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchWithdrawals,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _withdrawalRequests.length,
                  itemBuilder: (context, idx) {
                    final req = _withdrawalRequests[idx];
                    final String description = req["description"]?.toString() ?? "Withdrawal";
                    final String amount = req["requestedAmount"]?.toString() ?? "0";
                    final String status = req["status"]?.toString() ?? "Pending";
                    
                    return Card(
                      color: cardColor,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(backgroundColor: bgLight, child: Icon(Icons.monetization_on_rounded, color: Colors.green)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text("Amount Requested: ₹$amount", style: const TextStyle(color: textLight, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text("Status: $status", style: TextStyle(fontWeight: FontWeight.bold, color: status == 'Pending' || status == 'pending' ? Colors.amber : (status == 'Approved' || status == 'approved' || status == 'success' ? Colors.green : Colors.red), fontSize: 11)),
                                ],
                              ),
                            ),
                            if (status == 'Pending' || status == 'pending') ...[
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Withdrawal Request approved!")),
                                  );
                                  setState(() {
                                    req['status'] = 'Approved';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  minimumSize: const Size(0, 0),
                                ),
                                child: const Text("Approve", style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
  }

  // 15. Community Approvals View
  Widget _buildPendingCard({
    required String name,
    required String role,
    required String avatarUrl,
    required int memberId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: const Color(0xFF006565)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBDC9C8)),
                        image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1C1B1B))),
                          Text(role, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4F3F3),
                          foregroundColor: const Color(0xFF1C1B1B),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showActionAlert("Inquiry dossier sent to $name"),
                        child: const Text(
                          "Contact",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4F3F3),
                          foregroundColor: const Color(0xFF1C1B1B),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _updateMemberStatus(memberId, 'rejected'),
                        child: const Text(
                          "Reject",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _updateMemberStatus(memberId, 'approved'),
                        child: const Text(
                          "Approve",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
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
  }

  Widget _buildCommunityApprovalsView() {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    final Widget pendingSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Pending Approval",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1C),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF006565).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${_pendingApprovals.length} Pending",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006565),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_pendingApprovals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No pending approval requests.", style: TextStyle(color: textLight)),
          )
        else
          ..._pendingApprovals.map((item) {
            final details = item['vendor_details'] ?? {};
            final name = details['name']?.toString() ?? 'No Name';
            final designation = details['designation']?.toString() ?? 'Applicant';
            final avatar = details['profile_pic']?.toString() ?? "https://i.pravatar.cc/150";
            final memberId = int.tryParse(item['member_id']?.toString() ?? '0') ?? 0;
            return _buildPendingCard(
              name: name,
              role: designation,
              avatarUrl: avatar.startsWith('http') ? avatar : "https://i.pravatar.cc/150",
              memberId: memberId,
            );
          }).toList(),
      ],
    );

    // Active Members List Table
    final String query = _memberSearchController.text.toLowerCase();
    final List<Map<String, dynamic>> filteredMembers = _activeMembers.where((m) {
      final String name = m["name"].toString().toLowerCase();
      final String role = m["role"].toString().toLowerCase();
      return name.contains(query) || role.contains(query);
    }).toList();

    final Widget activeMembersSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Active Members",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1C),
              ),
            ),
            // Search Input
            SizedBox(
              width: 180,
              height: 36,
              child: TextField(
                controller: _memberSearchController,
                onChanged: (val) => setState(() {}),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF3E4949)),
                  hintText: "Filter members...",
                  hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  filled: true,
                  fillColor: const Color(0xFFF4F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF006565)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: isDesktop ? 900 : 550,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBDC9C8)),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    color: const Color(0xFFF4F3F3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text("MEMBER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text("ENGAGEMENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("ACTIONS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFBDC9C8)),
                  if (filteredMembers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: const Center(
                        child: Text("No members match filter query", style: TextStyle(color: Color(0xFF757575), fontSize: 13)),
                      ),
                    )
                  else
                    ...filteredMembers.map((m) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Row(
                              children: [
                                // Member Initials/Avatar
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F3F3),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFBDC9C8)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            m["initials"],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: m["statusColor"],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1C1B1B)), overflow: TextOverflow.ellipsis),
                                            Text(m["role"], style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949)), overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status tag
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (m["statusColor"] as Color).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        m["status"],
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: m["statusColor"],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Engagement progress
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: m["progress"],
                                        minHeight: 6,
                                        backgroundColor: const Color(0xFFF4F3F3),
                                        valueColor: AlwaysStoppedAnimation<Color>(m["statusColor"]),
                                      ),
                                    ),
                                  ),
                                ),
                                // Actions
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.mail_outline_rounded, size: 16, color: Color(0xFF006565)),
                                        onPressed: () => _showActionAlert("Opened mail box for ${m['name']}"),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _showActionAlert("Details page for ${m['name']}"),
                                        child: const Text(
                                          "VIEW",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF006565),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFBDC9C8)),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Title Header
          const Text(
            "Admin Profile Hub",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Strategic oversight and dossier management for your community network.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 24),
          // Statistics Slider
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDossierTextCard("TOTAL MEMBERS", "12,482", "4% up", valColor: const Color(0xFF1C1B1B)),
                const SizedBox(width: 12),
                _buildDossierTextCard("NEW REQUESTS", "48", "URGENT", valColor: const Color(0xFFB45309)),
                const SizedBox(width: 12),
                _buildDossierTextCard("ACTIVE TODAY", "3,891", "12% up", valColor: const Color(0xFF008080)),
                const SizedBox(width: 12),
                _buildDossierTextCard("MONTHLY GROWTH", "+842", "Growing", valColor: const Color(0xFF6750A4)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: pendingSection,
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 8,
                  child: activeMembersSection,
                ),
              ],
            )
          else ...[
            pendingSection,
            const SizedBox(height: 28),
            activeMembersSection,
          ],
        ],
      ),
    );
  }

  // 10. Seller Bank Details View
  Widget _buildBankDetailsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _mockBankDetails.length,
      itemBuilder: (context, idx) {
        final bank = _mockBankDetails[idx];
        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.account_balance_rounded, color: primaryPurple, size: 28),
            title: Text(bank["vendor"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Bank: ${bank['bank']} | Acc: ${bank['account']}"),
            trailing: Text("IFSC: ${bank['ifsc']}", style: const TextStyle(fontSize: 12, color: textLight)),
          ),
        );
      },
    );
  }

  // 11. Membership Plans View
  Widget _buildMembershipPlansView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _mockMembershipPlans.length,
      itemBuilder: (context, idx) {
        final plan = _mockMembershipPlans[idx];
        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plan["tier"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryPurple)),
                    Text(plan["price"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Billing Cycle: ${plan['duration']}", style: const TextStyle(color: textLight, fontSize: 13)),
                const Divider(),
                Text("Features: ${plan['features']}", style: const TextStyle(color: textDark, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 12. Profile View
  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: bgDark,
            child: Icon(Icons.admin_panel_settings_rounded, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text("Luxe System Admin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
          const Text("admin@luxe.com", style: TextStyle(color: textLight)),
          const SizedBox(height: 32),
          const Card(
            color: cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.security, color: primaryPurple),
                  title: Text("Role Security Credentials"),
                  subtitle: Text("Level 1 Super Admin"),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_active_outlined, color: primaryPurple),
                  title: Text("System Logs Alerting"),
                  subtitle: Text("Enabled via Slack & Email"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _showAddOpportunityDialog() {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("List New Opportunity", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Opportunity Title"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: "Company/Organization"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(labelText: "Budget (e.g. ₹50k-80k)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final response = await Database().getData({
                  "action": "create_opportunity",
                  "title": titleController.text,
                  "organization": companyController.text.isNotEmpty ? companyController.text : "Luxe Partner",
                  "payout_amount": budgetController.text.isNotEmpty ? budgetController.text : "Flexible",
                }, endpoint: "new_apis/marketplace_opportunity_api.php");
                
                if (response['success'] == true) {
                  _fetchOpportunities();
                  _fetchMyListings();
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Opportunity listed successfully!")),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to post: ${response['message'] ?? 'Error'}")),
                    );
                  }
                }
              }
            },
            child: const Text("Post", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceOpportunitiesView() {
    if (_isLoadingOpportunities) {
      return const Center(child: CircularProgressIndicator(color: primaryPurple));
    }
    if (_realOpportunities.isEmpty) {
      return const Center(
        child: Text(
          "No opportunities found in the database.",
          style: TextStyle(color: textLight, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _realOpportunities.length,
      itemBuilder: (context, index) {
        final item = _realOpportunities[index];
        final opp = item["opportunity"] as Map<String, dynamic>;
        final vendor = item["vendor"] as Map<String, dynamic>?;
        final comp = item["compensation"] as Map<String, dynamic>?;

        final title = opp["title"] ?? "Untitled Opportunity";
        final companyName = vendor != null ? (vendor["company_name"] ?? vendor["name"]) : (opp["organization"] ?? "Luxe Partner");
        final match = opp["label_name"] ?? "Premium";
        final payoutAmount = comp != null ? (comp["payout_amount"] ?? "Flexible") : "Flexible";
        final applicantsCount = item["total_applications"] ?? 0;

        final tags = [
          opp["type"],
          opp["location"],
          opp["opportunity_for"]
        ].where((t) => t != null && t.toString().isNotEmpty).toList();

        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black.withOpacity(0.04)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushNamed(context, '/opportunity_detail', arguments: item);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.business_center_rounded, color: primaryPurple, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textDark,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                companyName,
                                style: const TextStyle(
                                  color: textLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            match,
                            style: const TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xfff0f7f7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryPurple.withOpacity(0.05)),
                          ),
                          child: Text(
                            t.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff004d4d),
                            ),
                          ),
                        )).toList(),
                      ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.black.withOpacity(0.05)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Budget: $payoutAmount",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryPurple,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "$applicantsCount Applicants",
                          style: const TextStyle(
                            color: textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildMyListingsView() {
    if (_isLoadingListings) {
      return const Center(child: CircularProgressIndicator(color: primaryPurple));
    }
    if (_myListings.isEmpty) {
      return const Center(
        child: Text(
          "You haven't listed any opportunities yet.",
          style: TextStyle(color: textLight, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _myListings.length,
      itemBuilder: (context, index) {
        final item = _myListings[index];
        final title = item["title"] ?? "Untitled";
        final catTitle = item["category_title"] ?? "Opportunity";
        final status = (item["status"].toString() == "1") ? "Active" : "Draft";
        final date = item["created_at"] ?? "Posted recently";
        final appCount = item["total_applications"] ?? 0;
        final isActive = status == "Active";

        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: bgLight,
              child: Icon(Icons.list_alt_rounded, color: primaryPurple),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Category: $catTitle • $appCount Applicants", style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: textLight)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withAlpha(20) : Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMySubmissionsView() {
    if (_isLoadingSubmissions) {
      return const Center(child: CircularProgressIndicator(color: primaryPurple));
    }
    if (_mySubmissions.isEmpty) {
      return const Center(
        child: Text(
          "You haven't applied to any opportunities.",
          style: TextStyle(color: textLight, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _mySubmissions.length,
      itemBuilder: (context, index) {
        final item = _mySubmissions[index];
        final title = item["opportunity_title"] ?? "Opportunity";
        final company = item["vendor_company"] ?? item["vendor_name"] ?? "Luxe Partner";
        final date = item["created_date"] ?? "Applied recently";
        final statusText = (item["status"].toString() == "1") ? "Interviewing" : "Pending";
        final isInterviewing = statusText == "Interviewing";

        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: bgLight,
              child: Icon(Icons.assignment_turned_in_rounded, color: primaryPurple),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: textLight)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isInterviewing ? Colors.blue.withAlpha(20) : Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: isInterviewing ? Colors.blue.shade700 : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== HOME FEED SCREEN VIEW (MIGRATED FROM HTML) ====================

  Widget _buildHomeFeedView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentIndex == 50) {
        _checkAndShowPersonalizeFeedModal();
      }
    });

    final bool isDesktop = MediaQuery.of(context).size.width >= 768;
    
    final Widget mainFeed = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop) ...[
          _buildExecutiveOverviewCard(),
          const SizedBox(height: 16),
        ],
        _buildCreatePostCard(),
        const SizedBox(height: 16),
        _buildPersonalizeFeedBanner(),
        const SizedBox(height: 24),
        if (_isLoadingFeed)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: primaryPurple),
            ),
          )
        else if (_feedPosts.isEmpty)
          Center(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "No updates on your feed yet. Start by writing a post!",
                  style: TextStyle(color: textLight, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ..._feedPosts.map((post) => _buildDynamicPostCard(post)).toList(),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildExecutiveOverviewCard(),
                          const SizedBox(height: 16),
                          _buildPinnedReportsCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 9,
                      child: mainFeed,
                    ),
                  ],
                )
              : mainFeed,
        ),
      ),
    );
  }

  Widget _buildPersonalizeFeedBanner() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006565), Color(0xFF008080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personalize Your Feed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Choose interests to tailor your business matches and content.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF006565),
                elevation: 0,
                minimumSize: const Size(0, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const PersonalizeFeedDialog(),
                );
              },
              child: const Text(
                "Personalize",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveOverviewCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(color: Color(0xFF008080), width: 4),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Executive Overview",
              style: TextStyle(
                fontFamily: "Manrope",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF3E4949)),
                children: [
                  const TextSpan(text: "Strategic community health is currently "),
                  TextSpan(
                    text: "Optimal",
                    style: TextStyle(
                      color: const Color(0xFF008080),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildOverviewRow("Engagement", "+12.4%", const Color(0xFF15803D)),
            const SizedBox(height: 8),
            _buildOverviewRow("New Members", "+450", const Color(0xFF15803D)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color(0xFF3E4949),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPinnedReportsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pinned Reports",
              style: TextStyle(
                fontFamily: "Manrope",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
              ),
            ),
            const SizedBox(height: 12),
            _buildPinnedReportItem("Q3 Market Sentiment"),
            const SizedBox(height: 8),
            _buildPinnedReportItem("Governance Updates"),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedReportItem(String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 16, color: Color(0xFF006565)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3E4949),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBDC9C8)),
                image: const DecorationImage(
                  image: NetworkImage(
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuCjROtURqL93PgulLZeoQISnVMbeVSXeJZJjeLS91RV6bmgMKQymFpZ_utBLCs055N5AX4xs0IugklqoBczkEaX0hbcQn_RZBpAJk72jtsnuCW7s4z4j1B1Q12ggbPunW50AZGyoyA8pEUadRV_dLcs0qgNtJaeCt6jVRcs2Q0Dzc25ouX2QwdKAgnSo-A5TgZyuUkeehKO0TeVM-u5ER9Y3fILJHS5AXZriszyEVfacfEVyqX-7qdz",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => CreatePostDialog(
                      onPostCreated: () {
                        _fetchHomeFeed();
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F3F3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBDC9C8)),
                  ),
                  child: const Text(
                    "Draft a community update...",
                    style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => CreatePostDialog(
                    onPostCreated: () {
                      _fetchHomeFeed();
                    },
                  ),
                );
              },
              child: const Text(
                "Post",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicPostCard(dynamic post) {
    final int postId = int.tryParse(post['id']?.toString() ?? '0') ?? 0;
    final String authorName = post['author_name']?.toString() ?? 'Anonymous User';
    final String authorAvatar = post['author_avatar']?.toString() ?? '';
    final String postText = post['label']?.toString() ?? '';
    final String postImage = post['image_url']?.toString() ?? '';
    final String? youtubeId = _extractYoutubeId(postText);
    final String? twitterUrl = youtubeId == null ? _extractTwitterVideoUrl(postText) : null;
    final String createdDate = post['created_date']?.toString()?.split(' ')?.first ?? 'Just now';
    final int likesCount = int.tryParse(post['likes_count']?.toString() ?? '0') ?? 0;
    final bool isLiked = int.tryParse(post['is_liked']?.toString() ?? '0') == 1;
    final List<dynamic> comments = post['comments_list'] ?? [];
    final bool commentsExpanded = _expandedPostComments.contains(postId);
    
    if (!_commentControllers.containsKey(postId)) {
      _commentControllers[postId] = TextEditingController();
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: bgLight,
                  backgroundImage: authorAvatar.isNotEmpty ? NetworkImage(authorAvatar) : null,
                  radius: 24,
                  child: authorAvatar.isEmpty
                      ? Text(authorName.isNotEmpty ? authorName[0].toUpperCase() : "?", 
                          style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    Text(
                      createdDate.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (postText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                postText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1C1B1B),
                  height: 1.4,
                ),
              ),
            ),
          if (youtubeId != null)
            _buildYoutubePreview(youtubeId),
          if (twitterUrl != null)
            _buildTwitterPreview(twitterUrl),
          if (postImage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Image.network(
                postImage,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F3F3),
              border: Border(
                top: BorderSide(color: Color(0xFFBDC9C8)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleLike(postId),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                            size: 18,
                            color: isLiked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$likesCount",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isLiked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (commentsExpanded) {
                            _expandedPostComments.remove(postId);
                          } else {
                            _expandedPostComments.add(postId);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: Color(0xFF3E4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${comments.length}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _sharePost(postId),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: Color(0xFF3E4949),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Share",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (commentsExpanded) ...[
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                border: Border(
                  top: BorderSide(color: Color(0xFFBDC9C8)),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (comments.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final String cUser = comment['user_name']?.toString() ?? 'Anonymous';
                        final String cAvatar = comment['user_avatar']?.toString() ?? '';
                        final String cText = comment['message']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: bgLight,
                                backgroundImage: cAvatar.isNotEmpty ? NetworkImage(cAvatar) : null,
                                radius: 16,
                                child: cAvatar.isEmpty
                                    ? Text(cUser.isNotEmpty ? cUser[0].toUpperCase() : "?", 
                                        style: const TextStyle(color: primaryPurple, fontSize: 10, fontWeight: FontWeight.bold))
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F3F3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cUser,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cText,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF1C1B1B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentControllers[postId],
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          minimumSize: const Size(0, 0),
                        ),
                        onPressed: () {
                          final msg = _commentControllers[postId]!.text;
                          _addComment(postId, msg);
                          _commentControllers[postId]!.clear();
                        },
                        child: const Text("Post", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSarahMitchellPost() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBDC9C8)),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://lh3.googleusercontent.com/aida-public/AB6AXuAm1Y-cM-txAeQqpeUrttSjZpGFbUAOJvsif64_ecYneK5YroKzXv1DS1ddYVyQWZp1Z3wQgqNdm8AvlqZowiUj0XRrEdT8Fc65ji5AYLFC1wqhiq7xTHHIl68-RwiTYfbnt9NfA3pG7ho--7BIOWutFlpVVf4GDXP0CpVsudogYo2jnf5vGT6faUYh3PQaai8aXvS1xINLwslSx8r0pHtuH_CTyoinVmehyRpP8Myy2mKDsk8HZZJI",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sarah Mitchell",
                          style: TextStyle(
                            fontFamily: "Manrope",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1C1B1B),
                          ),
                        ),
                        Text(
                          "Director of Community Operations • 2h ago".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Strategic Update",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF008080),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Following our quarterly review, we are seeing a significant shift in community sentiment towards sustainable governance. I've uploaded the primary findings to the internal dashboard for further review by the committee. Let's maintain this momentum into Q4.",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1C1B1B),
                height: 1.4,
              ),
            ),
          ),
          // Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F3F3),
              border: Border(
                top: BorderSide(color: Color(0xFFBDC9C8)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _sarahMitchellLiked = !_sarahMitchellLiked;
                          if (_sarahMitchellLiked) {
                            _sarahMitchellLikes++;
                          } else {
                            _sarahMitchellLikes--;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            _sarahMitchellLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                            size: 18,
                            color: _sarahMitchellLiked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$_sarahMitchellLikes",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _sarahMitchellLiked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _commentsExpanded = !_commentsExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: Color(0xFF3E4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${_sarahComments.length}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "1.2k Views",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF3E4949)),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_commentsExpanded) ...[
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                border: Border(
                  top: BorderSide(color: Color(0xFFBDC9C8)),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sarahComments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person, size: 16, color: Color(0xFF6E7979)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F3F3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          index == 0 ? "Marcus Thorne" : "Feedback Contributor",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        const Text(
                                          "1h ago",
                                          style: TextStyle(color: Color(0xFF757575), fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _sarahComments[index],
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF1C1B1B)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Add a professional comment...",
                            hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF006565), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          minimumSize: const Size(0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_commentController.text.trim().isNotEmpty) {
                            setState(() {
                              _sarahComments.add(_commentController.text.trim());
                              _commentController.clear();
                            });
                          }
                        },
                        child: const Text("Post", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSponsoredProductsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Sponsored Products",
                    style: TextStyle(
                      fontFamily: "Manrope",
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006565),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBDC9C8).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Sponsored",
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildRoundIconButton(Icons.chevron_left, () {}),
                  const SizedBox(width: 4),
                  _buildRoundIconButton(Icons.chevron_right, () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildProductItemCard(
                  name: "Focus Pro ANC",
                  price: r"₹299.00",
                  image: "https://lh3.googleusercontent.com/aida-public/AB6AXuCdukG5Bs5MYrKezSVgml7mh082CzrDdiWUG-blbFr_Gen8Cv8vJoLMA3Y6nukYWyRcyYXb9NzEjwXtN1CzRM7TLk2tO4DkAhJNmAQPqNnzCN9CNLVEjbo_fmEAMR37_LtF0aTndX9xRuIA5PTI6XjAV5u36NzPAGo4wWHHoZPE_RrFxMeysFqgZmucUAVmuBxzymBpxMxtRRUpIB3yjYhSUfgrz7PY3Jp8166tWsIFuWuqQPKAm37i",
                ),
                const SizedBox(width: 12),
                _buildProductItemCard(
                  name: "Precision MX Mouse",
                  price: r"₹89.00",
                  image: "https://lh3.googleusercontent.com/aida-public/AB6AXuBOgKANhjHiOPlvSv4sED6CvcyV5KI3tc3FBKGGFrBUWqgq-PQIIjY5cmd8RPSlS2F1QpETUFl_3UqMU8_jrxNC2GmKLUqpSqakpX12wWDvdMVma40HxkGE5fx77c2QPFBEiQ3Fz0BOhPp9UguJUftrIcE-eUgWwRHlEmJ4d6d-BvHy9qNpwA9SFRfZ_OVDb7AInfLCZdel-VsE00_SuKdGeZ1KFkxFya-LE9suk23SIsUN6FLg8qDq",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 14, color: const Color(0xFF006565)),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildProductItemCard({required String name, required String price, required String image}) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3F3),
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1C1B1B)),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF006565)),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {},
              child: const Text("View Product", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDavidChenPost() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBDC9C8)),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://lh3.googleusercontent.com/aida-public/AB6AXuCnSNN9Ev9bSWwWJ0jVDJa7v95KZHw03OdmS74O_DUX6cKOqIeGzjd0y6JVJ24p97C2c1tDmdH26A5LA5VyV4nHvrFOVtPImUujWTdavfhUcq412ieukjKH5xlby9dVhcjoEp2gs208yU1gxl2fA1-ogBOj40rw0hgsU74eX829kySW-tRQJKNxPmOZ_TM4UeVfioSyfE-Is-o44UiXGUaUcNiz2q84vAVVfRbgUOMpET5APCsbQ1JO",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "David Chen",
                          style: TextStyle(
                            fontFamily: "Manrope",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1C1B1B),
                          ),
                        ),
                        Text(
                          "Lead Market Strategist • 5h ago".toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6750A4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Insights",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Visualizing the impact of our latest regional campaign. Data integrity across all touchpoints remains our priority.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1C1B1B)),
            ),
          ),
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F3F3),
              image: DecorationImage(
                image: NetworkImage(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuDNJaxx--dEpn58nLrLsuVU22zy_1B9kd7zR85UVOG6yITw4rFQALVSUXIQ4phjB2Bl2FqW2oHnbxZlKOdpLHQ3-gm2y7zHSSYLjMa6fjTI1bY1H05cwAmcY31C5jwMzodJ5IpQ2E2Mgvx_P7rkSCS5cl50pEdBt9ZRA0XM41zfGW2_9j9_gv0vNqgKKr6DMMPg67-mMAtvgAenuc6d1yFNI3DypCfz7refJD8z1PyhqRzA_Spfpymo",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F3F3),
              border: Border(
                top: BorderSide(color: Color(0xFFBDC9C8)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _davidChenLiked = !_davidChenLiked;
                          if (_davidChenLiked) {
                            _davidChenLikes++;
                          } else {
                            _davidChenLikes--;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            _davidChenLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: _davidChenLiked ? Colors.red : const Color(0xFF3E4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$_davidChenLikes",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _davidChenLiked ? Colors.red : const Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: const [
                        Icon(Icons.comment_outlined, size: 18, color: Color(0xFF3E4949)),
                        SizedBox(width: 4),
                        Text(
                          "32",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "3.5k Views",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF3E4949)),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingVideoPost() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "TM",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF008080), fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Training Media",
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    Text(
                      "Educational Branch • 12h ago".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "New Onboarding Module: \"Strategic Calm in Crisis Management\". Essential for all regional directors.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1C1B1B)),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://lh3.googleusercontent.com/aida-public/AB6AXuCure-d83KWmFNlPbJv_xTvE8lu_ElFDWVZh-B6sn3WvUDIE9rR9fyfvscdQuVnOfSumWtQmTwT4Vaze4cXOdgS8U98FNGQsXqjzqDUTI2TYTlzLAPGyZqKMwuZHiSm6tKJRzu-S6i-VxdgWKOWL4D9q5bnXdS7g4Fdkof5fU16OF4VNQe-ZOf4l5Ree9c6w91Pz7P6Mg4nu2JXCOdo1rTiCtiEGtjOQGb6WJ1pFIdDQ4OK-D0KeM0A",
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.7,
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF006565).withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "12:45",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F3F3),
              border: Border(
                top: BorderSide(color: Color(0xFFBDC9C8)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF3E4949)),
                    SizedBox(width: 4),
                    Text(
                      "98",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "5.1k Completions",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF3E4949)),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverMoreSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Discover More",
                style: TextStyle(
                  fontFamily: "Manrope",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006565),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: const [
                    Text("View All", style: TextStyle(color: Color(0xFF006565), fontSize: 11, fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF006565)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDiscoverCard(
                  type: "Product Shop",
                  title: "Executive Kit 2.0",
                  action: "View",
                  image: "https://lh3.googleusercontent.com/aida-public/AB6AXuB2B-fAjGeeGWH0mRI0k7nmwVdw40r-jVPY7yT5xpX6OmJXpZpsPcCweSgoFKozzYa3OM94_6KmiZh2_Z6gJcIqk3EBThKf5XAzf7y9BCgCfF3aM9m9u0Bg6eH0CuFzXK-iFkGdBf3ze7a6cbwaigpgSY0ilFn-5Xra_2tHt_8A3w39GYV1S5USV2UWiW3j7uR-IArW0H1K-y2PJm3QVQY0ds1c5gwMXvsJ0FvMtP8RBAsD9HfRu21G",
                ),
                const SizedBox(width: 12),
                _buildDiscoverJobCard(),
                const SizedBox(width: 12),
                _buildDiscoverEventCard(),
                const SizedBox(width: 12),
                _buildDiscoverCard(
                  type: "Training",
                  title: "Data Ethics 101",
                  action: "Start",
                  image: "https://lh3.googleusercontent.com/aida-public/AB6AXuABEQMxUVpkCYVMhdOe0VnC8R47eoH8ZAR8jTF41HjkqfDtBtspsQLld-ZP95760gSUL4sQG7iliF3I3MRaqY6EBCKUSG7p8kcf4Av8Geec26VzMijTr7vXSuHX3p9DTGTi7JmxsjegUw1s9doRV2eRjbmg0dPPUTq0YTRwbk9fDLRFAQu20H9R3HBsoPwFR_huxdT0g59AO0VelF7wG7jpbsH42GdcHA_pgafJd7TOwck9j-UMdQqI",
                ),
                const SizedBox(width: 12),
                _buildDiscoverCharityCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard({required String type, required String title, required String action, required String image}) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3F3),
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            type.toUpperCase(),
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1C1B1B)),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {},
              child: Text(action, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverJobCard() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            color: const Color(0xFF6750A4),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6750A4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.work_outline, size: 14, color: Color(0xFF6750A4)),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          "Senior Analyst",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1C1B1B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Regional HQ",
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)),
                  ),
                  const SizedBox(height: 4),
                  const Expanded(
                    child: Text(
                      "Looking for a strategy lead to manage EMEA community portfolio.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, color: Color(0xFF3E4949)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF006565)),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Apply", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverEventCard() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            color: const Color(0xFFB45309),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB45309).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("14", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFB45309))),
                        Text("NOV", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Annual Summit",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1C1B1B)),
                  ),
                  const SizedBox(height: 2),
                  const Expanded(
                    child: Text(
                      "Global Digital Transformation",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, color: Color(0xFF3E4949)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Register", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCharityCard() {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF008080).withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Icon(Icons.handshake_outlined, size: 24, color: Color(0xFF008080)),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tech for All",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1C1B1B)),
          ),
          const SizedBox(height: 2),
          const Text(
            "Donation Goal: 85%",
            style: TextStyle(fontSize: 9, color: Color(0xFF3E4949)),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.85,
              backgroundColor: Color(0xFFBDC9C8),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
              minHeight: 4,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF006565),
                elevation: 0,
                side: const BorderSide(color: Color(0xFF006565)),
                padding: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {},
              child: const Text("Donate", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElenaRodriguezPost() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBDC9C8)),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuCNIS1tQpvP0kkwlBlC26UVrtnoxGPplSnzenXLpyynw_Ch36k33qhSJeT5iyqdpPELxHvZCNktXs-iR9_nfh_SyDwbqtAkK9-WWAvS72EtAwjtskTbJG-fWsPsHV7mq7PTr6PzpfPlsVR9fiWDI6J0cXqtTKQ6MnW7sDVoA017j6Q9urSFpEURSbVtUhrLEVf2T3k08Vhbs8ItNViek4n_-QdnHR_nK9SU5xSae_p0vdD_tioWMSu1",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Elena Rodriguez",
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    Text(
                      "Global Research Lead • 1d ago".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Highlights from the 'Intelligence & Community' exhibition last week. It was inspiring to see how data can truly humanize our strategy.",
              style: TextStyle(fontSize: 14, color: Color(0xFF1C1B1B)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuA4NcJIhU4VtzQFVkmqGSqR91YX_w2s0P_8z2TcPe2CqJ6pvnq1ZVOPqw3xtxSkHgum_r4i1xvsLk8x81cHQzTV45jZvoBLg3Dmw9Lo8UytngG0niOIE3C150UFfFaoE-Vb33HoS6PS1G6vtPWsO2HX3ZNsWurjPGuv2U3TMYqOd-h69at4esCkF55NPiP2UtyLUbY-hqdet8U4_GrZ-FR_miTi0CpyaxoIc4ef238vyvmnMiSwnZQ2",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  "https://lh3.googleusercontent.com/aida-public/AB6AXuCVJzOk2vRcpvYZRy_usO_rmqdhCAkwg_PzQvYaBsunsTvScU1jAoAxdh4EVUmVhPTTjCgOOE1uYNQG9Yrjh78FdeXhOe5aeVf_TBZMCmUF2KwcMweKrdYZlJRWiIIKJie8HjyHLrgSx6quSHXRlMFq10NPjbNOwXilxttCb4ysbT8R9kBs7rOdn-Vs7Ge1mnkCVB3bIzbm3xACDBCipXMDfgyIi_mctucF7dqS27C0ltHTgzLsxW9D",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://lh3.googleusercontent.com/aida-public/AB6AXuBhoDm5e3L6wfu1DqbaUGSpRpUOyKlXuvC0rOvKZyKReQkMyrDaqSDnX-7GwaKXlXwk8ELYMg00kOM92WJ8ytNjsWpaBeW-QRruq1m0J3xk8Xu97NGta_2XJ-JeXVYKtdPGlFiPqDBFzeCDKJ5AeevBjEpZJXeghsCdsuIC7Xj8LpDTVrY5p4043_5YITyZ11Vuvs8Zpkh8FzJ1oTMNnDifkooQPd-ZItCQF6CXSJD3LUu6dIffIWa8",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.black45,
                                alignment: Alignment.center,
                                child: const Text(
                                  "+5 More",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F3F3),
              border: Border(
                top: BorderSide(color: Color(0xFFBDC9C8)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.star_outline_rounded, size: 18, color: Color(0xFF3E4949)),
                    SizedBox(width: 4),
                    Text(
                      "56",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "800 Shares",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF3E4949)),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}


// Local Standalone Notifications Mock Screen
class LocalNotificationsScreen extends StatefulWidget {
  const LocalNotificationsScreen({super.key});

  @override
  State<LocalNotificationsScreen> createState() => _LocalNotificationsScreenState();
}

class _NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  bool isUnread;
  final String dateGroup;
  final String? statusLabel;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isUnread = false,
    required this.dateGroup,
    this.statusLabel,
  });
}

class _LocalNotificationsScreenState extends State<LocalNotificationsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Orders', 'Payments', 'System', 'Support'];

  late List<_NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      _NotificationItem(
        id: '1',
        title: 'New Order Received',
        subtitle: 'Global Fintech Partners has ordered the Q4 Growth Accelerator dossier package.',
        category: 'Orders',
        time: '2m ago',
        icon: Icons.shopping_cart_rounded,
        iconColor: const Color(0xFF006565),
        iconBgColor: const Color(0xFF006565).withOpacity(0.1),
        isUnread: true,
        dateGroup: 'Today',
      ),
      _NotificationItem(
        id: '2',
        title: 'Membership Approved',
        subtitle: 'The strategic partnership application for Elite Venture Group has been verified.',
        category: 'Support',
        time: '1h ago',
        icon: Icons.person_add_rounded,
        iconColor: const Color(0xFF6750A4),
        iconBgColor: const Color(0xFF6750A4).withOpacity(0.1),
        isUnread: true,
        dateGroup: 'Today',
      ),
      _NotificationItem(
        id: '3',
        title: 'Withdrawal Successful',
        subtitle: 'Funds (\$12,450.00) have been successfully transferred to your verified corporate account.',
        category: 'Payments',
        time: 'Oct 24, 14:30',
        icon: Icons.payments_rounded,
        iconColor: const Color(0xFFB45309),
        iconBgColor: const Color(0xFFB45309).withOpacity(0.1),
        isUnread: false,
        dateGroup: 'Yesterday',
        statusLabel: 'Completed',
      ),
      _NotificationItem(
        id: '4',
        title: 'System Maintenance',
        subtitle: 'Scheduled optimization complete. All community management modules are at 100% efficiency.',
        category: 'System',
        time: 'Oct 24, 08:15',
        icon: Icons.settings_rounded,
        iconColor: const Color(0xFF657675),
        iconBgColor: const Color(0xFF657675).withOpacity(0.1),
        isUnread: false,
        dateGroup: 'Yesterday',
      ),
      _NotificationItem(
        id: '5',
        title: 'Support Ticket Closed',
        subtitle: 'Ticket #8821 regarding data export latency has been resolved by our strategic tech team.',
        category: 'Support',
        time: 'Oct 22, 11:05',
        icon: Icons.support_agent_rounded,
        iconColor: const Color(0xFF006565),
        iconBgColor: const Color(0xFF006565).withOpacity(0.1),
        isUnread: false,
        dateGroup: 'Earlier',
      ),
    ];
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && _notifications[index].isUnread) {
        _notifications[index].isUnread = false;
        
        // Show Toast
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("Marked as read", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF006565),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.only(bottom: 24, left: 60, right: 60),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter the items
    final filteredNotifications = _notifications.where((n) {
      if (_selectedFilter == 'All') return true;
      return n.category.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    // Group items by dateGroup
    final groups = <String, List<_NotificationItem>>{};
    for (var item in filteredNotifications) {
      groups.putIfAbsent(item.dateGroup, () => []).add(item);
    }

    final sortedGroups = ['Today', 'Yesterday', 'Earlier'].where((g) => groups.containsKey(g));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFEEEEED),
            child: ClipOval(
              child: Image.network(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuCvVD94n48_rKSlmLsyFDJAz292MXPm_TKHAZ9mbL7nd0WjKqPIbj8RkE7XkXGRyBzLNTdHDAJ8uCkkC-XPQ_5Xx0ojSo0UVDn6XDz34s1hjlXuS7ePS8u-dCaPRvtSPinuj109IZORatQrDt6gaUeN4oW-9Xk_-cVL6zL8H6cgQgFUxcwREywoIoXcJVp5c75nNTqb9-l8FWVuTuistoXEcqwtF6a9gR7l6NsG3kULzKTUJFKuiHxu",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Color(0xFF006565),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF006565)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF3E4949),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }
                        },
                        selectedColor: const Color(0xFF006565),
                        backgroundColor: const Color(0xFFEEEEED),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: Color(0xFFBDC9C8), height: 1),
            ],
          ),
        ),
      ),
      body: filteredNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No notifications found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedGroups.length,
              itemBuilder: (context, index) {
                final groupName = sortedGroups.elementAt(index);
                final groupItems = groups[groupName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        groupName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E4949),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...groupItems.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFFBDC9C8)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _markAsRead(item.id),
                          child: Stack(
                            children: [
                              if (item.isUnread)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  width: 4,
                                  child: Container(
                                    color: const Color(0xFF006565),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: item.iconBgColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        color: item.iconColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1A1C1C),
                                                  ),
                                                ),
                                              ),
                                              if (item.isUnread)
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF008080),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.subtitle,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF3E4949),
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                "${item.time} • ${item.category}",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (item.statusLabel != null) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF008080).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    item.statusLabel!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF008080),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
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
                    }).toList(),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
    );
  }
}

// Local Standalone Chat Mock Screen
class LocalChatListScreen extends StatelessWidget {
  const LocalChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Chats"),
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final names = ["Prince Garg", "Ananya Sharma", "Rahul Verma", "Siddharth Sen"];
          final messages = [
            "Hi, is my listing approved?",
            "I have updated the bank details.",
            "Can you help me with membership?",
            "Thanks for the support!"
          ];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF4F6FC),
              child: Text(names[index][0], style: const TextStyle(color: Color(0xFF006565))),
            ),
            title: Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(messages[index]),
            trailing: const Text("10m ago", style: TextStyle(color: Colors.grey, fontSize: 12)),
          );
        },
      ),
    );
  }
}

// Demographics Custom Painter for Community Dashboard Demographics Card
class _DemographicsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 8.0;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    final Paint bgPaint = Paint()
      ..color = const Color(0xFFEEEEED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint tealPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint purplePaint = Paint()
      ..color = const Color(0xFF6750A4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw background circle
    canvas.drawArc(rect, 0, 2 * 3.14159265, false, bgPaint);

    // Draw teal segment (70%) starting from -90 degrees (-pi/2)
    const double startAngle = -3.14159265 / 2;
    const double tealSweep = 2 * 3.14159265 * 0.70;
    canvas.drawArc(rect, startAngle, tealSweep, false, tealPaint);

    // Draw purple segment (30%) starting from where teal ends
    const double purpleSweep = 2 * 3.14159265 * 0.30;
    canvas.drawArc(rect, startAngle + tealSweep, purpleSweep, false, purplePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
