import 'package:flutter/material.dart';
import '../Database/Database.dart';
import 'packaging_cart_screen.dart';
import 'packaging_product_detail_screen.dart';

class Product {
  final String name;
  final String image;
  final double rating;
  final String price;
  final double minPrice;
  final double maxPriceVal;
  final String minOrder;
  final String badge;
  final String category;
  final String subcategory;
  final double discountPercent;
  bool isFavorite;

  // New optional fields for API integration
  final String productId;
  final String? brandName;
  final String? sellerName;
  final double deliveryCharge;
  final int deliveryTime;
  final bool canSelect;

  Product({
    required this.name,
    required this.image,
    required this.rating,
    required this.price,
    required this.minPrice,
    required this.maxPriceVal,
    required this.minOrder,
    required this.badge,
    required this.category,
    required this.subcategory,
    required this.discountPercent,
    this.isFavorite = false,
    this.productId = '',
    this.brandName,
    this.sellerName,
    this.deliveryCharge = 0.0,
    this.deliveryTime = 0,
    this.canSelect = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final double charge = double.tryParse(json['delivery_charge']?.toString() ?? '0.0') ?? 0.0;
    final int delTime = int.tryParse(json['delivery_time']?.toString() ?? '0') ?? 0;
    final String priceStr = charge > 0 ? "₹$charge" : "Free Delivery";

    return Product(
      productId: json['product_id']?.toString() ?? '',
      name: json['product_title']?.toString() ?? '',
      image: json['image_url']?.toString() ?? 'https://res.cloudinary.com/deadpool/image/upload/v1596902174/vful0bm6qb9gre2lad4o.jpg',
      rating: 4.5,
      price: priceStr,
      minPrice: charge,
      maxPriceVal: charge,
      minOrder: "Min. 100 Units",
      badge: json['sustainable']?.toString() ?? 'Eco Friendly',
      category: json['category']?.toString() ?? 'All',
      subcategory: json['brand_name']?.toString() ?? '',
      discountPercent: 10.0,
      brandName: json['brand_name']?.toString(),
      sellerName: json['seller_name']?.toString(),
      deliveryCharge: charge,
      deliveryTime: delTime,
      canSelect: json['can_select'] ?? true,
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == '1' || json['is_favorite'] == true,
    );
  }
}

class PackagingScreen extends StatefulWidget {
  final bool isEmbedded;
  const PackagingScreen({super.key, this.isEmbedded = false});

  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

class _PackagingScreenState extends State<PackagingScreen> {
  int cartCount = 0;
  String selectedCategory = "All";
  String searchText = "";
  String selectedSort = "Relevance";

  // Filter values
  double maxPrice = 2000;
  bool discount10 = false;
  bool discount25 = false;
  bool discount50 = false;

  final List<String> boxCategories = [
    "Mailer Boxes",
    "Shipping Boxes",
    "Gift Boxes",
  ];

  String selectedSubCategory = "Shipping Boxes";

  final List<String> categories = [
    "All",
    "Corrugated Boxes",
    "Eco-friendly Bags",
    "Food Containers",
  ];

  // API states
  bool isLoading = false;
  List<Product> apiProducts = [];
  List<String> sustainableOptions = [];
  Map<String, bool> selectedSustainables = {};

