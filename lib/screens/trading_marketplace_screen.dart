import 'dart:convert';
import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../index.dart';

class MarketplaceItem {
  final String id;
  final String variantId;
  final String marketplaceId;
  final String title;
  final String subtitle;
  final String image;
  final String price;
  final String earning;
  final String category;
  bool selected;

  MarketplaceItem({
    required this.id,
    required this.variantId,
    required this.marketplaceId,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.price,
    required this.earning,
    required this.category,
    this.selected = false,
  });
}

class TradingMarketplaceScreen extends StatefulWidget {
  final bool isEmbedded;

  const TradingMarketplaceScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<TradingMarketplaceScreen> createState() =>
      _TradingMarketplaceScreenState();
}

class _TradingMarketplaceScreenState extends State<TradingMarketplaceScreen> {
  final TextEditingController searchController = TextEditingController();
  int currentIndex = 0;
  bool isLoading = false;
  List<MarketplaceItem> selectedItems = [];

  List<MarketplaceItem> b2cProducts = [];
  List<MarketplaceItem> b2bProducts = [];
  List<MarketplaceItem> servicesList = [];

  // Static high-fidelity mockup lists (fallbacks when API returns empty)
  final List<MarketplaceItem> mockB2C = [
    MarketplaceItem(
      id: "101",
      variantId: "201",
      marketplaceId: "5",
      title: "Premium Quartz Watch v2",
      subtitle: "Luxury Collection",
      image: "https://lh3.googleusercontent.com/aida-public/AB6AXuBKM-HOD7CEZuOQRaBSnnprakdb5jfGyqmmJECq7POhy6d5NKpaHC_y-ek8yBBumg73TLMklrwZZn5ZsSxm0qIr5Kx5-z-sSQODyqQWwnO0PH8n9X7s0npHxYeAjFtySFI5MnT6LWkQeV08CwyGtlVBtUpd1JdCqmS0N0vu7agaV4sxtZpRegj6SElLVlzwf-C_fB6Kst08nc-DmSkJm1o_u75yPcfXTdexG79qDYRnqDsKtsdU3K_Fkw",
      price: "₹1,200",
      earning: "₹96",
      category: "B2C",
    ),
    MarketplaceItem(
      id: "102",
      variantId: "202",
      marketplaceId: "5",
      title: "Acoustic Pro Headphones",
      subtitle: "Premium Audio",
      image: "https://lh3.googleusercontent.com/aida-public/AB6AXuAeiOjJG4iAcTtFJKWOL_0ugAMrhVhlA-kkLs79uUhLr2RIuKWmQ03RaAJdoJVbpIxM4WK7q815XXnGRFNiX_Gy9155Ac0pMXsYrLzuqdj58Kn_-lAv22lt6H7uK6gFAlmnUn1st3CA4zXuvA5wdTqqw0J-Aor06oj2S23ztm6EO9OlQRm0EVkhBikm_osA0AppuJABhtU_up_RtKI8RPpgtaqpvbgfJ-FteCxWS16qCjV2ankzX71ynA",
      price: "₹1,500",
      earning: "₹120",
      category: "B2C",
    ),
    MarketplaceItem(
      id: "103",
      variantId: "203",
      marketplaceId: "5",
      title: "Smart Hydration Bottle",
      subtitle: "Health Tech",
      image: "https://lh3.googleusercontent.com/aida-public/AB6AXuDHyy7m8qaZZLN2S8ig-q589RBaLCs-SAkdBjoi3LmNP40Y7fxiuKmO9GYk2hxaj6ORbZMWsNvaEdXN-Xn-Ob3lFL1JL-umulR9yREY5Asq8rWQ31dj_zUU5suMnw_ykrzLez8QbR1HDgUfjBSsxl3e-e7Lgd7Y7B6URHQbF-UR67NeOyneWCZccxqEO21naC_fUEpmbq-XSEFjVaE2g_KHHlHGAPBHagCG1egxjtWe-XaUZjtVOwGsTw",
      price: "₹1,000",
      earning: "₹80",
      category: "B2C",
    ),
  ];

