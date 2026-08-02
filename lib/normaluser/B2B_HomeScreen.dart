import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';
import '../common/header.dart';
import '../core/theme/app_theme.dart';
import 'Btb_product_details.dart';

// ======================================================
// PRODUCT MODEL
// ======================================================
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

  factory ProductModel.fromBackendJson(Map<String, dynamic> json) {
    final product = json['product_details'] ?? json;
    final primaryVariant =
    (json['variants'] != null && json['variants'].isNotEmpty)
        ? json['variants'][0]
        : null;

    final variantDetails =
    primaryVariant != null ? primaryVariant['variant_details'] : null;

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

// ======================================================
// MAIN MARKETPLACE SCREEN
// ======================================================
class BTBMarketplaceScreen extends StatefulWidget {
  final bool isEmbedded;
  const BTBMarketplaceScreen({super.key, this.isEmbedded = false});

  @override
  State<BTBMarketplaceScreen> createState() => _BTBMarketplaceScreenState();
}

class _BTBMarketplaceScreenState extends State<BTBMarketplaceScreen> {
  List<ProductModel> fetchedProducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    syncMarketplaceData();
  }

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
    } else {
      setState(() => isLoading = false);
      showMarketplaceToast(context, result['message'] ?? "Error loading items");
    }
  }

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
  final TextEditingController searchController = TextEditingController();

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

  String formatPrice(double btcValue) {
    final converted = btcValue * exchangeRates[selectedCurrency]!;
    if (selectedCurrency == "BTC") {
      return converted.toStringAsFixed(4);
    }
    return converted.toStringAsFixed(0);
  }

  String get symbol => symbols[selectedCurrency]!;

  @override
  Widget build(BuildContext context) {
    final bodyContent = Column(
      children: [
        buildSearchTools(),
        Expanded(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
              setState(() {
                product.wishlist = !product.wishlist;
              });

              final res = await MarketplaceApiService.addItemToWishlist(
                productId: product.id,
                variantId: product.encryptedVariantId ?? '',
              );

              if (res['success'] != true) {
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
                encryptedVariantId: product.encryptedVariantId ?? '',
                quantity: 1,
              );

              if (res['success'] == true) {
                setState(() {
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
                showMarketplaceToast(
                    context, res['message'] ?? "Error adding item to cart");
              }
            },
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: BTCTheme.background,
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
      body: bodyContent,
    );
  }

  Widget buildSearchTools() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, size: 18),
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
}

// ======================================================
// PRODUCT DETAIL SCREEN (NAVIGATED TARGET)
// ======================================================


// ======================================================
// PRODUCT GRID
// ======================================================
class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final String currency;
  final String symbol;
  final String Function(double) formatter;
  final Function(ProductModel) onWishlist;
  final Function(ProductModel) onAddCart;

  const ProductGrid({
    super.key,
    required this.products,
    required this.currency,
    required this.symbol,
    required this.formatter,
    required this.onWishlist,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .68,
      ),
      itemBuilder: (_, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          currency: currency,
          symbol: symbol,
          formatter: formatter,
          onWishlist: () => onWishlist(product),
          onAddCart: () => onAddCart(product),
          onTap: () {
            final int parsedItemId = int.tryParse(product.id) ?? 2;
            final int parsedVarId =
                int.tryParse(product.encryptedVariantId ?? '') ?? 2;

            debugPrint('itemId=$parsedItemId varId=$parsedVarId raw=${product.encryptedVariantId}');

            if (parsedItemId == 0 || parsedVarId == 0) {
              showMarketplaceToast(context, "Missing product/variant info");
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BtbProductDetailPage(
                  marketplaceId: 6,
                  itemId: parsedItemId,
                  varId: parsedVarId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ======================================================
// PRODUCT CARD
// ======================================================
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String currency;
  final String symbol;
  final String Function(double) formatter;
  final VoidCallback onWishlist;
  final VoidCallback onAddCart;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.currency,
    required this.symbol,
    required this.formatter,
    required this.onWishlist,
    required this.onAddCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 20,
            )
          ],
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
      ),
    );
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
              errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, size: 36)),
            ),
          ),
        ),
        if (product.badge.isNotEmpty)
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.badge == "NEW" ? Colors.red : BTCTheme.primary,
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
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                product.wishlist ? Icons.favorite : Icons.favorite_border,
                color: product.wishlist ? Colors.red : BTCTheme.secondary,
              ),
              onPressed: onWishlist,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.store,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: BTCTheme.secondary,
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
                color: BTCTheme.primary,
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
              color: BTCTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$symbol${formatter(product.btcOldPrice)}",
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: BTCTheme.secondary,
            ),
          ),
          Text(
            product.subtitle,
            style: const TextStyle(
              color: BTCTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            product.usdText,
            style: const TextStyle(
              color: BTCTheme.secondary,
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
                backgroundColor: const Color(0xffD4E6E5),
                foregroundColor: BTCTheme.primary,
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

// ======================================================
// THEME & SELECTOR COMPONENTS
// ======================================================
class BTCTheme {
  static const primary = Color(0xFF006565);
  static const background = Color(0xFFFCF9F8);
  static const secondary = Color(0xFF516161);
  static const surfaceLow = Color(0xFFF6F3F2);
  static const border = Color(0xFFE5E2E1);
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
            DropdownMenuItem(value: "BTC", child: Text("BTC")),
            DropdownMenuItem(value: "INR", child: Text("INR")),
            DropdownMenuItem(value: "USD", child: Text("USD")),
            DropdownMenuItem(value: "GBP", child: Text("GBP")),
            DropdownMenuItem(value: "JPY", child: Text("JPY")),
            DropdownMenuItem(value: "EUR", child: Text("EUR")),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ======================================================
// FILTER SHEET
// ======================================================
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
        border: Border(bottom: BorderSide(color: BTCTheme.border)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Filters",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            buildCheckbox("Wallets", wallets, (v) {
              setState(() {
                wallets = v!;
              });
            }),
            buildCheckbox("ASICs", asics, (v) {
              setState(() {
                asics = v!;
              });
            }),
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
            buildCheckbox("T-Shirts", tshirts, (v) {
              setState(() {
                tshirts = v!;
              });
            }),
            buildCheckbox("Hoodies", hoodies, (v) {
              setState(() {
                hoodies = v!;
              });
            }),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? .5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more),
              )
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Column(children: children),
          ),
          crossFadeState:
          expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        )
      ],
    );
  }

  Widget buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeColor: BTCTheme.primary,
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              selectedColor: const Color(0xff008080),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        Text(
          "₹${maxPrice.toInt()}",
          style: const TextStyle(
            fontSize: 20,
            color: BTCTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: maxPrice,
          min: 0,
          max: 500000,
          divisions: 500,
          activeColor: BTCTheme.primary,
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
      activeColor: BTCTheme.primary,
      title: Row(
        children: [
          ...List.generate(
            int.parse(rating),
                (_) => const Icon(
              Icons.star,
              color: BTCTheme.primary,
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
        border: Border(top: BorderSide(color: BTCTheme.border)),
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
                backgroundColor: BTCTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Apply Filters"),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Sort Products",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...options.map(
                (item) => RadioListTile<String>(
              activeColor: BTCTheme.primary,
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
// UTILITIES & EMPTY STATE
// ======================================================
class MarketplaceEmptyState extends StatelessWidget {
  const MarketplaceEmptyState({super.key});

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
              color: BTCTheme.primary.withOpacity(.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Products Found",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

void showMarketplaceToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          const Icon(Icons.info, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

void handleWishlistAction(BuildContext context, ProductModel product) {
  showMarketplaceToast(
    context,
    product.wishlist ? "Added to wishlist" : "Removed from wishlist",
  );
}

// ======================================================
// API SERVICE
// ======================================================
class MarketplaceApiService {
  static const String url = "${baseUrl}new_apis/marketplace_btb_api.php";

  static Map<String, String> get _headers => {
    "Content-Type": "application/json; charset=UTF-8",
    "Accept": "application/json",
  };

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
          "variant_id": variantId,
        }),
      );

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