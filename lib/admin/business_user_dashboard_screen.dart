import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/admin/Admin_Dashboard.dart';
import 'package:trading_ecommerce_admin/admin/Marketplace_opportunities.dart';
import 'package:trading_ecommerce_admin/admin/recruiter_dashboard_screen.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';

// Import all required screens for integration
import 'package:trading_ecommerce_admin/screens/product_management_screen.dart';
import 'package:trading_ecommerce_admin/screens/my_events_screen.dart';
import 'package:trading_ecommerce_admin/screens/explore_charity_projects_screen.dart';
import 'package:trading_ecommerce_admin/screens/combo_packages_screen.dart';
import 'package:trading_ecommerce_admin/screens/manage_tasks_screen.dart';
import 'package:trading_ecommerce_admin/admin/wallet_admin_screen.dart';
import 'package:trading_ecommerce_admin/admin/seller_orders_screen.dart';
import 'package:trading_ecommerce_admin/admin/marketplace_modules_screen.dart';
import 'package:trading_ecommerce_admin/admin/module_manager_screen.dart';
import 'package:trading_ecommerce_admin/screens/manage_opportunities_screen.dart';
import 'package:trading_ecommerce_admin/screens/trading_marketplace_screen.dart';
import 'package:trading_ecommerce_admin/screens/selected_items_screen.dart';
import 'package:trading_ecommerce_admin/screens/affiliate_orders_screen.dart';
import 'package:trading_ecommerce_admin/admin/platform_settings_screen.dart';
import 'package:trading_ecommerce_admin/common/setting_screen.dart';
import 'package:trading_ecommerce_admin/admin/site_settings_screen.dart';
import 'package:trading_ecommerce_admin/admin/taxonomy_manager_screen.dart';
import 'package:trading_ecommerce_admin/admin/manage_items_screen.dart';
import 'package:trading_ecommerce_admin/screens/seller_profile_screen.dart';
import 'package:trading_ecommerce_admin/common/chat_screen.dart';
import 'package:trading_ecommerce_admin/screens/manage_team_screen.dart';
import 'package:trading_ecommerce_admin/screens/explore_partners_screen.dart';
import 'package:trading_ecommerce_admin/screens/explore_talent_screen.dart';
import 'package:trading_ecommerce_admin/screens/rewards_recognition_screen.dart';
import 'package:trading_ecommerce_admin/screens/charity_marketplace_screen.dart';
import 'package:trading_ecommerce_admin/admin/membership_builder_screen.dart';
import 'package:trading_ecommerce_admin/services/location_service.dart';
import 'package:trading_ecommerce_admin/admin/business_user_profile_screen.dart';
import 'package:trading_ecommerce_admin/admin/financial_command_center_screen.dart';
import 'package:trading_ecommerce_admin/admin/manage_vendors_screen.dart';
import 'package:trading_ecommerce_admin/admin/commission_settings_screen.dart';
import 'package:trading_ecommerce_admin/user/seller_bank_accounts_screen.dart';
import 'package:trading_ecommerce_admin/screens/marketplace_trainings_screen.dart';
import 'package:trading_ecommerce_admin/screens/enrolled_trainings_screen.dart';
import 'package:trading_ecommerce_admin/screens/mom_trainings_screen.dart';

import 'Explore_communities.dart';
import 'candidate_manage_hub.dart';
import 'feed_Screen.dart';
import 'job_applications_screen.dart';
import 'job_form.dart';
import 'joblisting.dart';
import 'manage_opportunity.dart';

class BusinessUserDashboard extends StatefulWidget {
  const BusinessUserDashboard({super.key});

  @override
  State<BusinessUserDashboard> createState() => _BusinessUserDashboardState();
}