  @override
  void initState() {
    super.initState();
    _fetchFilters();
    _fetchProducts();
    _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    try {
      final response = await Database().getJsonData(
        {'action': 'fetch_cart_count'},
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          cartCount = int.tryParse(data['cart_count']?.toString() ?? '0') ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching cart count: $e");
    }
  }

  Future<void> _fetchFilters() async {
    try {
      final response = await Database().getJsonData(
        {'action': 'fetch_logistic_filters'},
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final fetchedCategories = List<String>.from(data['category'] ?? []);
        final fetchedSustainables = List<String>.from(data['sustainable'] ?? []);

        setState(() {
          if (fetchedCategories.isNotEmpty) {
            categories.clear();
            categories.add("All");
            categories.addAll(fetchedCategories);
          }
          if (fetchedSustainables.isNotEmpty) {
            sustainableOptions = fetchedSustainables;
            for (var item in fetchedSustainables) {
              selectedSustainables[item] = false;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching logistic filters: $e");
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => isLoading = true);
    try {
      List<String> reqCategories = [];
      if (selectedCategory != "All") {
        reqCategories.add(selectedCategory);
      }
      
      List<String> reqSustainables = [];
      selectedSustainables.forEach((key, val) {
        if (val == true) {
          reqSustainables.add(key);
        }
      });

      final Map<String, dynamic> requestBody = {
        'action': 'filter_logistic_products',
        'category': reqCategories,
        'sustainable': reqSustainables,
        'brand_name': [],
        'label_id': [],
        'page': 1,
        'limit': 20,
      };

      final response = await Database().getJsonData(
        requestBody,
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final productsList = data['products'] as List?;
        final List<Product> fetched = [];
        if (productsList != null) {
          for (var item in productsList) {
            fetched.add(Product.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        setState(() {
          apiProducts = fetched;
        });
      } else {
        setState(() {
          apiProducts = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching logistic products: $e");
      setState(() {
        apiProducts = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  final List<Product> products = [
    Product(
      name: "Premium Custom Mailer Boxes",
      image: "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&q=80&w=600",
      rating: 4.8,
      price: "₹12 - ₹18 /pc",
      minPrice: 12.0,
      maxPriceVal: 18.0,
      minOrder: "Min. 500 Units",
      badge: "Eco Friendly",
      category: "Corrugated Boxes",
      subcategory: "Mailer Boxes",
      discountPercent: 15.0,
    ),
    Product(
      name: "Kraft Paper Shipping Cartons",
      image: "https://images.unsplash.com/photo-1595079676339-1534801ad6cf?auto=format&fit=crop&q=80&w=600",
      rating: 4.5,
      price: "₹35 - ₹60 /pc",
      minPrice: 35.0,
      maxPriceVal: 60.0,
      minOrder: "Min. 100 Units",
      badge: "Heavy Duty",
      category: "Corrugated Boxes",
      subcategory: "Shipping Boxes",
      discountPercent: 10.0,
    ),
    Product(
      name: "Luxury Matte Gift Boxes",
      image: "https://images.unsplash.com/photo-1512909006721-3d6018887383?auto=format&fit=crop&q=80&w=600",
      rating: 4.9,
      price: "₹120 - ₹180 /pc",
      minPrice: 120.0,
      maxPriceVal: 180.0,
      minOrder: "Min. 50 Units",
      badge: "Premium Quality",
      category: "Corrugated Boxes",
      subcategory: "Gift Boxes",
      discountPercent: 30.0,
    ),
    Product(
      name: "Eco Ziplock Bag Pouches",
      image: "https://images.unsplash.com/photo-1607082350899-7e105aa886ae?auto=format&fit=crop&q=80&w=600",
      rating: 4.6,
      price: "₹4.5 - ₹7 /pc",
      minPrice: 4.5,
      maxPriceVal: 7.0,
      minOrder: "Min. 2000 Units",
      badge: "Food Grade",
      category: "Eco-friendly Bags",
      subcategory: "Mailer Boxes",
      discountPercent: 5.0,
    ),
    Product(
      name: "Reinforced Kraft Paper Tape",
      image: "https://images.unsplash.com/photo-1612817288484-6f916006741a?auto=format&fit=crop&q=80&w=600",
      rating: 4.9,
      price: "₹45 /roll",
      minPrice: 45.0,
      maxPriceVal: 45.0,
      minOrder: "Min. 50 Rolls",
      badge: "Recyclable",
      category: "All",
      subcategory: "Shipping Boxes",
      discountPercent: 20.0,
    ),
    Product(
      name: "Compostable Mailing Bags",
      image: "https://images.unsplash.com/photo-1586075010923-2dd4570fb338?auto=format&fit=crop&q=80&w=600",
      rating: 4.7,
      price: "₹8 - ₹12 /pc",
      minPrice: 8.0,
      maxPriceVal: 12.0,
      minOrder: "Min. 1000 Units",
      badge: "Biodegradable",
      category: "Eco-friendly Bags",
      subcategory: "Gift Boxes",
      discountPercent: 55.0,
    ),
    Product(
      name: "Bio Food Delivery Clamshells",
      image: "https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&q=80&w=600",
      rating: 4.4,
      price: "₹15 - ₹22 /pc",
      minPrice: 15.0,
      maxPriceVal: 22.0,
      minOrder: "Min. 300 Units",
      badge: "Compostable",
      category: "Food Containers",
      subcategory: "Mailer Boxes",
      discountPercent: 12.0,
    ),
  ];

  List<Product> get filteredProducts {
    final listToFilter = apiProducts.isNotEmpty ? apiProducts : products;

    final list = listToFilter.where((product) {
      if (searchText.isNotEmpty &&
          !product.name.toLowerCase().contains(searchText.toLowerCase())) {
        return false;
      }
      if (apiProducts.isEmpty) {
        if (selectedCategory != "All" && product.category != selectedCategory) {
          return false;
        }
        if (product.category == "Corrugated Boxes" &&
            product.subcategory != selectedSubCategory) {
          return false;
        }
      }
      if (product.maxPriceVal > maxPrice) {
        return false;
      }
      if (discount50 && product.discountPercent < 50.0) return false;
      if (discount25 && product.discountPercent < 25.0) return false;
      if (discount10 && product.discountPercent < 10.0) return false;
      return true;
    }).toList();

    if (selectedSort == "Price: Low to High") {
      list.sort((a, b) => a.minPrice.compareTo(b.minPrice));
    } else if (selectedSort == "Price: High to Low") {
      list.sort((a, b) => b.maxPriceVal.compareTo(a.maxPriceVal));
    } else if (selectedSort == "Rating") {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  Future<void> addToCart(Product product, {int? quantity}) async {
    // If the product doesn't have an ID, fall back to offline local addition
    if (product.productId.isEmpty) {
      setState(() {
        cartCount++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added ${product.name} to Cart (Offline Mode)"),
          backgroundColor: const Color(0xff006565),
        ),
      );
      return;
    }

    try {
      final Map<String, dynamic> requestBody = {
        'action': 'add_to_cart',
        'product_id': product.productId,
      };
      if (quantity != null) {
        requestBody['quantity'] = quantity;
      }
      final response = await Database().getJsonData(
        requestBody,
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] == true) {
        // Reload cart count dynamically
        _fetchCartCount();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']?.toString() ?? "Added ${product.name} to Cart"),
              backgroundColor: const Color(0xff006565),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']?.toString() ?? "Failed to add to cart"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error adding to cart: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error adding item to cart"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> toggleFavorite(Product product) async {
    if (product.productId.isEmpty) {
      setState(() {
        product.isFavorite = !product.isFavorite;
      });
      return;
    }

    try {
      final response = await Database().getJsonData(
        {
          'action': 'toggle_wishlist',
          'product_id': product.productId,
        },
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final bool isFav = data['is_favorite'] == 1 || data['is_favorite'] == '1' || data['is_favorite'] == true;
        setState(() {
          product.isFavorite = isFav;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']?.toString() ?? (isFav ? "Saved to wishlist" : "Removed from wishlist")),
              backgroundColor: const Color(0xff006565),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']?.toString() ?? "Failed to toggle wishlist"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error toggling wishlist: $e");
    }
  }

  void openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff006565),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          "Boxes & Cartons Subcategories",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        ...boxCategories.map(
                          (e) {
                            final isSelected = selectedSubCategory == e;
                            return ListTile(
                              leading: Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? const Color(0xff006565) : Colors.grey,
                              ),
                              title: Text(e, style: const TextStyle(fontSize: 14)),
                              onTap: () {
                                setModalState(() {
                                  selectedSubCategory = e;
                                });
                                setState(() {
                                  selectedSubCategory = e;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Price Range",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Up to ₹${maxPrice.toInt()}",
                          style: const TextStyle(
                            color: Color(0xff006565),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: maxPrice,
                          min: 0,
                          max: 5000,
                          activeColor: const Color(0xff006565),
                          onChanged: (value) {
                            setModalState(() {
                              maxPrice = value;
                            });
                            setState(() {
                              maxPrice = value;
                            });
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₹0"),
                              Text("₹5000+"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Discounts",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        CheckboxListTile(
                          value: discount10,
                          title: const Text("10% Off or More", style: TextStyle(fontSize: 14)),
                          activeColor: const Color(0xff006565),
                          onChanged: (value) {
                            setModalState(() {
                              discount10 = value!;
                            });
                            setState(() {
                              discount10 = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          value: discount25,
                          title: const Text("25% Off or More", style: TextStyle(fontSize: 14)),
                          activeColor: const Color(0xff006565),
                          onChanged: (value) {
                            setModalState(() {
                              discount25 = value!;
                            });
                            setState(() {
                              discount25 = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          value: discount50,
                          title: const Text("50% Off or More", style: TextStyle(fontSize: 14)),
                          activeColor: const Color(0xff006565),
                          onChanged: (value) {
                            setModalState(() {
                              discount50 = value!;
                            });
                            setState(() {
                              discount50 = value!;
                            });
                          },
                        ),
                        if (sustainableOptions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            "Sustainability",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          ...sustainableOptions.map((option) {
                            final isChecked = selectedSustainables[option] ?? false;
                            return CheckboxListTile(
                              value: isChecked,
                              title: Text(option, style: const TextStyle(fontSize: 14)),
                              activeColor: const Color(0xff006565),
                              onChanged: (value) {
                                setModalState(() {
                                  selectedSustainables[option] = value!;
                                });
                                setState(() {
                                  selectedSustainables[option] = value!;
                                });
                              },
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff006565)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(0, 44),
                          ),
                          onPressed: () {
                            setState(() {
                              maxPrice = 2000;
                              discount10 = false;
                              discount25 = false;
                              discount50 = false;
                              selectedSubCategory = "Shipping Boxes";
                              selectedSustainables.updateAll((key, value) => false);
                            });
                            Navigator.pop(context);
                            _fetchProducts();
                          },
                          child: const Text("Reset", style: TextStyle(color: Color(0xff006565))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006565),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(0, 44),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchProducts();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Filters Applied Successfully"),
                                backgroundColor: Color(0xff006565),
                              ),
                            );
                          },
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openProductDetailSheet(Product product) {
    int unitsSelected = 500;
    if (product.minOrder.contains("100")) {
      unitsSelected = 100;
    } else if (product.minOrder.contains("50")) {
      unitsSelected = 50;
    } else if (product.minOrder.contains("2000")) {
      unitsSelected = 2000;
    } else if (product.minOrder.contains("1000")) {
      unitsSelected = 1000;
    } else if (product.minOrder.contains("300")) {
      unitsSelected = 300;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xff006565).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.badge,
                          style: const TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.image,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${product.rating} • ${product.category}",
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                      const Spacer(),
                      Text(
                        product.price,
                        style: const TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text(
                    "Specifications & Customization",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  specRow("Minimum Order Quantity", product.minOrder),
                  if (product.brandName != null && product.brandName!.isNotEmpty)
                    specRow("Brand Name", product.brandName!),
                  if (product.sellerName != null && product.sellerName!.isNotEmpty)
                    specRow("Seller Name", product.sellerName!),
                  specRow("Estimated Production/Delivery Time", product.deliveryTime > 0 ? "${product.deliveryTime} Days" : "5 - 8 Business Days"),
                  specRow("Delivery/Service Charge", product.deliveryCharge > 0 ? "₹${product.deliveryCharge}" : "Free"),
                  specRow("Material Weight / Quality", "Eco Kraft Cardboard 320 GSM"),
                  specRow("Print Design Assistance", "Free Mockup / Digital Proofing"),
                  const Divider(height: 30),
                  const Text(
                    "Select Order Volume",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        "Order Quantity:",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black54),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (unitsSelected > 50) {
                            setSheetState(() {
                              unitsSelected -= 50;
                            });
                          }
                        },
                      ),
                      Text(
                        "$unitsSelected units",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setSheetState(() {
                            unitsSelected += 50;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff006565)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(0, 44),
                          ),
                          onPressed: () async {
                            await toggleFavorite(product);
                            setSheetState(() {});
                            setState(() {});
                          },
                          icon: Icon(
                            product.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: const Color(0xff006565),
                          ),
                          label: Text(
                            product.isFavorite ? "Saved" : "Save Item",
                            style: const TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006565),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(0, 44),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            addToCart(product, quantity: unitsSelected);
                          },
                          child: const Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget specRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProducts = filteredProducts;

    Widget content = Column(
      children: [
        // Search Bar and Filter row
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search boxes, bags, mailers...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF006565)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFF006565), width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006565),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(0, 46),
                ),
                onPressed: openFilterDrawer,
                icon: const Icon(Icons.filter_list),
                label: const Text("Filter"),
              ),
            ],
          ),
        ),

        // Horizontal Categories Row
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final category = categories[index];
              final selected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selected,
                  label: Text(category),
                  selectedColor: const Color(0xFF006565),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: selected ? Colors.transparent : Colors.grey.shade200),
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                    _fetchProducts();
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Sort Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.sort, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              const Text(
                "Sort by: ",
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedSort,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold, fontSize: 13),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xff006565), size: 18),
                  items: <String>['Relevance', 'Price: Low to High', 'Price: High to Low', 'Rating']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSort = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${activeProducts.length} items",
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Product Grid list / Empty view
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006565)),
                  ),
                )
              : activeProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "No Packaging Products Found",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Try resetting filters or changing terms.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.54,
                  ),
                  itemBuilder: (_, index) {
                    final product = activeProducts[index];
                    return ProductCard(
                      product: product,
                      onAddCart: () => addToCart(product),
                      onWishlist: () => toggleFavorite(product),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PackagingProductDetailPage(
                            productId: product.productId,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xffFCF9F8),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: const Text(
          "Packaging Hub",
          style: TextStyle(
            color: Color(0xFF006565),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF006565),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PackagingCartScreen(),
                    ),
                  ).then((_) {
                    _fetchCartCount();
                  });
                },
              ),
              Positioned(
                right: 8,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006565),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "$cartCount",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: content,
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddCart;
  final VoidCallback onWishlist;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddCart,
    required this.onWishlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.inventory, color: Colors.grey, size: 30),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: onWishlist,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: product.isFavorite ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff006565),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      product.price,
                      style: const TextStyle(
                        color: Color(0xFF006565),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      product.minOrder,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAddCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 32),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          "Add To Cart",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


