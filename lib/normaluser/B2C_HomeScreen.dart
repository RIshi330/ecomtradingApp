import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../app_constants.dart';
import '../common/header.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'Product_details_page.dart';

// Update your existing ProductModel with this factory mapping clean parsed logic
class ProductModel {
  final String id;
  final String store;
  final String title;
  final double rating;
  final double btcPrice;
  final double btcOldPrice;
  final String badge;
  final String subtitle;
  final String usdText;
  final String image;
  bool wishlist;

  // Custom tracking ID fields needed for transactional API processing mutations
  final String? encryptedVariantId;

  ProductModel({
    required this.id,
    required this.store,
    required this.title,
    required this.rating,
    required this.btcPrice,
    required this.btcOldPrice,
    required this.badge,
    required this.subtitle,
    required this.usdText,
    required this.image,
    this.wishlist = false,
    this.encryptedVariantId,
  });

  /// Factory blueprint map to serialize backend API data matrices cleanly
  factory ProductModel.fromBackendJson(Map<String, dynamic> json) {
    final product = json['product_details'] ?? json;
    final primaryVariant =
    (json['variants'] != null && json['variants'].isNotEmpty)
        ? json['variants'][0]
        : null;

    final variantDetails =
    primaryVariant != null ? primaryVariant['variant_details'] : null;

    // Fallback math engines matching your PHP schema fields configurations
    double extractedPrice = variantDetails != null
        ? (double.tryParse(variantDetails['price'].toString()) ?? 0.0)
        : (double.tryParse(product['price'].toString()) ?? 0.0);

    double extractedMrp = variantDetails != null
        ? (double.tryParse(variantDetails['mrp'].toString()) ?? extractedPrice)
        : (double.tryParse(product['mrp'].toString()) ?? extractedPrice);

    return ProductModel(
      id: product['id']?.toString() ?? '',
      store: product['brand_name'] ?? 'Marketplace Store',
      title: product['product_title'] ?? '',
      rating: primaryVariant != null
          ? (double.tryParse(primaryVariant['rating'].toString()) ?? 5.0)
          : (double.tryParse(json['average_rating'].toString()) ?? 5.0),
      // Converting standard values back to visual comparative units if processing in BTC
      btcPrice: extractedPrice / 3662000,
      btcOldPrice: extractedMrp / 3662000,
      badge: product['label'] ?? '',
      subtitle: variantDetails != null
          ? "${variantDetails['size'] ?? ''} | ${variantDetails['color'] ?? ''}"
          : 'Available Now',
      usdText: "≈ ₹${(extractedPrice / 85).toStringAsFixed(2)} USD",
      image: primaryVariant != null
          ? (primaryVariant['image'] ?? '')
          : (json['main_image'] ?? ''),
      wishlist: json['wishlist'] == true,
      encryptedVariantId:
      variantDetails != null ? variantDetails['id']?.toString() : null,
    );
  }
}

class BTCMarketplaceScreen extends StatefulWidget {
  const BTCMarketplaceScreen({super.key});

  @override
  State<BTCMarketplaceScreen> createState() => _BTCMarketplaceScreenState();
}

class _BTCMarketplaceScreenState extends State<BTCMarketplaceScreen> {
// Place this state logic modification pattern within your initialization pipelines
  List<ProductModel> fetchedProducts = [];
  bool isLoading = false;

