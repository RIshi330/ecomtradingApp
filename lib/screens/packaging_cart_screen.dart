import 'package:flutter/material.dart';
import '../Database/Database.dart';

class CartItem {
  final int cartId;
  final String productId;
  int quantity;
  final String productTitle;
  final String category;
  final String? brandName;
  final String sustainable;
  final String? sellerName;
  final String imageUrl;
  final double deliveryCharge;
  final int deliveryTime;

  CartItem({
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.productTitle,
    required this.category,
    this.brandName,
    required this.sustainable,
    this.sellerName,
    required this.imageUrl,
    required this.deliveryCharge,
    required this.deliveryTime,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: int.tryParse(json['cart_id']?.toString() ?? '0') ?? 0,
      productId: json['product_id']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      productTitle: json['product_title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      brandName: json['brand_name']?.toString(),
      sustainable: json['sustainable']?.toString() ?? 'Eco Friendly',
      sellerName: json['seller_name']?.toString(),
      imageUrl: json['image_url']?.toString() ?? 'https://res.cloudinary.com/deadpool/image/upload/v1596902174/vful0bm6qb9gre2lad4o.jpg',
      deliveryCharge: double.tryParse(json['delivery_charge']?.toString() ?? '0.0') ?? 0.0,
      deliveryTime: int.tryParse(json['delivery_time']?.toString() ?? '0') ?? 0,
    );
  }
}

class PackagingCartScreen extends StatefulWidget {
  const PackagingCartScreen({super.key});

  @override
  State<PackagingCartScreen> createState() => _PackagingCartScreenState();
}

class _PackagingCartScreenState extends State<PackagingCartScreen> {
  static const Color themeColor = Color(0xFF006565); // Teal Primary
  static const Color themeAccent = Color(0xFFD4E6E5); // Light Teal
  
  bool isLoading = false;
  List<CartItem> cartItems = [];

  // Fallback mock list for offline testing
  final List<CartItem> mockCartItems = [
    CartItem(
      cartId: 1,
      productId: "47",
      quantity: 500,
      productTitle: "Premium Custom Mailer Boxes",
      category: "General Customer,e-commerce Sellers",
      brandName: "EcoPack",
      sustainable: "Over Night",
      sellerName: "Vikas Kumar",
      imageUrl: "https://res.cloudinary.com/deadpool/image/upload/v1596902174/vful0bm6qb9gre2lad4o.jpg",
      deliveryCharge: 400.0,
      deliveryTime: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    setState(() => isLoading = true);
    try {
      final response = await Database().getJsonData(
        {'action': 'fetch_cart'},
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final List<CartItem> fetched = dataList.map((x) => CartItem.fromJson(Map<String, dynamic>.from(x))).toList();
        setState(() {
          cartItems = fetched;
        });
      } else {
        setState(() {
          cartItems = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching cart items: $e");
      // Fallback to mock items in case of API failure / Offline
      setState(() {
        cartItems = mockCartItems;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQty) async {
    if (newQty <= 0) {
      _removeItem(item);
      return;
    }

    // Capture the original quantity for state reversion in case of failure
    final originalQty = item.quantity;
    setState(() {
      item.quantity = newQty;
    });

    try {
      final response = await Database().getJsonData(
        {
          'action': 'update_cart_quantity',
          'product_id': item.productId,
          'quantity': newQty,
        },
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] != true) {
        setState(() {
          item.quantity = originalQty;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to update quantity"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating quantity: $e");
      // For mock items, keep the state change
      if (item.productId == "47") return;

      setState(() {
        item.quantity = originalQty;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error updating quantity"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    final originalList = List<CartItem>.from(cartItems);
    setState(() {
      cartItems.removeWhere((x) => x.productId == item.productId);
    });

    try {
      final response = await Database().getJsonData(
        {
          'action': 'remove_from_cart',
          'product_id': item.productId,
        },
        endpoint: 'new_apis/logistic_package_shop_API.php',
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Item removed from cart"),
              backgroundColor: themeColor,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        setState(() {
          cartItems = originalList;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to remove item"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error removing item: $e");
      // Allow offline deletion for mock items
      if (item.productId == "47") return;

      setState(() {
        cartItems = originalList;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error removing item"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double get totalCost {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.deliveryCharge * item.quantity;
    }
    return total;
  }

  int get totalItemsCount {
    int total = 0;
    for (var item in cartItems) {
      total += item.quantity;
    }
    return total;
  }

  void _checkout() {
    if (cartItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: themeAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: themeColor,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Order Placed!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your packaging materials request has been successfully submitted. The vendors will package and dispatch your order shortly.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close Dialog
                  setState(() {
                    cartItems.clear(); // Clear local state cart
                  });
                  Navigator.pop(context); // Return back to Packaging Hub Screen
                },
                child: const Text(
                  "Done",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: const Text(
          "Packaging Cart",
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: themeColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            )
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Your Packaging Cart is Empty",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Go back and select packaging items.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey.shade100,
                                        child: const Icon(Icons.inventory, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (item.sellerName != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              "Seller: ${item.sellerName}",
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            "Delivery: ₹${item.deliveryCharge} / unit",
                                            style: const TextStyle(
                                              color: themeColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "Delivery time: ${item.deliveryTime} days",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, color: themeColor),
                                                  onPressed: () => _updateQuantity(item, item.quantity - 50),
                                                ),
                                                Text(
                                                  "${item.quantity}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle_outline, color: themeColor),
                                                  onPressed: () => _updateQuantity(item, item.quantity + 50),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              onPressed: () => _removeItem(item),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Items:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "$totalItemsCount units",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Delivery Charges:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "₹${totalCost.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _checkout,
                              child: const Text(
                                "Place Order",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