class _BusinessUserDashboardState extends State<BusinessUserDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Navigation State
  int _currentIndex = 0;
  // 0: Dashboard Overview (Executive View)
  // 1: Manage Vendors
  // 2: Listings -> Products
  // 3: Listings -> Jobs
  // 4: Listings -> Events
  // 5: Listings -> Charity
  // 6: Listings -> Combo Packages
  // 7: Project Management
  // 8: Financials -> Wallet
  // 9: Financials -> Bank Details
  // 10: Financials -> Payout Requests
  // 11: Order Management
  // 12: Manage Communities
  // 13: Modules -> Marketplace
  // 14: Modules -> Manager
  // 15: Opportunity -> Marketplace
  // 16: Opportunity -> My Listings
  // 17: Opportunity -> My Submissions
  // 18: Trading -> Explore
  // 19: Trading -> Selected
  // 20: Trading -> Affiliate Orders
  // 21: Settings -> Platform
  // 22: Settings -> Site Settings
  // 23: Category Management
  // 24: Item Management
  // 25: Profile

  // Visual Styling constants
  static const Color primaryTeal = Color(0xFF006565);
  static const Color darkTeal = Color(0xFF00796B); // Colors.teal.shade700
  static const Color cardColor = Colors.white;
  static const Color bgLight = Color(0xFFF9F9F9);
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textLight = Color(0xFF3E4949);
  static const Color selectedBg = Color(0xFFE3FFFE);
  static const Color outlineVariant = Color(0xFFBDC9C8);

  // Mock State Data
  bool _isLoading = false;
  String _businessName = "Admin User";
  String _businessEmail = "business@serenecommerce.com";
  String _businessLocation = "London, UK";
  String _businessProfilePic = "";

  // Dashboard mock data values
  double _salesToday = 14500.0;
  int _activeClients = 124;
  int _pendingApprovalsCount = 5;
  int _activeJobsCount = 3;
  String _currentMembershipTier = "Gold Plan";

  // Mock lists
  final List<Map<String, dynamic>> _mockUsers = [
    {"id": "1", "name": "Pranav Kumar", "email": "pranav@gmail.com", "role": "General", "status": "Active", "pic": ""},
    {"id": "2", "name": "Sneha Sharma", "email": "sneha@business.com", "role": "Business", "status": "Active", "pic": ""},
    {"id": "3", "name": "Amit Patel", "email": "amit.patel@gmail.com", "role": "General", "status": "Inactive", "pic": ""},
    {"id": "4", "name": "Venkatesh Iyer", "email": "venky@corporate.in", "role": "Business", "status": "Active", "pic": ""},
  ];

  final List<Map<String, dynamic>> _mockJobs = [
    {
      "title": "Senior Flutter Developer",
      "company": "SereneCommerce Ltd",
      "salary": "₹6,50,000 - ₹7,50,000",
      "location": "Remote (UK)",
      "type": "Full-Time",
      "applicants": 14,
      "date": "Posted 2 days ago"
    },
    {
      "title": "E-Commerce Category Lead",
      "company": "Luxe B2B Global",
      "salary": "₹4,50,000 - ₹5,00,000",
      "location": "London, UK",
      "type": "Hybrid",
      "applicants": 27,
      "date": "Posted 5 days ago"
    },
    {
      "title": "Logistics & Operations Manager",
      "company": "SetupBackend Solutions",
      "salary": "₹5,50,000",
      "location": "Manchester, UK",
      "type": "Full-Time",
      "applicants": 8,
      "date": "Posted 1 week ago"
    }
  ];

  final List<Map<String, dynamic>> _mockBankDetails = [
    {"vendor": "SereneCommerce Ltd", "bank": "Barclays Bank", "account": "•••• 5678", "ifsc": "BARC012345"},
    {"vendor": "Luxe B2B Global", "bank": "HSBC UK", "account": "•••• 9012", "ifsc": "MIDL098765"},
  ];

  final List<Map<String, dynamic>> _mockPayouts = [
    {"id": "V-9421", "vendor": "Apex Tech Solutions", "amount": "₹8,420.00", "status": "Pending", "date": "Oct 24, 2023", "method": "ACH Transfer"},
    {"id": "V-8812", "vendor": "Oceanic Crafts", "amount": "₹1,240.50", "status": "Pending", "date": "Oct 25, 2023", "method": "Crypto (USDC)"},
  ];

  final List<Map<String, dynamic>> _mockCommunities = [
    {"id": "1", "user_name": "Rohan Deshmukh", "community_name": "Textiles & Apparel Exporters", "date": "Today"},
    {"id": "2", "user_name": "Meera Sen", "community_name": "Organic Agri-Produce Hub", "date": "Yesterday"},
  ];

  final List<Map<String, dynamic>> _mockAddresses = [
    {"id": "1", "label": "Head Office", "address": "123 Business Way, Tech City, TC1 2AB", "phone": "+44 20 7946 0958"},
    {"id": "2", "label": "Main Warehouse", "address": "Unit 4, Industrial Logistics Park, London, E16 2PX", "phone": "+44 20 7946 0988"},
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinessProfile();
    // Request location permission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _requestLocationPermission();

      // Handle route arguments safely after frame is built
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          switch (args) {
            case 0: _currentIndex = 0; break;
            case 1: _currentIndex = 11; break;
            case 2: _currentIndex = 18; break;
            case 3: _currentIndex = 22; break;
          }
        });
      }
    });
    // Show Membership Upsell modal after 3.5 seconds, ensuring route is active
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          _showMembershipUpsellDialog();
        }
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      final denied = await LocationService.isPermissionDenied();
      if (denied) {
        await _showLocationPermissionDialog();
      } else {
        await LocationService.requestAndGetLocation();
      }
    } catch (e) {
      debugPrint("Error requesting location: $e");
    }
  }
  Future<void> _showLocationPermissionDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5F5F5), // Light teal circle background
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on,
                      color: Color(0xFF006565), // Dark teal pin
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  "Enable Location",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                const Text(
                  "Luxe requires access to your location to provide personalized delivery estimates, calculate taxes correctly, and display premium stores near you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Allow Access Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await LocationService.requestAndGetLocation();
                      } catch (_) {}
                    },
                    child: const Text(
                      "Allow Access",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Not Now Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF006565)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Not Now",
                      style: TextStyle(
                        color: Color(0xFF006565),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadBusinessProfile() async {
    setState(() => _isLoading = true);
    try {
      final cache = await AuthService.getCachedUserData();
      if (cache != null) {
        setState(() {
          _businessName = cache['name']?.toString() ?? "Premium Business User";
          _businessEmail = cache['email']?.toString() ?? "business@serenecommerce.com";
          _businessLocation = cache['location']?.toString() ?? "London, UK";
          _businessProfilePic = cache['profile_pic']?.toString() ?? "";
        });
      }
    } catch (_) {}

    try {
      final vendorId = await AuthService.getVendorIdString();
      if (vendorId != '0') {
        final response = await Database().getData({
          'action': 'profile',
          'vendor_id': vendorId,
        });
        if (response['success'] == true && response['data'] != null) {
          final profile = response['data']['profile'];
          if (profile != null) {
            setState(() {
              _businessName = profile['name']?.toString() ?? _businessName;
              _businessEmail = profile['email']?.toString() ?? _businessEmail;
              _businessLocation = profile['location']?.toString() ?? _businessLocation;
              _businessProfilePic = profile['profile_pic']?.toString() ?? "";
            });
            // Update cache
            await AuthService.saveLoginSession(
              vendorId: int.parse(vendorId),
              userData: Map<String, dynamic>.from(profile),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading profile from API: $e");
    }
    setState(() => _isLoading = false);
  }

  // ══════════════════════════════════════════════════════════
  // MEMBERSHIP UPSELL MODAL DIALOG
  // ══════════════════════════════════════════════════════════
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
                            Icon(Icons.verified, color: primaryTeal, size: 20),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Serene Membership",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTeal,
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
                            color: textLight,
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
                            color: textDark,
                            fontFamily: 'Manrope',
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Get exclusive access to strategic partnerships, priority placement, and dedicated support designed for high-stakes administrative environments.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: textLight),
                        ),
                        const SizedBox(height: 32),

                        // Plans Row (Responsive layout simulated with wrapping)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isWide = constraints.maxWidth > 850;
                            return isWide
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _buildPlanCard("BRONZE", "₹2,499", "Standard Support", ["Up to 5 Listings", "Standard Marketplace Entry", "Email Support (48h)"], Colors.grey.shade400)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildPlanCard("SILVER", "₹5,999", "Priority Partnerships", ["Unlimited Listings", "Priority Marketplace Placement", "Analytics Dashboard", "Email Support (12h)"], primaryTeal, isFeatured: true)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildPlanCard("GOLD", "₹12,999", "Dedicated Account Director", ["Verified Partner Status", "Direct CRM Integration", "Concierge PR & Events", "24/7 Dedicated Support"], const Color(0xFFB45309))),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildPlanCard("BRONZE", "₹2,499", "Standard Support", ["Up to 5 Listings", "Standard Marketplace Entry", "Email Support (48h)"], Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      _buildPlanCard("SILVER", "₹5,999", "Priority Partnerships", ["Unlimited Listings", "Priority Marketplace Placement", "Analytics Dashboard", "Email Support (12h)"], primaryTeal, isFeatured: true),
                                      const SizedBox(height: 16),
                                      _buildPlanCard("GOLD", "₹12,999", "Dedicated Account Director", ["Verified Partner Status", "Direct CRM Integration", "Concierge PR & Events", "24/7 Dedicated Support"], const Color(0xFFB45309)),
                                    ],
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
                            backgroundColor: primaryTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showSuccess("Redirecting to all membership plans...");
                          },
                          icon: const Text("View All Membership Plans", style: TextStyle(fontWeight: FontWeight.bold)),
                          label: const Icon(Icons.arrow_forward),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: textLight),
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

  Widget _buildPlanCard(String title, String price, String subtitle, List<String> features, Color color, {bool isFeatured = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFeatured ? primaryTeal : Colors.grey.shade200, width: isFeatured ? 2.5 : 1),
        boxShadow: isFeatured
            ? [BoxShadow(color: primaryTeal.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(8)),
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
              Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark)),
              const Text("/mo", style: TextStyle(fontSize: 13, color: textLight)),
            ],
          ),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: textLight, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: primaryTeal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: textDark))),
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
                setState(() {
                  _currentMembershipTier = "$title Plan";
                });
                _showSuccess("Successfully switched to $title Plan!");
              },
              child: Text("Select $title", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        } else {
          return await _showExitConfirmation();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgLight,
        drawer: _buildLeftDrawer(),
        appBar: _buildHeader(),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
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
          selectedItemColor: primaryTeal,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.business_center_rounded), label: "Opportunities"),
            BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Comm"),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile"),
          ],
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
                            color: Color(0xFFBA1A1A),
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

  int _getBottomNavBarIndex() {
    if (_currentIndex == 0) return 0; // Home -> Dashboard
    if (_currentIndex == 11) return 1; // Orders
    if (_currentIndex == 18 || _currentIndex == 15) return 2; // Opportunities
    if (_currentIndex == 36) return 3; // Settings
    if (_currentIndex == 25) return 4; //profile

    return 0;
  }

  void _setTabFromBottomNav(int index) {
    setState(() {
      switch (index) {
        case 0: _currentIndex = 0; break;
        case 1: _currentIndex = 11; break;
        case 2: _currentIndex = 18; break; // Explore Trading Opportunities
        case 3: _currentIndex = 36; break; // Site settings
        case 4: _currentIndex= 25;break;
      }
    });
  }

  PreferredSizeWidget _buildHeader() {
    String titleText = "Admin Dashboard";
    switch (_currentIndex) {
      case 36: titleText = "Commission Settings"; break;
      case 1: titleText = "User Management"; break;
      case 2: titleText = "Product Listing"; break;
      case 3: titleText = "Job Board"; break;
      case 4: titleText = "Events Hub"; break;
      case 5: titleText = "Charity Cause"; break;
      case 6: titleText = "Package Builder"; break;
      case 7: titleText = "Project Management"; break;
      case 8: titleText = "My Wallet"; break;
      case 9: titleText = "Payment Settings"; break;
      case 10: titleText = "My Addresses"; break;
      case 11: titleText = "Orders Central"; break;
      case 26: titleText = "Withdrawals"; break;
      case 12: titleText = "Community approvals"; break;
      case 13: titleText = "Module Marketplace"; break;
      case 14: titleText = "Module Manager"; break;
      case 15: titleText = "Marketplace Opportunities"; break;
      case 16: titleText = "Opportunity Listings"; break;
      case 17: titleText = "My Applications"; break;
      case 18: titleText = "Trading Marketplace"; break;
      case 19: titleText = "Selected Items"; break;
      case 20: titleText = "Affiliate Orders"; break;
      case 21: titleText = "Platform Setting"; break;
      case 22: titleText = "Site Setting"; break;
      case 23: titleText = "Category Settings"; break;
      case 24: titleText = "Item Setting"; break;
      case 25: titleText = "My Profile"; break;
      case 27: titleText = "Team Management"; break;
      case 28: titleText = "Explore Partners"; break;
      case 29: titleText = "Explore Talent"; break;
      case 30: titleText = "Rewards & Recognition"; break;
      case 31: titleText = "Charity Marketplace"; break;
      case 32: titleText = "Membership Builder"; break;
      case 33: titleText = "Marketplace Trainings"; break;
      case 34: titleText = "Enrolled Trainings"; break;
      case 35: titleText = "MOM Trainings"; break;
      case 42: titleText = "Recruiter Dashbord"; break;
      case 41: titleText = "Job Listing"; break;
      // case 42: titleText = "MOM Trainings"; break;
      case 43: titleText = "Candidate Manage"; break;
      case 45: titleText = "Manage Opp.."; break;
      case 49: titleText = "Marketplace OPP.."; break;
      case 70: titleText = "Explore Communities"; break;


    }

    return AppBar(
      backgroundColor: Colors.teal.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        titleText,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.video_collection),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityIntelligenceApp(),));
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        GestureDetector(
          // onTap: () => setState(() => _currentIndex = 25),
          child: const CircleAvatar(
             radius: 16,
            backgroundColor: Color(0xFF004D4D),
            child: Icon(Icons.message_outlined, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildLeftDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE0F2F1),
                    backgroundImage: _businessProfilePic.isNotEmpty
                        ? NetworkImage(_businessProfilePic)
                        : null,
                    child: _businessProfilePic.isEmpty
                        ? const Icon(Icons.business_rounded, color: primaryTeal, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: primaryTeal,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "Verified Business",
                              style: TextStyle(
                                color: textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _businessLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Drawer Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                _buildDrawerHeaderLabel("OVERVIEW"),
                _buildDrawerItem(0, Icons.dashboard_rounded, "Dashboard"),
                _buildDrawerItem(36, Icons.percent_rounded, "Commission Settings"),
                _buildDrawerItem(1, Icons.storefront_rounded, "Manage Vendors"),
                _buildDrawerItem(70, Icons.storefront_rounded, "Explore Communities"),
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
                      title: const Text("Project Management", style: TextStyle(fontSize: 14, color: textDark)),
                      children: [
                        _buildDrawerItem(7, Icons.task_outlined, "Manage Tasks", isSubItem: true),
                        _buildDrawerItem(27, Icons.people_outline_rounded, "Manage Team", isSubItem: true),
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
                        leading: const Icon(Icons.task_rounded, color: textLight, size: 24),
                        title: const Text("Business Opportunities", style: TextStyle(fontSize: 14, color: textDark)),
                        children: [
                          _buildDrawerItem(45, Icons.task_outlined, "Manage opportunities", isSubItem: true),
                          _buildDrawerItem(49, Icons.people_outline_rounded, "Explore Opportunities", isSubItem: true),

                        ],
                      ),
                    ),
                  ),

                  _buildDrawerItem(11, Icons.shopping_bag_rounded, "Order Management"),
                _buildDrawerItem(12, Icons.diversity_3_rounded, "Manage Communities"),
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
                        leading: const Icon(Icons.work, color: textLight, size: 24),
                        title: const Text("Talent Management", style: TextStyle(fontSize: 14, color: textDark)),
                        children: [
                          _buildDrawerItem(42, Icons.task_outlined, "Recruiter Dashboard", isSubItem: true),
                          _buildDrawerItem(41, Icons.task_outlined, "Manage jobs", isSubItem: true),
                          _buildDrawerItem(43, Icons.list, "Manage Candidate", isSubItem: true),
                        ],
                      ),
                    ),
                  ),

                const Divider(height: 16),
                _buildDrawerHeaderLabel("LISTINGS & CATALOGS"),
                _buildDrawerItem(2, Icons.shopping_cart_outlined, "Products", isSubItem: true),
                _buildDrawerItem(3, Icons.work_outline_rounded, "Jobs Board", isSubItem: true),
                _buildDrawerItem(4, Icons.event_rounded, "Events & Charity", isSubItem: true),
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
                      leading: const Icon(Icons.volunteer_activism_rounded, color: textLight, size: 24),
                      title: const Text("Support a Cause", style: TextStyle(fontSize: 14, color: textDark)),
                      children: [
                        _buildDrawerItem(5, Icons.explore_outlined, "Explore Charity Projects", isSubItem: true),
                        _buildDrawerItem(31, Icons.storefront_outlined, "Charity Marketplace", isSubItem: true),
                      ],
                    ),
                  ),
                ),
                _buildDrawerItem(6, Icons.layers_outlined, "Packages Builder", isSubItem: true),

                const Divider(height: 16),
                _buildDrawerHeaderLabel("FINANCIALS"),
                _buildDrawerItem(8, Icons.account_balance_wallet_rounded, "Financial Command Center"),

                const Divider(height: 16),
                _buildDrawerHeaderLabel("OPPORTUNITIES"),
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
                      leading: const Icon(Icons.business_center_rounded, color: textLight, size: 24),
                      title: const Text("Opportunity Marketplace", style: TextStyle(fontSize: 14, color: textDark)),
                      children: [
                        _buildDrawerItem(15, Icons.storefront_rounded, "Marketplace", isSubItem: true),
                        _buildDrawerItem(16, Icons.list_alt_rounded, "My Listings", isSubItem: true),
                        _buildDrawerItem(17, Icons.assignment_turned_in_rounded, "My Submissions", isSubItem: true),
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
                      leading: const Icon(Icons.swap_horiz_rounded, color: textLight, size: 24),
                      title: const Text("Trading Opportunities", style: TextStyle(fontSize: 14, color: textDark)),
                      children: [
                        _buildDrawerItem(18, Icons.explore_rounded, "Explore Marketplace", isSubItem: true),
                        _buildDrawerItem(19, Icons.bookmark_added_rounded, "Selected Items", isSubItem: true),
                        _buildDrawerItem(20, Icons.receipt_long_rounded, "Affiliate Orders", isSubItem: true),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 16),
                _buildDrawerHeaderLabel("SKILLS & LEARNING"),
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
                      leading: const Icon(Icons.school_rounded, color: textLight, size: 24),
                      title: const Text("Upgrade your Skills", style: TextStyle(fontSize: 14, color: textDark)),
                      children: [
                        _buildDrawerItem(33, Icons.storefront_outlined, "Marketplace Training", isSubItem: true),
                        _buildDrawerItem(34, Icons.collections_bookmark_rounded, "Enrolled Trainings", isSubItem: true),
                        _buildDrawerItem(35, Icons.psychology_outlined, "MOM Training", isSubItem: true),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 16),
                _buildDrawerHeaderLabel("INTEGRATIONS"),
                _buildDrawerItem(13, Icons.storefront_rounded, "Module Marketplace"),
                _buildDrawerItem(14, Icons.extension_rounded, "Module Manager"),

                const Divider(height: 16),
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
                      leading: const Icon(Icons.settings_rounded, color: textLight, size: 24),
                      title: const Text("Platform Settings", style: TextStyle(fontSize: 14, color: textDark)),
                      children: [
                        _buildDrawerItem(22, Icons.settings_rounded, "Site Setting", isSubItem: true),
                        _buildDrawerItem(23, Icons.category_rounded, "Category Settings", isSubItem: true),
                        _buildDrawerItem(24, Icons.manage_accounts_rounded, "Item Setting", isSubItem: true),
                        _buildDrawerItem(21, Icons.settings_applications_rounded, "Platform Setting", isSubItem: true),
                        _buildDrawerItem(9, Icons.payment_rounded, "Payment Settings", isSubItem: true),
                        _buildDrawerItem(32, Icons.build_circle_rounded, "Membership Builder", isSubItem: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          // Drawer Footer
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFBA1A1A)),
            title: const Text("Sign Out", style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

  Widget _buildDrawerHeaderLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title, {bool isSubItem = false}) {
    final bool isSelected = _currentIndex == index;
    return Container(
      margin: EdgeInsets.only(left: isSubItem ? 16 : 8, right: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        horizontalTitleGap: 8,
        leading: Icon(icon, color: isSelected ? primaryTeal : textLight, size: isSubItem ? 20 : 24),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryTeal : textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: isSubItem ? 13 : 14,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close Drawer
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0: return AdminDashboard();
      case 36: return const CommissionSettingsScreen(isEmbedded: true);
      case 1: return const ManageVendorsScreen(isEmbedded: true);
      case 2: return const ProductManagementScreen(isEmbedded: true);
      case 3: return _buildJobsView();
      case 4: return const MyEventsScreen(isEmbedded: true);
      case 5: return const ExploreCharityProjectsScreen(isEmbedded: true);
      case 6: return const ComboPackagesScreen(isEmbedded: true);
      case 7: return const ManageTasksScreen(isEmbedded: true);
      case 8: return const FinancialCommandCenterScreen(isEmbedded: true);
      case 9: return const SellerBankAccountsScreen();
      case 10: return _buildMyAddressesView();
      case 11: return const SellerOrderScreen(isEmbedded: true);
      case 26: return _buildWithdrawalsView();
      case 12: return _buildCommunityApprovalsView();
      case 13: return const MarketplaceModulesScreen(isEmbedded: true);
      case 14: return const ModuleManagerScreen();
      case 15: return _buildMarketplaceOpportunitiesView();
      case 16: return const ManageOpportunitiesScreen(isTab: true);
      case 17: return _buildMySubmissionsView();
      case 18: return const TradingMarketplaceScreen();//isEmbedded: true /comment
      case 19: return const SelectedItemsScreen(isEmbedded: true);
      case 20: return const AffiliateOrdersScreen(isEmbedded: true);
      case 21: return const PlatformSettingsScreen(isEmbedded: true);
      case 22: return const SiteSettingsScreen(isEmbedded: true);
      case 23: return const TaxonomyManagerScreen(isEmbedded: true);
      case 24: return const ManageItemsScreen(isEmbedded: true);
      case 25: return BusinessUserProfileScreen(
        onManagePlanTap: () => setState(() => _currentIndex = 32),
        onAddressUpdateTap: () => setState(() => _currentIndex = 10),
        onBankAddTap: () => setState(() => _currentIndex = 9),
      );
      case 27: return const ManageTeamScreen(isEmbedded: true);
      case 28: return const ExplorePartnersScreen(isEmbedded: true);
      case 29: return const ExploreTalentScreen(isEmbedded: true);
      case 30: return const RewardsRecognitionScreen(isEmbedded: true);
      case 31: return const CharityMarketplaceScreen(isEmbedded: true);
      case 32: return const MembershipBuilderScreen(isEmbedded: true);
      case 33: return const MarketplaceTrainingsScreen(isEmbedded: true);
      case 34: return const EnrolledTrainingsScreen(isEmbedded: true);
      case 35: return const MomTrainingsScreen(isEmbedded: true);
       case 40: return const JobApplicationsScreen(jobId: '4',);
      case 41: return const JobManagementHub();
      case 42: return const RecruiterApp();
      case 43: return const CandidateHubScreen();
      case 45: return const manageopportunity();
      case 49: return const MarketplaceScreen();
      case 70: return const DossierHQApp();
      default: return AdminDashboard();
    }
  }

  // ══════════════════════════════════════════════════════════
  // VIEW BUILDERS
  // ══════════════════════════════════════════════════════════

  // 1. Dashboard View (Serene Commerce Executive Dashboard Layout)
  // Widget _buildDashboardView() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Header Section
  //         Wrap(
  //           alignment: WrapAlignment.spaceBetween,
  //           crossAxisAlignment: WrapCrossAlignment.center,
  //           spacing: 16,
  //           runSpacing: 12,
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: const [
  //                 Text(
  //                   "Strategic Overview",
  //                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'Manrope'),
  //                 ),
  //                 SizedBox(height: 2),
  //                 Text(
  //                   "Enhanced executive insights and operational flows.",
  //                   style: TextStyle(fontSize: 12, color: textLight),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         const Divider(),
  //
  //         // 1. Platform Health & Access Header
  //         const Text("Platform Health & Access", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
  //         const SizedBox(height: 12),
  //
  //         // Row 1: Horizontal Sliding Stats
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           physics: const BouncingScrollPhysics(),
  //           child: Row(
  //             children: [
  //               // Current Membership Card
  //               _buildSliderCard(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         const Text("CURRENT MEMBERSHIP", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 0.5)),
  //                         const SizedBox(height: 4),
  //                         Text(_currentMembershipTier, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
  //                         const SizedBox(height: 4),
  //                         const Text("Unlimited Marketplace Access", style: TextStyle(fontSize: 11, color: textLight)),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 12),
  //                     SizedBox(
  //                       width: double.infinity,
  //                       height: 32,
  //                       child: FilledButton(
  //                         style: FilledButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  //                         onPressed: _showMembershipUpsellDialog,
  //                         child: const Text("Upgrade Plan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //
  //               // Space Utilization Circular Chart Card
  //               _buildSliderCard(
  //                 child: Row(
  //                   children: [
  //                     Stack(
  //                       alignment: Alignment.center,
  //                       children: [
  //                         SizedBox(
  //                           width: 54,
  //                           height: 54,
  //                           child: CircularProgressIndicator(
  //                             value: 0.75,
  //                             strokeWidth: 5,
  //                             color: primaryTeal,
  //                             backgroundColor: Colors.grey.shade200,
  //                           ),
  //                         ),
  //                         const Text("75%", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
  //                       ],
  //                     ),
  //                     const SizedBox(width: 16),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: const [
  //                           Text("SPACE UTILIZATION", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textLight, letterSpacing: 0.5)),
  //                           SizedBox(height: 4),
  //                           Text("6.4 / 8.0 TB", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //
  //               // Platform Status
  //               _buildSliderCard(
  //                 child: Row(
  //                   children: [
  //                     Container(
  //                       width: 50,
  //                       height: 50,
  //                       decoration: BoxDecoration(color: selectedBg, shape: BoxShape.circle),
  //                       child: const Icon(Icons.verified, color: primaryTeal, size: 28),
  //                     ),
  //                     const SizedBox(width: 16),
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: const [
  //                         Text("PLATFORM STATUS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textLight, letterSpacing: 0.5)),
  //                         SizedBox(height: 4),
  //                         Text("Enterprise Elite", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //
  //               // Next Milestone
  //               _buildSliderCard(
  //                 color: primaryTeal,
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: const [
  //                         Text("NEXT MILESTONE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.5)),
  //                         SizedBox(height: 4),
  //                         Text("Unlock Global Node Access", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 12),
  //                     SizedBox(
  //                       height: 32,
  //                       child: OutlinedButton(
  //                         style: OutlinedButton.styleFrom(
  //                           side: const BorderSide(color: Colors.white),
  //                           foregroundColor: Colors.white,
  //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                           padding: const EdgeInsets.symmetric(horizontal: 16),
  //                         ),
  //                         onPressed: _showMembershipUpsellDialog,
  //                         child: const Text("Upgrade Membership", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 28),
  //
  //         // 2. Advanced Analytics Header
  //         const Text("Advanced Analytics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
  //         const SizedBox(height: 12),
  //
  //         // Row 2: Analytics Cards Horizontal Scroll
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           physics: const BouncingScrollPhysics(),
  //           child: Row(
  //             children: [
  //               // Global Traffic Density Card
  //               Container(
  //                 width: 320,
  //                 height: 260,
  //                 decoration: _dashboardCardDecoration(),
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: const [
  //                             Text("Global Traffic Density", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  //                             Text("VISITOR CLUSTERS BY REGION", style: TextStyle(fontSize: 8, color: textLight, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
  //                           ],
  //                         ),
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                           decoration: BoxDecoration(color: Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
  //                           child: const Text("LIVE", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
  //                         )
  //                       ],
  //                     ),
  //                     const SizedBox(height: 16),
  //                     // Mock visual representation
  //                     Expanded(
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           _buildProgressRow("North America", "42.5k", 0.85),
  //                           const SizedBox(height: 16),
  //                           _buildProgressRow("Europe", "38.2k", 0.76),
  //                           const SizedBox(height: 16),
  //                           _buildProgressRow("Asia Pacific", "24.1k", 0.48),
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //
  //               // Listing Distribution Card
  //               Container(
  //                 width: 300,
  //                 height: 260,
  //                 decoration: _dashboardCardDecoration(),
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Text("Listing Distribution", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  //                     const Text("CATEGORY BREAKDOWN", style: TextStyle(fontSize: 8, color: textLight, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
  //                     const SizedBox(height: 12),
  //                     Expanded(
  //                       child: Center(
  //                         child: Stack(
  //                           alignment: Alignment.center,
  //                           children: [
  //                             SizedBox(
  //                               width: 100,
  //                               height: 100,
  //                               child: CircularProgressIndicator(
  //                                 value: 0.45,
  //                                 strokeWidth: 16,
  //                                 color: primaryTeal,
  //                                 backgroundColor: Colors.grey.shade100,
  //                               ),
  //                             ),
  //                             Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: const [
  //                                 Text("45%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
  //                                 Text("PRODUCTS", style: TextStyle(fontSize: 8, color: textLight, fontWeight: FontWeight.bold)),
  //                               ],
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         Row(
  //                           children: const [
  //                             Icon(Icons.lens, color: primaryTeal, size: 8),
  //                             SizedBox(width: 4),
  //                             Text("Products", style: TextStyle(fontSize: 10, color: textLight)),
  //                           ],
  //                         ),
  //                         Row(
  //                           children: const [
  //                             Icon(Icons.lens, color: Colors.grey, size: 8),
  //                             SizedBox(width: 4),
  //                             Text("Services", style: TextStyle(fontSize: 10, color: textLight)),
  //                           ],
  //                         ),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //
  //               // Revenue Growth Card
  //               Container(
  //                 width: 320,
  //                 height: 260,
  //                 decoration: _dashboardCardDecoration(),
  //                 padding: const EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: const [
  //                             Text("Revenue Growth Cycle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  //                             Text("PERFORMANCE OVER TIME", style: TextStyle(fontSize: 8, color: textLight, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
  //                           ],
  //                         ),
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                           decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(6)),
  //                           child: const Text("LAST 30 DAYS", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textDark)),
  //                         )
  //                       ],
  //                     ),
  //                     const SizedBox(height: 24),
  //                     Expanded(
  //                       child: CustomPaint(
  //                         size: Size.infinite,
  //                         painter: SparklinePainter(),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: const [
  //                         Text("Week 1", style: TextStyle(fontSize: 9, color: Colors.grey)),
  //                         Text("Week 2", style: TextStyle(fontSize: 9, color: Colors.grey)),
  //                         Text("Week 3", style: TextStyle(fontSize: 9, color: Colors.grey)),
  //                         Text("Week 4", style: TextStyle(fontSize: 9, color: Colors.grey)),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 28),
  //
  //         // 3. Pending Seller Withdrawals
  //         Container(
  //           decoration: _dashboardCardDecoration(),
  //           clipBehavior: Clip.antiAlias,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(16),
  //                 color: Colors.grey.shade50,
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: const [
  //                         Text("Pending Seller Withdrawals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
  //                         Text("Review and authorize financial payouts", style: TextStyle(fontSize: 11, color: textLight)),
  //                       ],
  //                     ),
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //                       decoration: BoxDecoration(color: selectedBg, borderRadius: BorderRadius.circular(12)),
  //                       child: const Text("2 PENDING", style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               const Divider(height: 1),
  //               ListView.separated(
  //                 shrinkWrap: true,
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 itemCount: _mockPayouts.length,
  //                 separatorBuilder: (context, index) => const Divider(height: 1),
  //                 itemBuilder: (context, index) {
  //                   final item = _mockPayouts[index];
  //                   return Padding(
  //                     padding: const EdgeInsets.all(16),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Container(
  //                               width: 44,
  //                               height: 44,
  //                               decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(10)),
  //                               child: const Icon(Icons.account_balance, color: primaryTeal),
  //                             ),
  //                             const SizedBox(width: 16),
  //                             Expanded(
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Row(
  //                                     children: [
  //                                       Text(item["vendor"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
  //                                       const SizedBox(width: 8),
  //                                       Container(
  //                                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
  //                                         decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
  //                                         child: Text(item["id"], style: TextStyle(fontSize: 8, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text(item["amount"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTeal)),
  //                                   const SizedBox(height: 4),
  //                                   Text("Request Date: ${item['date']} • Method: ${item['method']}", style: const TextStyle(fontSize: 9, color: Colors.grey)),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         const SizedBox(height: 12),
  //                         Row(
  //                           children: [
  //                             Expanded(
  //                               child: SizedBox(
  //                                 height: 36,
  //                                 child: OutlinedButton(
  //                                   style: OutlinedButton.styleFrom(
  //                                     side: const BorderSide(color: outlineVariant),
  //                                     foregroundColor: primaryTeal,
  //                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                                     padding: EdgeInsets.zero,
  //                                   ),
  //                                   onPressed: () {
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (_) => ChatScreen(
  //                                           user: ChatUser(
  //                                             id: item["id"],
  //                                             name: item["vendor"],
  //                                             lastMessage: "",
  //                                             time: "",
  //                                             avatarUrl: "",
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     );
  //                                   },
  //                                   child: const Text("Contact", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
  //                                 ),
  //                               ),
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Expanded(
  //                               child: SizedBox(
  //                                 height: 36,
  //                                 child: ElevatedButton(
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: const Color(0xFFFFEBEE), // Soft pinkish red
  //                                     foregroundColor: const Color(0xFFC62828), // Crimson red
  //                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                                     padding: EdgeInsets.zero,
  //                                     elevation: 0,
  //                                   ),
  //                                   onPressed: () {
  //                                     setState(() {
  //                                       _mockPayouts.removeAt(index);
  //                                     });
  //                                     _showSuccess("Payout request disapproved.");
  //                                   },
  //                                   child: const Text("Disapprove", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
  //                                 ),
  //                               ),
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Expanded(
  //                               child: SizedBox(
  //                                 height: 36,
  //                                 child: ElevatedButton(
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor: primaryTeal,
  //                                     foregroundColor: Colors.white,
  //                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                                     padding: EdgeInsets.zero,
  //                                     elevation: 0,
  //                                   ),
  //                                   onPressed: () {
  //                                     setState(() {
  //                                       _mockPayouts.removeAt(index);
  //                                     });
  //                                     _showSuccess("Payout approved successfully!");
  //                                   },
  //                                   child: const Text("Approve", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               )
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 28),
  //
  //         // 4. Live Stream: Recent Orders Header
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text("Live Stream: Recent Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
  //             TextButton(
  //               style: TextButton.styleFrom(foregroundColor: primaryTeal),
  //               onPressed: () => setState(() => _currentIndex = 11),
  //               child: Row(
  //                 children: const [
  //                   Text("View Ledger", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                   SizedBox(width: 4),
  //                   Icon(Icons.arrow_forward, size: 14),
  //                 ],
  //               ),
  //             )
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //
  //         // Orders Horizontal Card
  //         Container(
  //           width: double.infinity,
  //           decoration: _dashboardCardDecoration(),
  //           padding: const EdgeInsets.all(16),
  //           child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                 width: 48,
  //                 height: 48,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade100,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: const Icon(Icons.headphones, color: primaryTeal),
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const Expanded(
  //                           child: Text(
  //                             "Zen Series Wireless Earbuds",
  //                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //                             maxLines: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 8),
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //                           decoration: BoxDecoration(color: selectedBg, borderRadius: BorderRadius.circular(8)),
  //                           child: const Text("Fulfilled", style: TextStyle(color: primaryTeal, fontSize: 9, fontWeight: FontWeight.bold)),
  //                         )
  //                       ],
  //                     ),
  //                     const SizedBox(height: 2),
  //                     const Text("ID: #ORD-22910", style: TextStyle(fontSize: 10, color: Colors.grey)),
  //                     const SizedBox(height: 8),
  //                     Wrap(
  //                       spacing: 16,
  //                       runSpacing: 4,
  //                       crossAxisAlignment: WrapCrossAlignment.center,
  //                       children: [
  //                         Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: const [
  //                             Icon(Icons.store, color: Colors.grey, size: 14),
  //                             SizedBox(width: 4),
  //                             Text("Seller: ", style: TextStyle(fontSize: 11, color: textLight)),
  //                             Text("Urban Electronics", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
  //                           ],
  //                         ),
  //                         Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: const [
  //                             Icon(Icons.person, color: Colors.grey, size: 14),
  //                             SizedBox(width: 4),
  //                             Text("Buyer: ", style: TextStyle(fontSize: 11, color: textLight)),
  //                             Text("Sarah Jenkins", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     const Divider(height: 24),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const Text("₹18,900.00", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
  //                         TextButton(
  //                           style: TextButton.styleFrom(foregroundColor: primaryTeal, padding: EdgeInsets.zero, minimumSize: Size.zero),
  //                           onPressed: () {},
  //                           child: const Text("Contact Seller", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                         )
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 28),
  //
  //         // 5. Curated Queue: Listing Approvals
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             const Text("Curated Queue: Listing Approvals", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //               decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
  //               child: const Text("12 New", style: TextStyle(color: Color(0xFFC62828), fontSize: 9, fontWeight: FontWeight.bold)),
  //             )
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //
  //         LayoutBuilder(
  //           builder: (context, constraints) {
  //             final isNarrow = constraints.maxWidth < 500;
  //             final cards = [
  //               // Card 1: Soundbar Pro
  //               Container(
  //                 decoration: _dashboardCardDecoration(),
  //                 padding: const EdgeInsets.all(12),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       height: 100,
  //                       decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
  //                       alignment: Alignment.center,
  //                       child: const Icon(Icons.speaker, color: primaryTeal, size: 36),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     const Text("Premium Soundbar Pro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
  //                     const Text("Requested by: TechNexus", style: TextStyle(fontSize: 10, color: Colors.grey)),
  //                     const SizedBox(height: 12),
  //                     SizedBox(
  //                       height: 38,
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: ElevatedButton(
  //                               style: ElevatedButton.styleFrom(
  //                                 backgroundColor: const Color(0xFFFFEBEE), // Soft pinkish red
  //                                 foregroundColor: const Color(0xFFC62828), // Crimson red
  //                                 elevation: 0,
  //                                 padding: const EdgeInsets.symmetric(vertical: 8),
  //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                               ),
  //                               onPressed: () => _showSuccess("Soundbar Pro listing rejected."),
  //                               child: const Text("Reject", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 8),
  //                           Expanded(
  //                             child: ElevatedButton(
  //                               style: ElevatedButton.styleFrom(
  //                                 backgroundColor: primaryTeal,
  //                                 foregroundColor: Colors.white,
  //                                 elevation: 0,
  //                                 padding: const EdgeInsets.symmetric(vertical: 8),
  //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                               ),
  //                               onPressed: () => _showSuccess("Soundbar Pro listing approved!"),
  //                               child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               // Card 2: Brand Strategy Workshop
  //               Container(
  //                 decoration: _dashboardCardDecoration(),
  //                 padding: const EdgeInsets.all(12),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       height: 100,
  //                       decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
  //                       alignment: Alignment.center,
  //                       child: const Icon(Icons.brush, color: primaryTeal, size: 36),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     const Text("Brand Strategy Workshop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
  //                     const Text("Requested by: Creative Labs", style: TextStyle(fontSize: 10, color: Colors.grey)),
  //                     const SizedBox(height: 12),
  //                     SizedBox(
  //                       height: 38,
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: ElevatedButton(
  //                               style: ElevatedButton.styleFrom(
  //                                 backgroundColor: const Color(0xFFFFEBEE), // Soft pinkish red
  //                                 foregroundColor: const Color(0xFFC62828), // Crimson red
  //                                 elevation: 0,
  //                                 padding: const EdgeInsets.symmetric(vertical: 8),
  //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                               ),
  //                               onPressed: () => _showSuccess("Workshop listing rejected."),
  //                               child: const Text("Reject", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 8),
  //                           Expanded(
  //                             child: ElevatedButton(
  //                               style: ElevatedButton.styleFrom(
  //                                 backgroundColor: primaryTeal,
  //                                 foregroundColor: Colors.white,
  //                                 elevation: 0,
  //                                 padding: const EdgeInsets.symmetric(vertical: 8),
  //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                               ),
  //                               onPressed: () => _showSuccess("Workshop listing approved!"),
  //                               child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
  //                             ),
  //                           )
  //                         ],
  //                       ),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ];
  //
  //             return isNarrow
  //                 ? Column(
  //                     children: [
  //                       cards[0],
  //                       const SizedBox(height: 16),
  //                       cards[1],
  //                     ],
  //                   )
  //                 : Row(
  //                     children: [
  //                       Expanded(child: cards[0]),
  //                       const SizedBox(width: 16),
  //                       Expanded(child: cards[1]),
  //                     ],
  //                   );
  //           },
  //         ),
  //         const SizedBox(height: 28),
  //
  //         // 6. News & Insights
  //         const Text("News & Global Insights", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
  //         const SizedBox(height: 12),
  //         Container(
  //           decoration: _dashboardCardDecoration(),
  //           clipBehavior: Clip.antiAlias,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                 height: 140,
  //                 color: primaryTeal.withOpacity(0.2),
  //                 width: double.infinity,
  //                 alignment: Alignment.center,
  //                 child: const Icon(Icons.newspaper, color: primaryTeal, size: 48),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(16),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: const [
  //                     Text("FUTURE-PROOFING COMMERCE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 0.5)),
  //                     SizedBox(height: 4),
  //                     Text("Future-proofing commerce: The rise of hybrid supply chains.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSliderCard({required Widget child, Color? color}) {
    return SizedBox(
      width: 260,
      height: 155,
      child: HoverableCard(
        borderRadius: 20.0,
        backgroundColor: color ?? Colors.white,
        borderColor: const Color(0xff006565),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, double pct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textLight)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryTeal)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            color: primaryTeal,
            backgroundColor: Colors.grey.shade100,
          ),
        )
      ],
    );
  }

  BoxDecoration _dashboardCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  // 2. Manage Users View
  Widget _buildManageUsersView() {
    final generalUsers = _mockUsers.where((u) => u['role'] == 'General').toList();
    final businessUsers = _mockUsers.where((u) => u['role'] == 'Business').toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: primaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryTeal,
            tabs: [
              Tab(text: "General Users"),
              Tab(text: "Business Users"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUsersList(generalUsers, "General"),
                _buildUsersList(businessUsers, "Business"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<Map<String, dynamic>> usersList, String role) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: usersList.length,
      itemBuilder: (context, idx) {
        final user = usersList[idx];
        final name = user["name"];
        final email = user["email"];
        final status = user["status"];
        final isActive = status == "Active";

        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: selectedBg,
                  child: Text(name[0], style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(email, style: const TextStyle(color: textLight, fontSize: 11)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.withOpacity(0.1) : const Color(0xFFBA1A1A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: isActive ? Colors.green : const Color(0xFFBA1A1A), fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: primaryTeal),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          user: ChatUser(
                            id: user["id"],
                            name: name,
                            lastMessage: "",
                            time: "",
                            avatarUrl: "",
                          ),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, color: Colors.grey),
                  onPressed: () => _showUserDetailsDialog(user),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user["name"], style: const TextStyle(fontWeight: FontWeight.bold, color: darkTeal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User ID: ${user['id']}"),
            const SizedBox(height: 6),
            Text("Email: ${user['email']}"),
            const SizedBox(height: 6),
            Text("Role Level: ${user['role']} User"),
            const SizedBox(height: 6),
            Text("Status: ${user['status']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: primaryTeal)),
          )
        ],
      ),
    );
  }

  // 3. Jobs Board View (Rich mockup)
  Widget _buildJobsView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: primaryTeal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryTeal,
            tabs: [
              Tab(text: "Active Openings"),
              Tab(text: "Post a New Job"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildActiveJobsTab(),
                _buildPostJobTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockJobs.length,
      itemBuilder: (context, idx) {
        final job = _mockJobs[idx];
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(job["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkTeal)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: selectedBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(job["type"], style: const TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(job["company"], style: const TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(job["location"], style: const TextStyle(color: textLight, fontSize: 11)),
                    const SizedBox(width: 16),
                    const Icon(Icons.monetization_on_outlined, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(job["salary"], style: const TextStyle(color: textLight, fontSize: 11)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(job["date"], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    Text("${job['applicants']} Applicants", style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostJobTab() {
    final titleController = TextEditingController();
    final salaryController = TextEditingController();
    final locationController = TextEditingController();
    final descController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Create a Job Opening", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTeal)),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "Job Title", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: salaryController,
            decoration: const InputDecoration(labelText: "Salary Range (e.g. ₹50k - ₹60k)", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(labelText: "Job Location / Remote Status", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: "Brief Description", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: primaryTeal),
              onPressed: () {
                if (titleController.text.isEmpty) return;
                setState(() {
                  _mockJobs.insert(0, {
                    "title": titleController.text,
                    "company": _businessName,
                    "salary": salaryController.text.isNotEmpty ? salaryController.text : "Competitive",
                    "location": locationController.text.isNotEmpty ? locationController.text : "Remote",
                    "type": "Full-Time",
                    "applicants": 0,
                    "date": "Posted just now"
                  });
                  _activeJobsCount++;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Job posted successfully!"), backgroundColor: Colors.green),
                );
                DefaultTabController.of(context).animateTo(0);
              },
              child: const Text("Submit & Post", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // 9. Financials -> Bank Details View
  Widget _buildBankDetailsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockBankDetails.length,
      itemBuilder: (context, idx) {
        final bank = _mockBankDetails[idx];
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: selectedBg,
              child: Icon(Icons.account_balance_rounded, color: primaryTeal),
            ),
            title: Text(bank["vendor"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("Bank: ${bank['bank']} • Account: ${bank['account']}"),
            trailing: Text("IFSC: ${bank['ifsc']}", style: const TextStyle(fontSize: 10, color: textLight)),
          ),
        );
      },
    );
  }

  // 10. Financials -> Payout/Withdrawal Requests View
  Widget _buildWithdrawalsView() {
    final pendingPayouts = _mockPayouts;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingPayouts.length,
      itemBuilder: (context, idx) {
        final pay = pendingPayouts[idx];
        final status = pay["status"];
        final isSuccess = status == "Success" || status == "Approved";

        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ref: ${pay['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("Requested on: ${pay['date']}", style: const TextStyle(color: textLight, fontSize: 11)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(pay["amount"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryTeal)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: isSuccess ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 12. Manage Communities approvals View
  Widget _buildCommunityApprovalsView() {
    if (_mockCommunities.isEmpty) {
      return const Center(child: Text("No pending community approvals.", style: TextStyle(color: textLight)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockCommunities.length,
      itemBuilder: (context, idx) {
        final comm = _mockCommunities[idx];
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: selectedBg,
                  child: Icon(Icons.diversity_3_rounded, color: primaryTeal),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comm["user_name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Requesting: ${comm['community_name']}", style: const TextStyle(color: textLight, fontSize: 12)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          _mockCommunities.removeAt(idx);
                          _pendingApprovalsCount--;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Approval request approved successfully!"), backgroundColor: Colors.green),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Color(0xFFBA1A1A)),
                      onPressed: () {
                        setState(() {
                          _mockCommunities.removeAt(idx);
                          _pendingApprovalsCount--;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Approval request rejected."), backgroundColor: Color(0xFFBA1A1A)),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 15. Opportunity Marketplace -> Marketplace
  Widget _buildMarketplaceOpportunitiesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, idx) {
        final opps = [
          {"title": "Eco-friendly Cardboard Packing Boxes", "qty": "10,000 units", "budget": "₹5,000.00"},
          {"title": "Bamboo Disposable Cutlery Sets", "qty": "50,000 units", "budget": "₹12,000.00"},
        ];
        final op = opps[idx];
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(op["title"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkTeal)),
                const SizedBox(height: 8),
                Text("Required Qty: ${op['qty']}", style: const TextStyle(color: textLight, fontSize: 12)),
                const SizedBox(height: 4),
                Text("Proposed Budget: ${op['budget']}", style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  // 17. Opportunity Marketplace -> My Submissions
  Widget _buildMySubmissionsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, idx) {
        final subs = [
          {"title": "Biodegradable Kraft Paper Bags Submission", "status": "Interviewing"},
          {"title": "Reusable Glass Jar Packaging Pitch", "status": "Under Review"},
        ];
        final sub = subs[idx];
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: selectedBg,
              child: Icon(Icons.assignment_turned_in_rounded, color: primaryTeal),
            ),
            title: Text(sub["title"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: selectedBg, borderRadius: BorderRadius.circular(8)),
              child: Text(sub["status"]!, style: const TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  // My Addresses View matching admin conventions
  Widget _buildMyAddressesView() {
    return Scaffold(
      backgroundColor: bgLight,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockAddresses.length,
        itemBuilder: (context, idx) {
          final addr = _mockAddresses[idx];
          return Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: selectedBg,
                child: Icon(Icons.location_on, color: primaryTeal),
              ),
              title: Text(addr["label"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(addr["address"], style: const TextStyle(color: textLight, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text("Phone: ${addr['phone']}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: primaryTeal, size: 20),
                onPressed: () {
                  // _showEditAddressDialog(addr);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {

        },
      ),
    );
  }

  // void _showEditAddressDialog(Map<String, dynamic> addr) {
  //   final labelCtrl = TextEditingController(text: addr["label"]);
  //   final addrCtrl = TextEditingController(text: addr["address"]);
  //   final phoneCtrl = TextEditingController(text: addr["phone"]);
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Edit Address", style: TextStyle(fontWeight: FontWeight.bold, color: darkTeal)),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: "Label")),
  //           const SizedBox(height: 12),
  //           TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: "Address")),
  //           const SizedBox(height: 12),
  //           TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
  //         ),
  //         SizedBox(
  //           height: 36,
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, elevation: 0),
  //             onPressed: () {
  //               setState(() {
  //                 addr["label"] = labelCtrl.text;
  //                 addr["address"] = addrCtrl.text;
  //                 addr["phone"] = phoneCtrl.text;
  //               });
  //               Navigator.pop(context);
  //               _showSuccess("Address updated successfully!");
  //             },
  //             child: const Text("Save", style: TextStyle(color: Colors.white)),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // void _showAddAddressDialog() {
  //   final labelCtrl = TextEditingController();
  //   final addrCtrl = TextEditingController();
  //   final phoneCtrl = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Add New Address", style: TextStyle(fontWeight: FontWeight.bold, color: darkTeal)),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: "Label")),
  //           const SizedBox(height: 12),
  //           TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: "Address")),
  //           const SizedBox(height: 12),
  //           TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
  //         ),
  //         SizedBox(
  //           height: 36,
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, elevation: 0),
  //             onPressed: () {
  //               setState(() {
  //                 _mockAddresses.add({
  //                   "id": (DateTime.now().millisecondsSinceEpoch).toString(),
  //                   "label": labelCtrl.text,
  //                   "address": addrCtrl.text,
  //                   "phone": phoneCtrl.text,
  //                 });
  //               });
  //               Navigator.pop(context);
  //               _showSuccess("New address added successfully!");
  //             },
  //             child: const Text("Add", style: TextStyle(color: Colors.white)),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}

// ══════════════════════════════════════════════════════════
// CUSTOM SPARKLINE PAINTER (FOR REVENUE CHART)
// ══════════════════════════════════════════════════════════
class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006565)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Create curve points mirroring: M0,80 Q100,20 200,60 T400,40 T600,70 T800,30 T1000,50
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.2,
      size.width * 0.2, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.8,
      size.width * 0.4, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.2,
      size.width * 0.6, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.9,
      size.width * 0.8, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.1,
      size.width, size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