  final List<MarketplaceItem> mockB2B = [
    MarketplaceItem(
      id: "301",
      variantId: "401",
      marketplaceId: "6",
      title: "Enterprise CRM",
      subtitle: "TechCorp Solutions",
      image: "",
      price: "₹25,000",
      earning: "₹2,000",
      category: "B2B",
    ),
    MarketplaceItem(
      id: "302",
      variantId: "402",
      marketplaceId: "6",
      title: "Cloud ERP Suite",
      subtitle: "SaaS Systems",
      image: "",
      price: "₹50,000",
      earning: "₹4,000",
      category: "B2B",
    ),
    MarketplaceItem(
      id: "303",
      variantId: "403",
      marketplaceId: "6",
      title: "Marketing Automation",
      subtitle: "GrowFast Digital",
      image: "",
      price: "₹15,000",
      earning: "₹1,200",
      category: "B2B",
    ),
  ];

  final List<MarketplaceItem> mockServices = [
    MarketplaceItem(
      id: "501",
      variantId: "0",
      marketplaceId: "16",
      title: "Affiliate Marketing Masterclass",
      subtitle: "12 Modules • Certify Pro",
      image: "",
      price: "₹999",
      earning: "₹200",
      category: "Service",
    ),
    MarketplaceItem(
      id: "502",
      variantId: "0",
      marketplaceId: "16",
      title: "Sales Funnel Optimization",
      subtitle: "8 Modules • Conversion Lab",
      image: "",
      price: "₹799",
      earning: "₹160",
      category: "Service",
    ),
    MarketplaceItem(
      id: "503",
      variantId: "0",
      marketplaceId: "16",
      title: "Influencer Growth Program",
      subtitle: "15 Modules • Media Academy",
      image: "",
      price: "₹1,499",
      earning: "₹300",
      category: "Service",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch real products from marketplace_trading_API.php
    _fetchItems();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Triggers search fetch after user types
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Database().getData({
        'keyword': searchController.text,
      }, endpoint: 'new_apis/marketplace_trading_API.php');

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];
        final List<MarketplaceItem> fetchedB2C = [];
        final List<MarketplaceItem> fetchedB2B = [];
        final List<MarketplaceItem> fetchedServices = [];

        // Parse ORG products (B2C)
        final org = data['org_products'] as List?;
        if (org != null) {
          for (var item in org) {
            fetchedB2C.add(
              MarketplaceItem(
                id: item['product_id']?.toString() ?? '',
                variantId: item['variant_id']?.toString() ?? '',
                marketplaceId: '5',
                title: item['title']?.toString() ?? '',
                subtitle: item['seller']?.toString() ?? '',
                image: item['image']?.toString() ?? '',
                price: '₹${item['price']}',
                earning: '₹${item['commission'] ?? item['upgradedcommission'] ?? '0'}',
                category: item['category']?.toString() ?? 'B2C',
                selected: item['is_selected'] == true,
              ),
            );
          }
        }

        // Parse BTB products (B2B)
        final btb = data['btb_products'] as List?;
        if (btb != null) {
          for (var item in btb) {
            fetchedB2B.add(
              MarketplaceItem(
                id: item['product_id']?.toString() ?? '',
                variantId: item['variant_id']?.toString() ?? '',
                marketplaceId: '6',
                title: item['title']?.toString() ?? '',
                subtitle: item['seller']?.toString() ?? '',
                image: item['image']?.toString() ?? '',
                price: '₹${item['price']}',
                earning: '₹${item['commission'] ?? item['upgraded_commission'] ?? '0'}',
                category: item['category']?.toString() ?? 'B2B',
                selected: item['is_selected'] == true,
              ),
            );
          }
        }

        // Parse Services
        final services = data['services'] as List?;
        if (services != null) {
          for (var item in services) {
            fetchedServices.add(
              MarketplaceItem(
                id: item['service_id']?.toString() ?? '',
                variantId: '0',
                marketplaceId: '16',
                title: item['name']?.toString() ?? '',
                subtitle: item['seller']?.toString() ?? '',
                image: item['image']?.toString() ?? '',
                price: '₹${item['price']}',
                earning: '₹${item['commission'] ?? item['upgraded_commission'] ?? '0'}',
                category: item['category']?.toString() ?? 'Service',
                selected: item['is_selected'] == true,
              ),
            );
          }
        }

        setState(() {
          b2cProducts = fetchedB2C.isNotEmpty ? fetchedB2C : mockB2C;
          b2bProducts = fetchedB2B.isNotEmpty ? fetchedB2B : mockB2B;
          servicesList = fetchedServices.isNotEmpty ? fetchedServices : mockServices;

          // Sync selection array
          selectedItems.clear();
          selectedItems.addAll(b2cProducts.where((e) => e.selected));
          selectedItems.addAll(b2bProducts.where((e) => e.selected));
          selectedItems.addAll(servicesList.where((e) => e.selected));
        });
      } else {
        // Fallback to static mocklists if API call fails
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error fetching marketplace items: $e');
      _loadMockData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMockData() {
    setState(() {
      b2cProducts = mockB2C;
      b2bProducts = mockB2B;
      servicesList = mockServices;

      selectedItems.clear();
      selectedItems.addAll(b2cProducts.where((e) => e.selected));
      selectedItems.addAll(b2bProducts.where((e) => e.selected));
      selectedItems.addAll(servicesList.where((e) => e.selected));
    });
  }

  Future<void> saveSelectedItems() async {
    setState(() => isLoading = true);
    try {
      // items format is JSON array of strings: "pid-vid-marketplaceId"
      final itemIds = selectedItems
          .map((item) => "${item.id}-${item.variantId}-${item.marketplaceId}")
          .toList();

      final response = await Database().getData({
        'keyword': searchController.text,
        'selectItems': 'true',
        'items': jsonEncode(itemIds),
      }, endpoint: 'new_apis/marketplace_trading_API.php');

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Items successfully selected'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh selection states from backend database
        await _fetchItems();

        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text("Go to Promoted Products?", style: TextStyle(fontWeight: FontWeight.bold)),
                content: const Text("Your items have been selected successfully. Do you want to view them in your Promoted Products list?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("No", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, AppRoutes.selectedItems);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Yes", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to select items'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving items: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void toggleSelection(MarketplaceItem item) {
    setState(() {
      item.selected = !item.selected;
      if (item.selected) {
        if (!selectedItems.any((e) => e.id == item.id && e.marketplaceId == item.marketplaceId)) {
          selectedItems.add(item);
        }
      } else {
        selectedItems.removeWhere((e) => e.id == item.id && e.marketplaceId == item.marketplaceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (!widget.isEmbedded) buildTopBar(),
                buildSearchBar(),
                buildMembershipBanner(),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                buildB2CSection(),
                buildB2BSection(),
                buildServicesSection(),
                buildComboPackSection(),
                buildMembershipPlans(),
                buildTrainingSection(),
                buildDonationSection(),
                buildEventsSection(),
                const SizedBox(height: 180),
              ],
            ),
          ),
        ),
        if (selectedItems.isNotEmpty) buildSelectionBar(),
      ],
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xffFEF7FF),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFEF7FF),
      bottomNavigationBar: buildBottomNav(),
      body: content,
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Marketplace",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Search high-margin products...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: openFilterSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }

  Widget buildMembershipBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffE8DEF9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuAst1jWbJ4HFNmYu4UgzP5IJAZ8TIHukvFrQ6NWCEG483mNxR5NdiR9iCRa0MG1JZpvedDYxQIJfSLDDTrUtifxlgZLgoojYgMSCULTIIflYD9eqMfB2_fXZFT9iaBrefL9hkIUyp2JIVx_i35hDeIS0UHTb3FpQDLbyBdgGdBxa46NV08al_AkULT3dlffqDSPBvDZZJBOxWj7zh2TyXFISpHUKBulrA7wAhvjxz_uRCt2plLff9O4Fw",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.deepPurple.shade100,
                    child: const Icon(Icons.business, size: 40, color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enterprise Suite",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("By TechCorp Solutions"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildInfoRow("MOQ", "5 Licenses"),
          buildInfoRow("Commission", "₹2,000 (8%)"),
          buildInfoRow("Starting Price", "₹25,000"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text("Share & Earn"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildB2CSection() {
    if (b2cProducts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "B2C Products",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("View All"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 360,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: b2cProducts.length,
            itemBuilder: (context, index) {
              return buildProductCard(b2cProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget buildProductCard(MarketplaceItem item) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: item.image.isNotEmpty
                    ? Image.network(
                        item.image,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 180,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image, size: 60, color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image, size: 60, color: Colors.grey),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Earn ${item.earning}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Checkbox(
                  value: item.selected,
                  activeColor: Colors.deepPurple,
                  onChanged: (_) {
                    toggleSelection(item);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  item.price,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text("Share & Earn"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildB2BSection() {
    if (b2bProducts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "B2B Solutions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: b2bProducts.length,
            itemBuilder: (context, index) {
              return buildB2BCard(b2bProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget buildB2BCard(MarketplaceItem item) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.business_center,
                size: 60,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              Text(
                item.price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Commission ${item.earning}",
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Promote"),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Checkbox(
              value: item.selected,
              activeColor: Colors.deepPurple,
              onChanged: (_) {
                toggleSelection(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServicesSection() {
    if (servicesList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Services & Opportunities",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: servicesList.length,
          itemBuilder: (context, index) {
            return buildServiceCard(servicesList[index]);
          },
        ),
      ],
    );
  }

  Widget buildServiceCard(MarketplaceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.deepPurple.shade50,
                backgroundImage: item.image.isNotEmpty ? NetworkImage(item.image) : null,
                child: item.image.isEmpty
                    ? const Icon(Icons.school, size: 30, color: Colors.deepPurple)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "Earn: ${item.earning}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Checkbox(
                value: item.selected,
                activeColor: Colors.deepPurple,
                onChanged: (_) {
                  toggleSelection(item);
                },
              ),
              const SizedBox(height: 8),
              Text(
                item.price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSelectionBar() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: widget.isEmbedded ? 20 : 90,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                selectedItems.length.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Selected Items",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${selectedItems.length} products selected",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: saveSelectedItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Add To My List"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildComboPackSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff7C3AED),
              Color(0xffA855F7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Combo Promotion Pack",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Promote 5 products together and boost conversions",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(
                  child: Text(
                    "Price",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  "₹4,999",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                ),
                child: const Text("Buy Combo"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMembershipPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Membership Plans",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildMembershipCard(
          "Silver",
          "₹999",
          [
            "5 Products",
            "Basic Analytics",
            "Email Support",
          ],
        ),
        buildMembershipCard(
          "Gold",
          "₹2,499",
          [
            "20 Products",
            "Advanced Analytics",
            "Priority Support",
          ],
        ),
        buildMembershipCard(
          "Platinum",
          "₹4,999",
          [
            "Unlimited Products",
            "Dedicated Manager",
            "Premium Visibility",
          ],
        ),
      ],
    );
  }

  Widget buildMembershipCard(
    String title,
    String price,
    List<String> features,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              color: Colors.deepPurple,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Text(feature),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Choose Plan"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTrainingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Training & Skills",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildTrainingCard(
          "Affiliate Marketing Masterclass",
          "12 Modules",
          "₹999",
        ),
        buildTrainingCard(
          "Sales Funnel Optimization",
          "8 Modules",
          "₹799",
        ),
        buildTrainingCard(
          "Influencer Growth Program",
          "15 Modules",
          "₹1,499",
        ),
      ],
    );
  }

  Widget buildTrainingCard(
    String title,
    String modules,
    String price,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.school, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(modules),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 40),
                ),
                onPressed: () {},
                child: const Text("Enroll"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDonationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Donation Projects",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildDonationCard(
          "Education For All",
          "Raised ₹1.2L",
        ),
        buildDonationCard(
          "Clean Water Initiative",
          "Raised ₹90K",
        ),
      ],
    );
  }

  Widget buildDonationCard(
    String title,
    String raised,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const LinearProgressIndicator(
            value: .65,
            color: Colors.deepPurple,
            backgroundColor: Color(0xffE8DEF9),
          ),
          const SizedBox(height: 10),
          Text(raised),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Donate"),
          ),
        ],
      ),
    );
  }

  Widget buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Upcoming Events",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildEventCard(
          "Affiliate Summit 2026",
          "12 Aug 2026",
        ),
        buildEventCard(
          "Creator Economy Meetup",
          "28 Aug 2026",
        ),
      ],
    );
  }

  Widget buildEventCard(
    String title,
    String date,
  ) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.event, color: Colors.white),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: ElevatedButton(
        onPressed: () {},
        child: const Text("Register"),
      ),
    );
  }

  Widget buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: "Marketplace",
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
    );
  }

  void openFilterSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Marketplace Filters",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                items: const [
                  DropdownMenuItem(
                    value: "All",
                    child: Text("All Categories"),
                  ),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
