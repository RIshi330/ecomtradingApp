import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/screens/promotions_payment_modal.dart';

// Package Model representing the promotional offerings
class PromoPackage {
  final String title;
  final String seller;
  final String sellerTitle;
  final double rating;
  final int reviews;
  final String reach;
  final String cvr;
  final String impressions;
  final String orders;
  final String roi;
  final String retention;
  final double price;
  final String priceUnit;
  final String category;
  final String image;
  final bool isFeatured;
  final bool isLive;
  final bool isLimited;

  PromoPackage({
    required this.title,
    required this.seller,
    required this.sellerTitle,
    required this.rating,
    required this.reviews,
    required this.reach,
    required this.cvr,
    required this.impressions,
    required this.orders,
    required this.roi,
    required this.retention,
    required this.price,
    required this.priceUnit,
    required this.category,
    required this.image,
    this.isFeatured = false,
    this.isLive = false,
    this.isLimited = false,
  });
}

class PromotionalPackagesScreen extends StatefulWidget {
  final bool isEmbedded;
  const PromotionalPackagesScreen({super.key, this.isEmbedded = false});

  @override
  State<PromotionalPackagesScreen> createState() => _PromotionalPackagesScreenState();
}

class _PromotionalPackagesScreenState extends State<PromotionalPackagesScreen> {
  final searchController = TextEditingController();
  String selectedCategory = "All";
  bool _isLoadingPackages = true;
  List<PromoPackage> packages = [];

  final List<String> categories = ["All", "Social Media", "Influencer", "Search Ads", "Email"];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final db = Database();
      final response = await db.getData({
        'action': 'get_packages',
        'status': '1',
      }, endpoint: 'new_apis/promotion_package_api.php');

