import 'dart:io';
import 'package:trading_ecommerce_admin/screens/seller_profile_screen.dart';
import 'package:trading_ecommerce_admin/screens/promotional_packages_screen.dart';
import 'package:trading_ecommerce_admin/admin/digital_marketplace_screen.dart';
import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trading_ecommerce_admin/screens/low_stock_inventory_screen.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'seller_orders_screen.dart';

class MyLocalHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'SereneCommerceAdmin/1.0 (contact@serenecommerce.com)';
  }
}

void main() {
  HttpOverrides.global = MyLocalHttpOverrides();
  runApp(const SellerCentralApp());
}

class SellerCentralApp extends StatelessWidget {
  const SellerCentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seller Central',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffFCF9F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff006565),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: const SellerDashboard(),
      routes: {
        '/user/profile': (context) => const SellerProfileScreen(),
      },
    );
  }
}

class SellerDashboardScreen extends StatelessWidget {
  final bool isEmbedded;
  const SellerDashboardScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    return SellerDashboard(isEmbedded: isEmbedded);
  }
}

class SellerDashboard extends StatefulWidget {
  final bool isEmbedded;
  const SellerDashboard({super.key, this.isEmbedded = false});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int bottomIndex = 0;
  bool isLoading = true;
  double salesToday = 0.0;
  int pendingOrdersCount = 0;
  int lowStockCount = 0;
  List<dynamic> recentOrders = [];
  List<dynamic> categoryData = [];
  List<String> salesLabels = [];
  List<double> salesValues = [];
  List<dynamic> lowStockItems = [];
  List<dynamic> marketNews = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final db = Database();

      // 1. Fetch stats
      final statsResponse = await db.getData({
        'action': 'get_stats',
      }, endpoint: 'new_apis/ecommerce_dashboard_API.php');

      if (statsResponse['success'] == true) {
        final data = statsResponse['data'];
        salesToday =
            double.tryParse(data['sales_today']?.toString() ?? '0') ?? 0.0;
        pendingOrdersCount =
            int.tryParse(data['pending_orders']?.toString() ?? '0') ?? 0;
        lowStockCount = int.tryParse(data['low_stock']?.toString() ?? '0') ?? 0;
      }

      // 2. Fetch category data
      final catResponse = await db.getData({
        'action': 'category_pie',
      }, endpoint: 'new_apis/ecommerce_dashboard_API.php');

      if (catResponse['success'] == true) {
        categoryData = catResponse['data'] ?? [];
      }

      // 3. Fetch sales trend monthly orders
      final trendResponse = await db.getData({
        'action': 'monthly_orders',
      }, endpoint: 'new_apis/ecommerce_dashboard_API.php');

      if (trendResponse['success'] == true) {
        final trendData = trendResponse['data'];
        final labels = List<String>.from(trendData['labels'] ?? []);
        final orders = List<int>.from(trendData['orders'] ?? []);

        salesLabels = labels;
        if (orders.isNotEmpty) {
          final maxVal = orders.reduce((a, b) => a > b ? a : b);
          salesValues = orders
              .map((e) => maxVal > 0 ? (e / maxVal).clamp(0.1, 1.0) : 0.1)
              .toList();
        } else {
          salesValues = [];
        }
      }

      // 4. Fetch recent orders
      final ordersResponse = await db.getData({
        'action': 'get_recent_orders',
      }, endpoint: 'new_apis/ecommerce_dashboard_API.php');

      if (ordersResponse['success'] == true) {
        recentOrders = ordersResponse['data'] ?? [];
      }

      // 5. Fetch live low stock items list
      try {
        final lowStockResponse = await db.getData({
          'action': 'stockList',
        }, endpoint: 'new_apis/inventory_update.php');
        if ((lowStockResponse['success'] == true ||
                lowStockResponse['ok'] == true) &&
            lowStockResponse['data'] != null) {
          lowStockItems = lowStockResponse['data'] ?? [];
        }
      } catch (e) {
        debugPrint("Error fetching low stock list: $e");
      }

