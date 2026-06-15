import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import '../screens/product_management_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState
    extends State<SellerDashboardScreen> {

  int selectedIndex = 0;
  double salesToday = 0.0;
  int pendingOrdersCount = 0;
  int lowStockCount = 0;
  List<dynamic> recentOrders = [];
  bool isLoading = true;

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
        if (mounted) {
          setState(() {
            salesToday = double.tryParse(data['sales_today']?.toString() ?? '0') ?? 0.0;
            pendingOrdersCount = int.tryParse(data['pending_orders']?.toString() ?? '0') ?? 0;
            lowStockCount = int.tryParse(data['low_stock']?.toString() ?? '0') ?? 0;
          });
        }
      }

      // 2. Fetch recent orders
      final ordersResponse = await db.getData({
        'action': 'get_recent_orders',
      }, endpoint: 'new_apis/ecommerce_dashboard_API.php');

      if (ordersResponse['success'] == true) {
        if (mounted) {
          setState(() {
            recentOrders = ordersResponse['data'] ?? [];
          });
        }
      }
    } catch (e) {
      print("Error fetching seller dashboard data: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff006565),
        onPressed: _showFabOptions,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff006565),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
          if (value == 1) {
            Navigator.pushNamed(context, '/admin/seller_orders');
          } else if (value == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductManagementScreen(initialTab: 0),
              ),
            );
          } else if (value == 3) {
            Navigator.pushNamed(context, '/marketplace_modules');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Explore",
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xff006565),
          onRefresh: _fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    if (Navigator.canPop(context)) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const CircleAvatar(
                      radius: 22,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        "comm-Unity Seller",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff006565),
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {},
                    ),

                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "Welcome Seller",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff006565),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Here's what's happening with your store today.",
                ),

                const SizedBox(height: 24),

                isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006565)),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            SellerStatCard(
                              title: "Sales Today",
                              value: "\$${salesToday.toStringAsFixed(2)}",
                              subtitle: salesToday > 0 ? "Active Sales" : "No sales yet",
                              positive: salesToday > 0,
                            ),
                            const SizedBox(width: 12),
                            SellerStatCard(
                              title: "Pending Orders",
                              value: "$pendingOrdersCount",
                              subtitle: pendingOrdersCount > 0 ? "Action Required" : "No pending",
                              positive: pendingOrdersCount == 0,
                            ),
                            const SizedBox(width: 12),
                            SellerStatCard(
                              title: "Low Stock",
                              value: "$lowStockCount",
                              subtitle: lowStockCount > 0 ? "Items Alert" : "Good stock",
                              positive: lowStockCount == 0,
                            ),
                          ],
                        ),
                      ),

                const SizedBox(height: 24),

                const Text(
                  "Product Management",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff006565),
                  ),
                ),

                const SizedBox(height: 16),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    ProductActionCard(
                      icon: Icons.inventory_2,
                      title: "Manage Listings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductManagementScreen(initialTab: 0),
                          ),
                        );
                      },
                    ),
                    ProductActionCard(
                      icon: Icons.corporate_fare,
                      title: "B2B Catalog",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductManagementScreen(initialTab: 1),
                          ),
                        );
                      },
                    ),
                    ProductActionCard(
                      icon: Icons.storefront,
                      title: "B2C Store",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductManagementScreen(initialTab: 0),
                          ),
                        );
                      },
                    ),
                    ProductActionCard(
                      icon: Icons.layers,
                      title: "Combo Packages",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductManagementScreen(initialTab: 2),
                          ),
                        );
                      },
                    ),
                    const ProductActionCard(
                      icon: Icons.branding_watermark,
                      title: "Branding",
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Recent Orders",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff006565),
                  ),
                ),

                const SizedBox(height: 16),

                isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006565)),
                          ),
                        ),
                      )
                    : recentOrders.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                "No recent orders",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Column(
                            children: recentOrders.map((order) {
                              final orderId = "#ORD-${order['id'] ?? ''}";
                              final total = double.tryParse(order['total']?.toString() ?? '0') ?? 0.0;
                              final status = order['status'] ?? 'Processing';
                              final isDelivered = status == 'Delivered';
                              return OrderTile(
                                orderId: orderId,
                                amount: "\$${total.toStringAsFixed(2)}",
                                items: order['product_title']?.toString() ?? '1 item',
                                status: status,
                                delivered: isDelivered,
                              );
                            }).toList(),
                          ),

                const SizedBox(height: 30),

              const Text(
                "Ecosystem Explorer",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff006565),
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: const [

                  EcosystemCard(
                    icon: Icons.groups,
                    title: "Partners",
                  ),

                  EcosystemCard(
                    icon: Icons.volunteer_activism,
                    title: "Charity",
                  ),

                  EcosystemCard(
                    icon: Icons.delivery_dining,
                    title: "Delivery",
                  ),

                  EcosystemCard(
                    icon: Icons.inventory,
                    title: "Logistics",
                  ),

                  EcosystemCard(
                    icon: Icons.handshake,
                    title: "Affiliate",
                  ),

                  EcosystemCard(
                    icon: Icons.analytics,
                    title: "Market Trends",
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    ),
  );
}

  void _showFabOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ListTile(
                leading: const Icon(Icons.corporate_fare),
                title: const Text("List B2B Product"),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.storefront),
                title: const Text("List B2C Product"),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.layers),
                title: const Text("List Combo Product"),
                onTap: () {},
              ),

              ListTile(
                leading:
                    const Icon(Icons.branding_watermark),
                title:
                    const Text("Branding Opportunity"),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class SellerStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool positive;

  const SellerStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.positive,
  });

  @override
  State<SellerStatCard> createState() => _SellerStatCardState();
}