  final TextEditingController searchController = TextEditingController();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    syncMarketplaceData();
  }

  /// Call-out layer execution pipeline
  Future<void> syncMarketplaceData() async {
    setState(() => isLoading = true);

    final result =
    await MarketplaceApiService.fetchMarketplaceProducts(page: 1);

    if (result['success'] == true && result['data'] != null) {
      final List dynamicList = result['data']['products'] ?? [];
      setState(() {
        fetchedProducts = dynamicList
            .map((item) => ProductModel.fromBackendJson(item))
            .toList();
        isLoading = false;
      });
      print("Products fetched: ${fetchedProducts.length}");
    } else {
      setState(() => isLoading = false);
      showMarketplaceToast(context, result['message'] ?? "Error loading items");
    }
  }

  /// Dynamic filtering sync integration point
  Future<void> filterActionSearch(String criteria) async {
    setState(() => isLoading = true);
    final filterResults = await MarketplaceApiService.applyMarketplaceFilter(
      category: criteria,
      keyword: searchController.text,
    );

    if (filterResults['success'] == true && filterResults['data'] != null) {
      final List dataItems = filterResults['data'];
      setState(() {
        fetchedProducts = dataItems
            .map((item) => ProductModel.fromBackendJson(item))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  int selectedBottomNav = 1;

  String selectedCurrency = "INR";

  final Map<String, double> exchangeRates = {
    "BTC": 1,
    "INR": 3662000,
    "USD": 43500,
    "GBP": 34200,
    "JPY": 6540000,
    "EUR": 40100,
  };

  final Map<String, String> symbols = {
    "BTC": "₿",
    "INR": "₹",
    "USD": "\$",
    "GBP": "£",
    "JPY": "¥",
    "EUR": "€",
  };

  int cartCount = 2;

  final List<ProductModel> products = [
    ProductModel(
      id: "1",
      store: "Coinkite Store",
      title: "Coldcard Mk4 Device",
      rating: 4.9,
      btcPrice: 0.0034,
      btcOldPrice: 0.0038,
      badge: "PRIME DISCOUNT",
      subtitle: "Limited Stock",
      usdText: "≈ ₹154.20 USD",
      image:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuBjE2nl9b24m9I0EE10SVuL65F5HaOXeAytNUaYFBaW7U5db9z1myfiloXp65--m6G9Drct5hRSW8z63DeoetQlLPgLGIGM4Q5B1RQX6jA6lQEaFBlFU2WOvomK_I61XWgOQpSYRHGPXvnL1fdrCIK67rV_AHlRcRvjYN952UehgcMSmer7vMklJRqnn9dKMoc7vkr4UyKHF233rPMIrvRJUcmj3FD6uBqaILecBhaVq1CSlntXmnGJXBQQZebDj3ab6PEXR2k1TOE",
    ),
    ProductModel(
      id: "2",
      store: "Genesis Fashion",
      title: "Embossed Teal Tee",
      rating: 4.7,
      btcPrice: 0.0008,
      btcOldPrice: 0.0010,
      badge: "",
      subtitle: "New Arrival",
      usdText: "≈ ₹38.50 USD",
      image:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuBV34lAdPK9U3bBqPju6BFuSVauHd9V_JZ7c-I-_yeKEXcUmQ5Ps0Ka1Cli3wb_vix3AgNYPQybdjAFkZCCtSdXb5jZDchWnNNXpz6VILuFLMNfD7tLIyaqBjRmBk6FJa93b7pzndmvcW5TG7w3jUSxKY4wynDySjP4XpNUli8hFbR13iRdZdT4EKtJcluQJOAEs7DnzF4oY_Fguh1u5KvTapzZdO8lcrmL5E5qNloPnHpvxvz1LEhS_u3bYLxgGfUvlLzskDdVtCs",
    ),
    ProductModel(
      id: "3",
      store: "Minter's Mark",
      title: "Limited Gold SATS",
      rating: 5.0,
      btcPrice: 0.0012,
      btcOldPrice: 0.0015,
      badge: "NEW",
      subtitle: "Collector's Item",
      usdText: "≈ ₹54.00 USD",
      image:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuBTFGFB-Qa1RztTjJSg94P1GJCvGSyBqJj7kCEqBTSL2C4L56FzoWoSka9o_YLRqjV-FJ4Yz-yfNJelqsHqWO6mBobCffYtAcs8Tdhuz69fWmfH7kui4lpmHtRY6Z9qHPvJLV5J_BQsLRvGNLcmiU9kJhTQdvHYnMj9ab8Tn26yV79lNFwIuX09UK0imofGq14fyobBzv2hDNhDmJbtN28ROYksfssxSmmW3Bw9s7eBb43XV9XKuuCZpILf9gikzHQi6iW9Rr6mQw4",
    ),
    ProductModel(
      id: "4",
      store: "Bitmain Official",
      title: "Antminer S19 Pro",
      rating: 4.8,
      btcPrice: 0.0950,
      btcOldPrice: 0.1050,
      badge: "PRIME DISCOUNT",
      subtitle: "Heavy Hardware",
      usdText: "≈ ₹4.2k USD",
      image:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuA_7G_1zqSLd7PLRw75J-sY7lo8dbh5MqQUmmbYB_ywynkBLXjBQv4ONZHs4zDBEkJrr_UgDm9lO5r2xBvlivILV15vGqyADam83RqQplThERZaY1MVOq5DzQcwC8HKK6QqDhEmwRwCcaW5AScepTK74ycs0HlfSonFxLJB3NYR8JQYqAW-KfIPi72QGF0mZinTGLkMMP19a9RcEI5uElYJpGdT8IWlabAqI_VWlOPCN0LtD-If89MRZ1zPuJZLy62BTJZDaxZEtzY",
    ),
  ];

  String formatPrice(double btcValue) {
    final converted = btcValue * exchangeRates[selectedCurrency]!;

    if (selectedCurrency == "BTC") {
      return converted.toStringAsFixed(4);
    }

    return converted.toStringAsFixed(0);
  }

  String get symbol => symbols[selectedCurrency]!;

  // ======================================================
// UPDATE THE GRID TARGET & ADD LOADING STATES
// ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: LuxeHeader(
        trailingWidget: CurrencySelector(
          selected: selectedCurrency,
          onChanged: (value) {
            setState(() {
              selectedCurrency = value;
            });
          },
        ),
      ),
      body: Column(
        children: [
          buildSearchTools(),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
                : fetchedProducts.isEmpty
                ? const MarketplaceEmptyState()
                : ProductGrid(
              products: fetchedProducts,
              currency: selectedCurrency,
              symbol: symbol,
              formatter: formatPrice,
              onWishlist: (product) async {
                // Optimistic UI state updates
                setState(() {
                  product.wishlist = !product.wishlist;
                });

                // Fire transactional API backend updates
                final res =
                await MarketplaceApiService.addItemToWishlist(
                  productId: product.id,
                  variantId: product.encryptedVariantId ?? '',
                );

                if (res['success'] != true) {
                  // Revert state if backend validation completely fails
                  setState(() {
                    product.wishlist = !product.wishlist;
                  });
                  showMarketplaceToast(
                      context, "Failed to update wishlist status");
                } else {
                  handleWishlistAction(context, product);
                }
              },
              onAddCart: (product) async {
                showMarketplaceToast(context, "Adding to cart...");

                final res = await MarketplaceApiService.addItemToCart(
                  encryptedProductId: product.id,
                  encryptedVariantId:
                  product.encryptedVariantId ?? '',
                  quantity: 1,
                );

                if (res['success'] == true) {
                  setState(() {
                    // Dynamically update counter matching backend matrix responses
                    if (res['data'] != null &&
                        res['data']['quantity'] != null) {
                      cartCount = int.tryParse(
                          res['data']['quantity'].toString()) ??
                          (cartCount + 1);
                    } else {
                      cartCount++;
                    }
                  });
                  showMarketplaceToast(
                      context, "${product.title} added to cart");
                } else {
                  showMarketplaceToast(context,
                      res['message'] ?? "Error adding item to cart");
                }
              },
              onQuickView: (product) {
                openQuickViewDialog(
                  context: context,
                  product: product,
                  currencySymbol: symbol,
                  formatter: formatPrice,
                  onAddToCart: () async {
                    setState(() {
                      cartCount++;
                    });
                    showMarketplaceToast(
                        context, "Item added to cart");
                  },
                );
              },
            ),
          ),            // const LuxeFooter(),
        ],
      ),
    );
  }

  // PreferredSizeWidget buildAppBar() {
  //   return AppBar(
  //     backgroundColor: Colors.white,
  //     elevation: 1,
  //     toolbarHeight: 72,
  //     automaticallyImplyLeading: false,
  //     title: Row(
  //       children: [
  //         Builder(
  //           builder: (context) => IconButton(
  //             onPressed: () => Scaffold.of(context).openDrawer(),
  //             icon: const Icon(
  //               Icons.menu,
  //               color: AppTheme.primary,
  //             ),
  //           ),
  //         ),
  //         const Text(
  //           "LUXE",
  //           style: TextStyle(
  //             color: AppTheme.primary,
  //             fontWeight: FontWeight.bold,
  //             letterSpacing: 2,
  //           ),
  //         ),
  //         const Spacer(),
  //         CurrencySelector(
  //           selected: selectedCurrency,
  //           onChanged: (value) {
  //             setState(() {
  //               selectedCurrency = value;
  //             });
  //           },
  //         ),
  //         const SizedBox(width: 16),
  //         Stack(
  //           children: [
  //             const Icon(
  //               Icons.notifications,
  //               color: AppTheme.primary,
  //             ),
  //             Positioned(
  //               right: 0,
  //               top: 0,
  //               child: Container(
  //                 width: 8,
  //                 height: 8,
  //                 decoration: const BoxDecoration(
  //                   color: AppTheme.error,
  //                   shape: BoxShape.circle,
  //                 ),
  //               ),
  //             )
  //           ],
  //         ),
  //         const SizedBox(width: 20),
  //         Stack(
  //           children: [
  //             const Icon(
  //               Icons.shopping_cart,
  //               color: AppTheme.primary,
  //             ),
  //             Positioned(
  //               right: -4,
  //               top: -6,
  //               child: Container(
  //                 padding: const EdgeInsets.all(4),
  //                 decoration: const BoxDecoration(
  //                   color: AppTheme.primary,
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Text(
  //                   "$cartCount",
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 10,
  //                   ),
  //                 ),
  //               ),
  //             )
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

  /// Toggles voice listening on and off
  // void _listen() async {
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) {
  //         print('onStatus: $val');
  //         // If it stops listening automatically, update state safely
  //         if (val == 'done' || val == 'notListening') {
  //           if (mounted) setState(() => _isListening = false);
  //         }
  //       },
  //       onError: (val) {
  //         print('onError: $val');
  //         if (mounted) setState(() => _isListening = false);
  //       },
  //     );
  //
  //     if (available) {
  //       if (mounted) setState(() => _isListening = true);
  //       _speech.listen(
  //         listenMode:
  //         stt.ListenMode.search, // Optimized for short search phrases
  //         partialResults: true,
  //         onResult: (val) {
  //           if (mounted) {
  //             setState(() {
  //               searchController.text = val.recognizedWords;
  //               searchController.selection = TextSelection.fromPosition(
  //                 TextPosition(offset: searchController.text.length),
  //               );
  //             });
  //           }
  //         },
  //       );
  //     } else {
  //       print("Speech recognition not available or permission denied.");
  //     }
  //   } else {
  //     if (mounted) setState(() => _isListening = false);
  //     _speech.stop();
  //   }
  // }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
                //   // onPressed: _listen,
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
            icon: Icons.swap_vert,
            label: 'Sort',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => const MarketplaceSortSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

// Helper widget for action buttons
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
  // Dummy placeholder for categoryChip to prevent compiler errors
  Widget categoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? AppTheme.primary : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.secondary,
        ),
      ),
    );
  }
}

class CurrencySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const CurrencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          icon: const Icon(
            Icons.expand_more,
            size: 18,
            color: Colors.white,
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: AppTheme.primary,
          items: const [
            DropdownMenuItem(
              value: "BTC",
              child: Text("BTC"),
            ),
            DropdownMenuItem(
              value: "INR",
              child: Text("INR"),
            ),
            DropdownMenuItem(
              value: "USD",
              child: Text("USD"),
            ),
            DropdownMenuItem(
              value: "GBP",
              child: Text("GBP"),
            ),
            DropdownMenuItem(
              value: "JPY",
              child: Text("JPY"),
            ),
            DropdownMenuItem(
              value: "EUR",
              child: Text("EUR"),
            ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final String currency;
  final String symbol;
  final String Function(double) formatter;

  final Function(ProductModel) onWishlist;

  final Function(ProductModel) onAddCart;

  final Function(ProductModel) onQuickView;

  const ProductGrid({
    super.key,
    required this.products,
    required this.currency,
    required this.symbol,
    required this.formatter,
    required this.onWishlist,
    required this.onAddCart,
    required this.onQuickView,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        100,
      ),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .68,
      ),
      itemBuilder: (_, index) {
        return ProductCard(
          product: products[index],
          currency: currency,
          symbol: symbol,
          formatter: formatter,
          onWishlist: () => onWishlist(products[index]),
          onAddCart: () => onAddCart(products[index]),
          onQuickView: () => onQuickView(products[index]),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String currency;
  final String symbol;
  final String Function(double) formatter;

  final VoidCallback onWishlist;
  final VoidCallback onAddCart;
  final VoidCallback onQuickView;

  const ProductCard({
    super.key,
    required this.product,
    required this.currency,
    required this.symbol,
    required this.formatter,
    required this.onWishlist,
    required this.onAddCart,
    required this.onQuickView,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print("===== PRODUCT CLICKED =====");
          print("Product ID: ${product.id}");
          print("Variant ID: ${product.encryptedVariantId}");
          print("===========================");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),   // ✅ pass the real product
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: buildImage(),
              ),
              Expanded(
                flex: 6,
                child: buildInfo(),
              ),
            ],
          ),
        ));
  }

  Widget buildImage() {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (product.badge.isNotEmpty)
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color:
                product.badge == "NEW" ? AppTheme.error : AppTheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                product.badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    product.wishlist ? Icons.favorite : Icons.favorite_border,
                    color:
                    product.wishlist ? AppTheme.error : AppTheme.secondary,
                  ),
                  onPressed: onWishlist,
                ),
              ),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.visibility,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  onPressed: onQuickView,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            product.store,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: AppTheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.star,
                size: 14,
                color: AppTheme.primary,
              ),
              Text(
                product.rating.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          Text(
            "$symbol${formatter(product.btcPrice)}",
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$symbol${formatter(product.btcOldPrice)}",
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: AppTheme.secondary,
            ),
          ),
          Text(
            product.subtitle,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            product.usdText,
            style: const TextStyle(
              color: AppTheme.secondary,
              fontSize: 10,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(
                Icons.shopping_cart,
                size: 18,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryContainer,
                foregroundColor: AppTheme.primary,
              ),
              onPressed: onAddCart,
              label: const Text("Add to Cart"),
            ),
          )
        ],
      ),
    );
  }
}