      // 6. Fetch live market news posts
      try {
        final newsResponse = await db.getData({
          'action': 'latest_posts',
          'limit': '10',
        }, endpoint: 'new_apis/post_testimonials_api 1.php');
        if (newsResponse['status'] == true && newsResponse['data'] != null) {
          marketNews = newsResponse['data'] ?? [];
        }
      } catch (e) {
        debugPrint("Error fetching market news: $e");
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateStock(String variantId, int newStock) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xff006565)),
      ),
    );

    try {
      final db = Database();
      final response = await db.getData({
        'action': 'update',
        'id': variantId,
        'stock': newStock.toString(),
      }, endpoint: 'new_apis/inventory_update.php');

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading

      if (response['success'] == true || response['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inventory stock updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchDashboardData(); // Refresh metrics
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ??
                response['error']?.toString() ??
                "Failed to update stock"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRestockDialog(BuildContext context, dynamic item) {
    final controller =
        TextEditingController(text: item['a_stock']?.toString() ?? '0');
    final title = item['product_title']?.toString() ?? 'Update Stock';
    final variantId = item['variant_id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff006565)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current Stock: ${item['a_stock'] ?? 0} units",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "New Stock Total",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff006565), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff006565),
            ),
            onPressed: () {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                Navigator.pop(context);
                _updateStock(variantId, newStock);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter a valid stock number")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.isEmbedded ? null : const DashboardDrawer(),
      appBar: widget.isEmbedded
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: buildHeader(),
            ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: const Color(0xff006565),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: isLoading
              ? const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xff006565)),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    HeroStatsSection(
                      salesToday: salesToday,
                      pendingOrders: pendingOrdersCount,
                      lowStock: lowStockCount,
                    ),
                    const SizedBox(height: 24),
                    AnalyticsSection(
                      labels: salesLabels,
                      values: salesValues,
                    ),
                    const SizedBox(height: 24),
                    OperationsSection(
                      categoryData: categoryData,
                      recentOrders: recentOrders,
                      lowStockItems: lowStockItems,
                      onRestock: (item) {
                        _showRestockDialog(context, item);
                      },
                    ),
                    const SizedBox(height: 30),
                    MarketNewsSection(marketNews: marketNews),
                    const SizedBox(height: 30),
                    const SellerOpportunitySection(),
                    const SizedBox(height: 30),
                    const ReviewsSection(),
                    const SizedBox(height: 30),
                    const PartnersSection(),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: widget.isEmbedded
          ? null
          : (MediaQuery.of(context).size.width < 768
              ? NavigationBar(
                  selectedIndex: bottomIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      bottomIndex = value;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_rounded),
                      label: "Dashboard",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.inventory_2_rounded),
                      label: "Inventory",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.shopping_cart_rounded),
                      label: "Orders",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_rounded),
                      label: "Settings",
                    ),
                  ],
                )
              : null),
    );
  }

  Widget buildHeader() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1.0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.black.withValues(alpha: 0.04),
          height: 1,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff006565).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront,
              color: Color(0xff006565),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              "Seller Central",
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
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.02),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {},
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
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context, rootNavigator: true).pushNamed('/user/profile');
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff006565).withValues(alpha: 0.2),
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
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  drawerItem(Icons.home_rounded, "Overview", true),
                  drawerItem(
                      Icons.inventory_2_rounded, "Product Manager", false),
                  drawerItem(
                      Icons.local_shipping_rounded, "Fulfillment", false),
                  drawerItem(Icons.trending_up_rounded, "Performance", false),
                  drawerItem(
                      Icons.shop_outlined, "Digital Marketplace", false,
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DigitalMarketplaceScreen(isEmbedded: false),
                          ),
                        );
                      }),
                  drawerItem(
                      Icons.campaign_rounded, "Marketplace Promotions", false,
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PromotionalPackagesScreen(),
                          ),
                        );
                      }),
                  drawerItem(
                      Icons.manage_accounts_rounded, "Account Settings", false,
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.of(context, rootNavigator: true).pushNamed('/user/profile');
                      }),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff006565),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Support Plan",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Priority Business",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff006565),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("View Benefits",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget drawerItem(IconData icon, String title, bool selected, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xff006565).withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? const Color(0xff006565) : Colors.black54,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? const Color(0xff006565) : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class HeroStatsSection extends StatelessWidget {
  final double salesToday;
  final int pendingOrders;
  final int lowStock;

  const HeroStatsSection({
    super.key,
    required this.salesToday,
    required this.pendingOrders,
    required this.lowStock,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool mobile = constraints.maxWidth < 900;

        if (mobile) {
          return Column(
            children: [
              const MembershipCard(),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: constraints.maxWidth < 500 ? 0.95 : 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  RevenueCard(value: salesToday),
                  OrdersCard(value: pendingOrders),
                  LowStockCard(value: lowStock),
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 4,
              child: MembershipCard(),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 8,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  RevenueCard(value: salesToday),
                  OrdersCard(value: pendingOrders),
                  LowStockCard(value: lowStock),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class MembershipCard extends StatelessWidget {
  const MembershipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff004d4d),
            Color(0xff006565),
            Color(0xff008080),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff004d4d).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        "PREMIUM INSIGHTS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Elevate Your\nStrategy.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.2,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Get real-time market trends and competitor analysis to boost your sales by up to 40%.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xff006565),
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Upgrade Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RevenueCard extends StatelessWidget {
  final double value;
  const RevenueCard({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.payments,
      title: "Total Revenue",
      value: "₹${value.toStringAsFixed(2)}",
      growth: "+12.5%",
      positive: true,
    );
  }
}

class OrdersCard extends StatelessWidget {
  final int value;
  const OrdersCard({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.shopping_bag,
      title: "Pending Orders",
      value: "$value",
      growth: "+8.2%",
      positive: true,
    );
  }
}

class LowStockCard extends StatelessWidget {
  final int value;
  const LowStockCard({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.warning,
      title: "Low Stock Alerts",
      value: "$value",
      growth: value > 0 ? "Alert" : "Good",
      positive: value == 0,
    );
  }
}



class AnalyticsSection extends StatefulWidget {
  final List<String> labels;
  final List<double> values;

  const AnalyticsSection({
    super.key,
    required this.labels,
    required this.values,
  });

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              final List<Widget> slides = [
                const VisitorTrafficCard(),
                SalesTrendCard(labels: widget.labels, values: widget.values),
                const RevenueDistributionCard(),
                const PerformanceScoreCard(),
              ];

              return Column(
                children: [
                  SizedBox(
                    height: 460,
                    child: PageView(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      children: slides,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: slides.length,
                    effect: const ScrollingDotsEffect(
                      activeDotColor: Color(0xff006565),
                      dotColor: Colors.black12,
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotScale: 1.3,
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 8,
                  child: VisitorTrafficCard(),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      SalesTrendCard(
                          labels: widget.labels, values: widget.values),
                      const SizedBox(height: 20),
                      const RevenueDistributionCard(),
                      const SizedBox(height: 20),
                      const PerformanceScoreCard(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class VisitorLatLng {
  final String name;
  final MapLatLng latLng;
  final String percentage;
  final Color color;

  const VisitorLatLng({
    required this.name,
    required this.latLng,
    required this.percentage,
    required this.color,
  });
}

class VisitorTrafficCard extends StatelessWidget {
  const VisitorTrafficCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<VisitorLatLng> visitorData = const [
      VisitorLatLng(
        name: "North America",
        latLng: MapLatLng(40.7128, -74.0060),
        percentage: "42%",
        color: Color(0xff006565),
      ),
      VisitorLatLng(
        name: "Europe",
        latLng: MapLatLng(51.5074, -0.1278),
        percentage: "28%",
        color: Color(0xff00bfa5),
      ),
      VisitorLatLng(
        name: "Asia-Pacific",
        latLng: MapLatLng(19.0760, 72.8777),
        percentage: "18%",
        color: Color(0xffffb300),
      ),
    ];

    return Container(
      height: 440,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Visitor Traffic Distribution",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Real-time geographic audience",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xff006565).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Global",
                  style: TextStyle(
                    color: Color(0xff006565),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xfff5fbfb),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xff006565).withValues(alpha: 0.04),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SfMaps(
                  layers: [
                    MapTileLayer(
                      urlTemplate:
                          'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                      initialFocalLatLng: const MapLatLng(20.0, 0.0),
                      initialZoomLevel: 1,
                      initialMarkersCount: visitorData.length,
                      markerBuilder: (BuildContext context, int index) {
                        final data = visitorData[index];
                        return MapMarker(
                          latitude: data.latLng.latitude,
                          longitude: data.latLng.longitude,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: data.color.withValues(alpha: 0.24),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: data.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${data.name} ${data.percentage}",
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: data.color.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: data.color.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: data.color,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
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
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              _buildRegionRow(
                  "North America", "42%", const Color(0xff006565), 0.42),
              const SizedBox(height: 12),
              _buildRegionRow("Europe", "28%", const Color(0xff00bfa5), 0.28),
              const SizedBox(height: 12),
              _buildRegionRow(
                  "Asia-Pacific", "18%", const Color(0xffffb300), 0.18),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRegionRow(
      String name, String percentage, Color color, double progress) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 35,
          child: Text(
            percentage,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

class SalesTrendCard extends StatelessWidget {
  final List<String> labels;
  final List<double> values;

  const SalesTrendCard({
    super.key,
    required this.labels,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final displayValues = values.isEmpty ? [.4, .6, .55, .85, .7, .95] : values;
    final fallbackLabels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
    final displayLabels = labels.isEmpty ? fallbackLabels : labels;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sales Trend",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Monthly Orders count",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 45),
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade100,
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(displayValues.length, (index) {
                    final double val = displayValues[index];
                    final String label = index < displayLabels.length
                        ? displayLabels[index]
                        : "";

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                width: 18,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xff004d4d),
                                      Color(0xff006565),
                                      Color(0xff00bfa5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 140 * val,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RevenueDistributionCard extends StatelessWidget {
  const RevenueDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Revenue By Category",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const DoughnutChart(
            values: [54, 22, 24],
            colors: [
              Color(0xff006565),
              Color(0xff00bfa5),
              Color(0xffffb300),
            ],
            centerValue: "54%",
            centerLabel: "Tech",
          ),
          const SizedBox(height: 24),
          _buildCategoryItem(
              "Tech Accessories", "54%", const Color(0xff006565)),
          _buildCategoryItem("Home Office", "22%", const Color(0xff00bfa5)),
          _buildCategoryItem("Lifestyle", "24%", const Color(0xffffb300)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceScoreCard extends StatelessWidget {
  const PerformanceScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xffe5f7f7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xff006565).withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 40,
              color: Color(0xff006565),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Performance Score",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff006565),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Excellent • Top 5% Sellers",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPerformanceMetric("98%", "Rating"),
              Container(
                width: 1,
                height: 30,
                color: const Color(0xff006565).withValues(alpha: 0.15),
              ),
              _buildPerformanceMetric("2.1d", "Shipping"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}

class OperationsSection extends StatelessWidget {
  final List<dynamic> categoryData;
  final List<dynamic> recentOrders;
  final List<dynamic> lowStockItems;
  final Function(dynamic item) onRestock;

  const OperationsSection({
    super.key,
    required this.categoryData,
    required this.recentOrders,
    required this.lowStockItems,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        CategoryAnalysisCard(categoryData: categoryData),
        const SizedBox(height: 24),
        ResponsiveOperationsLayout(
          recentOrders: recentOrders,
          lowStockItems: lowStockItems,
          onRestock: onRestock,
        ),
      ],
    );
  }
}

class CategoryAnalysisCard extends StatelessWidget {
  final List<dynamic> categoryData;

  const CategoryAnalysisCard({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    final displayData = categoryData.isEmpty
        ? [
            {'category': 'Tech Accessories', 'count': 42},
            {'category': 'Home Office', 'count': 28},
            {'category': 'Lifestyle', 'count': 15},
            {'category': 'Kitchenware', 'count': 10},
          ]
        : categoryData;

    final double totalCount = displayData.fold<double>(
        0.0,
        (sum, item) =>
            sum + (double.tryParse(item['count']?.toString() ?? '0') ?? 0.0));
    final chartValues = displayData
        .map<double>(
            (e) => double.tryParse(e['count']?.toString() ?? '0') ?? 0.0)
        .toList();

    final colors = [
      const Color(0xff006565),
      const Color(0xff00bfa5),
      const Color(0xffffb300),
      const Color(0xff757575),
      const Color(0xffe91e63),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Category Analysis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              DoughnutChart(
                values: chartValues,
                colors: colors,
                centerValue: totalCount.toStringAsFixed(0),
                centerLabel: "Items",
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: List.generate(displayData.length, (index) {
                    final e = displayData[index];
                    final catName = e['category']?.toString() ?? 'Category';
                    final count =
                        double.tryParse(e['count']?.toString() ?? '0') ?? 0.0;
                    final pct =
                        totalCount > 0 ? (count * 100 / totalCount).round() : 0;
                    return CategoryItem(
                      catName,
                      "${count.toStringAsFixed(0)} ($pct%)",
                      colors[index % colors.length],
                    );
                  }),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color dotColor;

  const CategoryItem(
    this.title,
    this.value,
    this.dotColor, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          )
        ],
      ),
    );
  }
}

class ResponsiveOperationsLayout extends StatelessWidget {
  final List<dynamic> recentOrders;
  final List<dynamic> lowStockItems;
  final Function(dynamic item) onRestock;

  const ResponsiveOperationsLayout({
    super.key,
    required this.recentOrders,
    required this.lowStockItems,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return Column(
            children: [
              RecentOrdersCard(recentOrders: recentOrders),
              const SizedBox(height: 24),
              InventoryAlertsCard(
                lowStockItems: lowStockItems,
                onRestock: onRestock,
              ),
              const SizedBox(height: 24),
              const PromotionCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: RecentOrdersCard(recentOrders: recentOrders),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  InventoryAlertsCard(
                    lowStockItems: lowStockItems,
                    onRestock: onRestock,
                  ),
                  const SizedBox(height: 24),
                  const PromotionCard(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class RecentOrdersCard extends StatelessWidget {
  final List<dynamic> recentOrders;

  const RecentOrdersCard({
    super.key,
    required this.recentOrders,
  });

  String _getEmail(String name, String id) {
    if (name.toLowerCase() == 'customer' || name.trim().isEmpty) {
      return 'cust.$id@store.com';
    }
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0].toLowerCase()}.${parts[1].toLowerCase()}@tech.com';
    }
    return '${name.toLowerCase()}@store.com';
  }

  Widget _buildIcon(String title, int index) {
    final t = title.toLowerCase();
    IconData iconData = Icons.shopping_bag_outlined;
    Color iconColor = const Color(0xff006565);
    Color bgColor = const Color(0xffe5f7f7);

    if (t.contains("lamp") || index % 4 == 0) {
      iconData = Icons.light_rounded;
      iconColor = Colors.grey.shade800;
      bgColor = Colors.grey.shade100;
    } else if (t.contains("keyboard") || index % 4 == 1) {
      iconData = Icons.keyboard_rounded;
      iconColor = const Color(0xff006565);
      bgColor = const Color(0xffe5f7f7);
    } else if (t.contains("laptop") || index % 4 == 2) {
      iconData = Icons.laptop_mac_rounded;
      iconColor = Colors.blue.shade700;
      bgColor = Colors.blue.shade50;
    } else {
      iconData = Icons.devices_other_rounded;
      iconColor = Colors.amber.shade800;
      bgColor = Colors.amber.shade50;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Orders",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Latest purchases from your store",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerOrderScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xff006565),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          recentOrders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      "No recent orders yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Container(
                  height: 200,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: recentOrders.length,
                    itemBuilder: (context, index) {
                      final item = recentOrders[index];
                      final orderId = "#SC-${item['id'] ?? ''}";
                      final buyerName =
                          item['customer_name']?.toString() ?? 'Customer';
                      final amount =
                          "₹${(double.tryParse(item['total']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}";
                      final email = _getEmail(
                          buyerName, item['id']?.toString() ?? '$index');
                      final productTitle =
                          item['product_title']?.toString() ?? 'Product';

                      return Container(
                        width: 260,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.04),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildIcon(productTitle, index),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    orderId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              buyerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              amount,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Color(0xff006565),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class InventoryAlertsCard extends StatelessWidget {
  final List<dynamic> lowStockItems;
  final Function(dynamic item) onRestock;

  const InventoryAlertsCard({
    super.key,
    required this.lowStockItems,
    required this.onRestock,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = lowStockItems.isEmpty
        ? [
            {
              'variant_id': 0,
              'product_title': 'Serene Desk Lamp',
              'a_stock': 4,
              'image_url': ''
            },
            {
              'variant_id': 0,
              'product_title': 'Zen Keyboard',
              'a_stock': 0,
              'image_url': ''
            },
          ]
        : lowStockItems.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Inventory Alerts",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(displayItems.length, (index) {
            final item = displayItems[index];
            final title = item['product_title']?.toString() ?? 'Product';
            final stock = int.tryParse(item['a_stock']?.toString() ?? '0') ?? 0;
            final subtitle = stock == 0 ? "Out of Stock" : "Only $stock Left";
            final imgUrl = item['image_url']?.toString() ?? '';

            return Padding(
              padding: EdgeInsets.only(
                  bottom: index == displayItems.length - 1 ? 0 : 12.0),
              child: alertItem(
                title,
                subtitle,
                imgUrl,
                () => onRestock(item),
              ),
            );
          }),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff006565), width: 1.5),
                foregroundColor: const Color(0xff006565),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LowStockInventoryScreen()),
                );
              },
              child: const Text(
                "Inventory Manager",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget alertItem(
    String title,
    String subtitle,
    String imageUrl,
    VoidCallback onAddPressed,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xfffcfdfe),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.black.withValues(alpha: 0.03), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  )
                : _fallbackIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.redAccent.shade200,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff006565).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onAddPressed,
              icon: const Icon(
                Icons.add_rounded,
                color: Color(0xff006565),
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget _fallbackIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xff006565).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Color(0xff006565),
        size: 20,
      ),
    );
  }
}

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xff004d4d),
            Color(0xff008080),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff004d4d).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.bolt_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Grow Your Reach",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Promote your listings to appear first in customer searches.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xff006565),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PromotionalPackagesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text(
                    "Promote Now",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MarketNewsSection extends StatelessWidget {
  final List<dynamic> marketNews;

  const MarketNewsSection({
    super.key,
    required this.marketNews,
  });

  @override
  Widget build(BuildContext context) {
    final displayNews = marketNews.isEmpty
        ? [
            {
              'title': 'Sustainable Workspace Trends',
              'category': 'Home Office',
              'feature_image': '',
              'views': 2400,
              'author_name': 'Sarah Chen',
              'author_profile_pic': 'https://i.pravatar.cc/150?img=32',
              'post_date': 'Lead Analyst • Sep 24',
              'comments': 42
            },
            {
              'title': 'AI In Retail Automation',
              'category': 'Innovation',
              'feature_image': '',
              'views': 1800,
              'author_name': 'Alex Rivera',
              'author_profile_pic': 'https://i.pravatar.cc/150?img=47',
              'post_date': 'Tech Lead • Sep 22',
              'comments': 18
            },
            {
              'title': 'European Market Guide',
              'category': 'Logistics',
              'feature_image': '',
              'views': 950,
              'author_name': 'Emma Vance',
              'author_profile_pic': 'https://i.pravatar.cc/150?img=49',
              'post_date': 'Global Editor • Sep 18',
              'comments': 9
            },
          ]
        : marketNews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Market News",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayNews.length,
            itemBuilder: (context, index) {
              final item = displayNews[index];
              final title = item['title']?.toString() ?? 'News';
              final category = item['category']?.toString() ?? 'General';
              final imageUrl = item['feature_image']?.toString() ?? '';
              final views = int.tryParse(item['views']?.toString() ?? '0') ?? 0;
              final authorName =
                  item['author_name']?.toString() ?? 'Sarah Chen';
              final authorProfilePic =
                  item['author_profile_pic']?.toString() ?? '';
              final rawDate = item['post_date']?.toString() ?? 'Sep 24';
              final comments =
                  int.tryParse(item['comments']?.toString() ?? '12') ?? 12;

              String authorSubtitle = 'Lead Analyst • Sep 24';
              if (rawDate.contains('-')) {
                try {
                  final parsedDate = DateTime.parse(rawDate);
                  final List<String> months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec'
                  ];
                  authorSubtitle =
                      'Author • ${months[parsedDate.month - 1]} ${parsedDate.day}';
                } catch (_) {
                  authorSubtitle = 'Author • $rawDate';
                }
              } else {
                authorSubtitle = rawDate;
              }

              return NewsCard(
                title: title,
                category: category,
                imageUrl: imageUrl,
                views: views,
                authorName: authorName,
                authorProfilePic: authorProfilePic,
                authorSubtitle: authorSubtitle,
                comments: comments,
              );
            },
          ),
        )
      ],
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;
  final int views;
  final String authorName;
  final String authorProfilePic;
  final String authorSubtitle;
  final int comments;

  const NewsCard({
    super.key,
    required this.title,
    required this.category,
    this.imageUrl = '',
    this.views = 0,
    required this.authorName,
    required this.authorProfilePic,
    required this.authorSubtitle,
    this.comments = 12,
  });

  @override
  Widget build(BuildContext context) {
    String viewsText =
        views >= 1000 ? "${(views / 1000).toStringAsFixed(1)}k" : "$views";

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 20, bottom: 8, top: 4),
      child: HoverableCard(
        borderColor: const Color(0xff006565),
        borderRadius: 24.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: imageUrl.isEmpty
                      ? LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: [
                            const Color(0xff006565).withValues(alpha: 0.15),
                            const Color(0xff00bfa5).withValues(alpha: 0.05),
                          ],
                        )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.article_rounded,
                          size: 50,
                          color: Color(0xff006565),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xff006565).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xff006565),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        const Color(0xff006565).withValues(alpha: 0.08),
                    backgroundImage: authorProfilePic.isNotEmpty
                        ? NetworkImage(authorProfilePic)
                        : null,
                    child: authorProfilePic.isEmpty
                        ? const Icon(Icons.person,
                            size: 16, color: Color(0xff006565))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authorSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    viewsText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 15,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$comments",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SellerOpportunitySection extends StatelessWidget {
  const SellerOpportunitySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Seller Opportunities",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Active quotation requests from potential buyers",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: const [
            OpportunityCard(
              buyer: "Alex Morgan",
              buyerSubtitle: "Verified Buyer",
              product: "Custom Bamboo Desk Organizers",
              quantity: "500 units",
              budget: "₹4,500.00",
            ),
            OpportunityCard(
              buyer: "Sarah Kross",
              buyerSubtitle: "Enterprise Client",
              product: "Ergonomic Office Chairs (Teal)",
              quantity: "120 units",
              budget: "₹18,000.00",
            ),
          ],
        )
      ],
    );
  }
}

class OpportunityCard extends StatelessWidget {
  final String buyer;
  final String buyerSubtitle;
  final String product;
  final String quantity;
  final String budget;

  const OpportunityCard({
    super.key,
    required this.buyer,
    required this.buyerSubtitle,
    required this.product,
    required this.quantity,
    required this.budget,
  });

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return "U";
    final parts = fullName.trim().split(" ");
    String initials = "";
    int numWords = parts.length > 2 ? 2 : parts.length;
    for (var i = 0; i < numWords; i++) {
      if (parts[i].isNotEmpty) {
        initials += parts[i][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: HoverableCard(
        borderColor: const Color(0xff006565),
        borderRadius: 24.0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xffe5f7f7),
                    child: Text(
                      _getInitials(buyer),
                      style: const TextStyle(
                        color: Color(0xff006565),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buyer,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          buyerSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                product,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Quantity (MOQ):",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Target Budget:",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    budget,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff006565),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    showQuoteDialog(context);
                  },
                  child: const Text(
                    "Respond to Quote",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Reviews",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View All",
                style: TextStyle(
                  color: Color(0xff006565),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: const [
              ReviewCard(
                name: "Jane Doe",
                review:
                    "The Serene Desk Lamp is absolutely beautiful. The build quality is top-notch and it fits perfectly in my home office. Fast shipping too!",
                time: "2 hours ago",
                rating: 5,
              ),
              ReviewCard(
                name: "Robert King",
                review:
                    "Great keyboard, very tactile. Only wish the cable was a bit longer, but otherwise a solid purchase for the price.",
                time: "Yesterday",
                rating: 5,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final String review;
  final String time;
  final int rating;

  const ReviewCard({
    super.key,
    required this.name,
    required this.review,
    required this.time,
    required this.rating,
  });

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return "U";
    final parts = fullName.trim().split(" ");
    String initials = "";
    int numWords = parts.length > 2 ? 2 : parts.length;
    for (var i = 0; i < numWords; i++) {
      if (parts[i].isNotEmpty) {
        initials += parts[i][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      margin: const EdgeInsets.only(right: 20, bottom: 8, top: 4),
      child: HoverableCard(
        borderColor: const Color(0xff006565),
        borderRadius: 24.0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xff006565).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(name),
                        style: const TextStyle(
                          color: Color(0xff006565),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating
                                  ? Icons.star_border_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xff006565),
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                review,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff006565),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Review from $name published on site!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        "Publish on Site",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        showContactBuyerDialog(context, name);
                      },
                      child: const Text(
                        "Contact Buyer",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
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
}

class PartnersSection extends StatelessWidget {
  const PartnersSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "New Partners",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 330,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: const [
              PartnerCard(
                name: "Elena Dovetail",
                subtitle: "CEO, Dovetail Logistics",
                badgeText: "Logistics",
                rating: "4.9",
                location: "Berlin",
                avatarUrl: "https://i.pravatar.cc/150?img=38",
              ),
              PartnerCard(
                name: "Zen Manufacturing",
                subtitle: "Production Lead",
                badgeText: "Manufacturer",
                rating: "4.7",
                location: "Tokyo",
                avatarUrl: "",
              ),
            ],
          ),
        )
      ],
    );
  }
}

class PartnerCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String badgeText;
  final String rating;
  final String location;
  final String? avatarUrl;

  const PartnerCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.badgeText,
    required this.rating,
    required this.location,
    this.avatarUrl,
  });

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return "U";
    final parts = fullName.trim().split(" ");
    String initials = "";
    int numWords = parts.length > 2 ? 2 : parts.length;
    for (var i = 0; i < numWords; i++) {
      if (parts[i].isNotEmpty) {
        initials += parts[i][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: 310,
      margin: const EdgeInsets.only(right: 20, bottom: 8, top: 4),
      child: HoverableCard(
        borderColor: const Color(0xff006565),
        borderRadius: 24.0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff006565).withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(avatarUrl!),
                        backgroundColor: Colors.transparent,
                      ),
                    )
                  : CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xffe5f7f7),
                      child: Text(
                        _getInitials(name),
                        style: const TextStyle(
                          color: Color(0xff006565),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffe5f7f7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xff006565),
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "RATING",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.grey.shade200,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "LOCATION",
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    showInvitePartnershipDialog(context, name);
                  },
                  child: const Text(
                    "Invite for Partnership",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showInvitePartnershipDialog(BuildContext context, String partnerName) {
  showDialog(
    context: context,
    builder: (context) => InvitePartnershipDialog(partnerName: partnerName),
  );
}

class InvitePartnershipDialog extends StatefulWidget {
  final String partnerName;

  const InvitePartnershipDialog({
    super.key,
    required this.partnerName,
  });

  @override
  State<InvitePartnershipDialog> createState() =>
      _InvitePartnershipDialogState();
}

class _InvitePartnershipDialogState extends State<InvitePartnershipDialog> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text:
          "Hi, I'm interested in partnering with you for our upcoming trade campaign. Let's discuss how we can collaborate.",
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Invite for Partnership",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Send a collaboration request to this partner.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "MESSAGE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type your message here...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xff006565), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff006565),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_messageController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please write a message first."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Collaboration request sent to ${widget.partnerName}!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      "Send Invitation",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
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

void showQuoteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const SendQuotationDialog(),
  );
}

class SendQuotationDialog extends StatefulWidget {
  const SendQuotationDialog({super.key});

  @override
  State<SendQuotationDialog> createState() => _SendQuotationDialogState();
}

class _SendQuotationDialogState extends State<SendQuotationDialog> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _fileName;

  @override
  void dispose() {
    _messageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Send Quotation",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Provide your proposal details to the buyer.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "QUOTATION MESSAGE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe your offer...",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xff006565), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "PROPOSED DELIVERY DATE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xff006565),
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _dateController.text =
                          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "dd-mm-yyyy",
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      color: Colors.black87, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xff006565), width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "UPLOAD QUOTATION FILE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _fileName ??= "quotation_draft.pdf";
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: Colors.grey.shade300,
                    borderRadius: 12.0,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _fileName == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file_rounded,
                                size: 32,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Click to upload PDF or DOCX",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: Colors.redAccent,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _fileName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close_rounded,
                                    color: Colors.grey.shade600),
                                onPressed: () {
                                  setState(() {
                                    _fileName = null;
                                  });
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff006565),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (_messageController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Please describe your offer first."),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Quotation sent successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        "Send Quote",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
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
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0.0, metric.length);
        dashPath.addPath(
          metric.extractPath(distance, end),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.borderRadius != borderRadius;
  }
}

void showContactBuyerDialog(BuildContext context, [String? buyerName]) {
  showDialog(
    context: context,
    builder: (context) => ContactBuyerDialog(buyerName: buyerName),
  );
}

class ContactBuyerDialog extends StatefulWidget {
  final String? buyerName;

  const ContactBuyerDialog({
    super.key,
    this.buyerName,
  });

  @override
  State<ContactBuyerDialog> createState() => _ContactBuyerDialogState();
}

class _ContactBuyerDialogState extends State<ContactBuyerDialog> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.buyerName ?? "Jane Doe";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contact Buyer",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                children: [
                  const TextSpan(text: "Messaging: "),
                  TextSpan(
                    text: displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff006565),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "MESSAGE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type your message here...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xff006565), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff006565),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_messageController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please write a message first."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Message sent to $displayName successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      "Send Message",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
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



class DoughnutChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final String centerLabel;
  final String centerValue;

  const DoughnutChart({
    super.key,
    required this.values,
    required this.colors,
    this.centerLabel = "Total",
    required this.centerValue,
  });

  @override
  Widget build(BuildContext context) {
    double total = values.fold(0.0, (sum, item) => sum + item);
    List<double> percentages = [];
    if (total > 0) {
      percentages = values.map((v) => v / total).toList();
    } else {
      percentages = values.map((_) => 0.0).toList();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: DoughnutChartPainter(
              percentages: percentages,
              colors: colors,
              strokeWidth: 14.0,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              centerValue,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff006565),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              centerLabel,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DoughnutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;
  final double strokeWidth;

  DoughnutChartPainter({
    required this.percentages,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -3.1415926535 / 2; // start from top

    // Draw background track
    final Paint trackPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    for (int i = 0; i < percentages.length; i++) {
      if (percentages[i] <= 0) continue;
      final double sweepAngle = percentages[i] * 2 * 3.1415926535;

      final Paint paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw segment
      canvas.drawArc(rect, startAngle + 0.04, sweepAngle - 0.08, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DoughnutChartPainter oldDelegate) => true;
}
