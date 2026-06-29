import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class ManageItemsScreen extends StatefulWidget {
  final bool isEmbedded;
  const ManageItemsScreen({super.key, this.isEmbedded = false});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  bool _isLoading = true;
  bool _isGridView = false;
  String _searchQuery = "";
  final _searchController = TextEditingController();

  List<ItemModel> _items = [];
  List<dynamic> _marketplaces = [];
  List<dynamic> _mainCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch marketplaces
      final mktRes = await Database().getData({}, endpoint: 'new_apis/categoryAPI.php?action=get_marketplaces');
      if (mktRes != null && mktRes['success'] == true) {
        _marketplaces = mktRes['data'] ?? [];
      }

      // Fetch categories
      final catRes = await Database().getData({
        'action': 'get_categories',
      }, endpoint: 'new_apis/items_api.php');
      if (catRes != null && catRes['success'] == true) {
        _mainCategories = catRes['data']['categories'] ?? [];
      }

      // Fetch items list
      await _fetchItems();
    } catch (e) {
      print("Error loading initial data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchItems() async {
    try {
      final res = await Database().getData({
        'action': 'get_all_items',
        'search': _searchQuery,
        'page': 1,
        'per_page': 50,
      }, endpoint: 'new_apis/items_api.php');

      if (res != null && res['success'] == true) {
        final List<dynamic> itemsList = res['data']['items'] ?? [];
        setState(() {
          _items = itemsList.map((itemData) {
            final String categoryTitle = itemData['cat_id']?.toString() ?? 'Fashion';
            final String subCategoryTitle = itemData['sub_cat_id']?.toString() ?? '';
            final String childCategoryTitle = itemData['child_cat_id']?.toString() ?? '';
            final List<String> variantsList = List<String>.from(itemData['variants'] ?? []);

            // Generate deterministic mock numbers for stats based on item ID
            final int idVal = int.tryParse(itemData['id']?.toString() ?? '1') ?? 1;
            final int mockQty = idVal % 3 == 0 ? 8 : (40 + (idVal % 60));
            final double mockWeight = 100.0 + (idVal % 8) * 120.0;
            final String mockPackaging = idVal % 2 == 0 ? "Eco-Box" : "Retail Slim";

            return ItemModel(
              id: idVal,
              title: itemData['item_name'] ?? '',
              image: itemData['image'] != null && itemData['image'].toString().isNotEmpty
                  ? itemData['image'].toString()
                  : "https://images.unsplash.com/photo-1523170335258-f5ed11844a49", // default fallback
              category: categoryTitle,
              subcategory: subCategoryTitle,
              childCategory: childCategoryTitle,
              quantity: mockQty,
              weight: mockWeight,
              packaging: mockPackaging,
              marketplace: "All Marketplaces",
              variants: variantsList,
              tags: [
                "Category: $categoryTitle",
                if (subCategoryTitle.isNotEmpty) "Sub: $subCategoryTitle",
                if (variantsList.isNotEmpty) "Variants: ${variantsList.join(', ')}",
              ],
            );
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  Future<void> _deleteItem(int id, String title) async {
    final confirm = await _showDeleteConfirmationDialog(title);
    if (confirm != true) return;

    try {
      final res = await Database().getData({
        'action': 'delete_item',
        'id': id,
      }, endpoint: 'new_apis/items_api.php');

      if (res != null && res['success'] == true) {
        _fetchItems();
        _showSuccessDialog("Item '$title' was deleted successfully.");
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(String itemTitle) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Item", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff0b1c30))),
          content: Text("Are you sure you want to delete '$itemTitle' from the inventory? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 54),
              const SizedBox(height: 16),
              const Text(
                "Success!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0b1c30)),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalQty = _items.fold<int>(0, (sum, item) => sum + item.quantity);
    final lowStockCount = _items.where((item) => item.quantity < 15).length;
    final activeListings = _items.length;
    final categoriesCount = _items.map((e) => e.category).toSet().length;

    return Scaffold(
      backgroundColor: const Color(0xfff8f9ff),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: const Color(0xfff8f9ff),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Inventory Pro",
                style: TextStyle(
                  color: Color(0xff006565),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                      onPressed: () => Navigator.pop(context),
                    )
                  : const Icon(Icons.menu, color: Color(0xff006565)),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56), // Elevate FAB above bottom nav height
        child: FloatingActionButton(
          mini: true,
          backgroundColor: const Color(0xff006565),
          foregroundColor: Colors.white,
          onPressed: _showAddItemSheet,
          elevation: 4,
          child: const Icon(Icons.add),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006565)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchItems,
              color: const Color(0xff006565),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Section (Bento Grid)
                    _buildStatsBento(
                      totalQty: totalQty,
                      lowStockCount: lowStockCount,
                      activeListings: activeListings,
                      categoriesCount: categoriesCount,
                    ),
                    const SizedBox(height: 16),

                    // Controls Section (Search + View Toggler)
                    _buildControlsBar(),
                    const SizedBox(height: 16),

                    // Products Container
                    _items.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                "No items found in database.",
                                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                              ),
                            ),
                          )
                        : _isGridView
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return ItemCard(
                                    item: item,
                                    isGridView: true,
                                    onDelete: () => _deleteItem(item.id, item.title),
                                  );
                                },
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ItemCard(
                                      item: item,
                                      isGridView: false,
                                      onDelete: () => _deleteItem(item.id, item.title),
                                    ),
                                  );
                                },
                              ),
                    const SizedBox(height: 80), // bottom space buffer
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsBento({
    required int totalQty,
    required int lowStockCount,
    required int activeListings,
    required int categoriesCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Total Items
          _buildStatCard(
            title: "Total Items",
            value: totalQty.toString(),
            footerWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xffe5eeff),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff006565),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Low Stock
          _buildStatCard(
            title: "Low Stock",
            value: lowStockCount.toString(),
            valueColor: const Color(0xffba1a1a),
            footerWidget: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xffba1a1a)),
                SizedBox(width: 4),
                Text(
                  "Action required",
                  style: TextStyle(color: Color(0xffba1a1a), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Active Listings
          _buildStatCard(
            title: "Active Listings",
            value: activeListings.toString(),
            footerWidget: Row(
              children: const [
                Icon(Icons.trending_up, size: 14, color: Color(0xff006565)),
                SizedBox(width: 4),
                Text(
                  "+5.2% from last week",
                  style: TextStyle(color: Color(0xff006565), fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Categories
          _buildStatCard(
            title: "Categories",
            value: categoriesCount.toString(),
            footerWidget: const Text(
              "Top: Fashion",
              style: TextStyle(color: Color(0xff3e4949), fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    Color valueColor = const Color(0xff0b1c30),
    required Widget footerWidget,
  }) {
    return SizedBox(
      width: 175,
      child: StatCard(
        title: title,
        value: value,
        valueColor: valueColor,
        footer: footerWidget,
      ),
    );
  }

  Widget _buildControlsBar() {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
            _fetchItems();
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Color(0xff006565)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = "";
                      });
                      _fetchItems();
                    },
                  )
                : null,
            hintText: "Search item name in database...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffbdc9c8), width: 1.2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "CATALOG INVENTORY",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xff3e4949)),
            ),
            // Toggle container
            Row(
              children: [
                const Text("View: ", style: TextStyle(fontSize: 11, color: Color(0xff3e4949), fontWeight: FontWeight.w600)),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffeff4ff),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: !_isGridView ? const Color(0xff006565) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.list,
                            size: 16,
                            color: !_isGridView ? Colors.white : const Color(0xff3e4949),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isGridView = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isGridView ? const Color(0xff006565) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            size: 16,
                            color: _isGridView ? Colors.white : const Color(0xff3e4949),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddItemSheet(
          marketplaces: _marketplaces,
          mainCategories: _mainCategories,
          onItemAdded: (newItem) {
            _fetchItems();
          },
        );
      },
    );
  }
}

class ItemModel {
  final int id;
  final String title;
  final String image;
  final String category;
  final String subcategory;
  final String childCategory;
  final int quantity;
  final double weight;
  final String packaging;
  final String marketplace;
  final List<String> variants;
  final List<String> tags;

  ItemModel({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.subcategory,
    required this.childCategory,
    required this.quantity,
    required this.weight,
    required this.packaging,
    required this.marketplace,
    required this.variants,
    required this.tags,
  });
}

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool isGridView;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.isGridView,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = item.quantity < 15;

    if (isGridView) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffbdc9c8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildImage(item.image),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Body
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffc6e9e9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(color: Color(0xff006565), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff0b1c30)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Qty: ${item.quantity}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isLowStock ? const Color(0xffba1a1a) : const Color(0xff006565),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Render compact tag icons
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.tags.take(2).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xffeff4ff),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xffbdc9c8), width: 0.8),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(color: Color(0xff3e4949), fontSize: 8, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // List Layout
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffbdc9c8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Image
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(item.image),
          ),
          // Right Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffc6e9e9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(color: Color(0xff006565), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Qty: ${item.quantity}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isLowStock ? const Color(0xffba1a1a) : const Color(0xff006565),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xff0b1c30)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xffeff4ff),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xffbdc9c8), width: 0.8),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(color: Color(0xff3e4949), fontSize: 9, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: const Color(0xffbdc9c8).withOpacity(0.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.scale_outlined, size: 13, color: Color(0xff3e4949)),
                          const SizedBox(width: 4),
                          Text(
                            "Weight: ${item.weight.toInt()}g",
                            style: const TextStyle(fontSize: 10, color: Color(0xff3e4949), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.inventory_2_outlined, size: 13, color: Color(0xff3e4949)),
                          const SizedBox(width: 4),
                          Text(
                            "Packaging: ${item.packaging}",
                            style: const TextStyle(fontSize: 10, color: Color(0xff3e4949), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xffeff4ff),
          child: const Icon(Icons.image_not_supported_outlined, color: Color(0xff006565), size: 28),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xffeff4ff),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff006565)),
            ),
          ),
        );
      },
    );
  }
}