class MarketplaceFilterSheet extends StatefulWidget {
  const MarketplaceFilterSheet({super.key});

  @override
  State<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends State<MarketplaceFilterSheet> {
  bool hardwareExpanded = true;
  bool apparelExpanded = false;

  double maxPrice = 50000;

  final Set<String> selectedBrands = {};

  String? selectedRating;

  bool wallets = false;
  bool asics = false;

  bool tshirts = false;
  bool hoodies = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildCategories(),
                  const SizedBox(height: 32),
                  buildBrands(),
                  const SizedBox(height: 32),
                  buildPriceRange(),
                  const SizedBox(height: 32),
                  buildRatings(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          buildBottomButtons(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outline,
          ),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Filters",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          )
        ],
      ),
    );
  }

  Widget buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        buildExpandableCategory(
          title: "Hardware",
          expanded: hardwareExpanded,
          onTap: () {
            setState(() {
              hardwareExpanded = !hardwareExpanded;
            });
          },
          children: [
            buildCheckbox(
              "Wallets",
              wallets,
                  (v) {
                setState(() {
                  wallets = v!;
                });
              },
            ),
            buildCheckbox(
              "ASICs",
              asics,
                  (v) {
                setState(() {
                  asics = v!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildExpandableCategory(
          title: "Apparel",
          expanded: apparelExpanded,
          onTap: () {
            setState(() {
              apparelExpanded = !apparelExpanded;
            });
          },
          children: [
            buildCheckbox(
              "T-Shirts",
              tshirts,
                  (v) {
                setState(() {
                  tshirts = v!;
                });
              },
            ),
            buildCheckbox(
              "Hoodies",
              hoodies,
                  (v) {
                setState(() {
                  hoodies = v!;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildExpandableCategory({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? .5 : 0,
                duration: const Duration(
                  milliseconds: 300,
                ),
                child: const Icon(
                  Icons.expand_more,
                ),
              )
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(
            milliseconds: 300,
          ),
          firstChild: const SizedBox(),
          secondChild: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 12,
            ),
            child: Column(
              children: children,
            ),
          ),
          crossFadeState:
          expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        )
      ],
    );
  }

  Widget buildCheckbox(
      String title,
      bool value,
      Function(bool?) onChanged,
      ) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeColor: AppTheme.primary,
      title: Text(title),
      onChanged: onChanged,
    );
  }

  Widget buildBrands() {
    final brands = ["Coinkite", "Bitmain", "Genesis Wear"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Brands",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: brands.map((brand) {
            bool selected = selectedBrands.contains(brand);

            return FilterChip(
              selected: selected,
              label: Text(brand),
              selectedColor: AppTheme.primaryContainer,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
              onSelected: (_) {
                setState(() {
                  if (selected) {
                    selectedBrands.remove(brand);
                  } else {
                    selectedBrands.add(brand);
                  }
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }

  Widget buildPriceRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Price Range (INR)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "₹${maxPrice.toInt()}",
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: maxPrice,
          min: 0,
          max: 500000,
          divisions: 500,
          activeColor: AppTheme.primary,
          onChanged: (value) {
            setState(() {
              maxPrice = value;
            });
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("₹0"),
            Text("₹5,00,000"),
          ],
        )
      ],
    );
  }

  Widget buildRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Rating",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        ratingTile("4"),
        ratingTile("3"),
      ],
    );
  }

  Widget ratingTile(String rating) {
    return RadioListTile<String>(
      value: rating,
      groupValue: selectedRating,
      activeColor: AppTheme.primary,
      title: Row(
        children: [
          ...List.generate(
            int.parse(rating),
                (_) => const Icon(
              Icons.star,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text("& Up")
        ],
      ),
      onChanged: (value) {
        setState(() {
          selectedRating = value;
        });
      },
    );
  }

  Widget buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.outline,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: clearAll,
              child: const Text("Clear All"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Apply Filters",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearAll() {
    setState(() {
      wallets = false;
      asics = false;
      tshirts = false;
      hoodies = false;
      selectedBrands.clear();
      selectedRating = null;
      maxPrice = 50000;
    });
  }
}
// ======================================================
// QUICK VIEW DIALOG
// ======================================================

Future<void> openQuickViewDialog({
  required BuildContext context,
  required ProductModel product,
  required String currencySymbol,
  required String Function(double) formatter,
  required VoidCallback onAddToCart,
}) async {
  final discountPercent = product.btcOldPrice > product.btcPrice
      ? (((product.btcOldPrice - product.btcPrice) / product.btcOldPrice) * 100).round()
      : 0;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Quick View",
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: 0.92 + (0.08 * curved.value),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ---- Image header ----
                    Stack(
                      children: [
                        Container(
                          height: 280,
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: Image.network(
                            product.image,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // subtle gradient so the close button/badge stay legible
                        Container(
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        if (discountPercent > 0)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "-$discountPercent% OFF",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.close_rounded, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ---- Content ----
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + rating pill
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 17),
                                    const SizedBox(width: 3),
                                    Text(
                                      product.rating.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Price block
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "$currencySymbol${formatter(product.btcPrice)}",
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 30,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (product.btcOldPrice > product.btcPrice) ...[
                                const SizedBox(width: 10),
                                Text(
                                  "$currencySymbol${formatter(product.btcOldPrice)}",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 26),

                          // Buy now — primary
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                showMarketplaceToast(context, "Redirecting to checkout...");
                                Future.delayed(
                                  const Duration(seconds: 1),
                                      () => Navigator.pop(context),
                                );
                              },
                              child: const Text(
                                "Buy Now",
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Add to cart — secondary
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                onAddToCart();
                                Navigator.pop(context);
                              },
                              label: const Text(
                                "Add To Cart",
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ======================================================
// TOAST
// ======================================================

void showMarketplaceToast(
    BuildContext context,
    String message,
    ) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          const Icon(
            Icons.info,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          )
        ],
      ),
    ),
  );
}

// ======================================================
// WISHLIST ACTIONS
// ======================================================

void handleWishlistAction(
    BuildContext context,
    ProductModel product,
    ) {
  showMarketplaceToast(
    context,
    product.wishlist ? "Added to wishlist" : "Removed from wishlist",
  );
}

// ======================================================
// BUY NOW FLOW
// ======================================================

Future<void> startCheckoutFlow(
    BuildContext context,
    ProductModel product,
    ) async {
  showMarketplaceToast(
    context,
    "Preparing checkout...",
  );

  await Future.delayed(
    const Duration(seconds: 1),
  );

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Checkout"),
        content: Text(
          "Proceed with purchase of ${product.title}?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              showMarketplaceToast(
                context,
                "Order placed successfully",
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}

// ======================================================
// CART ANIMATION HELPER
// ======================================================

class AddToCartAnimatedButton extends StatefulWidget {
  final VoidCallback onTap;

  const AddToCartAnimatedButton({
    super.key,
    required this.onTap,
  });

  @override
  State<AddToCartAnimatedButton> createState() =>
      _AddToCartAnimatedButtonState();
}

class _AddToCartAnimatedButtonState extends State<AddToCartAnimatedButton> {
  bool added = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        added ? Icons.check_circle : Icons.shopping_cart,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
        added ? AppTheme.primaryContainer : AppTheme.secondaryContainer,
        foregroundColor: added ? Colors.white : AppTheme.primary,
      ),
      onPressed: () {
        setState(() {
          added = true;
        });

        widget.onTap();

        Future.delayed(
          const Duration(milliseconds: 1500),
              () {
            if (mounted) {
              setState(() {
                added = false;
              });
            }
          },
        );
      },
      label: Text(
        added ? "Added" : "Add To Cart",
      ),
    );
  }
}
// ======================================================
// SORT SHEET
// ======================================================

class MarketplaceSortSheet extends StatefulWidget {
  const MarketplaceSortSheet({super.key});

  @override
  State<MarketplaceSortSheet> createState() => _MarketplaceSortSheetState();
}

class _MarketplaceSortSheetState extends State<MarketplaceSortSheet> {
  String selected = "Featured";

  final List<String> options = [
    "Featured",
    "Newest",
    "Price Low → High",
    "Price High → Low",
    "Highest Rated",
    "Best Selling",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Sort Products",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...options.map(
                (item) => RadioListTile<String>(
              activeColor: AppTheme.primary,
              value: item,
              groupValue: selected,
              title: Text(item),
              onChanged: (value) {
                setState(() {
                  selected = value!;
                });

                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}

// ======================================================
// EMPTY STATE
// ======================================================

class MarketplaceEmptyState extends StatelessWidget {
  const MarketplaceEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 90,
              color: AppTheme.primary.withOpacity(.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Products Found",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try changing filters or search terms.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// RESPONSIVE GRID HELPER
// ======================================================

class ResponsiveMarketplaceGrid extends StatelessWidget {
  final Widget child;

  const ResponsiveMarketplaceGrid({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1400) {
      return Center(
        child: SizedBox(
          width: 1400,
          child: child,
        ),
      );
    }

    return child;
  }
}

// ======================================================
// CURRENCY PERSISTENCE SERVICE
// ======================================================

class CurrencySettings {
  static String currency = "INR";

  static void saveCurrency(
      String value,
      ) {
    currency = value;
  }

  static String loadCurrency() {
    return currency;
  }
}

// ======================================================
// MARKETPLACE ACTION BAR
// ======================================================

class MarketplaceActionBar extends StatelessWidget {
  final VoidCallback onFilter;
  final VoidCallback onSort;

  const MarketplaceActionBar({
    super.key,
    required this.onFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(
                Icons.tune,
              ),
              label: const Text("Filter"),
              onPressed: onFilter,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(
                Icons.sort,
              ),
              label: const Text("Sort"),
              onPressed: onSort,
            ),
          ),
        ],
      ),
    );
  }
}

class MarketplaceApiService {
  // Update this with your host's actual endpoint configuration
  static const String url = "${baseUrl}new_apis/marketplace_btc_api.php";

  /// Helper to manage common headers
  static Map<String, String> get _headers => {
    "Content-Type": "application/json; charset=UTF-8",
    "Accept": "application/json",
  };

  /// 1. Fetch Default Marketplace Products (Paginated)
  static Future<Map<String, dynamic>> fetchMarketplaceProducts(
      {int page = 1, String catId = ''}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          "action": "get_marketplace_products",
          "page": page,
          "cat_id": catId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// 2. Apply Normal Filter & Search Queries
  static Future<Map<String, dynamic>> applyMarketplaceFilter({
    required String category,
    String keyword = '',
    String selectedSize = '',
    String selectedBrand = '',
    String selectedColor = '',
    double minPrice = 0,
    double maxPrice = 999999999,
    String sortingTech = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          "action": "applyNormalFilter",
          "applyNormalFilter": category,
          "keyword": keyword,
          "selectedSize": selectedSize,
          "selectedBrand": selectedBrand,
          "selectedColor": selectedColor,
          "minPrice": minPrice,
          "maxPrice": maxPrice,
          "sortingTech": sortingTech,
          'vendor_id': UserSessionSet.instance.vendorId,

        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error status code: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// 3. Add Item to Database Cart
  static Future<Map<String, dynamic>> addItemToCart({
    required String encryptedProductId,
    required String encryptedVariantId,
    int quantity = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          "action": "addToCart",
          "addToCart": encryptedProductId,
          "variant": encryptedVariantId,
          "quantity": quantity,
          'vendor_id': UserSessionSet.instance.vendorId,

        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Failed to add code: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// 4. Toggle/Add to Wishlist Status
  static Future<Map<String, dynamic>> addItemToWishlist({
    required String productId,
    required String variantId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          "action": "addToWishlist",
          "addToWishlist": productId,
          "variant": variantId,
          'vendor_id': UserSessionSet.instance.vendorId,

        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Network error code: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// 5. Fetch Full Live Details & Current Variants
  static Future<Map<String, dynamic>> getFullProductDetails({
    required String productId,
    String variantId = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          "action": "get_full_product_details",
          "product_id": productId,
          'vendor_id': UserSessionSet.instance.vendorId,

          "variant_id": variantId,
        }),
      );
      print("API RESPONSE:");
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Could not complete product detail parse error"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
