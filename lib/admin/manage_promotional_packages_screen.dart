import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/admin/community_monetization_screen.dart';

class ManagePromotionalPackagesScreen extends StatefulWidget {
  final bool isEmbedded;
  const ManagePromotionalPackagesScreen({super.key, this.isEmbedded = false});

  @override
  State<ManagePromotionalPackagesScreen> createState() => _ManagePromotionalPackagesScreenState();
}

class _PromotionPackage {
  final int id;
  final String name;
  final String duration;
  final double price;
  final String? pricingType;
  final List<String> badges;
  final int orders;
  final double revenue;
  final int impressions;
  final int clicks;
  final List<String> audience;
  final List<String> interests;

  _PromotionPackage({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.pricingType,
    required this.badges,
    required this.orders,
    required this.revenue,
    required this.impressions,
    required this.clicks,
    required this.audience,
    required this.interests,
  });

  factory _PromotionPackage.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is Iterable) {
        return val.map((e) => e.toString()).toList();
      }
      if (val is String) {
        if (val.trim().isEmpty) return [];
        if (val.contains(',')) {
          return val.split(',').map((e) => e.trim()).toList();
        }
        return [val.trim()];
      }
      return [val.toString()];
    }

    return _PromotionPackage(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      pricingType: json['pricing_type']?.toString(),
      badges: parseList(json['badges']),
      orders: int.tryParse(json['orders']?.toString() ?? '0') ?? 0,
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0.0,
      impressions: int.tryParse(json['impressions']?.toString() ?? '0') ?? 0,
      clicks: int.tryParse(json['clicks']?.toString() ?? '0') ?? 0,
      audience: parseList(json['audience']),
      interests: parseList(json['interests']),
    );
  }
}

class _ManagePromotionalPackagesScreenState extends State<ManagePromotionalPackagesScreen> {
  List<_PromotionPackage> _packages = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPackages() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await Database().getData({
        'action': 'get_packages',
        'search': _searchQuery,
      }, endpoint: 'new_apis/promotion_package_api.php');

      if (!mounted) return;

      if (response['success'] == true && response['data'] != null) {
        final List listData = response['data'] is List ? response['data'] : [];
        setState(() {
          _packages = listData.map((item) => _PromotionPackage.fromJson(Map<String, dynamic>.from(item))).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message']?.toString() ?? 'Failed to load packages';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stats calculation
    final totalPackages = _packages.length;
    final activeOrders = _packages.fold<int>(0, (sum, p) => sum + p.orders);
    final totalImpressions = _packages.fold<int>(0, (sum, p) => sum + p.impressions);
    final totalRevenue = _packages.fold<double>(0.0, (sum, p) => sum + p.revenue);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: const Color(0xFFF9F9F9),
              elevation: 0,
              title: const Text(
                "Promotional Packages",
                style: TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold),
              ),
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            ),
      body: RefreshIndicator(
        onRefresh: _fetchPackages,
        color: const Color(0xFF006565),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and Filter Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                        _fetchPackages();
                      },
                      decoration: InputDecoration(
                        hintText: "Search packages...",
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF3E4949)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF006565), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBDC9C8)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Color(0xFF3E4949)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Statistics Slider Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatCard("Total Packages", totalPackages.toString(), Icons.layers_outlined, "12%"),
                    _buildStatCard("Active Orders", activeOrders.toString(), Icons.shopping_bag_outlined, "8%"),
                    _buildStatCard("Total Views", "${(totalImpressions / 1000).toStringAsFixed(1)}k", Icons.visibility_outlined, "24%"),
                    _buildStatCard("Revenue", "\$${(totalRevenue / 1000).toStringAsFixed(1)}k", Icons.payments_outlined, "3%"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Active Deployments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: Color(0xFF006565)),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                  ),
                )
              else if (_packages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No packages found.", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 170,
                  ),
                  itemCount: _packages.length,
                  itemBuilder: (context, index) {
                    final package = _packages[index];
                    return _buildPackageCard(package);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "manage_promo_packages_fab",
        onPressed: () {
          print("FAB: Navigating to CommunityMonetizationScreen...");
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => const CommunityMonetizationScreen(isEmbedded: false),
            ),
          ).then((_) => _fetchPackages());
        },
        backgroundColor: const Color(0xFF006565),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Create New Package",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, String percentage) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF006565), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 12),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(_PromotionPackage package) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "ACTIVE",
                    style: TextStyle(fontSize: 10, color: Color(0xFF008080), fontWeight: FontWeight.bold),
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
            const SizedBox(height: 8),
            Text(
              package.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCardMetric(Icons.favorite, package.clicks.toString()),
                const SizedBox(width: 16),
                _buildCardMetric(Icons.shopping_bag, package.orders.toString()),
                const SizedBox(width: 16),
                _buildCardMetric(Icons.percent, "15% Comm."),
              ],
            ),
            const Spacer(),
            const Divider(color: Color(0xFFBDC9C8), height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Created ${package.duration}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 24,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          color: const Color(0xFF006565),
                        ),
                        child: const Center(
                          child: Text(
                            "+4",
                            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 14),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            "https://i.pravatar.cc/100?img=12",
                            fit: BoxFit.cover,
                          ),
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
    );
  }

  Widget _buildCardMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF006565), size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