class AddItemSheet extends StatefulWidget {
  final List<dynamic> marketplaces;
  final List<dynamic> mainCategories;
  final Function(ItemModel) onItemAdded;

  const AddItemSheet({
    super.key,
    required this.marketplaces,
    required this.mainCategories,
    required this.onItemAdded,
  });

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _db = Database();
  final _titleController = TextEditingController();
  final _weightController = TextEditingController(text: "500");
  final _qtyController = TextEditingController(text: "50");

  String? _selectedMarketplace;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedChildCategory;
  String _selectedPackaging = "Eco-Box";

  List<String> _subcategories = [];
  List<String> _childcategories = [];

  final Map<String, bool> _variants = {
    "Color": true,
    "Size": true,
    "Gender": false,
    "Material": false,
    "Fabric": false,
    "Specification": false,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubCategories(String categoryName) async {
    try {
      final res = await _db.getData({
        'action': 'get_subcategories',
        'category': categoryName,
      }, endpoint: 'new_apis/items_api.php');
      if (res != null && res['success'] == true) {
        final List<dynamic> list = res['data']['subcategories'] ?? [];
        setState(() {
          _subcategories = list.map((s) => s['title']?.toString() ?? '').toList();
          _selectedSubCategory = null;
          _selectedChildCategory = null;
          _childcategories = [];
        });
      }
    } catch (e) {
      print("Error loading subcategories: $e");
    }
  }

  Future<void> _fetchChildCategories(String subCategoryName) async {
    try {
      final res = await _db.getData({
        'action': 'get_child_categories',
        'subcategory': subCategoryName,
      }, endpoint: 'new_apis/items_api.php');
      if (res != null && res['success'] == true) {
        final List<dynamic> list = res['data']['child_categories'] ?? [];
        setState(() {
          _childcategories = list.map((c) => c['title']?.toString() ?? '').toList();
          _selectedChildCategory = null;
        });
      }
    } catch (e) {
      print("Error loading child categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle Indicator
              Center(
                child: Container(
                  width: 48,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xffbdc9c8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add New Item",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff0b1c30)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xff3e4949)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Upload Product Image Mock Container
              const Text(
                "Upload Product Image",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff3e4949)),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xffeff4ff),
                  border: Border.all(color: const Color(0xffbdc9c8), width: 1.5, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xff006565)),
                    SizedBox(height: 6),
                    Text(
                      "Tap to select or drop image here",
                      style: TextStyle(fontSize: 12, color: Color(0xff3e4949), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Item Title Input Field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Item Title",
                  labelStyle: const TextStyle(color: Color(0xff006565), fontWeight: FontWeight.w600),
                  hintText: "e.g. Premium Cotton Crewneck",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xffbdc9c8), width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Marketplace Select Dropdown
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedMarketplace,
                decoration: const InputDecoration(labelText: "Marketplace"),
                items: widget.marketplaces.map((m) {
                  final name = m['display_name']?.toString() ?? 'B2C';
                  return DropdownMenuItem<String>(value: name, child: Text(name));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMarketplace = val;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Category, Subcategory, Child Category Inputs (Responsive layout)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: widget.mainCategories.map((c) {
                        final title = c['title']?.toString() ?? '';
                        return DropdownMenuItem<String>(value: title, child: Text(title));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                        if (val != null) {
                          _fetchSubCategories(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedSubCategory,
                      decoration: const InputDecoration(labelText: "Sub-Category"),
                      items: _subcategories.map((s) {
                        return DropdownMenuItem<String>(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSubCategory = val;
                        });
                        if (val != null) {
                          _fetchChildCategories(val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedChildCategory,
                      decoration: const InputDecoration(labelText: "Child Category"),
                      items: _childcategories.map((c) {
                        return DropdownMenuItem<String>(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedChildCategory = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quantity, Weight, Packaging Inputs
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Initial Qty"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Weight (g)"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedPackaging,
                      decoration: const InputDecoration(labelText: "Packaging"),
                      items: const [
                        DropdownMenuItem(value: "Eco-Box", child: Text("Eco-Box")),
                        DropdownMenuItem(value: "Retail Slim", child: Text("Retail Slim")),
                        DropdownMenuItem(value: "Box-B", child: Text("Box-B")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedPackaging = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Enable Variant Options Title & Checkboxes
              const Text(
                "Enable Variant Options",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff0b1c30)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _variants.keys.map((variantName) {
                  final bool active = _variants[variantName] ?? false;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _variants[variantName] = !active;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xff006565) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active ? const Color(0xff006565) : const Color(0xffbdc9c8),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            active ? Icons.check_circle : Icons.add_circle_outline,
                            size: 14,
                            color: active ? Colors.white : const Color(0xff3e4949),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            variantName,
                            style: TextStyle(
                              color: active ? Colors.white : const Color(0xff3e4949),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Title cannot be empty"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    if (_selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a Category"), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    // Create sub-variants list based on active checks
                    final List<String> activeVariants = [];
                    _variants.forEach((key, val) {
                      if (val) activeVariants.add(key);
                    });

                    // Build mock tags list
                    final List<String> itemTags = [];
                    if (_variants["Color"] == true) itemTags.add("Color: Custom");
                    if (_variants["Size"] == true) itemTags.add("Size: Standard");

                    try {
                      final addRes = await _db.getData({
                        'action': 'add_item',
                        'item_name': title,
                        'category': _selectedCategory,
                        'subcategory': _selectedSubCategory ?? '',
                        'childcategory': _selectedChildCategory ?? '',
                        'variants': activeVariants,
                      }, endpoint: 'new_apis/items_api.php');

                      if (addRes != null && addRes['success'] == true) {
                        final int newId = int.tryParse(addRes['data']['item_id']?.toString() ?? '1') ?? 1;
                        final newItem = ItemModel(
                          id: newId,
                          title: title,
                          image: addRes['data']['image']?.toString() ?? "https://images.unsplash.com/photo-1523170335258-f5ed11844a49",
                          category: _selectedCategory!,
                          subcategory: _selectedSubCategory ?? '',
                          childCategory: _selectedChildCategory ?? '',
                          quantity: int.tryParse(_qtyController.text) ?? 50,
                          weight: double.tryParse(_weightController.text) ?? 500,
                          packaging: _selectedPackaging,
                          marketplace: _selectedMarketplace ?? "B2C (Business to Consumer)",
                          variants: activeVariants,
                          tags: itemTags.isEmpty ? ["Custom Item"] : itemTags,
                        );

                        widget.onItemAdded(newItem);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Item Added Successfully"),
                            backgroundColor: Color(0xff006565),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(addRes?['message'] ?? "Failed to add item"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      print("Error adding item: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error communicating with server"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text(
                    "Submit Item",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
