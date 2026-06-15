import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/common/chat_screen.dart';
import 'package:trading_ecommerce_admin/common/community_inbox_screen.dart';
import 'package:trading_ecommerce_admin/screens/manage_opportunities_screen.dart';
import 'package:trading_ecommerce_admin/screens/product_management_screen.dart';
import 'package:trading_ecommerce_admin/screens/trading_marketplace_screen.dart';
import 'package:trading_ecommerce_admin/screens/selected_items_screen.dart';
import 'package:trading_ecommerce_admin/screens/affiliate_orders_screen.dart';
import 'package:trading_ecommerce_admin/admin/seller_orders_screen.dart';

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
  int _currentIndex = 0;

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

  @override
  void initState() {
    super.initState();
    _fetchUsersList();
    _fetchPendingApprovals();
    _fetchWithdrawals();
    _fetchOpportunities();
    _fetchMyListings();
    _fetchMySubmissions();
    _fetchPlatformSettings();
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
      }, endpoint: 'new_apis/manage_user_api 3.php');
      
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

  // API Call: Fetch Pending Community Approvals
  Future<void> _fetchPendingApprovals() async {
    setState(() {
      _isLoadingApprovals = true;
    });
    try {
      final database = Database();
      final response = await database.getData({
        'action': 'get_pending_community_approvals',
      }, endpoint: 'new_apis/manage_user_api 3.php');
      
      if (response['success'] == true || response['status'] == 200 || response.containsKey('data')) {
        setState(() {
          _pendingApprovals = response['data'] ?? [];
        });
      }
    } catch (e) {
      print('Error fetching approvals: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingApprovals = false;
        });
      }
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

  // Details dialog showing user's joined communities
  void _showUserDetailsDialog(Map<String, dynamic> user) {
    final joined = user["joined_communities"];
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
                      final String comName = item is Map ? (item["name"] ?? "") : item.toString();
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: primaryPurple)),
          )
        ],
      ),
    );
  }

  // Mock Data (legacy placeholders)
  final List<Map<String, dynamic>> _mockProducts = [
    {"title": "Rolex Submariner", "price": "\$12,500", "stock": 4, "status": "Approved"},
    {"title": "Louis Vuitton Keepall", "price": "\$2,800", "stock": 12, "status": "Approved"},
    {"title": "Gucci Double G Belt", "price": "\$650", "stock": 45, "status": "Pending"},
    {"title": "Hermes Birkin 30", "price": "\$22,000", "stock": 2, "status": "Approved"},
  ];

  final List<Map<String, dynamic>> _mockOrders = [
    {"id": "LX-9082", "user": "Aditya Singh", "amount": "\$12,500", "status": "Delivered"},
    {"id": "LX-9083", "user": "Nehal Gupta", "amount": "\$650", "status": "Pending"},
    {"id": "LX-9084", "user": "Vikram Rathore", "amount": "\$2,800", "status": "Shipped"},
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
    {"tier": "Basic (Free)", "price": "\$0", "duration": "Lifetime", "features": "List up to 5 items"},
    {"tier": "Silver Premium", "price": "\$29/mo", "duration": "1 Month", "features": "List up to 50 items, 5% commission"},
    {"tier": "Gold Elite", "price": "\$79/mo", "duration": "3 Months", "features": "Unlimited listings, 2.5% commission"},
    {"tier": "Platinum Royalty", "price": "\$249/yr", "duration": "1 Year", "features": "Unlimited listings, 0% commission, Priority Support"},
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
      default: return "Admin Portal";
    }
  }

  // Handle Logout action
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Logout", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out of the admin panel?", style: TextStyle(color: textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgLight,
      floatingActionButton: (_currentIndex == 18 || _currentIndex == 19)
          ? FloatingActionButton(
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryPurple),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.menu_rounded, color: primaryPurple),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        title: Text(
          _getTitle(),
          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Header Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: primaryPurple),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocalNotificationsScreen()),
            ),
          ),
          // Header Cart Icon
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: primaryPurple),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cart Overview: 3 Pending Purchases awaiting approval."),
                  backgroundColor: primaryPurple,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          // Header Chat Icon
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: primaryPurple),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityInboxScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Left Navigation Drawer
      drawer: Drawer(
        backgroundColor: bgDark,
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, bgDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings_rounded, size: 40, color: primaryPurple),
              ),
              accountName: const Text("Luxe Admin", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("admin@luxe.com"),
            ),

            // Navigation Drawer Items List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(0, Icons.dashboard_rounded, "Dashboard"),
                  _buildDrawerItem(12, Icons.storefront_rounded, "Seller Dashboard"),
                  _buildDrawerItem(13, Icons.supervised_user_circle_rounded, "Seller Management"),
                  _buildDrawerItem(1, Icons.people_rounded, "Users"),
                  _buildDrawerItem(15, Icons.group_add_rounded, "Community Approvals"),
                  // Collapsible Products (aligned and borderless)
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.shopping_bag_rounded, color: Colors.white70),
                        title: const Text(
                          "Products",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white70,
                        children: [
                          _buildDrawerItem(2, Icons.inventory_2_rounded, "Product Catalog", isSubItem: true),
                          _buildDrawerItem(22, Icons.local_shipping_rounded, "Order Management", isSubItem: true),
                        ],
                      ),
                    ),
                  ),
                  _buildDrawerItem(3, Icons.receipt_long_rounded, "Orders"),
                  
                  // Collapsible General Settings (aligned and borderless)
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.settings_rounded, color: Colors.white70),
                        title: const Text(
                          "General Settings",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white70,
                        children: [
                          _buildDrawerItem(4, Icons.category_rounded, "Category Management", isSubItem: true),
                          _buildDrawerItem(5, Icons.list_alt_rounded, "List Items", isSubItem: true),
                          _buildDrawerItem(16, Icons.shopping_bag_rounded, "Marketplace Modules", isSubItem: true),
                          _buildDrawerItem(17, Icons.integration_instructions_rounded, "Module Integration", isSubItem: true),
                        ],
                      ),
                    ),
                  ),

                  _buildDrawerItem(6, Icons.settings_input_component_rounded, "Platform Settings"),

                  // Collapsible Financials (aligned and borderless)
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70),
                        title: const Text(
                          "Financials",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white70,
                        children: [
                          _buildDrawerItem(7, Icons.wallet_giftcard_rounded, "Wallet", isSubItem: true),
                          _buildDrawerItem(8, Icons.monetization_on_rounded, "Withdrawal Requests", isSubItem: true),
                          _buildDrawerItem(9, Icons.account_balance_rounded, "Seller Bank Details", isSubItem: true),
                        ],
                      ),
                    ),
                  ),

                  // Collapsible Membership (aligned and borderless)
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.card_membership_rounded, color: Colors.white70),
                        title: const Text(
                          "Membership Options",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white70,
                        children: [
                          _buildDrawerItem(10, Icons.card_membership_rounded, "Plans List", isSubItem: true),
                          _buildDrawerItem(14, Icons.build_rounded, "Plans Builder", isSubItem: true),
                        ],
                      ),
                    ),
                  ),
                  
                  // Collapsible Opportunities (aligned and borderless)
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.business_center_rounded, color: Colors.white70),
                        title: const Text(
                          "Opportunity",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white70,
                        children: [
                          _buildDrawerItem(18, Icons.work_outline_rounded, "Marketplace Opportunities", isSubItem: true),
                          _buildDrawerItem(23, Icons.swap_horiz, "Trading Opportunities", isSubItem: true),
                          _buildDrawerItem(24, Icons.bookmark_border, "My Selected Items", isSubItem: true),
                          _buildDrawerItem(25, Icons.receipt_long, "Affiliate Orders", isSubItem: true),
                          _buildDrawerItem(19, Icons.list_alt_rounded, "My Listings", isSubItem: true),
                          _buildDrawerItem(20, Icons.assignment_turned_in_rounded, "My Submissions", isSubItem: true),
                        ],
                      ),
                    ),
                  ),

                  // Collapsible Team Building (aligned and borderless)
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.groups_rounded, color: Colors.white70),
                        title: const Text(
                          "Team Building",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white70,
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
                  
                  _buildDrawerItem(11, Icons.person_rounded, "Profile"),
                ],
              ),
            ),

            // Logout Footer
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); // Close Drawer
                _handleLogout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Page Contents
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildBodyContent(),
        ),
      ),

      // Footer Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getBottomNavBarIndex(),
        onTap: (index) {
          if (index == 4) {
            // Tapping 'More' opens Left Navigation Drawer
            _scaffoldKey.currentState?.openDrawer();
          } else {
            _setTabFromBottomNav(index);
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: "More"),
        ],
      ),
    );
  }

  // Map Drawer views to Bottom Nav indexes
  int _getBottomNavBarIndex() {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 2) return 1;
    if (_currentIndex == 4 || _currentIndex == 5 || _currentIndex == 6) return 2; // Settings group
    if (_currentIndex == 7) return 3; // Wallet
    return 4; // fallback for others
  }

  // Navigate from bottom bar tabs
  void _setTabFromBottomNav(int bottomIndex) {
    if (bottomIndex == 3) {
      Navigator.pushNamed(context, '/wallet');
    } else {
      setState(() {
        switch (bottomIndex) {
          case 0: _currentIndex = 0; break;
          case 1: _currentIndex = 2; break; // Products
          case 2: _currentIndex = 6; break; // Platform Settings
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
        visualDensity: VisualDensity.compact,
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: isSubItem ? 20 : 24),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: isSubItem ? 13 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close Drawer
          if (index == 4) {
            Navigator.pushNamed(context, '/taxonomy');
          } else if (index == 5) {
            Navigator.pushNamed(context, '/manage_items');
          } else if (index == 6) {
            Navigator.pushNamed(context, '/platform_settings');
          } else if (index == 7) {
            Navigator.pushNamed(context, '/wallet');
          } else if (index == 10) {
            Navigator.pushNamed(context, '/membership_plans');
          } else if (index == 14) {
            Navigator.pushNamed(context, '/membership_builder');
          } else if (index == 11) {
            setState(() => _currentIndex = index);
          } else if (index == 12) {
            Navigator.pushNamed(context, '/seller');
          } else if (index == 13) {
            Navigator.pushNamed(context, '/seller_management');
          } else if (index == 16) {
            Navigator.pushNamed(context, '/marketplace_modules');
          } else if (index == 17) {
            Navigator.pushNamed(context, '/module_integration');
          } else if (index == 21) {
            Navigator.pushNamed(context, AppRoutes.createOpportunity);
          } else if (index == 26) {
            Navigator.pushNamed(context, AppRoutes.manageTeam);
          } else if (index == 27) {
            Navigator.pushNamed(context, AppRoutes.manageTasks);
          } else if (index == 28) {
            Navigator.pushNamed(context, AppRoutes.explorePartners);
          } else if (index == 29) {
            Navigator.pushNamed(context, AppRoutes.exploreTalent);
          } else if (index == 30) {
            Navigator.pushNamed(context, AppRoutes.rewardsRecognition);
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }

  // Render Body based on index
  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0: return _buildDashboardView();
      case 1: return _buildTextUsersView(); // renamed custom users view helper below
      case 2: return const ProductManagementScreen(isEmbedded: true);
      case 3: return _buildOrdersView();
      case 4: return _buildCategoriesView();
      case 5: return _buildListItemsView();
      case 6: return _buildPlatformSettingsView();
      case 7: return _buildWalletView();
      case 8: return _buildWithdrawalRequestsView();
      case 9: return _buildBankDetailsView();
      case 10: return _buildMembershipPlansView();
      case 11: return _buildProfileView();
      case 15: return _buildCommunityApprovalsView();
      case 18: return _buildMarketplaceOpportunitiesView();
      case 19: return const ManageOpportunitiesScreen(isTab: true);
      case 20: return _buildMySubmissionsView();
      case 22: return const SellerOrderScreen(isEmbedded: true);
      case 23: return const TradingMarketplaceScreen(isEmbedded: true);
      case 24: return const SelectedItemsScreen(isEmbedded: true);
      case 25: return const AffiliateOrdersScreen(isEmbedded: true);
      default: return _buildDashboardView();
    }
  }

  // 1. Dashboard View
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Revenue", "\$438,200", Icons.monetization_on_rounded, Colors.green)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Active Sellers",
                  "84",
                  Icons.people_rounded,
                  primaryPurple,
                  onTap: () => Navigator.pushNamed(context, '/seller_management'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Sales", "1,248", Icons.shopping_cart_rounded, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Withdrawal Requests", "3 Pending", Icons.account_balance_wallet_rounded, Colors.redAccent)),
            ],
          ),

          const SizedBox(height: 24),
          // Recent Orders Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recent Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _mockOrders.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, idx) {
                    final order = _mockOrders[idx];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: bgLight,
                        child: Icon(Icons.receipt_rounded, color: primaryPurple),
                      ),
                      title: Text(order["user"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("ID: ${order["id"]}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(order["amount"], style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: order["status"] == "Delivered" ? Colors.green.withAlpha(25) : Colors.amber.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order["status"],
                              style: TextStyle(
                                fontSize: 10, 
                                color: order["status"] == "Delivered" ? Colors.green : Colors.amber.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: color, size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                Text(val, style: const TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
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

  // 4. Orders View
  Widget _buildOrdersView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _mockOrders.length,
      itemBuilder: (context, idx) {
        final order = _mockOrders[idx];
        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.receipt_rounded, color: primaryPurple, size: 28),
            title: Text("Order: ${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Customer: ${order['user']}"),
            trailing: Text(order["amount"], style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple, fontSize: 15)),
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
                const Text("\$184,350.00", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Commission Earned: \$18,435.00", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text("Payouts Pending: \$4,200", style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12)),
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
  Widget _buildCommunityApprovalsView() {
    return _isLoadingApprovals
        ? const Center(child: CircularProgressIndicator(color: primaryPurple))
        : _pendingApprovals.isEmpty
            ? RefreshIndicator(
                onRefresh: _fetchPendingApprovals,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: 400,
                    alignment: Alignment.center,
                    child: const Text("No pending community approvals.", style: TextStyle(color: textLight)),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchPendingApprovals,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _pendingApprovals.length,
                  itemBuilder: (context, idx) {
                    final req = _pendingApprovals[idx];
                    final String userName = req["user_name"]?.toString() ?? "User";
                    final String communityName = req["community_name"]?.toString() ?? "Community";
                    
                    return Card(
                      color: cardColor,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: bgLight,
                              child: Icon(Icons.group_add_rounded, color: primaryPurple),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text("Wants to join: $communityName", style: const TextStyle(color: textLight, fontSize: 13)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      _pendingApprovals.removeAt(idx);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Community join request approved!"),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _pendingApprovals.removeAt(idx);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Community join request rejected!"),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(context, '/opportunity_detail', arguments: item);
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: bgLight,
                        child: Icon(Icons.business_center_rounded, color: primaryPurple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(companyName, style: const TextStyle(color: textLight, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentPurple.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          match,
                          style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((t) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(t.toString(), style: const TextStyle(fontSize: 11)),
                        backgroundColor: bgLight,
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Budget: $payoutAmount", style: const TextStyle(fontWeight: FontWeight.w600, color: primaryPurple)),
                      Text("$applicantsCount Applicants", style: const TextStyle(color: textLight, fontSize: 12)),
                    ],
                  ),
                ],
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
}

// Local Standalone Notifications Mock Screen
class LocalNotificationsScreen extends StatelessWidget {
  const LocalNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final titles = ["Withdrawal Requested", "New Seller Signup", "Low Stock Alert"];
          final subtitles = [
            "Supreme Vintage requested a payout of \$4,200.",
            "Ananya Sharma registered as a new Vendor.",
            "Rolex Submariner has only 4 items left in stock."
          ];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF008080).withAlpha(30),
              child: Icon(
                index == 0
                    ? Icons.monetization_on
                    : index == 1
                        ? Icons.person_add
                        : Icons.warning,
                color: const Color(0xFF006565),
              ),
            ),
            title: Text(titles[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitles[index]),
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
