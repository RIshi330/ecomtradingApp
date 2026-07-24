import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../Database/Database.dart';

// ADJUST THIS IMPORT to wherever your Database class actually lives
// (the file you shared imports it as `../database.dart` relative to
// `services/`, so from this screen it's probably one of these two).
// import '../services/database.dart';

/// Btbshop — now wired to the marketplace PHP API instead of hardcoded
/// mock data.
///
/// What's connected (uses actions that exist in your PHP file):
///   - get_marketplace_products  -> Top Selling Products + New Arrivals
///   - addToCart                 -> "Add to cart" on product cards
///   - addToWishlist             -> wishlist heart toggle on product cards
///   - cat_id filter             -> tapping an industry chip re-queries
///
/// What's still static placeholder content (there's no matching action
/// in the PHP file for these, so nothing to wire up yet):
///   - Deal of the Day (needs a "get discounted / on-sale products" action)
///   - Verified Suppliers (needs a vendor/supplier listing action)
///   - Testimonials (needs a reviews/testimonials action)
///   - Industry Insights (needs a blog/articles action)
class Btbshop extends StatefulWidget {
  const Btbshop({super.key});

  @override
  State<Btbshop> createState() => _BtbshopState();
}

class _BtbshopState extends State<Btbshop> {
  // TODO: point this at whatever the file with `get_marketplace_products`,
  // `addToCart`, `addToWishlist` etc. is actually routed/named as.
  // (Same idea as `feedEndpoint` already used elsewhere in Database.)
  static const String _marketplaceEndpoint = 'new_apis/marketplace_btb_api.php';

