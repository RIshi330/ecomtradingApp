// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../Database/Database.dart';
// import '../index.dart';
//
// class MarketplaceItem {
//   final String id;
//   final String variantId;
//   final String marketplaceId;
//   final String title;
//   final String subtitle;
//   final String image;
//   final String price;
//   final String earning;
//   final String category;
//   bool selected;
//
//   MarketplaceItem({
//     required this.id,
//     required this.variantId,
//     required this.marketplaceId,
//     required this.title,
//     required this.subtitle,
//     required this.image,
//     required this.price,
//     required this.earning,
//     required this.category,
//     this.selected = false,
//   });
// }
//
// class TradingMarketplaceScreen extends StatefulWidget {
//   final bool isEmbedded;
//
//   const TradingMarketplaceScreen({
//     super.key,
//     this.isEmbedded = false,
//   });
//
//   @override
//   State<TradingMarketplaceScreen> createState() =>
//       _TradingMarketplaceScreenState();
// }
//
// class _TradingMarketplaceScreenState extends State<TradingMarketplaceScreen>
//     with SingleTickerProviderStateMixin {
//   // ── Design Tokens ──────────────────────────────────────────────
//   static const Color primary = Color(0xFF006565);
//   static const Color primaryDark = Color(0xFF004848);
//   static const Color primaryLight = Color(0xFFE0F2F2);
//   static const Color accent = Color(0xFF00A878);
//   static const Color surface = Color(0xFFF7FAFA);
//   static const Color cardBg = Colors.white;
//   static const Color textPrimary = Color(0xFF0D1B1B);
//   static const Color textSecondary = Color(0xFF6B8080);
//   static const Color divider = Color(0xFFECF3F3);
//
//   final TextEditingController searchController = TextEditingController();
//   late TabController _tabController;
//
//   int currentIndex = 1;
//   bool isLoading = false;
//   List<MarketplaceItem> selectedItems = [];
//
//   List<MarketplaceItem> b2cProducts = [];
//   List<MarketplaceItem> b2bProducts = [];
//   List<MarketplaceItem> servicesList = [];
//   List<MarketplaceItem> trainingList = []; // populated immediately in initState below
//   List<MarketplaceItem> donationList = [];
//   List<MarketplaceItem> eventsList = [];
//   List<MarketplaceItem> membershipList = [];
//
//   // ── Mock Data ───────────────────────────────────────────────────
//   final List<MarketplaceItem> mockB2C = [
//     MarketplaceItem(
//       id: "101", variantId: "201", marketplaceId: "5",
//       title: "Premium Quartz Watch v2", subtitle: "Luxury Collection",
//       image: "https://lh3.googleusercontent.com/aida-public/AB6AXuBKM-HOD7CEZuOQRaBSnnprakdb5jfGyqmmJECq7POhy6d5NKpaHC_y-ek8yBBumg73TLMklrwZZn5ZsSxm0qIr5Kx5-z-sSQODyqQWwnO0PH8n9X7s0npHxYeAjFtySFI5MnT6LWkQeV08CwyGtlVBtUpd1JdCqmS0N0vu7agaV4sxtZpRegj6SElLVlzwf-C_fB6Kst08nc-DmSkJm1o_u75yPcfXTdexG79qDYRnqDsKtsdU3K_Fkw",
//       price: "₹1,200", earning: "₹96", category: "B2C",
//     ),
//     MarketplaceItem(
//       id: "102", variantId: "202", marketplaceId: "5",
//       title: "Acoustic Pro Headphones", subtitle: "Premium Audio",
//       image: "https://lh3.googleusercontent.com/aida-public/AB6AXuAeiOjJG4iAcTtFJKWOL_0ugAMrhVhlA-kkLs79uUhLr2RIuKWmQ03RaAJdoJVbpIxM4WK7q815XXnGRFNiX_Gy9155Ac0pMXsYrLzuqdj58Kn_-lAv22lt6H7uK6gFAlmnUn1st3CA4zXuvA5wdTqqw0J-Aor06oj2S23ztm6EO9OlQRm0EVkhBikm_osA0AppuJABhtU_up_RtKI8RPpgtaqpvbgfJ-FteCxWS16qCjV2ankzX71ynA",
//       price: "₹1,500", earning: "₹120", category: "B2C",
//     ),
//     MarketplaceItem(
//       id: "103", variantId: "203", marketplaceId: "5",
//       title: "Smart Hydration Bottle", subtitle: "Health Tech",
//       image: "https://lh3.googleusercontent.com/aida-public/AB6AXuDHyy7m8qaZZLN2S8ig-q589RBaLCs-SAkdBjoi3LmNP40Y7fxiuKmO9GYk2hxaj6ORbZMWsNvaEdXN-Xn-Ob3lFL1JL-umulR9yREY5Asq8rWQ31dj_zUU5suMnw_ykrzLez8QbR1HDgUfjBSsxl3e-e7Lgd7Y7B6URHQbF-UR67NeOyneWCZccxqEO21naC_fUEpmbq-XSEFjVaE2g_KHHlHGAPBHagCG1egxjtWe-XaUZjtVOwGsTw",
//       price: "₹1,000", earning: "₹80", category: "B2C",
//     ),
//   ];
//
//   final List<MarketplaceItem> mockB2B = [
//     MarketplaceItem(id: "301", variantId: "401", marketplaceId: "6", title: "Enterprise CRM", subtitle: "TechCorp Solutions", image: "", price: "₹25,000", earning: "₹2,000", category: "B2B"),
//     MarketplaceItem(id: "302", variantId: "402", marketplaceId: "6", title: "Cloud ERP Suite", subtitle: "SaaS Systems", image: "", price: "₹50,000", earning: "₹4,000", category: "B2B"),
//     MarketplaceItem(id: "303", variantId: "403", marketplaceId: "6", title: "Marketing Automation", subtitle: "GrowFast Digital", image: "", price: "₹15,000", earning: "₹1,200", category: "B2B"),
//   ];
//
//   final List<MarketplaceItem> mockServices = [
//     MarketplaceItem(id: "501", variantId: "0", marketplaceId: "16", title: "Affiliate Marketing", subtitle: "12 Modules • Certify Pro", image: "", price: "₹999", earning: "₹200", category: "Service"),
//     MarketplaceItem(id: "502", variantId: "0", marketplaceId: "16", title: "Sales Funnel Optimization", subtitle: "8 Modules • Conversion Lab", image: "", price: "₹799", earning: "₹160", category: "Service"),
//     MarketplaceItem(id: "503", variantId: "0", marketplaceId: "16", title: "Influencer Growth Program", subtitle: "15 Modules • Media Academy", image: "", price: "₹1,499", earning: "₹300", category: "Service"),
//   ];
//
//   final List<MarketplaceItem> mockTraining = [
//     MarketplaceItem(id: "601", variantId: "0", marketplaceId: "17", title: "Affiliate Marketing", subtitle: "12 Modules", image: "", price: "₹999", earning: "₹200", category: "Training"),
//     MarketplaceItem(id: "602", variantId: "0", marketplaceId: "17", title: "Sales Funnel Optimization", subtitle: "8 Modules", image: "", price: "₹799", earning: "₹160", category: "Training"),
//     MarketplaceItem(id: "603", variantId: "0", marketplaceId: "17", title: "Influencer Growth Program", subtitle: "15 Modules", image: "", price: "₹1,499", earning: "₹300", category: "Training"),
//   ];
//
//   // Donation & Events now modeled as MarketplaceItem too, so they can share
//   // the exact same card design as B2C / B2B / Services / Training.
//   final List<MarketplaceItem> mockDonation = [
//     MarketplaceItem(
//       id: "701", variantId: "0", marketplaceId: "18",
//       title: "Education For All", subtitle: "Goal: ₹2L",
//       image: "", price: "₹1.2L raised", earning: "65%", category: "Donation",
//     ),
//     MarketplaceItem(
//       id: "702", variantId: "0", marketplaceId: "18",
//       title: "Clean Water Initiative", subtitle: "Goal: ₹2L",
//       image: "", price: "₹90K raised", earning: "45%", category: "Donation",
//     ),
//   ];
//
//   final List<MarketplaceItem> mockMembership = [
//     MarketplaceItem(
//       id: "901", variantId: "0", marketplaceId: "20",
//       title: "Silver", subtitle: "5 Products • Basic Analytics • Email Support",
//       image: "", price: "₹999", earning: "STANDARD", category: "Membership",
//     ),
//     MarketplaceItem(
//       id: "902", variantId: "0", marketplaceId: "20",
//       title: "Gold", subtitle: "20 Products • Advanced Analytics • Priority Support",
//       image: "", price: "₹2,499", earning: "POPULAR", category: "Membership",
//     ),
//     MarketplaceItem(
//       id: "903", variantId: "0", marketplaceId: "20",
//       title: "Platinum", subtitle: "Unlimited Products • Dedicated Manager • Premium Visibility",
//       image: "", price: "₹4,999", earning: "BEST", category: "Membership",
//     ),
//   ];
//
//   final List<MarketplaceItem> mockEvents = [
//     MarketplaceItem(
//       id: "801", variantId: "0", marketplaceId: "19",
//       title: "Affiliate Summit 2026", subtitle: "Conference",
//       image: "", price: "12 Aug 2026", earning: "Free Entry", category: "Event",
//     ),
//     MarketplaceItem(
//       id: "802", variantId: "0", marketplaceId: "19",
//       title: "Creator Economy Meetup", subtitle: "Meetup",
//       image: "", price: "28 Aug 2026", earning: "Free Entry", category: "Event",
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     // Show mock data immediately so sections (esp. Training) never render empty
//     // while the network call is in flight or if it fails.
//     b2cProducts = mockB2C;
//     b2bProducts = mockB2B;
//     servicesList = mockServices;
//     trainingList = mockTraining;
//     donationList = mockDonation;
//     eventsList = mockEvents;
//     membershipList = mockMembership;
//     _syncSelectedItems();
//     _fetchItems();
//     searchController.addListener(_onSearchChanged);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() => _fetchItems();
//
//   Future<void> _fetchItems() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//     try {
//       final response = await Database().getData(
//         {'keyword': searchController.text},
//         endpoint: 'new_apis/marketplace_trading_API.php',
//       );
//       if (response['status'] == true && response['data'] != null) {
//         final data = response['data'];
//         final List<MarketplaceItem> fetchedB2C = [];
//         final List<MarketplaceItem> fetchedB2B = [];
//         final List<MarketplaceItem> fetchedServices = [];
//
//         final org = data['org_products'] as List?;
//         if (org != null) {
//           for (var item in org) {
//             fetchedB2C.add(MarketplaceItem(
//               id: item['product_id']?.toString() ?? '',
//               variantId: item['variant_id']?.toString() ?? '',
//               marketplaceId: '5',
//               title: item['title']?.toString() ?? '',
//               subtitle: item['seller']?.toString() ?? '',
//               image: item['image']?.toString() ?? '',
//               price: '₹${item['price']}',
//               earning: '₹${item['commission'] ?? item['upgradedcommission'] ?? '0'}',
//               category: item['category']?.toString() ?? 'B2C',
//               selected: item['is_selected'] == true,
//             ));
//           }
//         }
//
//         final btb = data['btb_products'] as List?;
//         if (btb != null) {
//           for (var item in btb) {
//             fetchedB2B.add(MarketplaceItem(
//               id: item['product_id']?.toString() ?? '',
//               variantId: item['variant_id']?.toString() ?? '',
//               marketplaceId: '6',
//               title: item['title']?.toString() ?? '',
//               subtitle: item['seller']?.toString() ?? '',
//               image: item['image']?.toString() ?? '',
//               price: '₹${item['price']}',
//               earning: '₹${item['commission'] ?? item['upgraded_commission'] ?? '0'}',
//               category: item['category']?.toString() ?? 'B2B',
//               selected: item['is_selected'] == true,
//             ));
//           }
//         }
//
//         final services = data['services'] as List?;
//         if (services != null) {
//           for (var item in services) {
//             fetchedServices.add(MarketplaceItem(
//               id: item['service_id']?.toString() ?? '',
//               variantId: '0',
//               marketplaceId: '16',
//               title: item['name']?.toString() ?? '',
//               subtitle: item['seller']?.toString() ?? '',
//               image: item['image']?.toString() ?? '',
//               price: '₹${item['price']}',
//               earning: '₹${item['commission'] ?? item['upgraded_commission'] ?? '0'}',
//               category: item['category']?.toString() ?? 'Service',
//               selected: item['is_selected'] == true,
//             ));
//           }
//         }
//
//         if (!mounted) return;
//         setState(() {
//           b2cProducts = fetchedB2C.isNotEmpty ? fetchedB2C : mockB2C;
//           b2bProducts = fetchedB2B.isNotEmpty ? fetchedB2B : mockB2B;
//           servicesList = fetchedServices.isNotEmpty ? fetchedServices : mockServices;
//           trainingList = mockTraining;
//           donationList = mockDonation;
//           eventsList = mockEvents;
//           membershipList = mockMembership;
//           _syncSelectedItems();
//         });
//       } else {
//         _loadMockData();
//       }
//     } catch (e) {
//       debugPrint('Error fetching marketplace items: $e');
//       _loadMockData();
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   void _syncSelectedItems() {
//     selectedItems.clear();
//     selectedItems.addAll(b2cProducts.where((e) => e.selected));
//     selectedItems.addAll(b2bProducts.where((e) => e.selected));
//     selectedItems.addAll(servicesList.where((e) => e.selected));
//     selectedItems.addAll(trainingList.where((e) => e.selected));
//     selectedItems.addAll(donationList.where((e) => e.selected));
//     selectedItems.addAll(eventsList.where((e) => e.selected));
//     selectedItems.addAll(membershipList.where((e) => e.selected));
//   }
//
//   void _loadMockData() {
//     if (!mounted) return;
//     setState(() {
//       b2cProducts = mockB2C;
//       b2bProducts = mockB2B;
//       servicesList = mockServices;
//       trainingList = mockTraining;
//       donationList = mockDonation;
//       eventsList = mockEvents;
//       membershipList = mockMembership;
//       _syncSelectedItems();
//     });
//   }
//
//   Future<void> saveSelectedItems() async {
//     setState(() => isLoading = true);
//     try {
//       final itemIds = selectedItems
//           .map((item) => "${item.id}-${item.variantId}-${item.marketplaceId}")
//           .toList();
//
//       final response = await Database().getData({
//         'keyword': searchController.text,
//         'selectItems': 'true',
//         'items': jsonEncode(itemIds),
//       }, endpoint: 'new_apis/marketplace_trading_API.php');
//
//       if (response['status'] == true) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(response['message'] ?? 'Items successfully selected'),
//           backgroundColor: accent,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(16),
//         ));
//         await _fetchItems();
//         if (mounted) _showNavigateDialog();
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(response['message'] ?? 'Failed to select items'),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(16),
//         ));
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Error: $e'),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ));
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   void _showNavigateDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: cardBg,
//         title: const Text("View Promoted Products?",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
//         content: const Text(
//             "Your items are saved. Head to Promoted Products to manage them.",
//             style: TextStyle(fontSize: 13, color: textSecondary, height: 1.5)),
//         actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             style: TextButton.styleFrom(foregroundColor: textSecondary),
//             child: const Text("Later", style: TextStyle(fontSize: 13)),
//           ),
//           FilledButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               Navigator.pushNamed(context, AppRoutes.selectedItems);
//             },
//             style: FilledButton.styleFrom(
//               backgroundColor: primary,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             child: const Text("View Now", style: TextStyle(fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void toggleSelection(MarketplaceItem item) {
//     setState(() {
//       item.selected = !item.selected;
//       if (item.selected) {
//         if (!selectedItems.any((e) => e.id == item.id && e.marketplaceId == item.marketplaceId)) {
//           selectedItems.add(item);
//         }
//       } else {
//         selectedItems.removeWhere((e) => e.id == item.id && e.marketplaceId == item.marketplaceId);
//       }
//     });
//   }
//
//   void _upgradeEarning(MarketplaceItem item) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text('Upgraded "${item.title}" to earn 2% more'),
//       backgroundColor: primary,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.all(16),
//     ));
//   }
//
//   // ── Build ───────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final scrollContent = CustomScrollView(
//       slivers: [
//         if (!widget.isEmbedded) _buildSliverAppBar(),
//         SliverToBoxAdapter(child: _buildSearchBar()),
//         SliverToBoxAdapter(child: _buildFeaturedBanner()),
//         if (isLoading)
//           const SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 32),
//               child: Center(child: CircularProgressIndicator(color: primary, strokeWidth: 2)),
//             ),
//           ),
//         SliverToBoxAdapter(child: _buildSectionHeader("B2C Products", onViewAll: () {})),
//         SliverToBoxAdapter(child: _buildCardSlider(b2cProducts, fallbackIcon: Icons.shopping_bag_rounded)),
//         SliverToBoxAdapter(child: _buildSectionHeader("B2B Solutions", onViewAll: () {})),
//         SliverToBoxAdapter(child: _buildCardSlider(b2bProducts, fallbackIcon: Icons.business_center_rounded)),
//         SliverToBoxAdapter(child: _buildSectionHeader("Services & Opportunities", onViewAll: () {})),
//         SliverToBoxAdapter(child: _buildCardSlider(servicesList, fallbackIcon: Icons.school_rounded)),
//         SliverToBoxAdapter(child: _buildComboPack()),
//         SliverToBoxAdapter(child: _buildSectionHeader("Membership Plans", onViewAll: () {})),
//         SliverToBoxAdapter(child: _buildCardSlider(
//           membershipList,
//           fallbackIcon: Icons.workspace_premium_rounded,
//           buttonLabel: "Add to List",
//           badgePrefix: "",
//           badgeSuffix: "",
//         )),
//         SliverToBoxAdapter(child: _buildSectionHeader("Training & Skills", onViewAll: () {})),
//         SliverToBoxAdapter(child: _buildCardSlider(trainingList, fallbackIcon: Icons.menu_book_rounded)),
//         SliverToBoxAdapter(child: _buildSectionHeader("Donation Projects", onViewAll: () {})),
//         SliverToBoxAdapter(child: _buildCardSlider(
//           donationList,
//           fallbackIcon: Icons.volunteer_activism_rounded,
//           buttonLabel: "Donate Now",
//           badgePrefix: "Funded ",
//         )),
//         SliverToBoxAdapter(child: _buildSectionHeader("Upcoming Events", onViewAll: () {})),
//         SliverToBoxAdapter(child: _buildCardSlider(
//           eventsList,
//           fallbackIcon: Icons.event_rounded,
//           buttonLabel: "Register Now",
//           badgePrefix: "",
//         )),
//         const SliverToBoxAdapter(child: SizedBox(height: 120)),
//       ],
//     );
//
//     final content = Stack(
//       children: [
//         scrollContent,
//         if (selectedItems.isNotEmpty) _buildSelectionBar(),
//       ],
//     );
//
//     if (widget.isEmbedded) return content;
//
//     return Scaffold(
//       backgroundColor: surface,
//       extendBody: true,
//       bottomNavigationBar: _buildBottomNav(),
//       body: content,
//     );
//   }
//
//   // ── App Bar ─────────────────────────────────────────────────────
//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       backgroundColor: cardBg,
//       surfaceTintColor: Colors.transparent,
//       floating: true,
//       snap: true,
//       elevation: 0,
//       titleSpacing: 16,
//       title: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               color: primaryLight,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.storefront_rounded, color: primary, size: 18),
//           ),
//           const SizedBox(width: 10),
//           const Expanded(
//             child: Text("Marketplace",
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                     color: textPrimary,
//                     letterSpacing: -0.3)),
//           ),
//         ],
//       ),
//       actions: [
//         _iconBtn(Icons.notifications_none_rounded, () {}),
//         const SizedBox(width: 4),
//         Padding(
//           padding: const EdgeInsets.only(right: 12),
//           child: GestureDetector(
//             onTap: () {},
//             child: Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: primary,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Center(
//                 child: Text("A",
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
//               ),
//             ),
//           ),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Divider(height: 1, color: divider),
//       ),
//     );
//   }
//
//   Widget _iconBtn(IconData icon, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 34,
//         height: 34,
//         decoration: BoxDecoration(
//           color: surface,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, size: 18, color: textPrimary),
//       ),
//     );
//   }
//
//   // ── Search ──────────────────────────────────────────────────────
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 42,
//               decoration: BoxDecoration(
//                 color: cardBg,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: divider),
//               ),
//               child: TextField(
//                 controller: searchController,
//                 style: const TextStyle(fontSize: 13, color: textPrimary),
//                 decoration: InputDecoration(
//                   hintText: "Search products...",
//                   hintStyle: const TextStyle(fontSize: 13, color: textSecondary),
//                   prefixIcon: const Icon(Icons.search_rounded, size: 18, color: textSecondary),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                   isDense: true,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: openFilterSheet,
//             child: Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: primary,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.tune_rounded, size: 18, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Featured Banner ─────────────────────────────────────────────
//   Widget _buildFeaturedBanner() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
//       height: 150,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF003D3D), Color(0xFF006565), Color(0xFF008A8A)],
//         ),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: -20, top: -20,
//             child: Container(
//               width: 120, height: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),
//           Positioned(
//             right: 30, bottom: -30,
//             child: Container(
//               width: 80, height: 80,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.05),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(18),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Text("FEATURED",
//                             style: TextStyle(
//                                 color: Colors.white, fontSize: 9,
//                                 fontWeight: FontWeight.w700, letterSpacing: 1)),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text("Enterprise Suite",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               color: Colors.white, fontSize: 18,
//                               fontWeight: FontWeight.w800, letterSpacing: -0.4)),
//                       const SizedBox(height: 2),
//                       Text("By TechCorp Solutions",
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
//                       const SizedBox(height: 10),
//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 6,
//                         children: [
//                           _bannerChip("MOQ: 5"),
//                           _bannerChip("8% Commission"),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     const Text("₹25,000",
//                         style: TextStyle(
//                             color: Colors.white, fontSize: 20,
//                             fontWeight: FontWeight.w800)),
//                     const SizedBox(height: 10),
//                     _tinyButton("Share & Earn", Icons.share_rounded, () {}),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _bannerChip(String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label,
//           style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
//     );
//   }
//
//   // ── Section Header ──────────────────────────────────────────────
//   Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(14, 20, 14, 10),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                     fontSize: 15, fontWeight: FontWeight.w700,
//                     color: textPrimary, letterSpacing: -0.2)),
//           ),
//           if (onViewAll != null)
//             GestureDetector(
//               onTap: onViewAll,
//               child: const Text("View all",
//                   style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ── Reusable "Upgrade to earn 2% more" / action button ──────────
//   Widget _upgradeButton(MarketplaceItem item, {double height = 28, String label = "Upgrade to earn 2% more"}) {
//     return GestureDetector(
//       onTap: () => _upgradeEarning(item),
//       child: Container(
//         width: double.infinity,
//         height: height,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: const Color(0xFF0D1B1B),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           label,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
//         ),
//       ),
//     );
//   }
//
//   Widget _commissionBadge(String earning, {String prefix = ""}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: primaryLight,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         "$prefix$earning Commission",
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: const TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w700),
//       ),
//     );
//   }
//
//   // ── Unified Card (used by B2C, B2B, Services, Training, Donation, Events) ──
//   // This is the same B2C card design — image header, title, subtitle, price,
//   // a badge, and an action button — reused everywhere for consistency.
//   Widget _buildUnifiedCard(
//       MarketplaceItem item, {
//         IconData fallbackIcon = Icons.image_rounded,
//         String buttonLabel = "Upgrade to earn 2% more",
//         String badgePrefix = "",
//         String badgeSuffix = " Commission",
//       }) {
//     return GestureDetector(
//       onTap: () => toggleSelection(item),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: 200,
//         margin: const EdgeInsets.only(right: 12),
//         decoration: BoxDecoration(
//           color: cardBg,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: item.selected ? primary : divider,
//             width: item.selected ? 1.5 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8, offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//                   child: item.image.isNotEmpty
//                       ? Image.network(item.image,
//                       height: 120, width: double.infinity, fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => _imagePlaceholder(120, icon: fallbackIcon))
//                       : _imagePlaceholder(120, icon: fallbackIcon),
//                 ),
//                 Positioned(
//                   top: 6, right: 6,
//                   child: _selectionCircle(item.selected),
//                 ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(item.title,
//                       maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                           fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
//                   const SizedBox(height: 2),
//                   Text(item.subtitle,
//                       maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 11, color: textSecondary)),
//                   const SizedBox(height: 8),
//                   Text(item.price,
//                       maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                           fontSize: 15, fontWeight: FontWeight.w800, color: primary)),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: primaryLight,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       "$badgePrefix${item.earning}$badgeSuffix",
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(color: primary, fontSize: 10.5, fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _upgradeButton(item, label: buttonLabel),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Horizontal slider built from the unified card — replaces all the
//   // previous per-section card builders (B2C/B2B/Services/Training/etc).
//   Widget _buildCardSlider(
//       List<MarketplaceItem> items, {
//         IconData fallbackIcon = Icons.image_rounded,
//         String buttonLabel = "Upgrade to earn 2% more",
//         String badgePrefix = "",
//         String badgeSuffix = " Commission",
//       }) {
//     if (items.isEmpty) return const SizedBox.shrink();
//     return SizedBox(
//       height: 312,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         itemCount: items.length,
//         itemBuilder: (_, i) => _buildUnifiedCard(
//           items[i],
//           fallbackIcon: fallbackIcon,
//           buttonLabel: buttonLabel,
//           badgePrefix: badgePrefix,
//           badgeSuffix: badgeSuffix,
//         ),
//       ),
//     );
//   }
//
//   // ── Combo Pack ──────────────────────────────────────────────────
//   Widget _buildComboPack() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF003D3D), Color(0xFF006565)],
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: const Text("BUNDLE DEAL",
//                       style: TextStyle(color: Colors.white, fontSize: 9,
//                           fontWeight: FontWeight.w700, letterSpacing: 0.8)),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text("Combo Promotion Pack",
//                     maxLines: 1, overflow: TextOverflow.ellipsis,
//                     style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
//                 const SizedBox(height: 4),
//                 Text("Promote 5 products · Boost conversions",
//                     maxLines: 2, overflow: TextOverflow.ellipsis,
//                     style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("₹4,999",
//                   style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
//               const SizedBox(height: 8),
//               _tinyButton("Buy Now", Icons.bolt_rounded, () {},
//                   bgColor: Colors.white, textColor: primary),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   // ── Selection Bar ───────────────────────────────────────────────
//   Widget _buildSelectionBar() {
//     return Positioned(
//       left: 14, right: 14,
//       bottom: widget.isEmbedded ? 16 : 80,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
//         decoration: BoxDecoration(
//           color: const Color(0xFF0D1B1B),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.25),
//               blurRadius: 16, offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 32, height: 32,
//               decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
//               child: Center(
//                 child: Text(selectedItems.length.toString(),
//                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text("Selected",
//                       maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
//                   Text("Tap to promote",
//                       maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: Color(0xFF88AAAA), fontSize: 10)),
//                 ],
//               ),
//             ),
//             GestureDetector(
//               onTap: saveSelectedItems,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//                 decoration: BoxDecoration(
//                   color: primary,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Icon(Icons.add_rounded, color: Colors.white, size: 14),
//                     SizedBox(width: 4),
//                     Text("Add to List",
//                         style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Bottom Nav ──────────────────────────────────────────────────
//   Widget _buildBottomNav() {
//     return Container(
//       decoration: BoxDecoration(
//         color: cardBg,
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -2))],
//       ),
//       child: SafeArea(
//         child: SizedBox(
//           height: 60,
//           child: Row(
//             children: [
//               _navItem(Icons.home_rounded, Icons.home_outlined, "Home", 0),
//               _navItem(Icons.storefront_rounded, Icons.storefront_outlined, "Market", 1),
//               _navItem(Icons.favorite_rounded, Icons.favorite_outline_rounded, "Wishlist", 2),
//               _navItem(Icons.person_rounded, Icons.person_outline_rounded, "Profile", 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _navItem(IconData activeIcon, IconData icon, String label, int index) {
//     final isActive = currentIndex == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => currentIndex = index),
//         behavior: HitTestBehavior.opaque,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(isActive ? activeIcon : icon,
//                 size: 22, color: isActive ? primary : textSecondary),
//             const SizedBox(height: 3),
//             Text(label,
//                 maxLines: 1, overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//                     color: isActive ? primary : textSecondary)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Filter Sheet ────────────────────────────────────────────────
//   void openFilterSheet() {
//     showModalBottomSheet(
//       context: context,
//       showDragHandle: true,
//       backgroundColor: cardBg,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Filters",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)),
//             const SizedBox(height: 16),
//             const Text("Category",
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8, runSpacing: 8,
//               children: ["All", "B2C", "B2B", "Services", "Training"].map((c) {
//                 return ChoiceChip(
//                   label: Text(c, style: const TextStyle(fontSize: 12)),
//                   selected: c == "All",
//                   selectedColor: primary,
//                   labelStyle: TextStyle(color: c == "All" ? Colors.white : textPrimary),
//                   onSelected: (_) {},
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: _solidButton("Apply Filters", () => Navigator.pop(context), height: 44),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Shared Helpers ──────────────────────────────────────────────
//   Widget _imagePlaceholder(double height, {IconData icon = Icons.image_rounded}) {
//     return Container(
//       height: height,
//       width: double.infinity,
//       color: primaryLight,
//       child: Icon(icon, size: 36, color: primary),
//     );
//   }
//
//   Widget _selectionCircle(bool selected) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 150),
//       width: 22, height: 22,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: selected ? primary : Colors.white.withOpacity(0.9),
//         border: Border.all(color: selected ? primary : Colors.grey.shade300, width: 1.5),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
//       ),
//       child: selected
//           ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
//           : null,
//     );
//   }
//
//   Widget _tinyButton(String label, IconData? icon, VoidCallback onTap,
//       {Color bgColor = primary, Color textColor = Colors.white}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: icon != null ? 8 : 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (icon != null) ...[
//               Icon(icon, size: 11, color: textColor),
//               const SizedBox(width: 3),
//             ],
//             Text(label,
//                 maxLines: 1, overflow: TextOverflow.ellipsis,
//                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _solidButton(String label, VoidCallback onTap, {double height = 40}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           color: primary,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         alignment: Alignment.center,
//         child: Text(label,
//             maxLines: 1, overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
//       ),
//     );
//   }
//
//   Widget _outlineButton(String label, VoidCallback onTap,
//       {Color borderColor = primary, Color textColor = primary, double height = 40}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           border: Border.all(color: borderColor),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         alignment: Alignment.center,
//         child: Text(label,
//             maxLines: 1, overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//                 color: textColor, fontSize: 12, fontWeight: FontWeight.w700)),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TradingMarketplaceScreen extends StatefulWidget {
  const TradingMarketplaceScreen({super.key});

  @override
  State<TradingMarketplaceScreen> createState() => _TradingMarketplaceScreenState();
}

class _TradingMarketplaceScreenState extends State<TradingMarketplaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}