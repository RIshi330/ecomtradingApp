import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';
import '../common/header.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'Branding_details_page.dart';


class BrandingMarketplaceScreen extends StatefulWidget {
  final bool isEmbedded;
  const BrandingMarketplaceScreen({Key? key, this.isEmbedded = false})
      : super(key: key);

  @override
  State<BrandingMarketplaceScreen> createState() =>
      _BrandingMarketplaceScreenState();
}

class _BrandingMarketplaceScreenState extends State<BrandingMarketplaceScreen> {
  // Define endpoint configuration tracking reference block
  // Replace with your server's IP address or domain endpoint (e.g., 'http://10.0.2.2/api/...' for Android Emulator)
  static const String apiUrl = '${baseUrl}new_apis/branding_marketplace_api.php';

  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  bool _isLoadingBrands = true;
  bool _isLoadingCategories = true;
  String selectedCurrency = "INR";
  final TextEditingController searchController = TextEditingController();

  // Voice search
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String _selectedCategory = 'All';
  double _priceLimit = 1000.0;
  double _minRating = 0.0;

  // Sort state
  String _selectedSort = 'latest';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // --- API FUNCTION: Get Categories ---
  Future<void> fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'get_branding_categories',        'vendor_id': UserSessionSet.instance.vendorId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            _categories =
            List<Map<String, dynamic>>.from(jsonResponse['data'] ?? []);
            _isLoadingCategories = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  // --- API FUNCTION: Filter / Fetch Brands ---
  Future<void> fetchBrands() async {
    setState(() => _isLoadingBrands = true);
    try {
      int categoryId = 0;
      if (_selectedCategory != 'All' && _categories.isNotEmpty) {
        final catMap = _categories.firstWhere(
              (c) => c['category_title'] == _selectedCategory,
          orElse: () => {},
        );
        categoryId = int.tryParse(catMap['id']?.toString() ?? '0') ?? 0;
      }

      final Map<String, dynamic> requestBody = {
        'action': 'get_brands',
        'keyword': searchController.text.trim(),
        'sort': _selectedSort,
        'category_id': categoryId,
        'sub_category_id': 0,
        'vendor_id': UserSessionSet.instance.vendorId,

      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint("get_brands API Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          List<dynamic> brandsList = [];
          if (data is Map) {
            brandsList = data['brands'] ?? [];
          } else if (data is List) {
            brandsList = data;
          }

          setState(() {
            _brands = List<Map<String, dynamic>>.from(brandsList);
            _isLoadingBrands = false;
            _applyFilters();
          });
        } else {
          setState(() => _isLoadingBrands = false);
        }
      } else {
        setState(() => _isLoadingBrands = false);
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching brands: $e\n$stackTrace');
      setState(() => _isLoadingBrands = false);
    }
  }

  // --- API FUNCTION: Add / Remove Wishlist ---
  Future<void> toggleWishlist(Map<String, dynamic> product) async {
    final originalFavorite = product['favorite'];
    setState(() => product['favorite'] = !originalFavorite);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'add_brand_to_wishlist',
          'brand_id': product['id'],
          'vendor_id': UserSessionSet.instance.vendorId,

        }),
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  jsonResponse['message'] ?? 'Wishlist updated successfully')),
        );
      } else {
        setState(() => product['favorite'] = originalFavorite);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(jsonResponse['message'] ?? 'Failed to update wishlist'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => product['favorite'] = originalFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error updating wishlist: $e')),
      );
    }
  }

  // --- Map raw brand JSON into display-ready product map ---
  Map<String, dynamic> _mapBrandToProduct(Map<String, dynamic> b) {
    double btcPrice = 199.00;
    if (b['packages'] is List && (b['packages'] as List).isNotEmpty) {
      btcPrice =
          double.tryParse(b['packages'][0]['price']?.toString() ?? '') ?? 199.0;
    } else if (b['pricing'] is List && (b['pricing'] as List).isNotEmpty) {
      btcPrice =
          double.tryParse(b['pricing'][0]['price']?.toString() ?? '') ?? 199.0;
    }

    double btbPrice = btcPrice * 0.85;
    if (b['packages'] is List && (b['packages'] as List).length > 1) {
      btbPrice = double.tryParse(b['packages'][1]['price']?.toString() ?? '') ??
          btbPrice;
    }

    int minUnits = 10;
    if (b['packages'] is List && (b['packages'] as List).isNotEmpty) {
      minUnits =
          int.tryParse(b['packages'][0]['min_qty']?.toString() ?? '') ?? 10;
    }

    String discountBadge = 'SAVE UP TO 15%';
    if (btcPrice > btbPrice) {
      discountBadge =
      'SAVE UP TO ${(((btcPrice - btbPrice) / btcPrice) * 100).round()}%';
    }

    String image =
        'https://lh3.googleusercontent.com/aida/AP1WRLt3xBPmgE7X8Rf0ZMPczBRuR-00z8opWY495AIYY9EiU9U3hi_YrOG2vqjdWY2m3sU8nChtRG3qdo3RDTSHMjPj_Q6vsWt-E-CrsU4-qe2CiXi4Xr1awqXR-0akjT-OrjIGWgSMO_2WJRQ8yAx75ciDj2sL5KScrio9AcQ2A6cSU3iPfI3gKj44CJtPWjcKiirANSLxOG_O7WVZg__FTZ520iKf2NYG9xqBrXnV77uJQEo081oxXeTA7pQ';
    if (b['images'] is List && (b['images'] as List).isNotEmpty) {
      final imgObj = b['images'][0];
      image = imgObj['image_path']?.toString() ??
          imgObj['image']?.toString() ??
          imgObj['image_url']?.toString() ??
          image;
    }

    return {
      'id': b['id']?.toString() ?? '',
      'store': b['vendor']?['name']?.toString() ??
          b['brand_name']?.toString() ??
          'Unknown Store',
      'title': b['brand_name']?.toString() ?? 'Unknown Brand',
      'rating': 4.8,
      'reviews': 124,
      'btcPrice': btcPrice,
      'btbPrice': btbPrice,
      'minUnits': minUnits,
      'discountBadge': discountBadge,
      'image': image,
      'favorite': false,
      'category': b['category']?['name']?.toString() ?? 'Lifestyle',
    };
  }

  List<String> _getCategoryNames() {
    List<String> names = ['All'];
    if (_categories.isNotEmpty) {
      names.addAll(_categories
          .map((c) => c['category_title']?.toString() ?? '')
          .where((name) => name.isNotEmpty));
    } else {
      names.addAll(['Electronics', 'Lifestyle', 'Fashion']);
    }
    return names.toSet().toList();
  }

  void _applyFilters() {
    final products = _brands.map((b) => _mapBrandToProduct(b)).toList();
    _filteredProducts = products.where((p) {
      final query = searchController.text.toLowerCase();
      final matchesSearch = p['title'].toString().toLowerCase().contains(query) ||
          p['store'].toString().toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final matchesPrice = p['btcPrice'] <= _priceLimit;
      final matchesRating = p['rating'] >= _minRating;

      return matchesSearch && matchesCategory && matchesPrice && matchesRating;
    }).toList();
  }

  // ======================================================
  // VOICE SEARCH
  // ======================================================
  // void _listen() async {
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) {
  //         if (val == 'done' || val == 'notListening') {
  //           if (mounted) setState(() => _isListening = false);
  //         }
  //       },
  //       onError: (val) {
  //         if (mounted) setState(() => _isListening = false);
  //       },
  //     );
  //
  //     if (available) {
  //       setState(() => _isListening = true);
  //       _speech.listen(
  //         listenMode: stt.ListenMode.search,
  //         partialResults: true,
  //         onResult: (val) {
  //           if (mounted) {
  //             setState(() {
  //               searchController.text = val.recognizedWords;
  //             });
  //             fetchBrands();
  //           }
  //         },
  //       );
  //     }
  //   } else {
  //     setState(() => _isListening = false);
  //     _speech.stop();
  //   }
  // }

  // ======================================================
  // CURRENCY SELECTOR
  // ======================================================
  Widget _buildCurrencySelector() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCurrency,
          icon: const Icon(Icons.expand_more, size: 18, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          dropdownColor: AppTheme.primary,
          items: const [
            DropdownMenuItem(value: "BTC", child: Text("BTC")),
            DropdownMenuItem(value: "INR", child: Text("INR")),
            DropdownMenuItem(value: "USD", child: Text("USD")),
            DropdownMenuItem(value: "GBP", child: Text("GBP")),
            DropdownMenuItem(value: "JPY", child: Text("JPY")),
            DropdownMenuItem(value: "EUR", child: Text("EUR")),
          ],
          onChanged: (v) {
            if (v != null) setState(() => selectedCurrency = v);
          },
        ),
      ),
    );
  }

  // ======================================================
  // SEARCH BOX + FILTER/SORT ROW
  // (matches the Combo marketplace screen's buildSearchTools() pattern exactly)
  // ======================================================
  Widget buildSearchTools() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ── Search Bar ──
          Expanded(
            flex: 4,
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => fetchBrands(),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, size: 18),
                // suffixIcon: IconButton(
                //   icon: Icon(
                //     _isListening ? Icons.mic : Icons.mic_none,
                //     color: _isListening ? AppTheme.error : AppTheme.secondary,
                //     size: 18,
                //   ),
                //   onPressed: _listen,
                //   padding: EdgeInsets.zero,
                //   constraints: const BoxConstraints(),
                // ),
                filled: true,
                fillColor: AppTheme.surfaceContainer,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(width: 8),

          // ── Filter Button with Label ──
          _buildActionButton(
            icon: Icons.filter_list,
            label: 'Filter',
            onTap: () => _showFilterBottomSheet(context),
          ),

          const SizedBox(width: 4),

          // ── Sort Button with Label ──
          _buildActionButton(
            icon: Icons.swap_vert,
            label: 'Sort',
            onTap: _showSortBottomSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // SORT BOTTOM SHEET
  // ======================================================
  void _showSortBottomSheet() {
    final sortOptions = [
      {'value': 'latest', 'label': 'Latest'},
      {'value': 'price_low_high', 'label': 'Price: Low → High'},
      {'value': 'price_high_low', 'label': 'Price: High → Low'},
      {'value': 'rating', 'label': 'Highest Rated'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sort Products",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...sortOptions.map((option) => RadioListTile<String>(
              activeColor: AppTheme.primary,
              value: option['value']!,
              groupValue: _selectedSort,
              title: Text(option['label']!),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSort = value);
                  Navigator.pop(context);
                  fetchBrands();
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // FILTER BOTTOM SHEET (UPDATED WITH CONSISTENT UI)
  // ======================================================
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Categories',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    if (_isLoadingCategories)
                      const Center(child: CircularProgressIndicator())
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getCategoryNames().map((cat) {
                          final isSel = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            onSelected: (val) {
                              setModalState(() => _selectedCategory = cat);
                              setState(() => _selectedCategory = cat);
                            },
                            selectedColor: AppTheme.primary,
                            backgroundColor: AppTheme.surfaceContainer,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price Limit (₹)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('₹${_priceLimit.round()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary)),
                      ],
                    ),
                    Slider(
                      value: _priceLimit,
                      min: 10.0,
                      max: 1000.0,
                      divisions: 99,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.surfaceContainer,
                      onChanged: (val) {
                        setModalState(() => _priceLimit = val);
                        setState(() => _priceLimit = val);
                      },
                    ),
                    const Divider(height: 32),
                    const Text('Minimum Rating',
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...[0.0, 3.0, 4.0, 4.5].map((rating) {
                      final label = rating == 0.0
                          ? 'Any Rating'
                          : '${rating.toString()}+ Stars';
                      return RadioListTile<double>(
                        value: rating,
                        groupValue: _minRating,
                        onChanged: (val) {
                          setModalState(() => _minRating = val ?? 0.0);
                          setState(() => _minRating = val ?? 0.0);
                        },
                        activeColor: AppTheme.primary,
                        contentPadding: EdgeInsets.zero,
                        title: Text(label, style: const TextStyle(fontSize: 13)),
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategory = 'All';
                                _priceLimit = 1000.0;
                                _minRating = 0.0;
                              });
                              setState(() {
                                _selectedCategory = 'All';
                                _priceLimit = 1000.0;
                                _minRating = 0.0;
                              });
                              Navigator.pop(context);
                              fetchBrands();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Reset All',
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              fetchBrands();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Apply Filters',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ======================================================
  // EMPTY STATE
  // ======================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_off_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Product not Found',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 768) {
      crossAxisCount = 3;
    }

    Widget content = Column(
      children: [
        buildSearchTools(),
        if (_isLoadingBrands || _isLoadingCategories)
          const LinearProgressIndicator(
            color: AppTheme.primary,
            backgroundColor: AppTheme.surfaceContainer,
            minHeight: 2,
          ),
        Expanded(
          child: (!_isLoadingBrands && _filteredProducts.isEmpty)
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: () async {
              await fetchCategories();
              await fetchBrands();
            },
            color: AppTheme.primary,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.64,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _ProductCard(
                  product: product,
                  onToggleWishlist: () => toggleWishlist(product),
                );
              },
            ),
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: LuxeHeader(
        trailingWidget: _buildCurrencySelector(),
      ),
      body: content,
    );
  }
}

// ======================================================
// PRODUCT CARD (SEPARATE STATELESS WIDGET)
// ======================================================
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onToggleWishlist;

  const _ProductCard({
    required this.product,
    required this.onToggleWishlist,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BrandingDetailPage(productId: product['id']),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EDEC), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 115,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product['image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE1F5EE),
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Color(0xFF9FE1CB), size: 36),
                    ),
                  ),

                  // Discount badge
                  if (product['discountBadge'] != null &&
                      product['discountBadge'].toString().isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F6E56),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product['discountBadge'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      shape: const CircleBorder(),
                      color: Colors.white.withOpacity(0.95),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onToggleWishlist,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            product['favorite'] == true
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: product['favorite'] == true
                                ? Colors.redAccent
                                : const Color(0xFF0F6E56),
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card body
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product title + store
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1C1B1B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        product['store'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: Color(0xFF6B7E7D),
                        ),
                      ),
                    ],
                  ),

                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFEF9F27), size: 13),
                      const SizedBox(width: 3),
                      Text(
                        product['rating'].toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1B1B),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${product['reviews']})',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF9E9E9E)),
                      ),
                    ],
                  ),

                  // Retail price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Retail price',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFF9E9E9E)),
                      ),
                      Text(
                        '₹${(product['btcPrice'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),

                  // Bulk price box
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bulk price',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF085041),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${(product['btbPrice'] as double).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F6E56),
                              ),
                            ),
                            Text(
                              'Min: ${product['minUnits']} units',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1D9E75),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // CTA button
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 32,
                  //   child: ElevatedButton(
                  //     onPressed: () => Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) =>
                  //             BrandingDetailPage(productId: product['id']),
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xFF0F6E56),
                  //       foregroundColor: Colors.white,
                  //       padding: EdgeInsets.zero,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Customize logo',
                  //       style: TextStyle(
                  //         fontSize: 11,
                  //         fontWeight: FontWeight.w600,
                  //         letterSpacing: 0.2,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}