class _SellerStatCardState extends State<SellerStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.positive ? Colors.green : Colors.orange;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 260,
        padding: const EdgeInsets.all(18),
        transform: Matrix4.translationValues(0, _isHovered ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusColor.withAlpha(_isHovered ? 200 : 80),
            width: _isHovered ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_isHovered ? 18 : 10),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
            BoxShadow(
              color: const Color(0xff006565).withAlpha(_isHovered ? 12 : 6),
              blurRadius: _isHovered ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            const Spacer(),
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.subtitle,
              style: TextStyle(
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProductActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  State<ProductActionCard> createState() => _ProductActionCardState();
}

class _ProductActionCardState extends State<ProductActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xff006565).withAlpha(_isHovered ? 80 : 0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_isHovered ? 18 : 10),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
            BoxShadow(
              color: const Color(0xff006565).withAlpha(_isHovered ? 12 : 6),
              blurRadius: _isHovered ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 40,
                    color: const Color(0xff006565),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final String orderId;
  final String amount;
  final String items;
  final String status;
  final bool delivered;

  const OrderTile({
    super.key,
    required this.orderId,
    required this.amount,
    required this.items,
    required this.status,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              delivered ? Colors.green : Colors.orange,
          child: Icon(
            delivered
                ? Icons.local_shipping
                : Icons.sync_alt,
            color: Colors.white,
          ),
        ),
        title: Text(orderId),
        subtitle: Text("$items • $amount"),
        trailing: Chip(
          label: Text(status),
        ),
      ),
    );
  }
}

class EcosystemCard extends StatefulWidget {
  final IconData icon;
  final String title;

  const EcosystemCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  State<EcosystemCard> createState() => _EcosystemCardState();
}

class _EcosystemCardState extends State<EcosystemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xff006565).withAlpha(_isHovered ? 80 : 0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_isHovered ? 18 : 10),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 12 : 6),
            ),
            BoxShadow(
              color: const Color(0xff006565).withAlpha(_isHovered ? 12 : 6),
              blurRadius: _isHovered ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                size: 40,
                color: const Color(0xff006565),
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
