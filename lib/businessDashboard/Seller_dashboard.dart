import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:trading_ecommerce_admin/widgets/personalize_feed_dialog.dart';
import 'package:trading_ecommerce_admin/admin/site_settings_screen.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/admin/profile_screen.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/common/chat_screen.dart';
import 'package:trading_ecommerce_admin/widgets/account_actions.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/screens/manage_opportunities_screen.dart';
import 'package:trading_ecommerce_admin/screens/product_management_screen.dart';
import 'package:trading_ecommerce_admin/screens/low_stock_inventory_screen.dart';
import 'package:trading_ecommerce_admin/screens/trading_marketplace_screen.dart';
import 'package:trading_ecommerce_admin/screens/selected_items_screen.dart';
import 'package:trading_ecommerce_admin/screens/affiliate_orders_screen.dart';
import 'package:trading_ecommerce_admin/admin/seller_orders_screen.dart';
import 'package:trading_ecommerce_admin/screens/event_marketplace_screen.dart';
import 'package:trading_ecommerce_admin/screens/my_events_screen.dart';
import 'package:trading_ecommerce_admin/screens/event_opportunities_screen.dart';

import 'package:trading_ecommerce_admin/admin/taxonomy_manager_screen.dart';
import 'package:trading_ecommerce_admin/admin/manage_items_screen.dart';
import 'package:trading_ecommerce_admin/admin/platform_settings_screen.dart';
import 'package:trading_ecommerce_admin/admin/wallet_admin_screen.dart';
import 'package:trading_ecommerce_admin/admin/membership_plans_screen.dart';
import 'package:trading_ecommerce_admin/admin/membership_builder_screen.dart';
import 'package:trading_ecommerce_admin/common/notification_screen.dart';
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