      if (response['success'] == true) {
        final List<dynamic> list = response['data'] ?? [];
        final List<PromoPackage> loaded = [];
        for (var item in list) {
          final badges = List<String>.from(item['badges'] ?? []);
          loaded.add(PromoPackage(
            title: item['name']?.toString() ?? 'Promotion Package',
            seller: "Official Admin",
            sellerTitle: "Verified Partner",
            rating: 4.8,
            reviews: 120 + (item['orders'] as int? ?? 0),
            reach: "${item['duration'] ?? '7 days'} promotion duration",
            cvr: "5.4%",
            impressions: item['impressions'] != 0 ? "${item['impressions']}" : "15k+",
            orders: "${item['orders'] ?? 0}+",
            roi: "4.2x",
            retention: "92%",
            price: (item['price'] as num? ?? 0.0).toDouble(),
            priceUnit: "/camp.",
            category: badges.isNotEmpty ? badges.first : "Social Media",
            image: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500&auto=format&fit=crop",
            isFeatured: badges.contains("Featured"),
            isLive: true,
            isLimited: badges.contains("Trending"),
          ));
        }

        setState(() {
          packages = loaded;
          _isLoadingPackages = false;
        });
      } else {
        _loadStaticPackages();
      }
    } catch (e) {
      _loadStaticPackages();
    }
  }

  void _loadStaticPackages() {
    setState(() {
      packages = [
        PromoPackage(
          title: "Instagram Growth Blast",
          seller: "Digital Boost Pro",
          sellerTitle: "Top Seller",
          rating: 4.9,
          reviews: 1200,
          reach: "10k+ Founders reached",
          cvr: "4.2%",
          impressions: "250k",
          orders: "480+",
          roi: "3.5x",
          retention: "88%",
          price: 4999,
          priceUnit: "/camp.",
          category: "Social Media",
          image: "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=500&auto=format&fit=crop",
          isLive: true,
          isFeatured: true,
        ),
        PromoPackage(
          title: "LinkedIn CXO Network",
          seller: "B2B Connect",
          sellerTitle: "Expert Seller",
          rating: 4.7,
          reviews: 850,
          reach: "2k+ Decision makers reached",
          cvr: "8.1%",
          impressions: "15k",
          orders: "95+",
          roi: "5.2x",
          retention: "94%",
          price: 12500,
          priceUnit: "/ad set",
          category: "Influencer",
          image: "https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=500&auto=format&fit=crop",
          isLimited: true,
        ),
        PromoPackage(
          title: "Twitter Tech Surge",
          seller: "Viral Labs",
          sellerTitle: "New Seller",
          rating: 4.5,
          reviews: 210,
          reach: "50k+ Impressions guaranteed",
          cvr: "2.4%",
          impressions: "60k",
          orders: "1.2k+",
          roi: "1.8x",
          retention: "75%",
          price: 3499,
          priceUnit: "/camp.",
          category: "Social Media",
          image: "https://images.unsplash.com/photo-1611605698335-8b15d27e03f9?w=500&auto=format&fit=crop",
          isLive: true,
        ),
      ];
      _isLoadingPackages = false;
    });
  }

  List<PromoPackage> get filteredPackages {
    return packages.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
          p.seller.toLowerCase().contains(searchController.text.toLowerCase());
      final matchesCategory = selectedCategory == "All" || p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff006565);

    return Scaffold(
      backgroundColor: const Color(0xfff9f9ff),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Promo Market", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: "Search packages...",
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: primaryColor),
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Category Scroll Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Packages List
          Expanded(
            child: _isLoadingPackages
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : filteredPackages.isEmpty
                    ? const Center(
                        child: Text("No packages found", style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                    itemCount: filteredPackages.length,
                    itemBuilder: (context, index) {
                      final pkg = filteredPackages[index];
                      return _buildPackageCard(pkg);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(PromoPackage pkg) {
    const primaryColor = Color(0xff006565);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tags & Fav button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (pkg.isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Live",
                          style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (pkg.isLive) const SizedBox(width: 6),
                    if (pkg.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Featured",
                          style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (pkg.isLimited)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Limited",
                          style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const Icon(Icons.favorite_border, color: Colors.grey),
              ],
            ),
          ),

          // Seller Profile Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: const NetworkImage("https://i.pravatar.cc/150?img=47"),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pkg.seller, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(pkg.sellerTitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        pkg.rating.toString(),
                        style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Package Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.groups, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(pkg.reach, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Performance Stats Bento
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfff6f6f9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CVR", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(pkg.cvr, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("IMPRESSIONS", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(pkg.impressions, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ORDERS", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(pkg.orders, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),

          // Footer Action & Price
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "₹${pkg.price.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                    ),
                    Text(
                      pkg.priceUnit,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PromotionalPackageDetailsScreen(package: pkg),
                          ),
                        );
                      },
                      child: const Text("Details", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        int packageId = 1;
                        if (pkg.title.contains("LinkedIn")) {
                          packageId = 2;
                        } else if (pkg.title.contains("Twitter")) {
                          packageId = 3;
                        }
                        _processPayment(context, pkg, packageId);
                      },
                      child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, PromoPackage pkg, int packageId) async {
    final orderId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromotionsPaymentModal(
        packageId: packageId,
        packageTitle: pkg.title,
        totalRawPrice: pkg.price,
      ),
    );

    if (orderId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubmitCampaignContentScreen(
            package: pkg,
            orderId: orderId,
          ),
        ),
      );
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filters", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            selectedCategory = "All";
                          });
                          setState(() {});
                        },
                        child: const Text("Reset", style: TextStyle(color: Color(0xff006565))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: const Color(0xff006565),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        onSelected: (selected) {
                          setModalState(() {
                            selectedCategory = cat;
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff006565),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


class PromotionalPackageDetailsScreen extends StatefulWidget {
  final PromoPackage package;
  const PromotionalPackageDetailsScreen({super.key, required this.package});

  @override
  State<PromotionalPackageDetailsScreen> createState() => _PromotionalPackageDetailsScreenState();
}

class _PromotionalPackageDetailsScreenState extends State<PromotionalPackageDetailsScreen> {
  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, PromoPackage pkg, int packageId) async {
    final orderId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromotionsPaymentModal(
        packageId: packageId,
        packageTitle: pkg.title,
        totalRawPrice: pkg.price,
      ),
    );

    if (orderId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubmitCampaignContentScreen(
            package: pkg,
            orderId: orderId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    const primaryColor = Color(0xff006565);

    return Scaffold(
      backgroundColor: const Color(0xfff9f9ff),
      appBar: AppBar(
        title: const Text("Package Details", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Visual
            Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                image: DecorationImage(
                  image: NetworkImage(package.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      children: [
                        if (package.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Live", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        if (package.isLive) const SizedBox(width: 6),
                        if (package.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Featured", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

            // Package Title & Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(package.category, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price & Buy Block
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text("₹${package.price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryColor)),
                          Text(package.priceUnit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Text("Includes strategy & creation", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                   ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      int packageId = 1;
                      if (package.title.contains("LinkedIn")) {
                        packageId = 2;
                      } else if (package.title.contains("Twitter")) {
                        packageId = 3;
                      }
                      _processPayment(context, package, packageId);
                    },
                    child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Performance Metrics Bento Grid
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Performance Metrics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(Icons.trending_up, package.cvr, "Average CVR", primaryColor),
                _buildMetricCard(Icons.visibility, package.impressions, "Guaranteed Impressions", primaryColor),
                _buildMetricCard(Icons.shopping_cart, package.orders, "Orders Generated", primaryColor),
                _buildMetricCard(Icons.rocket_launch, package.roi, "Average ROI", primaryColor),
                _buildMetricCard(Icons.group, package.retention, "User Retention", primaryColor),
                _buildMetricCard(Icons.hub, package.reach.split(" ")[0], "Founders Reached", primaryColor),
              ],
            ),
            const SizedBox(height: 24),

            // Sold By
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Sold by", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: const NetworkImage("https://i.pravatar.cc/150?img=47"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(package.seller, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: primaryColor, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(package.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("(${package.reviews} reviews)", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(width: 8),
                            const Text("Top Seller", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String value, String label, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff1f2ff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: primaryColor, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}


class SubmitCampaignContentScreen extends StatefulWidget {
  final PromoPackage package;
  final String orderId;
  const SubmitCampaignContentScreen({super.key, required this.package, required this.orderId});

  @override
  State<SubmitCampaignContentScreen> createState() => _SubmitCampaignContentScreenState();
}

class _SubmitCampaignContentScreenState extends State<SubmitCampaignContentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Text inputs
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedProduct = "Select Product";
  String _selectedCta = "Apply Now";
  String? _uploadedFilePath;
  String? _uploadedFileName;

  final List<String> _products = [
    "Select Product",
    "Home Decor Collection",
    "Eco-Friendly Essentials",
    "Minimalist Tech Gear"
  ];

  final List<String> _ctas = [
    "Apply Now",
    "Shop Now",
    "Learn More",
    "Get Started"
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate titles for nice demo flow
    _titleController.text = "Launch Deal Promotion";
    _descController.text = "Promote our new minimalist gear and eco essentials to local tech founders.";
    _websiteController.text = "https://serenecommerce.com";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _websiteController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _uploadedFilePath = result.files.single.path;
        _uploadedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff006565);

    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        title: const Text("Submit Campaign Content", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ORDER INFO", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Order ID: ",
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
                            children: [
                              TextSpan(text: "ORD${widget.orderId}", style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("ACTIVE", style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Package: ${widget.package.title} • 7 Posts • 3 Days",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Campaign Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CAMPAIGN DETAILS", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 16),
                    // Campaign Title Input
                    const Text("Campaign Title", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF4F3F3),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        hintText: "Enter campaign title",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) => v!.isEmpty ? "Campaign Title is required" : null,
                    ),
                    const SizedBox(height: 16),
                    // Description Input
                    const Text("Description", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      onChanged: (_) => setState(() {}),
                      maxLines: 4,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF4F3F3),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        hintText: "Describe your campaign goals and style",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Product Selection
                    const Text("Product", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedProduct,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF4F3F3),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _products.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedProduct = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Upload Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("UPLOAD CONTENT", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3F3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: _uploadedFilePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_uploadedFilePath!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: Colors.grey.shade600, size: 36),
                                  const SizedBox(height: 8),
                                  const Text("+ Add Content", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text("MP4, JPG or PNG up to 50MB", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. CTA & Links Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CTA & LINKS", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 16),
                    // CTA dropdown
                    const Text("Call to Action", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCta,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF4F3F3),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _ctas.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCta = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Landing page URL input
                    const Text("Website / Landing Page", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _websiteController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.link, color: Colors.grey),
                        fillColor: const Color(0xFFF4F3F3),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        hintText: "https://yourwebsite.com",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Instructions Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("INSTRUCTIONS FOR ADMIN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF4F3F3),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        hintText: "Any specific request or instruction for our team...",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 6. Realtime Live Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf0f4f4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text("LIVE PREVIEW", style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xffe5e2e1),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: _uploadedFilePath != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.file(
                                      File(_uploadedFilePath!),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(child: Icon(Icons.photo, color: Colors.grey, size: 48)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _titleController.text.isNotEmpty ? _titleController.text : "Campaign Title",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _descController.text.isNotEmpty ? _descController.text : "Campaign description will appear here.",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {},
                                    child: Text(_selectedCta, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
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
              const SizedBox(height: 40),

              // CTA buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Draft saved successfully!"), backgroundColor: primaryColor),
                        );
                      },
                      child: const Text("Save Draft", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submitCampaign,
                      child: const Text("Submit for Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _submitCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

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
        'action': 'submit_opp_response',
        'marketplace_id': '0',
        'request_id': widget.package.price.toString(),
        'order_id': widget.orderId,
        'description': _descController.text.trim(),
        'location': _websiteController.text.trim(),
        'budget': widget.package.price.toString(),
        'availability': _selectedProduct,
        'min_qty': '7',
        'max_qty': '3',
        'status': '1',
        'comment': _instructionsController.text.trim(),
        'attachments[]': _uploadedFileName ?? 'default_attachment.png',
      }, endpoint: 'new_apis/submit_content_api.php');

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading spinner
      setState(() => _isSubmitting = false);

      if (response['status'] == true || response['success'] == true) {
        _showSuccessDialog(context);
      } else {
        _showError(context, response['message'] ?? "Failed to submit campaign content");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading spinner
        setState(() => _isSubmitting = false);
      }
      _showError(context, "Error submitting campaign: $e");
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text("Campaign Submitted"),
          ],
        ),
        content: const Text(
          "Your campaign content has been submitted successfully to the administrator. The status will be updated soon.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xff006565)),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
