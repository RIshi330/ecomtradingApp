import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../screens/create_opportunity_screen.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'opportunity_From2.dart';
import 'opportunity_details_screen.dart';
import 'opportunity_marketplace_Screen.dart';
/// Home screen for the Opportunity Hub, backed by the marketplace home API.
///
/// NOTE: the endpoint filename below (`_endpoint`) is a placeholder —
/// point it at wherever this PHP file actually lives on your server.
///
/// NOTE: `_marketplaceId` assumes `UserSessionSet.instance` exposes a
/// `marketplaceId` field, mirroring how `PersonalizeIndustryDialog` reads
/// `UserSessionSet.instance.vendorId`. If that getter doesn't exist yet,
/// add it to `UserSessionSet` (or swap this getter for wherever the
/// current marketplace id actually lives) before wiring this in.
class OpportunityHomeScreen extends StatefulWidget {
  const OpportunityHomeScreen({super.key});

  @override
  State<OpportunityHomeScreen> createState() =>
      _OpportunityHubHomeScreenState();
}

class _OpportunityHubHomeScreenState extends State<OpportunityHomeScreen> {
  // TODO: adjust to the real path of the PHP file shown above.
  static const String _endpoint = 'new_apis/marketplace_home_api.php';
  static const int _sectionLimit = 10;

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _premiumOpportunities = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _featuredOpportunities = [];
  List<Map<String, dynamic>> _latestOpportunities = [];

