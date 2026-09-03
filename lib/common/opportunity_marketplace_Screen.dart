import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

// TODO: point this at wherever the PHP file you shared actually lives.
const String _kEndpoint = 'new_apis/marketplace_opportunity_api.php';

int get _vendorId => int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

// --- Custom Theme Colors derived from your Tailwind Config ---
class AppColors {
  static const Color primary = Color(0xFF002B2F);
  static const Color primaryContainer = Color(0xFF004349);
  static const Color onPrimaryContainer = Color(0xFF7AAFB6);
  static const Color background = Color(0xFFF8F9F9);
  static const Color surface = Color(0xFFF8F9F9);
  static const Color surfaceContainerLow = Color(0xFFF2F4F4);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF191C1C);
  static const Color onSurfaceVariant = Color(0xFF404849);
  static const Color secondaryContainer = Color(0xFFCDE6F4);
  static const Color onSecondaryContainer = Color(0xFF506873);
  static const Color outline = Color(0xFF70797A);
  static const Color outlineVariant = Color(0xFFBFC8C9);
  static const Color borderSecondary = Color(0x264A626D); // 15% secondary
  static const Color warningMuted = Color(0xFFFFF8E1);
}

String formatCompactPrice(num value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return '\$${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return '\$${k == k.roundToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
  }
  return '\$${value.toStringAsFixed(0)}';
}

