import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class Product {
  final int productId;
  final int variantId;
  final String brand;
  final String name;
  final String variant;
  final int stock;
  final String image;

  Product({
    required this.productId,
    required this.variantId,
    required this.brand,
    required this.name,
    required this.variant,
    required this.stock,
    required this.image,
  });
}

class LowStockInventoryScreen extends StatefulWidget {
  final bool isEmbedded;
  const LowStockInventoryScreen({super.key, this.isEmbedded = false});

  @override
  State<LowStockInventoryScreen> createState() =>
      _LowStockInventoryScreenState();
}

class _LowStockInventoryScreenState
    extends State<LowStockInventoryScreen> {
  final searchController = TextEditingController();
  bool isLoading = true;
  List<Product> products = [];
  int criticalCount = 0;
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLowStock();
  }

  Future<void> _fetchLowStock() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final db = Database();

      // Fetch stats for Critical/Pending counts
      final statsResponse = await db.getData({
        'action': 'get_stats',
      }, endpoint: 'new_apis/ecommerce_dashboard_API.php');

      if (statsResponse['success'] == true && statsResponse['data'] != null) {
        final statsData = statsResponse['data'];
        criticalCount = int.tryParse(statsData['low_stock']?.toString() ?? '0') ?? 0;
        pendingCount = int.tryParse(statsData['pending_orders']?.toString() ?? '0') ?? 0;
      }

      // Fetch actual stock list
      final response = await db.getData({
        'action': 'stockList',
      }, endpoint: 'new_apis/inventory_update.php');

      if ((response['success'] == true || response['ok'] == true) && response['data'] != null) {
        final List<dynamic> data = response['data'];
        products = data.map((item) {
          final int pId = int.tryParse(item['product_id']?.toString() ?? '0') ?? 0;
          final int vId = int.tryParse(item['variant_id']?.toString() ?? '0') ?? 0;
          final String title = item['product_title']?.toString() ?? 'Untitled Product';
          final int aStock = int.tryParse(item['a_stock']?.toString() ?? '0') ?? 0;
          final String imageUrl = item['image_url']?.toString() ?? '';
          return Product(
            productId: pId,
            variantId: vId,
            brand: "Seller Product",
            name: title,
            variant: "Variant ID: $vId",
            stock: aStock,
            image: imageUrl.isNotEmpty
                ? imageUrl
                : "https://picsum.photos/200?random=$vId",
          );
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching low stock: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateStock(Product product, int newStock) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xff006565)),
      ),
    );

    try {
      final db = Database();
      final response = await db.getData({
        'action': 'update',
        'id': product.variantId.toString(),
        'stock': newStock.toString(),
      }, endpoint: 'new_apis/inventory_update.php');

      Navigator.pop(context); // Dismiss loading dialog

      if (response['success'] == true || response['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inventory stock updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchLowStock(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? response['error']?.toString() ?? "Failed to update stock"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Product> get filteredProducts {
    if (searchController.text.isEmpty) {
      return products;
    }

    return products.where((e) {
      return e.name
          .toLowerCase()
          .contains(
            searchController.text
                .toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = RefreshIndicator(
      onRefresh: _fetchLowStock,
      color: const Color(0xff006565),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Search specific products...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xff006565),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: summaryCard(
                    Colors.red.shade50,
                    Colors.red.shade800,
                    Icons.warning,
                    "Critical",
                    "$criticalCount items",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: summaryCard(
                    const Color(0xffE5F7F7),
                    const Color(0xff006565),
                    Icons.inventory_2,
                    "Pending Orders",
                    "$pendingCount items",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            isLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xff006565)),
                    ),
                  )
                : filteredProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            "No low stock products found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: filteredProducts.map((p) {
                          return ProductCard(
                            product: p,
                            onUpdate: () {
                              showUpdateStockSheet(
                                context,
                                p,
                                _updateStock,
                              );
                            },
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xffFCF9F8),
        body: content,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Low Stock Inventory",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          )
        ],
      ),
      body: content,
    );
  }

  Widget summaryCard(
    Color bgColor,
    Color textColor,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onUpdate;

  const ProductCard({
    super.key,
    required this.product,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return SizedBox(
          width: cardWidth,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          size: 36,
                          color: Color(0xff006565),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.brand,
                          style: const TextStyle(
                            color: Color(0xff006565),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.variant,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${product.stock} units left",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xff006565),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: onUpdate,
                              child: const Text(
                                "Update",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void showUpdateStockSheet(
  BuildContext context,
  Product product,
  Function(Product, int) onSave,
) {
  final controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Current Stock: ${product.stock} units",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "New Stock Total",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006565),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final int? count = int.tryParse(controller.text);
                  if (count != null) {
                    Navigator.pop(context);
                    onSave(product, count);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid stock count"),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Update Inventory",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
