import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';
import '../common/header.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'B2B_HomeScreen.dart';


class ComboMarketplaceScreena extends StatefulWidget {
  const ComboMarketplaceScreena({Key? key}) : super(key: key);

  @override
  State<ComboMarketplaceScreena> createState() => _ComboMarketplaceScreenState();
}

class _ComboMarketplaceScreenState extends State<ComboMarketplaceScreena> {
  // Define endpoint configuration tracking reference block
  // Replace with your server's IP address or domain endpoint (e.g., 'http://10.0.2.2/api/...' for Android Emulator)
  static const String apiUrl = '${baseUrl}new_apis/combo_shop_API.php';

  List<dynamic> _products = [];
  List<String> _categories = [];
  List<String> _selectedCategories = [];

  bool _isLoadingProducts = true;
  bool _isLoadingCategories = true;
  String _searchQuery = '';
  String selectedCurrency = "INR";
  final TextEditingController searchController = TextEditingController();

  // Voice search
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();

  // Sort state
  String _selectedSort = 'latest';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- API FUNCTION: Get Categories ---
  Future<void> fetchCategories() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'get_categories','vendor_id': UserSessionSet.instance.vendorId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            _categories = List<String>.from(jsonResponse['data']);
            _isLoadingCategories = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  // --- API FUNCTION: Filter / Fetch Products ---
  Future<void> fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final Map<String, dynamic> requestBody = {
        'action': 'filter_products',
        'page': 1,
        'limit': 20,
        'sort': _selectedSort, // Add sort parameter
        'vendor_id': UserSessionSet.instance.vendorId,

      };

      if (_selectedCategories.isNotEmpty) {
        requestBody['category'] = _selectedCategories;
      }
      if (_searchQuery.isNotEmpty) {
        requestBody['search_keywords'] = _searchQuery;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint("filter_products API Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            _products = jsonResponse['data'];
            _isLoadingProducts = false;
          });
        }
      } else {
        setState(() => _isLoadingProducts = false);
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching products: $e\n$stackTrace');
      setState(() => _isLoadingProducts = false);
    }
  }

  // --- API FUNCTION: Add to Cart ---
  Future<void> addToCart(int productId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'addToCart',
          'product_id': productId,
          'vendor_id': UserSessionSet.instance.vendorId,

        }),
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  jsonResponse['message'] ?? 'Added to cart successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(jsonResponse['message'] ?? 'Failed to add item to cart'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error adding item to cart: $e')),
      );
    }
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
  //               _searchController.text = val.recognizedWords;
  //               _searchQuery = val.recognizedWords;
  //             });
  //             fetchProducts();
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
  // (matches the BTC marketplace screen's buildSearchTools() /
  // MarketplaceActionBar pattern exactly)
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const MarketplaceFilterSheet(),
              );
            },
          ),

          const SizedBox(width: 4),

          // ── Sort Button with Label ──
          _buildActionButton(
            icon: Icons.filter_list,
            label: 'Filter',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const MarketplaceFilterSheet(),
              );
            },
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
  // CATEGORY CHIPS (MOVED FROM MAIN BUILD)
  // ======================================================
  Widget _buildCategoryChips() {
    if (_selectedCategories.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _selectedCategories.map((catName) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              backgroundColor: AppTheme.surfaceContainer,
              label: Text(
                catName,
                style: TextStyle(color: AppTheme.primary),
              ),
              onDeleted: () {
                setState(() {
                  _selectedCategories.remove(catName);
                });
                fetchProducts();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
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
                  fetchProducts();
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Categories',
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
                  if (_isLoadingCategories)
                    const Center(child: CircularProgressIndicator())
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((category) {
                            final bool isChecked =
                            _selectedCategories.contains(category);
                            return FilterChip(
                              label: Text(category),
                              selected: isChecked,
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isChecked ? Colors.white : Colors.black,
                              ),
                              onSelected: (bool selected) {
                                setModalState(() {
                                  if (selected) {
                                    _selectedCategories.add(category);
                                  } else {
                                    _selectedCategories.remove(category);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _selectedCategories.clear());
                            Navigator.pop(context);
                            fetchProducts();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('Reset All'),
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
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            fetchProducts();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('Apply Filters'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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

    return Scaffold(
      appBar: LuxeHeader(
        trailingWidget: _buildCurrencySelector(

        ),
      ),
      body: Column(
        children: [
          buildSearchTools(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data Loading Controller Framework Layout
                  if (_isLoadingProducts)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_products.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('No combo packages found match options.'),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.64,
                      ),
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return _ProductCard(
                          product: product,
                          onAddToCart: () =>
                              addToCart(int.parse(product['id'].toString())),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  // const LuxeFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// PRODUCT CARD (COMPLETELY UNCHANGED)
// ======================================================
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddToCart;

  const _ProductCard(
      {required this.product, required this.onAddToCart, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Process multiple imagery strings fetched from backend
    final List<dynamic> imageUrls = product['image_urls'] ?? [];
    final String mainImage = imageUrls.isNotEmpty
        ? imageUrls[0]
        : 'https://s.alicdn.com/@sc04/kf/H506b21c0c7784717a5a0d54e9fee3826C.jpg_300x300.jpg';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F3F2),
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Image.network(
                    mainImage,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                    const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 16,
                    child: const Icon(Icons.favorite_border,
                        size: 18, color: Colors.black87),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product['seller_name'] ?? 'Vendor Shop',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                        const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(' 5.0',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product['combo_title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4E6E5).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${product['combo_discount'] ?? '0'}% OFF COMBO',
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF576867))),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFBDC9C8)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Deal Price:',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const Spacer(),
                    Text(
                      '₹${product['combo_price']}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                if (product['combo_original_price'] != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text('MSRP:',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      Text(
                        '₹${product['combo_original_price']}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),

                // Add to Cart Action Call Trigger Button Link Interface
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: onAddToCart,
                    child: const Text('Add To Cart',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}