  // int get _marketplaceId => UserSessionSet.instance.marketplaceId;
  int  _marketplaceId =50;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  /// Calls all four existing actions in parallel and populates the sections.
  Future<void> _fetchHomeData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        Database().getData({
          'action': 'fetch_premium_opportunities',
          'marketplace_id': _marketplaceId,
          'limit': _sectionLimit,
        }, endpoint: _endpoint),
        Database().getData({
          'action': 'fetch_categories',
          'marketplace_id': _marketplaceId,
        }, endpoint: _endpoint),
        Database().getData({
          'action': 'fetch_featured_opportunities',
          'marketplace_id': _marketplaceId,
          'limit': _sectionLimit,
        }, endpoint: _endpoint),
        Database().getData({
          'action': 'fetch_latest_opportunities',
          'marketplace_id': _marketplaceId,
          'limit': _sectionLimit,
        }, endpoint: _endpoint),
      ]);

      if (!mounted) return;
      setState(() {
        _premiumOpportunities = _asMapList(results[0]);
        _categories = _asMapList(results[1]);
        _featuredOpportunities = _asMapList(results[2]);
        _latestOpportunities = _asMapList(results[3]);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching opportunity home data: $e");
      if (mounted) {
        setState(() {
          _error = "Couldn't load opportunities. Pull down to retry.";
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _asMapList(dynamic response) {
    if (response != null &&
        response['success'] == true &&
        response['data'] != null) {
      final List<dynamic> raw = response['data'];
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  // ---- Navigation -----------------------------------------------------

  /// `fetch_premium_opportunities` / `fetch_featured_opportunities` /
  /// `fetch_latest_opportunities` all select `o.id` as a plain (unencrypted)
  /// int, and `get_opportunity_details` currently reads `opportunity_id`
  /// straight off the request (its `decryptor()` call is commented out
  /// server-side), so passing the raw id straight through is correct as
  /// the backend stands today.
  void _openDetails(Map<String, dynamic> item) {
    final id = item['id'];
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OpportunityDetailsScreen(opportunityId: item['id']), // <--- Passing opportunityId as a named parameter
      ),
    );
  }

  // ---- Formatting helpers -------------------------------------------------

  String _formatPrice(Map<String, dynamic> item) {
    final rawAmount = item['price_amount'];
    if (rawAmount == null) return '';
    final amount = num.tryParse(rawAmount.toString()) ?? 0;
    final type = (item['pricing_type'] ?? '').toString().toLowerCase();
    final formatted = _formatAmount(amount);

    if (type.contains('year') || type.contains('yr')) return '\$$formatted / yr';
    if (type.contains('month')) return '\$$formatted / mo';
    if (type.contains('volume')) return '\$$formatted Volume';
    return '\$$formatted';
  }

  String _formatAmount(num amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m % 1 == 0 ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '${k % 1 == 0 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatPostedDate(dynamic rawDate) {
    if (rawDate == null) return '';
    final date = DateTime.tryParse(rawDate.toString());
    if (date == null) return '';
    return 'Posted ${_months[date.month - 1]} ${date.day}';
  }

  IconData _iconForCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('tech')) return Icons.memory;
    if (t.contains('logist')) return Icons.local_shipping;
    if (t.contains('construct')) return Icons.architecture;
    if (t.contains('material')) return Icons.inventory_2;
    if (t.contains('energy')) return Icons.bolt;
    if (t.contains('legal')) return Icons.gavel;
    if (t.contains('hardware') || t.contains('server')) return Icons.dns;
    return Icons.category_outlined;
  }

  String _combineCategory(Map<String, dynamic> item) {
    final cat = (item['category_name'] ?? '').toString();
    final sub = (item['subcategory_name'] ?? '').toString();
    if (cat.isEmpty) return sub;
    if (sub.isEmpty) return cat;
    return '$cat • $sub';
  }

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF002B2F))),
      );
    }

    return Scaffold(
      body: RefreshIndicator(

        onRefresh: _fetchHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                        TextButton(onPressed: _fetchHomeData, child: const Text("Retry")),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Premium Opportunities Slider
              _buildSectionHeader(title: 'Premium Opportunities', onViewAll: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    OpportunityMarketplaceScreen(),));
              }),
              const SizedBox(height: 8),
              _premiumOpportunities.isEmpty
                  ? _buildEmptySection('No premium opportunities right now.')
                  : SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _premiumOpportunities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = _premiumOpportunities[index];
                    return GestureDetector(
                      onTap: () => _openDetails(item),
                      child: _PremiumCard(
                        imageUrl: item['cover_image']?.toString(),
                        badgeText: 'Premium',
                        priceText: _formatPrice(item),
                        category: (item['category_name'] ?? '').toString(),
                        title: (item['title'] ?? '').toString(),
                        company: (item['vendor_name'] ?? '').toString(),
                        date: _formatPostedDate(item['created_at']),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 2. Categories Grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Browse Categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002B2F),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _categories.isEmpty
                  ? _buildEmptySection('No categories found.')
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: _categories.map((item) {
                    final title = (item['category_title'] ?? '').toString();
                    final count = item['opportunity_count']?.toString() ?? '0';
                    return _CategoryCard(
                      icon: _iconForCategory(title),
                      title: title,
                      subtitle: '$count Opportunities',
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Featured Opportunities Slider
              _buildSectionHeader(title: 'Featured Bids', onViewAll: () {}),
              const SizedBox(height: 8),
              _featuredOpportunities.isEmpty
                  ? _buildEmptySection('No featured opportunities right now.')
                  : SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _featuredOpportunities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = _featuredOpportunities[index];
                    return GestureDetector(
                      onTap: () => _openDetails(item),
                      child: _FeaturedCard(
                        category: _combineCategory(item),
                        title: (item['title'] ?? '').toString(),
                        company: (item['vendor_name'] ?? '').toString(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 4. Latest Opportunities Slider
              _buildSectionHeader(title: 'Latest Opportunities', onViewAll: () {}),
              const SizedBox(height: 8),
              _latestOpportunities.isEmpty
                  ? _buildEmptySection('No opportunities posted yet.')
                  : SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _latestOpportunities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = _latestOpportunities[index];
                    return GestureDetector(
                      onTap: () => _openDetails(item),
                      child: _OpportunityCard(
                        imageUrl: item['cover_image']?.toString(),
                        category: _combineCategory(item),
                        title: (item['title'] ?? '').toString(),
                        company: (item['vendor_name'] ?? '').toString(),
                        postedDate: _formatPostedDate(item['created_at']),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 5. Community Insights
              // No backend action exists for this yet (the API only exposes
              // fetch_premium_opportunities / fetch_categories /
              // fetch_featured_opportunities / fetch_latest_opportunities),
              // so this section stays static until a matching action is added.
              _buildSectionHeader(title: 'Community Insights', onViewAll: () {}),
              const SizedBox(height: 8),
              SizedBox(
                height: 230,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _InsightCard(
                      imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCJsU_CcgJDtOTlpgoVQvGvA26RpH0i_At0PXlHV9NRbf0V9d_7ciW3XkAvukKti14UdeZFqj1rhvIeU8xIswa5DZ7RJJPu_omcanOwRK2NQUxGnFUN2YQlTGfFKr8IFXBAz5la-3cziCGBkH_iDfHUjMjiu5vE8ZSGxm_0jUZrW3R0OQ-gNpnwODdGR73-efVlVm0FYwrdxLAU1i_8exa2Pn1pN36ymMz8DFqmlotic5PHDV966PYOzw',
                      category: 'MARKET ANALYSIS',
                      title: 'Navigating Semiconductor Shortages in Q4',
                      authorName: 'Sarah J.',
                      authorAvatarUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAaRKwqG3aUaxwSmreC0HZB6dygxv645QRadtxmUPhCOKgUE3PYq4-sGz7e8upPyZAntM6nIa3tYf4ID75LY-IY2aYqo_7Cu-Sq8D_PYBsue4WrJa6PnvnIltWK8FEc1mTtxTBKU0yRR0uOampTdEujRZaDOPQTDPwUkjNHy-KcXUML9K6esLg_Ibjq4IG2WWZQnLGXWTWPG3sTk9HD6mR0OCEbYXxaHD2yrrleLXILohn7qj6I58cu-w',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF002B2F),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
          // OpportunityFormScreen()
          CreateOpportunityScreen()
            ,));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required VoidCallback onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002B2F),
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(
                color: Color(0xFF4A626D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.1)),
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFF4A626D)),
        ),
      ),
    );
  }
}

// Shared network-image-with-fallback helper

Widget _networkImageOrPlaceholder(String? url, double height) {
  if (url == null || url.isEmpty) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFE1E3E3),
      child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF4A626D)),
    );
  }
  return Image.network(
    url,
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      height: height,
      color: const Color(0xFFE1E3E3),
      child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF4A626D)),
    ),
  );
}