String formatRelativeDate(dynamic raw) {
  final dt = DateTime.tryParse(raw?.toString() ?? '');
  if (dt == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(that).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff > 1 && diff < 7) return '$diff days ago';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class OpportunityMarketplaceScreen extends StatefulWidget {
  const OpportunityMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<OpportunityMarketplaceScreen> createState() =>
      _OpportunityMarketplaceScreenState();
}

class _OpportunityMarketplaceScreenState
    extends State<OpportunityMarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  static const int _pageSize = 20;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<Map<String, dynamic>> _opportunities = [];
  int _offset = 0;

  String _keyword = '';
  List<int> _categoryIds = [];
  double? _minPrice;
  double? _maxPrice;
  bool _premiumOnly = false;
  bool _includeClosed = false;

  @override
  void initState() {
    super.initState();
    _fetchOpportunities(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchOpportunities(reset: false);
    }
  }

  Future<void> _fetchOpportunities({required bool reset}) async {
    setState(() {
      if (reset) {
        _isLoading = true;
        _offset = 0;
        _hasMore = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final res = await Database().getData({
        'action': 'fetch_opportunities',
        'limit': _pageSize,
        'offset': reset ? 0 : _offset,
        'keyword': _keyword,
        'category_ids': _categoryIds,
        if (_minPrice != null) 'min_price': _minPrice,
        if (_maxPrice != null) 'max_price': _maxPrice,
        'premium_only': _premiumOnly,
        'include_closed': _includeClosed,
        'vendor_id': _vendorId,
      }, endpoint: _kEndpoint);

      if (res != null && res['success'] == true) {
        final items = (res['data'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        setState(() {
          _opportunities = reset ? items : [..._opportunities, ...items];
          _offset = (reset ? 0 : _offset) + items.length;
          _hasMore = items.length == _pageSize;
        });
      } else if (reset) {
        setState(() => _opportunities = []);
        if (res != null && res['success'] == false) {
          _showSnack(res['message']?.toString() ?? 'Failed to load opportunities');
        }
      }
    } catch (e) {
      print('Error fetching opportunities: $e');
      if (reset) _showSnack('Failed to load opportunities. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _keyword = value.trim();
      _fetchOpportunities(reset: true);
    });
  }

  Future<void> _openFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialCategoryIds: _categoryIds,
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialPremiumOnly: _premiumOnly,
        initialIncludeClosed: _includeClosed,
      ),
    );

    if (result != null) {
      setState(() {
        _categoryIds = List<int>.from(result['category_ids'] ?? []);
        _minPrice = result['min_price'] as double?;
        _maxPrice = result['max_price'] as double?;
        _premiumOnly = result['premium_only'] ?? false;
        _includeClosed = result['include_closed'] ?? false;
      });
      _fetchOpportunities(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.borderSecondary, height: 1.0),
        ),
        // This is a pushed screen, not a tab root — show a normal back
        // button instead of the old drawer-opener (which would have thrown
        // since this Scaffold has no Drawer).
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        title: Text(
          'Explore Opportunities',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Button Row
          Container(
            color: AppColors.surface.withOpacity(0.95),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search opportunities...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: AppColors.borderSecondary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _openFilterBottomSheet,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (_categoryIds.isNotEmpty ||
                            _premiumOnly ||
                            _includeClosed ||
                            _minPrice != null ||
                            _maxPrice != null)
                            ? AppColors.primary
                            : AppColors.borderSecondary,
                      ),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: AppColors.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Opportunity Cards List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _fetchOpportunities(reset: true),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (_opportunities.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else ...[
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.62,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                OpportunityCard(data: _opportunities[index]),
                            childCount: _opportunities.length,
                          ),
                        ),
                      ),
                      if (_isLoadingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No opportunities found',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Card Widget for Opportunity Items ---
class OpportunityCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const OpportunityCard({Key? key, required this.data}) : super(key: key);

  @override
  State<OpportunityCard> createState() => _OpportunityCardState();
}

class _OpportunityCardState extends State<OpportunityCard> {
  late bool _isBookmarked;
  bool _togglingBookmark = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked =
        (int.tryParse(widget.data['is_bookmarked']?.toString() ?? '0') ?? 0) > 0;
  }

  Future<void> _toggleBookmark() async {
    if (_togglingBookmark) return;
    final postId = int.tryParse(widget.data['id'].toString()) ?? 0;
    if (postId == 0) return;

    setState(() => _togglingBookmark = true);
    try {
      final res = await Database().getData({
        'action': 'toggle_bookmark',
        'post_id': postId,
        'vendor_id': _vendorId,
      }, endpoint: _kEndpoint);

      if (res != null && res['success'] == true) {
        setState(() => _isBookmarked = res['data']?['bookmarked'] == true);
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    } finally {
      if (mounted) setState(() => _togglingBookmark = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isPremium = (int.tryParse(d['label']?.toString() ?? '0') ?? 0) == 3;
    final imageUrl = d['cover_image']?.toString();
    final rawCategory = d['category_name']?.toString() ?? '';
    final category = rawCategory.isNotEmpty ? rawCategory.toUpperCase() : 'GENERAL';
    final title = d['title']?.toString() ?? '';
    final company = (d['vendor_name']?.toString().isNotEmpty == true)
        ? d['vendor_name'].toString()
        : (d['organization']?.toString() ?? '');
    final date = formatRelativeDate(d['created_at']);
    final priceAmount = double.tryParse(d['price_amount']?.toString() ?? '') ?? 0;
    final price = priceAmount > 0 ? formatCompactPrice(priceAmount) : '—';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                imageUrl,
                height: 128,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 128,
                  width: double.infinity,
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppColors.onSurfaceVariant),
                ),
              )
                  : Container(
                height: 128,
                width: double.infinity,
                color: AppColors.surfaceContainerHigh,
                child: const Icon(Icons.business_center_outlined,
                    color: AppColors.onSurfaceVariant, size: 32),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            company,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.borderSecondary),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            price,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          InkWell(
                            onTap: _toggleBookmark,
                            borderRadius: BorderRadius.circular(12),
                            child: _togglingBookmark
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary),
                            )
                                : Icon(
                              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: _isBookmarked
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
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
          if (isPremium)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningMuted,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSecondary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Filter Bottom Sheet Component ---
class FilterBottomSheet extends StatefulWidget {
  final List<int> initialCategoryIds;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final bool initialPremiumOnly;
  final bool initialIncludeClosed;

  const FilterBottomSheet({
    Key? key,
    this.initialCategoryIds = const [],
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialPremiumOnly = false,
    this.initialIncludeClosed = false,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  static const double _priceFloor = 10000;
  static const double _priceCeil = 1000000;

  late RangeValues _priceRange;
  late Set<int> _selectedCategoryIds;
  late bool _isPremiumOnly;
  late bool _includeClosed;

  bool _isLoadingCategories = true;
  List<Map<String, dynamic>> _categories = [];
  final Set<int> _expandedCategoryIds = {};
  final Map<int, List<Map<String, dynamic>>> _subcategories = {};
  final Set<int> _loadingSubcategoryIds = {};

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      (widget.initialMinPrice ?? _priceFloor).clamp(_priceFloor, _priceCeil),
      (widget.initialMaxPrice ?? _priceCeil).clamp(_priceFloor, _priceCeil),
    );
    _selectedCategoryIds = Set<int>.from(widget.initialCategoryIds);
    _isPremiumOnly = widget.initialPremiumOnly;
    _includeClosed = widget.initialIncludeClosed;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final res = await Database().getData(
        {'action': 'fetch_categories'},
        endpoint: _kEndpoint,
      );
      if (res != null && res['success'] == true) {
        setState(() {
          _categories =
              (res['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _toggleExpand(int categoryId) async {
    setState(() {
      if (_expandedCategoryIds.contains(categoryId)) {
        _expandedCategoryIds.remove(categoryId);
      } else {
        _expandedCategoryIds.add(categoryId);
      }
    });

    if (_expandedCategoryIds.contains(categoryId) &&
        !_subcategories.containsKey(categoryId)) {
      setState(() => _loadingSubcategoryIds.add(categoryId));
      try {
        final res = await Database().getData({
          'action': 'fetch_subcategories',
          'parent_id': categoryId,
        }, endpoint: _kEndpoint);
        if (res != null && res['success'] == true) {
          setState(() {
            _subcategories[categoryId] =
                (res['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
          });
        }
      } catch (e) {
        print('Error fetching subcategories: $e');
      } finally {
        if (mounted) setState(() => _loadingSubcategoryIds.remove(categoryId));
      }
    }
  }

  void _clearAll() {
    setState(() {
      _selectedCategoryIds.clear();
      _priceRange = const RangeValues(_priceFloor, _priceCeil);
      _isPremiumOnly = false;
      _includeClosed = false;
    });
  }

  void _apply() {
    Navigator.pop(context, {
      'category_ids': _selectedCategoryIds.toList(),
      // Only send bounds the user actually narrowed, so an untouched
      // slider doesn't add a redundant WHERE clause.
      'min_price': _priceRange.start > _priceFloor ? _priceRange.start : null,
      'max_price': _priceRange.end < _priceCeil ? _priceRange.end : null,
      'premium_only': _isPremiumOnly,
      'include_closed': _includeClosed,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSecondary),

          // Scrollable Filter Body
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'CATEGORIES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoadingCategories)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (_categories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No categories available',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSecondary),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _categories.length; i++) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.borderSecondary),
                          _buildCategoryTile(_categories[i]),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Opportunity Value Range Slider
                Text(
                  'OPPORTUNITY VALUE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                RangeSlider(
                  values: _priceRange,
                  min: _priceFloor,
                  max: _priceCeil,
                  activeColor: AppColors.primary,
                  onChanged: (RangeValues values) {
                    setState(() => _priceRange = values);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatCompactPrice(_priceFloor),
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                    Text(
                      '${formatCompactPrice(_priceRange.start)} - ${formatCompactPrice(_priceRange.end)}',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                    ),
                    Text('${formatCompactPrice(_priceCeil)}+',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Toggles
                Text(
                  'STATUS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text('Premium Only'),
                    ],
                  ),
                  value: _isPremiumOnly,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isPremiumOnly = val),
                ),
                CheckboxListTile(
                  title: const Text('Include completed/closed'),
                  subtitle: Text(
                    'Off shows active listings only',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                  value: _includeClosed,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _includeClosed = val ?? false),
                ),
              ],
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSecondary),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderSecondary),
                    ),
                    onPressed: _clearAll,
                    child: Text('Clear All',
                        style: GoogleFonts.jetBrainsMono(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _apply,
                    child: Text('Apply Filters',
                        style: GoogleFonts.jetBrainsMono(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> category) {
    final id = int.tryParse(category['id'].toString()) ?? 0;
    final title = category['category_title']?.toString() ?? '';
    final count = category['opportunity_count']?.toString() ?? '0';
    final isExpanded = _expandedCategoryIds.contains(id);
    final isSelected = _selectedCategoryIds.contains(id);
    final subs = _subcategories[id] ?? const [];
    final isLoadingSub = _loadingSubcategoryIds.contains(id);

    return Column(
      children: [
        CheckboxListTile(
          value: isSelected,
          activeColor: AppColors.primary,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedCategoryIds.add(id);
              } else {
                _selectedCategoryIds.remove(id);
              }
            });
          },
          title: Text(title,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: Text('$count opportunities',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
          secondary: IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => _toggleExpand(id),
          ),
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            color: AppColors.surfaceContainerLowest,
            padding: const EdgeInsets.only(left: 32, right: 16, top: 4, bottom: 12),
            child: isLoadingSub
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : subs.isEmpty
                ? Text(
              'No subcategories',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Informational only: fetch_opportunities filters on
              // the main category (o.cat_id), not sub_cat_id, so
              // subcategories aren't selectable filter controls.
              children: subs
                  .map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '•  ${s['category_title']}',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}