  final Database _db = Database();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _products = [];
  String _selectedCategory = ''; // '' == All Categories
  final Set<String> _wishlisted = {}; // keys: "productId_variantId"
  final Set<String> _busyKeys = {}; // productId_variantId currently mid-request

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Symbols.precision_manufacturing, 'label': 'Industrial'},
    {'icon': Symbols.construction, 'label': 'Tools'},
    {'icon': Symbols.bolt, 'label': 'Electrical'},
    {'icon': Symbols.medical_services, 'label': 'Medical'},
    {'icon': Symbols.laptop_mac, 'label': 'IT Hardware'},
    {'icon': Symbols.package_2, 'label': 'Packaging'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // ------------------------------------------------------------------
  // API CALLS
  // ------------------------------------------------------------------

  Future<void> _fetchProducts({String? catId}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final postBody = <String, dynamic>{
        'action': 'get_marketplace_products',
        'page': 1,
      };
      if (catId != null && catId.isNotEmpty) {
        postBody['cat_id'] = catId;
      }

      final result = await _db.getData(postBody, endpoint: _marketplaceEndpoint);

      if (result['success'] == true) {
        final data = result['data'];
        final productsRaw = (data is Map ? data['products'] : null) as List? ?? [];
        setState(() {
          _products = productsRaw
              .whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p))
              .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = (result['message'] ?? 'Failed to load products').toString();
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final productId = _productId(product);
    final variantId = _variantId(product);
    if (productId.isEmpty || variantId.isEmpty) return;

    final key = '${productId}_$variantId';
    setState(() => _busyKeys.add(key));

    final result = await _db.getData({
      'addToCart': productId,
      'variant': variantId,
    }, endpoint: _marketplaceEndpoint);

    if (!mounted) return;
    setState(() => _busyKeys.remove(key));

    final ok = result['success'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((result['message'] ?? (ok ? 'Added to cart' : 'Failed to add to cart')).toString()),
      ),
    );
  }

  Future<void> _toggleWishlist(Map<String, dynamic> product) async {
    final productId = _productId(product);
    final variantId = _variantId(product);
    if (productId.isEmpty || variantId.isEmpty) return;

    final key = '${productId}_$variantId';
    setState(() => _busyKeys.add(key));

    final result = await _db.getData({
      'addToWishlist': productId,
      'variant': variantId,
    }, endpoint: _marketplaceEndpoint);

    if (!mounted) return;

    setState(() {
      _busyKeys.remove(key);
      if (result['success'] == true) {
        if (_wishlisted.contains(key)) {
          _wishlisted.remove(key);
        } else {
          _wishlisted.add(key);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text((result['message'] ?? 'Wishlist updated').toString())),
    );
  }

  // ------------------------------------------------------------------
  // FIELD EXTRACTION HELPERS
  // (unwrap the nested product_details / variants[0].variant_details
  // shape the PHP file returns)
  // ------------------------------------------------------------------

  Map<String, dynamic>? _firstVariant(Map<String, dynamic> product) {
    final variants = product['variants'] as List? ?? [];
    if (variants.isEmpty) return null;
    return Map<String, dynamic>.from(variants.first as Map);
  }

  String _title(Map<String, dynamic> product) {
    final details = product['product_details'];
    if (details is Map && details['product_title'] != null) {
      return details['product_title'].toString();
    }
    return 'Untitled product';
  }

  String _brand(Map<String, dynamic> product) {
    final details = product['product_details'];
    if (details is Map && details['brand_name'] != null) {
      return details['brand_name'].toString();
    }
    return '';
  }

  double _price(Map<String, dynamic> product) {
    final v = _firstVariant(product);
    final vd = v?['variant_details'];
    final raw = vd is Map ? vd['price'] : null;
    return double.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String _packInfo(Map<String, dynamic> product) {
    final v = _firstVariant(product);
    final vd = v?['variant_details'];
    final unitPerPack = vd is Map ? vd['unit_per_pack'] : null;
    if (unitPerPack == null || unitPerPack.toString().isEmpty || unitPerPack.toString() == '0') {
      return '';
    }
    return 'Pack of $unitPerPack units';
  }

  String? _imageUrl(Map<String, dynamic> product) {
    final v = _firstVariant(product);
    final img = v?['image']?.toString();
    return (img == null || img.isEmpty) ? null : img;
  }

  String _productId(Map<String, dynamic> product) {
    final details = product['product_details'];
    if (details is Map && details['id'] != null) return details['id'].toString();
    return '';
  }

  String _variantId(Map<String, dynamic> product) {
    final v = _firstVariant(product);
    final vd = v?['variant_details'];
    if (vd is Map && vd['id'] != null) return vd['id'].toString();
    return '';
  }

  // ------------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DELIVERY TO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Text(
              'Silicon Valley, 94043',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Symbols.search, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Symbols.mic, color: theme.colorScheme.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: const Color(0xFFF6F3F2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Symbols.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      'Jun 13, 2026 | 02:53 PM',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Symbols.pin_drop, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Pincode: 560001',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchProducts(catId: _selectedCategory),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            const SizedBox(height: 24),
            _buildIndustrySlider(theme),
            const SizedBox(height: 32),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _buildErrorState(theme)
            else if (_products.isEmpty)
                _buildEmptyState(theme)
              else ...[
                  _buildTopSellingProducts(theme),
                  const SizedBox(height: 32),
                  _buildNewArrivals(theme),
                  const SizedBox(height: 32),
                ],

            // --- Static sections below: no matching backend action yet ---
            _buildDealOfTheDay(theme),
            const SizedBox(height: 32),
            _buildVerifiedSuppliers(theme),
            const SizedBox(height: 32),
            _buildTestimonials(theme),
            const SizedBox(height: 32),
            _buildIndustryInsights(theme),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            foregroundColor: theme.colorScheme.primary,
            shape: const CircleBorder(),
            onPressed: () {},
            child: const Icon(Symbols.shopping_cart, size: 24),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () {},
            child: const Icon(Symbols.chat_bubble, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Symbols.error, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _fetchProducts(catId: _selectedCategory),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No products found for this category.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  // 1. Browse by Industry (Horizontal Slider) — tapping re-fetches by cat_id
  Widget _buildIndustrySlider(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Text('Browse by Industry', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                setState(() => _selectedCategory = '');
                _fetchProducts();
              },
              child: Text('View All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final label = cat['label'] as String;
              final isSelected = _selectedCategory == label;
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = isSelected ? '' : label);
                    _fetchProducts(catId: _selectedCategory);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E2E1),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                        ),
                        child: Icon(cat['icon'] as IconData, color: theme.colorScheme.primary, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. Top Selling Products — first fetched product as the featured card,
  // next two as a grid.
  Widget _buildTopSellingProducts(ThemeData theme) {
    final featured = _products.first;
    final gridItems = _products.length > 1 ? _products.sublist(1, _products.length.clamp(0, 3)) : <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Selling Products', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFeaturedProductCard(theme, featured),
        if (gridItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < gridItems.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: _buildProductGridCard(theme, gridItems[i])),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturedProductCard(ThemeData theme, Map<String, dynamic> product) {
    final productId = _productId(product);
    final variantId = _variantId(product);
    final key = '${productId}_$variantId';
    final busy = _busyKeys.contains(key);
    final isWishlisted = _wishlisted.contains(key);
    final imageUrl = _imageUrl(product);
    final packInfo = _packInfo(product);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                color: const Color(0xFFF6F3F2),
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Symbols.precision_manufacturing, size: 64, color: Color(0xFFBDC9C8)),
                )
                    : const Icon(Symbols.precision_manufacturing, size: 64, color: Color(0xFFBDC9C8)),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: busy ? null : () => _toggleWishlist(product),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      isWishlisted ? Symbols.favorite : Symbols.favorite_border,
                      color: theme.colorScheme.primary,
                      fill: isWishlisted ? 1 : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_brand(product).isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF93F2F2), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _brand(product).toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF002020)),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(_title(product), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Starting from', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        Text(
                          '\$${_price(product).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (packInfo.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration:
                        BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                        child: Text(packInfo,
                            style:
                            TextStyle(fontSize: 11, color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: busy ? null : () => _addToCart(product),
                    icon: busy
                        ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Symbols.shopping_cart, size: 18),
                    label: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductGridCard(ThemeData theme, Map<String, dynamic> product) {
    final productId = _productId(product);
    final variantId = _variantId(product);
    final key = '${productId}_$variantId';
    final busy = _busyKeys.contains(key);
    final isWishlisted = _wishlisted.contains(key);
    final imageUrl = _imageUrl(product);
    final packInfo = _packInfo(product);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 110,
                color: const Color(0xFFF6F3F2),
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Symbols.inventory_2, size: 40, color: Color(0xFFBDC9C8)))
                    : const Icon(Symbols.inventory_2, size: 40, color: Color(0xFFBDC9C8)),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: busy ? null : () => _toggleWishlist(product),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      isWishlisted ? Symbols.favorite : Symbols.favorite_border,
                      size: 16,
                      color: theme.colorScheme.primary,
                      fill: isWishlisted ? 1 : 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title(product), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                if (packInfo.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
                    child: Text(packInfo,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer)),
                  ),
                const SizedBox(height: 8),
                Text('Onwards', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                Text('\$${_price(product).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: busy ? null : () => _addToCart(product),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: busy
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // New Arrivals — reuses whatever's left in the same fetched page
  // (the PHP file only exposes one products listing action, so "new
  // arrivals" here just means "the next few results after Top Selling").
  Widget _buildNewArrivals(ThemeData theme) {
    final start = 3;
    if (_products.length <= start) return const SizedBox.shrink();
    final arrivals = _products.sublist(start, _products.length.clamp(start, start + 3));
    if (arrivals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New Arrivals', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemCount: arrivals.length,
          itemBuilder: (context, index) => _buildProductGridCard(theme, arrivals[index]),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // STATIC SECTIONS (no matching backend action — left as mock UI)
  // ------------------------------------------------------------------

  Widget _buildDealOfTheDay(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deal of the Day', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text('Exclusive wholesale discounts expiring in:', style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimerChip('14', 'Hrs'),
              const SizedBox(width: 8),
              _buildTimerChip('22', 'Min'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hook this up once you add a "get discounted products" action '
                '(e.g. call get_discount per product, or add a dedicated '
                'endpoint) to the PHP file.',
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8), fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVerifiedSuppliers(ThemeData theme) {
    final suppliers = [
      {'logo': 'TECH+', 'name': 'TechSolutions Ltd', 'rating': '4.9', 'deals': '2.4k', 'rank': 'RANK #1 ELECTRONICS'},
      {'logo': 'MAX', 'name': 'MaxBuild Industrial', 'rating': '4.7', 'deals': '1.8k', 'rank': 'RANK #3 INDUSTRIAL'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verified Suppliers', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                      ),
                      alignment: Alignment.center,
                      child: Text(supplier['logo']!, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(supplier['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 4),
                              Icon(Symbols.verified, size: 14, color: theme.colorScheme.primary, fill: 1),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Symbols.star, size: 12, color: Colors.amber, fill: 1),
                              const SizedBox(width: 2),
                              Text('${supplier['rating']} ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text('• ${supplier['deals']} Deals', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: const Color(0xFFEAE7E7),
                            child: Text(supplier['rank']!, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonials(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF6F3F2), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text('Trusted by Industry Leaders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Building reliable global supply chains.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Symbols.format_quote, size: 32, color: theme.colorScheme.primary.withOpacity(0.2)),
                const Text(
                  '"B2B Connect has transformed our procurement cycle. The transparency in pricing has reduced our lead time by 30%."',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFF93F2F2), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('David Chen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Supply Chain Director', style: TextStyle(fontSize: 10, color: Colors.grey)),
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

  Widget _buildIndustryInsights(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Industry Insights', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 120, color: const Color(0xFFF0EDED), width: double.infinity, child: const Icon(Symbols.explore, size: 40, color: Color(0xFFBDC9C8))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('LOGISTICS', style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(' • Jun 10, 2026', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Global Shipping Trends for 2024', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          icon: const Text('Read More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          label: Icon(Symbols.arrow_forward, size: 14, color: theme.colorScheme.primary),
                        ),
                        const Spacer(),
                        Icon(Symbols.bookmark, size: 18, color: theme.colorScheme.onSurfaceVariant),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}