// Custom Reusable Components

class _PremiumCard extends StatelessWidget {
  final String? imageUrl;
  final String badgeText;
  final String priceText;
  final String category;
  final String title;
  final String company;
  final String date;

  const _PremiumCard({
    required this.imageUrl,
    required this.badgeText,
    required this.priceText,
    required this.category,
    required this.title,
    required this.company,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _networkImageOrPlaceholder(imageUrl, 140),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF041E28),
                    ),
                  ),
                ),
              ),
              if (priceText.isNotEmpty)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF002B2F),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A626D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1C),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A626D),
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF4A626D).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.share_outlined,
                            size: 18, color: Color(0xFF4A626D)),
                        SizedBox(width: 8),
                        Icon(Icons.bookmark_border,
                            size: 18, color: Color(0xFF4A626D)),
                        SizedBox(width: 8),
                        Icon(Icons.thumb_up_alt_outlined,
                            size: 18, color: Color(0xFF4A626D)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF002B2F), size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF191C1C),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4A626D),
            ),
          ),
        ],
      ),
    );
  }
}

/// NOTE: 'fetch_featured_opportunities' only returns id, title, status,
/// category_name, subcategory_name, vendor_name — there's no deadline,
/// views, or likes column in that query, so this card only shows what's
/// actually available.
class _FeaturedCard extends StatelessWidget {
  final String category;
  final String title;
  final String company;

  const _FeaturedCard({
    required this.category,
    required this.title,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A626D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191C1C),
            ),
          ),
          const Spacer(),
          Divider(color: const Color(0xFF4A626D).withOpacity(0.15)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Posted By',
                        style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF4A626D).withOpacity(0.7))),
                    Text(company,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF191C1C))),
                  ],
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.share_outlined,
                      size: 16, color: Color(0xFF4A626D)),
                  SizedBox(width: 8),
                  Icon(Icons.bookmark_border,
                      size: 16, color: Color(0xFF4A626D)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

/// NOTE: 'fetch_latest_opportunities' has no deadline or likes column —
/// this card shows the posting date (from created_at) instead of a deadline.
class _OpportunityCard extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final String title;
  final String company;
  final String postedDate;

  const _OpportunityCard({
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.company,
    required this.postedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _networkImageOrPlaceholder(imageUrl, 100),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A626D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Posted By',
                    style: TextStyle(
                        fontSize: 10,
                        color: const Color(0xFF4A626D).withOpacity(0.7))),
                Text(company,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF191C1C))),
                const SizedBox(height: 8),
                Divider(color: const Color(0xFF4A626D).withOpacity(0.15)),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Color(0xFF4A626D)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(postedDate,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF4A626D))),
                    ),
                    const Icon(Icons.share_outlined,
                        size: 16, color: Color(0xFF4A626D)),
                    const SizedBox(width: 8),
                    const Icon(Icons.bookmark_border,
                        size: 16, color: Color(0xFF4A626D)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Static placeholder — no backend action exists for community insights yet.
class _InsightCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String title;
  final String authorName;
  final String authorAvatarUrl;

  const _InsightCard({
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.authorName,
    required this.authorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 100,
              color: const Color(0xFFE1E3E3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A626D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1C),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(authorAvatarUrl),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4A626D),
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.share_outlined,
                            size: 16, color: Color(0xFF4A626D)),
                        SizedBox(width: 8),
                        Icon(Icons.bookmark_border,
                            size: 16, color: Color(0xFF4A626D)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}