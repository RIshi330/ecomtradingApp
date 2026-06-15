import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/coupon_model.dart';
import '../core/theme/app_theme.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final searchController = TextEditingController();
  String searchQuery = "";
  int selectedFilter = 0;

  final filters = [
    "All",
    "Percentage",
    "Cashback",
    "Popular",
  ];

  final List<CouponModel> activeCoupons = const [
    CouponModel(
      title: "Super Saver Discount",
      code: "SAVE50",
      description: "Get 50% off on all B2C purchases",
      discount: "50% OFF",
      expiry: "Valid till 30 Jun 2026",
      type: "Percentage",
    ),
    CouponModel(
      title: "First Order Cashback",
      code: "WELCOME100",
      description: "Get ₹100 cashback on your first transaction",
      discount: "₹100 Cashback",
      expiry: "Valid till 31 Dec 2026",
      type: "Cashback",
    ),
    CouponModel(
      title: "Popular Combo Deal",
      code: "COMBO20",
      description: "Flat 20% off on premium combo packages",
      discount: "20% OFF",
      expiry: "Valid till 15 Jul 2026",
      type: "Popular",
    ),
    CouponModel(
      title: "Mega Sale Cashback",
      code: "MEGA500",
      description: "Flat ₹500 cashback on orders above ₹5000",
      discount: "₹500 Cashback",
      expiry: "Valid till 20 Aug 2026",
      type: "Cashback",
    ),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search Coupons",
          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget buildFilters() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.secondaryContainer,
              onSelected: (_) {
                setState(() {
                  selectedFilter = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Coupons Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try changing your search or filter",
          ),
        ],
      ),
    );
  }

  List<CouponModel> get filteredCoupons {
    List<CouponModel> list = activeCoupons.where((coupon) {
      return coupon.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          coupon.code.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (selectedFilter > 0) {
      final filterType = filters[selectedFilter];
      list = list.where((coupon) => coupon.type.toLowerCase() == filterType.toLowerCase()).toList();
    }
    return list;
  }

  Widget buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: const Row(
        children: [
          Icon(Icons.stars, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mega Summer Sale!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Use code SUM20 for an extra 20% off all listings",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCouponCard(CouponModel coupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.outline.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 100,
              color: AppTheme.primary,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    coupon.discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    coupon.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          coupon.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        coupon.expiry,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.primary),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: coupon.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Coupon code '${coupon.code}' copied!"),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget buildAvailableTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildSearchBar(),
              buildFilters(),
              const SizedBox(height: 16),
              buildPromoBanner(),
            ],
          ),
        ),
        Expanded(
          child: filteredCoupons.isEmpty
              ? buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCoupons.length,
                  itemBuilder: (context, index) {
                    return buildCouponCard(
                      filteredCoupons[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildRewardsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium_outlined, size: 64, color: AppTheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "My Rewards",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text("You haven't claimed any exclusive rewards yet."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Offers & Coupons",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: "Available"),
            Tab(text: "My Rewards"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          buildAvailableTab(),
          buildRewardsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Shop",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Offers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
