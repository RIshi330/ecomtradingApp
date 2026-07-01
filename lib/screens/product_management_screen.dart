import 'package:flutter/material.dart';
import '../Database/Database.dart';
import 'proliferation_payment_modal.dart';
import 'product_listing_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  /// Optional initial tab index: 0=B2C, 1=B2B, 2=Combo
  final int initialTab;
  final bool isEmbedded;

  const ProductManagementScreen({
    super.key,
    this.initialTab = 0,
    this.isEmbedded = false,
  });

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class ProductModel {
  String id;
  String variantId;
  String name;
  String image;
  double price;
  String sellerName;
  String categoryId;
  String brandName;
  bool active;
  bool selected;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.variantId = '0',
    this.sellerName = '',
    this.categoryId = '',
    this.brandName = '',
    this.active = true,
    this.selected = false,
  });
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  static const Color primaryPurple = Color(0xFF008080); // Teal Container/Accent
  static const Color darkPurple = Color(0xFF006565);    // Teal Primary
  static const Color bgColor = Color(0xFFFCF9F8);       // Theme background

  late int selectedTab;
  bool _isLoading = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<ProductModel> products = [];

  // Tab labels
  final List<String> tabLabels = ['BTC', 'BTB', 'COMBO'];

  // State variables for filters and sorting
  String selectedFilterCategory = 'All';
  bool filterInStockOnly = false;
  bool filterLowStockOnly = false;
  String selectedSortOption = 'Newest First';

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get selectedCount => products.where((e) => e.selected).length;

  /// Fetch products from the correct API based on the selected tab
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      products.clear();
    });

    try {
      final db = Database();

      if (selectedTab == 0) {
        // B2C — product_vendors_API 3.php -> get_managing_products
        final response = await db.getJsonData({
          'action': 'get_managing_products',
          'page': 1,
          'limit': 50,
        }, endpoint: 'new_apis/product_vendors_API 3.php');

        _parseManagingProducts(response);
      } else if (selectedTab == 1) {
        // B2B — product_btb_vendors_API 3.php -> get_managing_products
        final response = await db.getJsonData({
          'action': 'get_managing_products',
          'page': 1,
          'limit': 50,
        }, endpoint: 'new_apis/product_btb_vendors_API 3.php');

        _parseManagingProducts(response);
      } else {
        // Combo — combo_vendor_api.php -> get_combo_packages
        final response = await db.getJsonData({
          'action': 'get_combo_packages',
        }, endpoint: 'new_apis/combo_vendor_api.php');

        _parseComboPackages(response);
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Parse response from get_managing_products (B2C & B2B)
  void _parseManagingProducts(Map response) {
    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final List<dynamic> productList = data['products'] ?? [];
      setState(() {
        products = productList.map((item) {
          return ProductModel(
            id: item['product_id']?.toString() ?? '',
            variantId: item['variant_id']?.toString() ?? '0',
            name: item['product_title']?.toString() ?? 'Untitled Product',
            image: item['image_url']?.toString() ??
                'https://picsum.photos/400',
            price: double.tryParse(
                    item['price']?.toString() ?? '0') ??
                0.0,
            sellerName: item['seller_name']?.toString() ?? '',
            categoryId: item['category_id']?.toString() ?? '',
            brandName: item['brand_name']?.toString() ?? '',
            active: true,
          );
        }).toList();
      });
    }
  }

  /// Parse response from get_combo_packages (Combo)
  void _parseComboPackages(Map response) {
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> comboList =
          response['data'] is List ? response['data'] : [];
      setState(() {
        products = comboList.map((item) {
          final List<dynamic> items = item['items'] is List ? item['items'] : [];
          final String imageUrl = items.isNotEmpty
              ? (items[0]['image_url']?.toString() ?? 'https://picsum.photos/400')
              : 'https://picsum.photos/400';

          return ProductModel(
            id: item['id']?.toString() ?? '',
            variantId: '0',
            name: item['combo_title']?.toString() ?? 'Untitled Combo',
            image: imageUrl,
            price: double.tryParse(
                    item['combo_price']?.toString() ?? '0') ??
                0.0,
            sellerName: item['vendor_name']?.toString() ?? '',
            active: item['status']?.toString() == '1',
          );
        }).toList();
      });
    }
  }

  /// Fetch product stats for a specific product
  Future<void> _showProductStats(ProductModel product) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final endpoint = selectedTab == 1
          ? 'new_apis/product_btb_vendors_API 3.php'
          : 'new_apis/product_vendors_API 3.php';

      final response = await Database().getJsonData({
        'action': 'get_product_stats',
        'product_id': product.id,
      }, endpoint: endpoint);

      if (!mounted) return;
      Navigator.pop(context); // dismiss loading

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _showStatsDialog(product.name, data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message']?.toString() ?? 'Failed to get stats'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatsDialog(String title, Map data) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: darkPurple),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statTile("Home Views", data['home_site_views']?.toString() ?? '0'),
              _statTile("Partner Views", data['partner_site_views']?.toString() ?? '0'),
              _statTile("Home Orders", data['home_site_orders']?.toString() ?? '0'),
              _statTile("Partner Orders", data['partner_site_orders']?.toString() ?? '0'),
              _statTile("Assured Stock", data['assured_stock_left']?.toString() ?? '0'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  Widget _statTile(String title, String value) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkPurple,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /// Fetch collateral for a product
  Future<void> _showCollateral(ProductModel product) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final endpoint = selectedTab == 1
          ? 'new_apis/product_btb_vendors_API 3.php'
          : 'new_apis/product_vendors_API 3.php';

      final marketplaceId = selectedTab == 2 ? 52 : (selectedTab == 1 ? 16 : 5);

      final response = await Database().getJsonData({
        'action': 'get_product_collateral',
        'product_id': product.id,
        'variant_id': product.variantId,
        'marketplace_id': marketplaceId,
      }, endpoint: endpoint);

      if (!mounted) return;
      Navigator.pop(context);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> collaterals =
            response['data'] is List ? response['data'] : [];
        _showCollateralDialog(product.name, collaterals);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ??
                'No collaterals found'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCollateralDialog(String title, List<dynamic> collaterals) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Product Collateral - $title",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (collaterals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('No collaterals found',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: collaterals.length,
                      itemBuilder: (context, index) {
                        final c = collaterals[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                          title: Text(
                            c['title']?.toString() ?? 'Guide.pdf',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${c['type'] ?? 'PDF'} • ${c['for'] ?? 'General'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Delete functionality simulated for preview")),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Upload functionality simulated")),
                    );
                  },
                  icon: const Icon(
                    Icons.upload,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Upload File",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  /// Toggle status for a product or combo package
  Future<void> _toggleProductStatus(ProductModel product) async {
    if (selectedTab == 2) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final newStatus = product.active ? '0' : '1';
        final response = await Database().getJsonData({
          'action': 'update_combo_status',
          'id': product.id,
          'status': newStatus,
        }, endpoint: 'new_apis/combo_vendor_api.php');

        if (!mounted) return;
        Navigator.pop(context); // dismiss loading

        if (response['success'] == true) {
          setState(() {
            product.active = !product.active;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(product.active
                  ? 'Combo package activated successfully'
                  : 'Combo package deactivated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message']?.toString() ??
                  'Failed to update status'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Local state toggle for non-combo products
      setState(() {
        product.active = !product.active;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(product.active
              ? 'Product activated'
              : 'Product deactivated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Delete a combo package
  Future<void> _deleteComboPackage(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Combo Package',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to delete this combo package? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await Database().getJsonData({
        'action': 'delete_combo_package',
        'pid': product.id,
      }, endpoint: 'new_apis/combo_vendor_api.php');

      if (!mounted) return;
      Navigator.pop(context); // dismiss loading

      if (response['success'] == true) {
        setState(() {
          products.removeWhere((p) => p.id == product.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Combo package deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ??
                'Failed to delete combo package'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Filtered and sorted products
  List<ProductModel> get filteredProducts {
    List<ProductModel> list = List.from(products);

    // Apply Search Query Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q) ||
          p.brandName.toLowerCase().contains(q)).toList();
    }

    // Apply Category Filter
    if (selectedFilterCategory != 'All') {
      list = list.where((p) {
        final cat = selectedFilterCategory.toLowerCase();
        return p.brandName.toLowerCase().contains(cat) ||
            p.categoryId.toLowerCase().contains(cat) ||
            p.name.toLowerCase().contains(cat);
      }).toList();
    }

    // Apply Stock Filter
    if (filterInStockOnly) {
      list = list.where((p) {
        final stock = ((int.tryParse(p.id) ?? 0) % 50) + 2;
        return stock > 5;
      }).toList();
    }
    if (filterLowStockOnly) {
      list = list.where((p) {
        final stock = ((int.tryParse(p.id) ?? 0) % 50) + 2;
        return stock <= 5;
      }).toList();
    }

    // Apply Sorting
    if (selectedSortOption == 'Price Low → High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSortOption == 'Price High → Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (selectedSortOption == 'Stock Level') {
      list.sort((a, b) {
        final stockA = ((int.tryParse(a.id) ?? 0) % 50) + 2;
        final stockB = ((int.tryParse(b.id) ?? 0) % 50) + 2;
        return stockA.compareTo(stockB);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: darkPurple),
                      onPressed: () => Navigator.pop(context),
                    )
                  : IconButton(
                      icon: const Icon(Icons.menu, color: darkPurple),
                      onPressed: () {},
                    ),
              title: const Text(
                "Manage Products",
                style: TextStyle(
                  color: darkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                    _fetchProducts();
                  },
                  icon: const Icon(Icons.refresh, color: darkPurple),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12, left: 4),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.person, color: darkPurple, size: 20),
                  ),
                )
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              _buildTabs(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryPurple))
                    : filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'No ${tabLabels[selectedTab]} products found',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Products listed on the platform will appear here.',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: primaryPurple,
                            onRefresh: _fetchProducts,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(
                                    filteredProducts[index]);
                              },
                            ),
                          ),
              ),
              if (selectedCount > 0)
                const SizedBox(height: 90),
            ],
          ),
        ],
      ),
      bottomSheet: selectedCount > 0
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$selectedCount Selected",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: darkPurple,
                          ),
                        ),
                        const Text(
                          "Bulk actions available",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      minimumSize: const Size(0, 48), // Avoid infinite width from theme when used inside a Row
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductProliferationScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Proceed",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductListingScreen(),
            ),
          );
        },
        backgroundColor: darkPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Tab bar: BTC | BTB | COMBO
  Widget _buildTabs() {
    return Row(
      children: [
        _buildSingleTab(0, "BTC"),
        _buildSingleTab(1, "BTB"),
        _buildSingleTab(2, "COMBO"),
      ],
    );
  }

  Widget _buildSingleTab(int index, String title) {
    bool active = selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = index;
            _searchQuery = '';
            _searchController.clear();
          });
          _fetchProducts();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? darkPurple : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? darkPurple : Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search products, SKUs...",
                prefixIcon: const Icon(Icons.search, color: primaryPurple),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: darkPurple),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list, color: darkPurple),
            onPressed: () => _showFilterModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: darkPurple),
            onPressed: () => _showSortModal(context),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Products",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedFilterCategory,
                    items: const [
                      DropdownMenuItem(
                        value: "All",
                        child: Text("All Categories"),
                      ),
                      DropdownMenuItem(
                        value: "Serum",
                        child: Text("Serum / Skincare"),
                      ),
                      DropdownMenuItem(
                        value: "Tee",
                        child: Text("Tee / Apparel"),
                      ),
                      DropdownMenuItem(
                        value: "Luxe",
                        child: Text("Luxe / Premium"),
                      ),
                    ],
                    onChanged: (value) {
                      modalSetState(() {
                        selectedFilterCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: filterInStockOnly,
                    activeColor: darkPurple,
                    onChanged: (value) {
                      modalSetState(() {
                        filterInStockOnly = value ?? false;
                        if (filterInStockOnly) filterLowStockOnly = false;
                      });
                    },
                    title: const Text("In Stock Only"),
                  ),
                  CheckboxListTile(
                    value: filterLowStockOnly,
                    activeColor: darkPurple,
                    onChanged: (value) {
                      modalSetState(() {
                        filterLowStockOnly = value ?? false;
                        if (filterLowStockOnly) filterInStockOnly = false;
                      });
                    },
                    title: const Text("Low Stock Only"),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Apply Filters",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Sort Products By",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text("Newest First"),
              trailing: selectedSortOption == "Newest First" ? const Icon(Icons.check, color: darkPurple) : null,
              onTap: () {
                setState(() {
                  selectedSortOption = "Newest First";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Price Low → High"),
              trailing: selectedSortOption == "Price Low → High" ? const Icon(Icons.check, color: darkPurple) : null,
              onTap: () {
                setState(() {
                  selectedSortOption = "Price Low → High";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Price High → Low"),
              trailing: selectedSortOption == "Price High → Low" ? const Icon(Icons.check, color: darkPurple) : null,
              onTap: () {
                setState(() {
                  selectedSortOption = "Price High → Low";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Stock Level"),
              trailing: selectedSortOption == "Stock Level" ? const Icon(Icons.check, color: darkPurple) : null,
              onTap: () {
                setState(() {
                  selectedSortOption = "Stock Level";
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCouponModal(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Manage Coupons",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Coupon %",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
              ),
              const SizedBox(height: 15),
              const ListTile(
                leading: Icon(Icons.local_offer, color: darkPurple),
                title: Text("SUMMER15"),
                subtitle: Text("15% OFF"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: darkPurple),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Coupon of ${controller.text}% updated successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  void _showDiscountModal(BuildContext context) {
    final controller = TextEditingController();
    String discountCategory = "Retail";

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Tiered Discounts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: discountCategory,
                    decoration: const InputDecoration(
                      labelText: "Target Audience",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Retail",
                        child: Text("Retail Customers"),
                      ),
                      DropdownMenuItem(
                        value: "Wholesale",
                        child: Text("Wholesale Partners"),
                      ),
                    ],
                    onChanged: (val) {
                      dialogSetState(() {
                        discountCategory = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Discount %",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: darkPurple),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Tiered discount for $discountCategory set to ${controller.text}%"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    bool isSelected = product.selected;
    int stock = ((int.tryParse(product.id) ?? 0) % 50) + 2;
    bool promoted = (int.tryParse(product.id) ?? 0) % 3 == 0;
    double oldPrice = product.price * 1.3;
    double savings = oldPrice - product.price;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return SizedBox(
          width: cardWidth,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: promoted
                  ? const BorderSide(
                      color: darkPurple,
                      width: 1.5,
                    )
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isSelected,
                    activeColor: Colors.grey,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) {
                      setState(() {
                        product.selected = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          size: 32,
                          color: darkPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: _buildProductPopupMenu(product),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "SKU: ${product.id}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "$stock units",
                                style: const TextStyle(fontSize: 10, color: Colors.black87),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.active ? Colors.teal.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.active ? "Active" : "Inactive",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: product.active ? Colors.teal.shade900 : Colors.red.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (promoted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Promoted",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "₹${product.price.toInt()}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: darkPurple,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "₹${oldPrice.toInt()}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Save ₹${savings.toInt()}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
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

  Widget _buildProductPopupMenu(ProductModel product) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.grey,
      ),
      onSelected: (value) {
        if (value == "stats") {
          _showProductStats(product);
        }
        if (value == "edit") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductListingScreen(),
            ),
          );
        }
        if (value == "coupon") {
          _showCouponModal(context);
        }
        if (value == "discount") {
          _showDiscountModal(context);
        }
        if (value == "collateral") {
          _showCollateral(product);
        }
        if (value == "toggle") {
          _toggleProductStatus(product);
        }
        if (value == "delete") {
          _deleteComboPackage(product);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: "stats",
          child: Text("Product Stats"),
        ),
        const PopupMenuItem(
          value: "edit",
          child: Text("Edit Product"),
        ),
        const PopupMenuItem(
          value: "coupon",
          child: Text("Update Coupon"),
        ),
        const PopupMenuItem(
          value: "discount",
          child: Text("Update Discount"),
        ),
        const PopupMenuItem(
          value: "collateral",
          child: Text("Product Collateral"),
        ),
        PopupMenuItem(
          value: "toggle",
          child: Text(product.active ? "Deactivate Product" : "Activate Product"),
        ),
        if (selectedTab == 2)
          const PopupMenuItem(
            value: "delete",
            child: Text("Delete Package", style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}

class PlatformModel {
  final int id;
  final String name;
  final String url;
  final int price;
  final String approval;
  final String reach;
  final String type;
  final String image;
  final String about;
  final List<String> categories;

  PlatformModel({
    required this.id,
    required this.name,
    required this.url,
    required this.price,
    required this.approval,
    required this.reach,
    required this.type,
    required this.image,
    required this.about,
    required this.categories,
  });
}

class ProductProliferationScreen extends StatefulWidget {
  const ProductProliferationScreen({
    super.key,
  });

  @override
  State<ProductProliferationScreen> createState() =>
      _ProductProliferationScreenState();
}

class _ProductProliferationScreenState extends State<ProductProliferationScreen> {
  List<PlatformModel> basket = [];
  bool basketExpanded = false;
  List<PlatformModel> platforms = [];
  List<String> categories = [];
  bool _isLoading = false;
  List<String> _savedBasketIds = [];

  String selectedPlatform = "All";
  String selectedApproval = "All";
  String selectedPricing = "All";
  String selectedReach = "All";
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _initCart();
    await _fetchCategories();
    await _fetchSites();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _initCart() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getJsonData({
        'action': 'initialise_cart',
      }, endpoint: 'new_apis/select_sites_API 1.php');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final String sitesStr = data['sites']?.toString() ?? '';
        final List<String> siteIds = sitesStr.split(',').where((e) => e.isNotEmpty).toList();
        _savedBasketIds = siteIds;
      }
    } catch (e) {
      debugPrint('Error initializing cart: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Database().getJsonData({
        'action': 'get_categories',
      }, endpoint: 'new_apis/select_sites_API 1.php');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> catList = response['data'] is List ? response['data'] : [];
        setState(() {
          categories = catList
              .map((e) => e['item_title']?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _fetchSites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final approvalVal = selectedApproval == "All"
          ? ""
          : (selectedApproval == "Auto Approve" ? "0" : "1");

      final pricingVal = selectedPricing == "All"
          ? ""
          : (selectedPricing == "Free" ? "free" : "paid");

      final categoryList = selectedPlatform == "All" ? [] : [selectedPlatform];

      final response = await Database().getJsonData({
        'action': 'get_site_cards',
        'marketplace_id': 0,
        'keyword': searchController.text,
        'approval_type': approvalVal,
        'payment_type': pricingVal,
        'categories': categoryList,
      }, endpoint: 'new_apis/select_sites_API 1.php');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> siteList = response['data'] is List ? response['data'] : [];
        setState(() {
          platforms = siteList.map((item) {
            final int id = int.tryParse(item['site_id']?.toString() ?? '0') ?? 0;
            final String name = item['site_name']?.toString() ?? '';
            final String logo = item['site_logo']?.toString() ?? 'https://picsum.photos/400';
            final String about = item['about_site']?.toString() ?? '';
            final int needApproval = int.tryParse(item['need_approval']?.toString() ?? '0') ?? 0;
            final String approvalStr = needApproval == 1 ? "Manual Review" : "Auto Approve";
            final double avgPrice = double.tryParse(item['avg_price']?.toString() ?? '0') ?? 0.0;
            final bool isFree = item['is_free_posting'] == true || avgPrice == 0;
            final String typeStr = isFree ? "Free" : "Paid";

            final List<dynamic> catData = item['categories'] is List ? item['categories'] : [];
            final List<String> siteCats = catData.map((e) => e['item_title']?.toString() ?? '').where((e) => e.isNotEmpty).toList();

            return PlatformModel(
              id: id,
              name: name,
              url: name.toLowerCase().replaceAll(' ', '') + ".com",
              price: avgPrice.round(),
              approval: approvalStr,
              reach: "20K",
              type: typeStr,
              image: logo,
              about: about,
              categories: siteCats,
            );
          }).toList();

          basket = platforms.where((p) => _savedBasketIds.contains(p.id.toString())).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching sites: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void resetFilters() {
    setState(() {
      selectedPlatform = "All";
      selectedApproval = "All";
      selectedPricing = "All";
      selectedReach = "All";
      searchController.clear();
    });
    _fetchSites();
  }

  void openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Refine proliferation platforms",
                    ),
                    const SizedBox(height: 24),
                    buildPlatformFilter(modalSetState),
                    const SizedBox(height: 16),
                    buildApprovalFilter(modalSetState),
                    const SizedBox(height: 16),
                    buildPricingFilter(modalSetState),
                    const SizedBox(height: 16),
                    buildReachFilter(modalSetState),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: "Search Platform",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _fetchSites();
                        },
                        child: const Text(
                          "Apply Filters",
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          modalSetState(() {
                            resetFilters();
                          });
                        },
                        child: const Text(
                          "Reset Filters",
                        ),
                      ),
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

  Widget buildPlatformFilter(StateSetter modalSetState) {
    final List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(value: "All", child: Text("All")),
    ];
    for (final cat in categories) {
      items.add(DropdownMenuItem(value: cat, child: Text(cat)));
    }

    if (selectedPlatform != "All" && !categories.contains(selectedPlatform)) {
      selectedPlatform = "All";
    }

    return DropdownButtonFormField<String>(
      value: selectedPlatform,
      decoration: const InputDecoration(
        labelText: "Category",
      ),
      items: items,
      onChanged: (value) {
        modalSetState(() {
          selectedPlatform = value!;
        });
      },
    );
  }

  Widget buildApprovalFilter(StateSetter modalSetState) {
    return DropdownButtonFormField<String>(
      value: selectedApproval,
      decoration: const InputDecoration(
        labelText: "Approval Rule",
      ),
      items: const [
        DropdownMenuItem(value: "All", child: Text("All")),
        DropdownMenuItem(value: "Auto Approve", child: Text("Auto Approve")),
        DropdownMenuItem(value: "Manual Review", child: Text("Manual Review")),
      ],
      onChanged: (value) {
        modalSetState(() {
          selectedApproval = value!;
        });
      },
    );
  }

  Widget buildPricingFilter(StateSetter modalSetState) {
    return DropdownButtonFormField<String>(
      value: selectedPricing,
      decoration: const InputDecoration(
        labelText: "Pricing",
      ),
      items: const [
        DropdownMenuItem(value: "All", child: Text("All")),
        DropdownMenuItem(value: "Free", child: Text("Free")),
        DropdownMenuItem(value: "Paid", child: Text("Paid")),
      ],
      onChanged: (value) {
        modalSetState(() {
          selectedPricing = value!;
        });
      },
    );
  }

  Widget buildReachFilter(StateSetter modalSetState) {
    return DropdownButtonFormField<String>(
      value: selectedReach,
      decoration: const InputDecoration(
        labelText: "Reach",
      ),
      items: const [
        DropdownMenuItem(value: "All", child: Text("All")),
        DropdownMenuItem(value: "Small", child: Text("Small")),
        DropdownMenuItem(value: "Medium", child: Text("Medium")),
        DropdownMenuItem(value: "Large", child: Text("Large")),
      ],
      onChanged: (value) {
        modalSetState(() {
          selectedReach = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4FBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff0F766E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Product Proliferation",
          style: TextStyle(
            color: Color(0xff0F766E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0F766E),
        onPressed: openFilterDrawer,
        child: const Icon(Icons.tune, color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              buildHero(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xff0F766E)))
                    : buildGrid(),
              ),
            ],
          ),
          buildBasket(),
        ],
      ),
    );
  }

  Widget buildHero() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0F766E),
            Color(0xff14B8A6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Product Proliferation Marketplace",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Explore communities, affiliate networks and partner ecosystems.",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGrid() {
    final items = platforms;
    if (items.isEmpty) {
      return const Center(
        child: Text("No Platforms Found"),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;
        if (constraints.maxWidth > 1200) {
          columns = 3;
        } else if (constraints.maxWidth > 700) {
          columns = 2;
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            return buildPlatformCard(items[index]);
          },
        );
      },
    );
  }

  Future<void> addToBasket(PlatformModel platform) async {
    if (basket.any((e) => e.id == platform.id)) {
      return;
    }

    try {
      final response = await Database().getJsonData({
        'action': 'add_item_to_cart',
        'item_id': platform.id,
        'type': 'sites',
      }, endpoint: 'new_apis/select_sites_API 1.php');

      if (response['success'] == true) {
        setState(() {
          basket.add(platform);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${platform.name} added"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to add to cart"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding to basket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> removeFromBasket(PlatformModel platform) async {
    try {
      final response = await Database().getJsonData({
        'action': 'remove_from_proliferation_cart',
        'item_id': platform.id,
        'type': 'sites',
      }, endpoint: 'new_apis/select_sites_API 1.php');

      if (response['success'] == true) {
        setState(() {
          basket.removeWhere((e) => e.id == platform.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${platform.name} removed"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to remove from cart"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing from basket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildPlatformCard(PlatformModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffDEECEB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  item.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.url,
                      style: const TextStyle(
                        color: Color(0xff0F766E),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              buildTag(item.type),
              buildTag("${item.reach} Reach"),
              ...item.categories.map((c) => buildTag(c)),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Price",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          Text(
            item.price == 0 ? "Free" : "₹${item.price}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Approval Rule",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          buildApprovalChip(item.approval),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => openTermsDialogForSite(item),
                  child: const Text("Terms"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    addToBasket(item);
                  },
                  child: const Text("Add"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffEEFCFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff0F766E),
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget buildApprovalChip(String value) {
    final auto = value == "Auto Approve";
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: auto ? const Color(0xffECFDF5) : const Color(0xffFFF7ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: auto ? const Color(0xff047857) : const Color(0xffB45309),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> openTermsDialogForSite(PlatformModel platform) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await Database().getJsonData({
        'action': 'get_site_modals',
      }, endpoint: 'new_apis/select_sites_API 1.php');

      if (!mounted) return;
      Navigator.pop(context);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> modalList = response['data'] is List ? response['data'] : [];
        final siteModal = modalList.firstWhere(
          (m) => m['site_id']?.toString() == platform.id.toString(),
          orElse: () => null,
        );

        if (siteModal != null) {
          final String terms = siteModal['terms']?.toString() ?? 'No terms available.';
          final String priceChangeText = siteModal['price_change_text']?.toString() ?? '';
          final List<dynamic> prices = siteModal['prices'] is List ? siteModal['prices'] : [];

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text("${platform.name} Details"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Terms & Conditions",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(terms),
                      const SizedBox(height: 16),
                      if (priceChangeText.isNotEmpty) ...[
                        Text(
                          priceChangeText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F766E),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (prices.isNotEmpty) ...[
                        const Text(
                          "Marketplace Prices",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...prices.map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p['marketplace']?.toString() ?? ''),
                              Text("₹${p['price'] ?? 0}"),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              );
            },
          );
        } else {
          _showFallbackTerms(platform);
        }
      } else {
        _showFallbackTerms(platform);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showFallbackTerms(platform);
    }
  }

  void _showFallbackTerms(PlatformModel platform) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("${platform.name} Terms & Conditions"),
          content: const SingleChildScrollView(
            child: Text(
              '''
Promotion Policy:
Products must comply with platform guidelines.

Approval Rules:
Some platforms require manual review.

Refund Policy:
Paid services are non-refundable.

Restricted Products:
Prohibited products are not allowed.

Seller Responsibility:
Seller is responsible for content accuracy.
''',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  int get subtotal {
    int total = 0;
    for (final item in basket) {
      total += item.price;
    }
    return total;
  }

  int get platformFee {
    return (subtotal * 0.08).round();
  }

  int get totalAmount {
    return subtotal + platformFee;
  }

  int get totalReach {
    int reach = 0;
    for (final item in basket) {
      reach += int.parse(
        item.reach.replaceAll("K", ""),
      );
    }
    return reach;
  }

  Widget buildBasket() {
    return Positioned(
      right: 16,
      left: 16,
      bottom: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xffDEECEB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBasketHeader(),
            if (basketExpanded) buildBasketBody(),
          ],
        ),
      ),
    );
  }

  Widget buildBasketHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff0F766E),
            Color(0xff14B8A6),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Proliferation Basket",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${basket.length} Platforms Added",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                basketExpanded = !basketExpanded;
              });
            },
            icon: Icon(
              basketExpanded ? Icons.expand_more : Icons.expand_less,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBasketBody() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (basket.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No platforms added yet"),
            ),
          ...basket.map((item) => buildBasketItem(item)),
          buildSummary(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              onPressed: basket.isEmpty ? null : proceedToCheckout,
              child: const Text("Proceed To Proliferation"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBasketItem(PlatformModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8FBFB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.url,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.price == 0 ? "Free" : "₹${item.price}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              removeFromBasket(item);
            },
            child: const Text(
              "Remove",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummary() {
    return Column(
      children: [
        const Divider(),
        buildSummaryRow("Subtotal", "₹$subtotal"),
        buildSummaryRow("Platform Fee", "₹$platformFee"),
        buildSummaryRow("Estimated Reach", "${totalReach}K+"),
        const SizedBox(height: 8),
        buildSummaryRow("Total", "₹$totalAmount", true),
      ],
    );
  }

  Widget buildSummaryRow(String title, String value, [bool total = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: total ? const Color(0xff0F766E) : null,
              fontSize: total ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void proceedToCheckout() async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProliferationPaymentModal(
        basket: basket,
        totalRawPrice: totalAmount.toDouble(),
        themeColor: const Color(0xff0F766E),
      ),
    );

    if (success == true) {
      setState(() {
        basket.clear();
      });
      _initCart();
    }
  }
}