import '../admin/my_Activity.dart';
import '../common/logout.dart';
import 'seller_dashboard_screen.dart';
import '../common/community_inbox_screen.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 12;

  static const Color primaryPurple = Color(0xFF006565);
  static const Color accentPurple = Color(0xFF008080);
  static const Color bgDark = Color(0xFF1E1E2C);
  static const Color bgLight = Color(0xFFF4F6FC);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);

  List<dynamic> _generalUsers = [];
  List<dynamic> _businessUsers = [];
  bool _isLoadingUsers = false;

  bool _isMaintenanceMode = false;
  bool _isAutoApproveVendors = true;
  bool _isEscrowEnabled = true;
  bool _isPushNotificationsEnabled = true;
  bool _isLoadingSettings = false;

  List<dynamic> _withdrawalRequests = [];
  bool _isLoadingWithdrawals = false;

  List<dynamic> _realOpportunities = [];
  bool _isLoadingOpportunities = false;

  List<dynamic> _myListings = [];
  bool _isLoadingListings = false;

  List<dynamic> _mySubmissions = [];
  bool _isLoadingSubmissions = false;

  @override
  void initState() {
    super.initState();
    _fetchUsersList();
    _fetchWithdrawals();
    _fetchOpportunities();
    _fetchMyListings();
    _fetchMySubmissions();
    _fetchPlatformSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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

  final List<Map<String, dynamic>> _mockProducts = [
    {"title": "Rolex Submariner", "price": "₹12,500", "stock": 4, "status": "Approved"},
    {"title": "Louis Vuitton Keepall", "price": "₹2,800", "stock": 12, "status": "Approved"},
    {"title": "Gucci Double G Belt", "price": "₹650", "stock": 45, "status": "Pending"},
    {"title": "Hermes Birkin 30", "price": "₹22,000", "stock": 2, "status": "Approved"},
  ];

  final List<String> _mockCategories = ["Luxury Watches", "Leather Bags", "Fine Jewelry", "Designer Belts", "Apparel"];

  final List<Map<String, dynamic>> _mockBankDetails = [
    {"vendor": "Ananya Sharma", "bank": "HDFC Bank", "account": "******9824", "ifsc": "HDFC0001202"},
    {"vendor": "Siddharth Sen", "bank": "ICICI Bank", "account": "******4019", "ifsc": "ICIC0000047"},
  ];

  final List<Map<String, dynamic>> _mockMembershipPlans = [
    {"tier": "Basic (Free)", "price": "₹0", "duration": "Lifetime", "features": "List up to 5 items"},
    {"tier": "Silver Premium", "price": "₹29/mo", "duration": "1 Month", "features": "List up to 50 items, 5% commission"},
    {"tier": "Gold Elite", "price": "₹79/mo", "duration": "3 Months", "features": "Unlimited listings, 2.5% commission"},
    {"tier": "Platinum Royalty", "price": "₹249/yr", "duration": "1 Year", "features": "Unlimited listings, 0% commission, Priority Support"},
  ];

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
        floatingActionButton: (_currentIndex == 18 || _currentIndex == 19)
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
            : null,
        appBar: (_currentIndex == 0)
            ? _buildSellerHeader()
            : AppBar(
          backgroundColor: Colors.teal,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              constraints: const BoxConstraints(minWidth: 40),
            ),
          ),
          leadingWidth: 40,
          title: Text(
            _getAppBarTitle(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 55,
                  child: IconButton(
                    icon: const Icon(Icons.chat, color: Colors.white, size: 22),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => const ChatListScreen(),
                        ),
                      );
                    },
                    tooltip: "Chat Messages",
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 50,
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
                          color: Colors.white,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      Positioned(
                        right: 7,
                        top: 7,
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
              ],
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
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
                                color: Color(0xFF1C1B1B),
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.verified,
                                  color: Color(0xFF006565),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Verified B2B",
                                  style: TextStyle(
                                    color: Color(0xFF3E4949),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Mumbai, India",
                              style: TextStyle(
                                color: Color(0xFF3E4949),
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
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(12, Icons.storefront_rounded, "Seller Dashboard"),
                      _buildDrawerItem(33, Icons.chat_bubble_outline_rounded, "Inbox"),
                      _buildDrawerItem(60, Icons.campaign_rounded, "Marketplace Promotions"),
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
                            leading: const Icon(Icons.task_rounded, color: textLight, size: 24),
                            title: const Text("My Activity Screen", style: TextStyle(fontSize: 14, color: textDark)),
                            children: [
                              _buildDrawerItem(7, Icons.task_outlined, "Job Applications", isSubItem: true),
                              _buildDrawerItem(27, Icons.people_outline_rounded, "Enrolled Trainings", isSubItem: true),
                              _buildDrawerItem(28, Icons.handshake_outlined, "Track Orders", isSubItem: true),
                              _buildDrawerItem(29, Icons.work_outline_rounded, "Track Digital product Orders", isSubItem: true),
                              _buildDrawerItem(30, Icons.emoji_events_outlined, "Support & Donations", isSubItem: true),
                              _buildDrawerItem(30, Icons.emoji_events_outlined, "Applied Opportunities", isSubItem: true),
                              _buildDrawerItem(30, Icons.emoji_events_outlined, "Upcoming Events", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(2, Icons.inventory_2_rounded, "Manage Listing", isSubItem: true),
                              _buildDrawerItem(3, Icons.receipt_long_rounded, "Manage Orders", isSubItem: true),
                              _buildDrawerItem(31, Icons.warning_amber_rounded, "Manage Inventory", isSubItem: true),
                              _buildDrawerItem(44, Icons.layers, "Combo Pack", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(10, Icons.card_membership_rounded, "Membership Plans", isSubItem: true),
                              _buildDrawerItem(14, Icons.build_rounded, "Membership Builder", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(18, Icons.work_outline_rounded, "Marketplace Opportunities", isSubItem: true),
                              _buildDrawerItem(20, Icons.assignment_turned_in_rounded, "My Submissions", isSubItem: true),
                              _buildDrawerItem(19, Icons.list_alt_rounded, "My Listings", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(23, Icons.swap_horiz, "Explore Opportunities", isSubItem: true),
                              _buildDrawerItem(24, Icons.bookmark_border, "My Selected Items", isSubItem: true),
                              _buildDrawerItem(25, Icons.receipt_long, "Affiliate Orders", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(7, Icons.wallet_giftcard_rounded, "Wallet", isSubItem: true),
                              _buildDrawerItem(9, Icons.account_balance_rounded, "Bank Details", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(16, Icons.shopping_bag_rounded, "Module Marketplace", isSubItem: true),
                              _buildDrawerItem(32, Icons.extension_rounded, "Module Manager", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(4, Icons.category_rounded, "Category management", isSubItem: true),
                              _buildDrawerItem(5, Icons.list_alt_rounded, "List Items", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(45, Icons.explore_outlined, "Explore Charity Projects", isSubItem: true),
                              _buildDrawerItem(46, Icons.storefront_outlined, "Charity Marketplace", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
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
                            iconColor: const Color(0xFF1C1B1B),
                            collapsedIconColor: const Color(0xFF3E4949),
                            children: [
                              _buildDrawerItem(47, Icons.storefront_outlined, "Event marketplace", isSubItem: true),
                              _buildDrawerItem(48, Icons.event_available_outlined, "My Events", isSubItem: true),
                              _buildDrawerItem(49, Icons.work_outline_rounded, "Event Opportunities", isSubItem: true),
                            ],
                          ),
                        ),
                      ),
                      _buildDrawerItem(6, Icons.settings_input_component_rounded, "Platform Settings"),
                    ],
                  ),
                ),
                const Divider(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xff006565),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff006565).withOpacity(0.2353),
                        offset: const Offset(0.0, 4.0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent, // keep the DecoratedBox color visible
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFFBA1A1A),
                      ),
                      title: const Text(
                        "Sign Out",
                        style: TextStyle(color: Color(0xFFBA1A1A)),
                      ),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer/menu first
                        showLogoutConfirmationDialog(context);
                      },
                    ),
                  ),
                )              ],
            ),
          ),
        ),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getBottomNavBarIndex(),
          onTap: (index) {
            _setTabFromBottomNav(index);
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryPurple,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: "Products"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
            BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: "Activity"),
          ],
        ),
      ),
    );
  }

  int _getBottomNavBarIndex() {
    if (_currentIndex == 0 ) return 0;
    if (_currentIndex == 3) return 1;
    if (_currentIndex == 2) return 2;
    if (_currentIndex == 7) return 3;
    if (_currentIndex == 70) return 4;
    return 0;
  }

  void _setTabFromBottomNav(int bottomIndex) {
    setState(() {
      switch (bottomIndex) {
        case 0:
          _currentIndex = 12; // Dashboard
          break;

        case 1:
          _currentIndex = 3; // Orders
          break;

        case 2:
          _currentIndex = 2; // Products
          break;

        case 3:
          _currentIndex = 7; // Wallet
          break;

        case 4:
          _currentIndex = 70; // Activity
          break;
      }
    });
  }
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
          Navigator.pop(context);
          if (index == 21) {
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
    switch (_currentIndex) {

      case 2: return "Products";
      case 3: return "Orders";
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
      case 70: return "My Activity";
      default: return "Seller Dashboard";
    }
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0: return SellerDashboardScreen(isEmbedded: true,);
      case 60: return const PromotionalPackagesScreen(isEmbedded: true);
      case 11: return const ProfileScreen();
      case 1: return _buildTextUsersView();
      case 2: return const ProductManagementScreen(isEmbedded: true);
      case 31: return const LowStockInventoryScreen(isEmbedded: true);
      case 3: return const SellerOrderScreen(isEmbedded: true);
      case 4: return const TaxonomyManagerScreen(isEmbedded: true);
      case 5: return const ManageItemsScreen(isEmbedded: true);
      // case 6: return const PersonalizeFeedDialog(isEmbedded: true);Biswajit
      case 7: return const WalletAdminScreen(isEmbedded: true);
      case 8: return _buildWithdrawalRequestsView();
      case 9: return _buildBankDetailsView();
      case 10: return const MembershipPlansScreen(isEmbedded: true);
      case 13: return const SellerManagementScreen(isEmbedded: true);
      case 14: return const MembershipBuilderScreen(isEmbedded: true);
      case 16: return const MarketplaceModulesScreen(isEmbedded: true);
      case 17: return const ModuleIntegrationScreen(isEmbedded: true);
      case 18: return _buildMarketplaceOpportunitiesView();
      case 19: return const ManageOpportunitiesScreen(isTab: true);
      case 20: return _buildMySubmissionsView();
      case 23: return const TradingMarketplaceScreen();
      case 24: return const SelectedItemsScreen(isEmbedded: true);
      case 25: return const AffiliateOrdersScreen(isEmbedded: true);
      case 26: return const ManageTeamScreen(isEmbedded: true);
      case 27: return const ManageTasksScreen(isEmbedded: true);
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
      case 70: return const MyActivity(isEmbedded: true);
      default: return const SellerDashboardScreen(isEmbedded: true,);
    }
  }

  PreferredSizeWidget _buildSellerHeader() {
    return AppBar(
      backgroundColor: Colors.teal,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(minWidth: 40),
        ),
      ),
      leadingWidth: 40,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
            child: Text(
              "Seller Dashboard",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 55,
              child: IconButton(
                icon: const Icon(Icons.chat, color: Colors.white, size: 22),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const ChatListScreen(),
                    ),
                  );
                },
                tooltip: "Chat Messages",
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(
              width: 40,
              height: 50,
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
                      color: Colors.white,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  Positioned(
                    right: 7,
                    top: 7,
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
          ],
        ),
      ],
      titleSpacing: 0,
    );
  }

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
}