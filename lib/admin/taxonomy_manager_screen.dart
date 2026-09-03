import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';


/// Category / marketplace taxonomy manager, backed by `categoryAPI.php`.
class TaxonomyManagerScreen extends StatefulWidget {
  final bool isEmbedded;
  const TaxonomyManagerScreen({super.key, this.isEmbedded = false});

  @override
  State<TaxonomyManagerScreen> createState() => _TaxonomyManagerScreenState();
}

class _TaxonomyManagerScreenState extends State<TaxonomyManagerScreen> {
  static const String _endpoint = '/new_apis/category_management_api.php';

  final Database _db = Database();
  bool _isLoading = true;
  String? _error;

  List<dynamic> _marketplaces = [];
  List<dynamic> _flatCategories = []; // raw rows from fetch_category
  String? _selectedMarketplaceId;
  String _searchQuery = "";

  int get _adminId => int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Helper to safely resolve a marketplace ID across varied API responses
  String? _getMarketplaceId(dynamic mkt) {
    if (mkt is! Map) return null;
    return (mkt['id'] ?? mkt['marketplace_id'] ?? mkt['mkt_id'])?.toString();
  }

  /// Helper to safely resolve a display name for a marketplace
  String _getMarketplaceName(dynamic mkt) {
    if (mkt is! Map) return 'Marketplace';
    return (mkt['display_name'] ?? mkt['marketplace_name'] ?? mkt['name'] ?? mkt['title'] ?? "Marketplace #${_getMarketplaceId(mkt) ?? ''}").toString();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print(_adminId);
      final mktResponse = await _db.getData({
        'action': 'get_marketplaces',
        'admin_id': _adminId,
      }, endpoint: _endpoint);

      final catResponse = await _db.getData({
        'action': 'fetch_category',
        'admin_id': _adminId,
      }, endpoint: _endpoint);

      List<dynamic> marketplaces = [];
      if (mktResponse['success'] == true && mktResponse['data'] != null) {
        marketplaces = mktResponse['data'];
      }

      List<dynamic> categories = [];
      if (catResponse['success'] == true && catResponse['data'] != null) {
        categories = catResponse['data'];
      }

      if (!mounted) return;
      setState(() {
        _marketplaces = marketplaces;
        _flatCategories = categories;

        if (_marketplaces.isNotEmpty) {
          final firstId = _getMarketplaceId(_marketplaces.first);
          final exists = _marketplaces.any((m) => _getMarketplaceId(m) == _selectedMarketplaceId);
          if (_selectedMarketplaceId == null || !exists) {
            _selectedMarketplaceId = firstId;
          }
        } else {
          _selectedMarketplaceId = null;
        }

        _isLoading = false;
        if (marketplaces.isEmpty) {
          _error = "No marketplaces returned — check the get_marketplaces query in categoryAPI.php.";
        }
      });
    } catch (e) {
      debugPrint("Error fetching categories data: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Couldn't load categories. Pull down to retry.";
      });
    }
  }

  List<Map<String, dynamic>> get _tree {
    if (_selectedMarketplaceId == null) return [];

    final inMarketplace = _flatCategories.where((c) {
      final mId = (c['marketplace_id'] ?? c['mkt_id'])?.toString();
      return mId == _selectedMarketplaceId;
    }).toList();

    final mains = inMarketplace.where((c) => c['type'] == 'main').toList();
    final subs = inMarketplace.where((c) => c['type'] == 'sub_category').toList();
    final children = inMarketplace.where((c) => c['type'] == 'child_category').toList();

    List<Map<String, dynamic>> tree = mains.map((main) {
      final mainMap = Map<String, dynamic>.from(main);
      final mainTitle = mainMap['title']?.toString();

      final mySubs = subs.where((s) => s['parent']?.toString() == mainTitle).map((s) {
        final subMap = Map<String, dynamic>.from(s);
        final subTitle = subMap['title']?.toString();
        final myChildren = children
            .where((c) => c['parent']?.toString() == subTitle)
            .map((c) => Map<String, dynamic>.from(c))
            .toList();
        subMap['children'] = myChildren;
        return subMap;
      }).toList();

      mainMap['children'] = mySubs;
      return mainMap;
    }).toList();

    if (_searchQuery.isEmpty) return tree;

    final q = _searchQuery.toLowerCase();
    return tree.where((cat) {
      final titleMatch = (cat['title'] ?? '').toString().toLowerCase().contains(q);
      if (titleMatch) return true;

      final subsList = cat['children'] as List? ?? [];
      return subsList.any((sub) {
        final subTitleMatch = (sub['title'] ?? '').toString().toLowerCase().contains(q);
        if (subTitleMatch) return true;

        final subChildren = sub['children'] as List? ?? [];
        return subChildren.any((child) =>
            (child['title'] ?? '').toString().toLowerCase().contains(q));
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _tree;

    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Category Settings",
          style: TextStyle(
            color: Color(0xFF1C1B1B),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
          onPressed: () => Navigator.pop(context),
        )
            : const Icon(
          Icons.menu,
          color: Color(0xff006565),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xff006565),
        foregroundColor: Colors.white,
        onPressed: _showAddCategoryDialog,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006565)),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xff006565),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                      TextButton(onPressed: _fetchData, child: const Text("Retry")),
                    ],
                  ),
                ),
              if (_marketplaces.isNotEmpty)
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _marketplaces.length,
                    itemBuilder: (_, index) {
                      final mkt = _marketplaces[index];
                      final mktId = _getMarketplaceId(mkt);
                      final active = _selectedMarketplaceId == mktId;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMarketplaceId = mktId;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xff006565) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: active ? const Color(0xff006565) : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: active
                                ? [
                              BoxShadow(
                                color: const Color(0xff006565).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                                : null,
                          ),
                          child: Text(
                            _getMarketplaceName(mkt),
                            style: TextStyle(
                              color: active ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Categories",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Color(0xff006565)),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    "Categories Structure",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1B1B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xffe5f7f7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${filtered.length} Main Nodes",
                      style: const TextStyle(
                        color: Color(0xff006565),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "No categories found",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pull to refresh or tap '+' to create one.",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filtered.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CategoryNode(
                      category: cat,
                      marketplaces: _marketplaces,
                      mainCategories:
                      _flatCategories.where((c) => c['type'] == 'main').toList(),
                      adminId: _adminId.toString(),
                      endpoint: _endpoint,
                      onChanged: _fetchData,
                    ),
                  );
                }).toList(),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff006565), Color(0xff008080)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff006565).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showHierarchyMap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.account_tree_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 14),
                          Text(
                            "Hierarchy Tree Preview",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Tap to view the complete catalog structure map",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xffe5f7f7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    if (_marketplaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait for marketplaces to load or create one first."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AddCategoryDialog(
        marketplaces: _marketplaces,
        mainCategories: _flatCategories.where((c) => c['type'] == 'main').toList(),
        selectedMarketplaceId: _selectedMarketplaceId,
        adminId: _adminId.toString(),
        endpoint: _endpoint,
        onChanged: _fetchData,
      ),
    );
  }

  void _showHierarchyMap() {
    showDialog(
      context: context,
      builder: (_) => HierarchyMapDialog(
        categories: _tree,
        marketplaces: _marketplaces,
      ),
    );
  }
}

class CategoryNode extends StatefulWidget {
  final Map<String, dynamic> category;
  final List<dynamic> marketplaces;
  final List<dynamic> mainCategories;
  final String adminId;
  final String endpoint;
  final VoidCallback onChanged;
  final bool expanded;

  const CategoryNode({
    super.key,
    required this.category,
    required this.marketplaces,
    required this.mainCategories,
    required this.adminId,
    required this.endpoint,
    required this.onChanged,
    this.expanded = false,
  });

  @override
  State<CategoryNode> createState() => _CategoryNodeState();
}

class _CategoryNodeState extends State<CategoryNode> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded;
  }

  @override
  Widget build(BuildContext context) {
    final subcategories = widget.category['children'] as List? ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffe5f7f7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff006565).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 4, top: 6, bottom: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.drag_indicator,
                  color: Color(0xffBDC9C8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1C1B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Type: Main",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      tooltip: "Add Subcategory",
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xff006565),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddCategoryDialog(
                            marketplaces: widget.marketplaces,
                            mainCategories: widget.mainCategories,
                            parentCategoryTitle: widget.category['title'],
                            initialType: "sub_category",
                            selectedMarketplaceId: (widget.category['marketplace_id'] ?? widget.category['mkt_id'])?.toString(),
                            adminId: widget.adminId,
                            endpoint: widget.endpoint,
                            onChanged: widget.onChanged,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      tooltip: "Edit Category",
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xff006565),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditCategoryDialog(
                            category: widget.category,
                            marketplaces: widget.marketplaces,
                            mainCategories: widget.mainCategories,
                            adminId: widget.adminId,
                            endpoint: widget.endpoint,
                            onChanged: widget.onChanged,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      tooltip: "Delete Category",
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => DeleteCategoryDialog(
                            categoryId: widget.category['id']?.toString() ?? '',
                            adminId: widget.adminId,
                            endpoint: widget.endpoint,
                            onChanged: widget.onChanged,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 2),
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xff006565),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                children: subcategories.isEmpty
                    ? [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "No subcategories added yet.",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  )
                ]
                    : subcategories.map((sub) {
                  return SubCategoryTile(
                    subcategory: Map<String, dynamic>.from(sub),
                    marketplaces: widget.marketplaces,
                    mainCategories: widget.mainCategories,
                    adminId: widget.adminId,
                    endpoint: widget.endpoint,
                    onChanged: widget.onChanged,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class SubCategoryTile extends StatefulWidget {
  final Map<String, dynamic> subcategory;
  final List<dynamic> marketplaces;
  final List<dynamic> mainCategories;
  final String adminId;
  final String endpoint;
  final VoidCallback onChanged;

  const SubCategoryTile({
    super.key,
    required this.subcategory,
    required this.marketplaces,
    required this.mainCategories,
    required this.adminId,
    required this.endpoint,
    required this.onChanged,
  });

  @override
  State<SubCategoryTile> createState() => _SubCategoryTileState();
}

class _SubCategoryTileState extends State<SubCategoryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final children = widget.subcategory['children'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffe5f7f7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff006565).withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: Color(0xffBDC9C8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subcategory['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1B1B),
                        ),
                      ),
                      const Text(
                        "Type: Sub-Category",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      tooltip: "Add Child Category",
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xff006565),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddCategoryDialog(
                            marketplaces: widget.marketplaces,
                            mainCategories: widget.mainCategories,
                            parentCategoryTitle: widget.subcategory['parent'],
                            subcategoryTitle: widget.subcategory['title'],
                            initialType: "child_category",
                            selectedMarketplaceId: (widget.subcategory['marketplace_id'] ?? widget.subcategory['mkt_id'])?.toString(),
                            adminId: widget.adminId,
                            endpoint: widget.endpoint,
                            onChanged: widget.onChanged,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      tooltip: "Edit Subcategory",
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xff006565),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditCategoryDialog(
                            category: widget.subcategory,
                            marketplaces: widget.marketplaces,
                            mainCategories: widget.mainCategories,
                            adminId: widget.adminId,
                            endpoint: widget.endpoint,
                            onChanged: widget.onChanged,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      tooltip: "Delete Subcategory",
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => DeleteCategoryDialog(
                            categoryId: widget.subcategory['id']?.toString() ?? '',
                            adminId: widget.adminId,
                            endpoint: widget.endpoint,
                            onChanged: widget.onChanged,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      icon: Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xff006565),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 28, right: 12, bottom: 12),
              child: Column(
                children: children.isEmpty
                    ? [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      "No child categories.",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  )
                ]
                    : children.map((ch) {
                  final childMap = Map<String, dynamic>.from(ch);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.subdirectory_arrow_right, size: 14, color: Color(0xff006565)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            childMap['title'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => EditCategoryDialog(
                                category: childMap,
                                marketplaces: widget.marketplaces,
                                mainCategories: widget.mainCategories,
                                adminId: widget.adminId,
                                endpoint: widget.endpoint,
                                onChanged: widget.onChanged,
                              ),
                            );
                          },
                          child: const Icon(Icons.edit, size: 14, color: Color(0xff006565)),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => DeleteCategoryDialog(
                                categoryId: childMap['id']?.toString() ?? '',
                                adminId: widget.adminId,
                                endpoint: widget.endpoint,
                                onChanged: widget.onChanged,
                              ),
                            );
                          },
                          child: const Icon(Icons.delete, size: 14, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}

class AddCategoryDialog extends StatefulWidget {
  final List<dynamic> marketplaces;
  final List<dynamic> mainCategories;
  final String? parentCategoryTitle;
  final String? subcategoryTitle;
  final String? selectedMarketplaceId;
  final String? initialType;
  final String adminId;
  final String endpoint;
  final VoidCallback onChanged;

  const AddCategoryDialog({
    super.key,
    required this.marketplaces,
    required this.mainCategories,
    this.parentCategoryTitle,
    this.subcategoryTitle,
    this.selectedMarketplaceId,
    this.initialType,
    required this.adminId,
    required this.endpoint,
    required this.onChanged,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _db = Database();
  final _titleController = TextEditingController();
  final _iconController = TextEditingController(text: "Icons.category");

  String? _selectedMarketplaceId;
  String _categoryType = "main"; // main, sub_category, child_category
  String? _selectedParentCategory; // For Sub & Child
  String? _selectedSubCategory; // For Child
  List<dynamic> _subcategories = [];
  bool _isSaving = false;

  String? _getMarketplaceId(dynamic mkt) {
    if (mkt is! Map) return null;
    return (mkt['id'] ?? mkt['marketplace_id'] ?? mkt['mkt_id'])?.toString();
  }

  String _getMarketplaceName(dynamic mkt) {
    if (mkt is! Map) return 'Marketplace';
    return (mkt['display_name'] ?? mkt['marketplace_name'] ?? mkt['name'] ?? mkt['title'] ?? "Marketplace #${_getMarketplaceId(mkt) ?? ''}").toString();
  }

  @override
  void initState() {
    super.initState();

    if (widget.marketplaces.isNotEmpty) {
      final initialId = widget.selectedMarketplaceId?.toString();
      final exists = widget.marketplaces.any((m) => _getMarketplaceId(m) == initialId);

      _selectedMarketplaceId = exists
          ? initialId
          : _getMarketplaceId(widget.marketplaces.first);
    } else {
      _selectedMarketplaceId = null;
    }

    _categoryType = widget.initialType ?? "main";
    _selectedParentCategory = widget.parentCategoryTitle;
    _selectedSubCategory = widget.subcategoryTitle;

    if (_selectedParentCategory != null) {
      final exists = widget.mainCategories.any((c) => c['title']?.toString() == _selectedParentCategory);
      if (!exists) {
        _selectedParentCategory = null;
      }
    }

    if (_selectedParentCategory != null) {
      _fetchSubcategories();
    }
  }

  Future<void> _fetchSubcategories() async {
    if (_selectedParentCategory == null || _selectedMarketplaceId == null) return;
    try {
      final res = await _db.getData({
        'action': 'get_subcategories',
        'admin_id': widget.adminId,
        'marketplace_id': _selectedMarketplaceId!,
        'parent_category': _selectedParentCategory!,
      }, endpoint: widget.endpoint);

      if (res['success'] == true && res['data'] != null) {
        if (!mounted) return;
        setState(() {
          _subcategories = res['data'];
          if (_selectedSubCategory != null) {
            final exists = _subcategories.any((s) => s.toString() == _selectedSubCategory);
            if (!exists) {
              _selectedSubCategory = null;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching subcategories: $e");
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title must be at least 3 characters long"), backgroundColor: Colors.red),
      );
      return;
    }

    if ((_categoryType == "sub_category" && _selectedParentCategory == null) ||
        (_categoryType == "child_category" &&
            (_selectedParentCategory == null || _selectedSubCategory == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a parent category first"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final params = <String, dynamic>{
        'action': 'create_category',
        'admin_id': widget.adminId,
        'marketplace_id': _selectedMarketplaceId ?? '',
        'category_title': title,
        'category_type': _categoryType,
        'icon': _iconController.text.trim(),
        'parent_category': _categoryType == 'child_category'
            ? (_selectedSubCategory ?? '')
            : (_selectedParentCategory ?? ''),
      };

      final response = await _db.getData(params, endpoint: widget.endpoint);

      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category created successfully!"), backgroundColor: Colors.green),
        );
        widget.onChanged();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to save category"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error creating category: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Category Node",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedMarketplaceId,
              decoration: const InputDecoration(labelText: "Marketplace"),
              items: widget.marketplaces.map((m) {
                final id = _getMarketplaceId(m);
                final name = _getMarketplaceName(m);
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMarketplaceId = val;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _categoryType,
              decoration: const InputDecoration(labelText: "Category Level"),
              items: const [
                DropdownMenuItem(value: "main", child: Text("Main Category")),
                DropdownMenuItem(value: "sub_category", child: Text("Sub-Category")),
                DropdownMenuItem(value: "child_category", child: Text("Child Category")),
              ],
              onChanged: (val) {
                setState(() {
                  _categoryType = val!;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_categoryType == "sub_category" || _categoryType == "child_category") ...[
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedParentCategory,
                decoration: const InputDecoration(labelText: "Parent Main Category"),
                items: widget.mainCategories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['title']?.toString(),
                    child: Text(c['title'] ?? ''),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedParentCategory = val;
                    _selectedSubCategory = null;
                    _subcategories = [];
                  });
                  _fetchSubcategories();
                },
              ),
              const SizedBox(height: 12),
            ],
            if (_categoryType == "child_category" && _selectedParentCategory != null) ...[
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedSubCategory,
                decoration: const InputDecoration(labelText: "Parent Sub-Category"),
                items: _subcategories.map((s) {
                  return DropdownMenuItem<String>(
                    value: s.toString(),
                    child: Text(s.toString()),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSubCategory = val;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Category Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _iconController,
              decoration: const InputDecoration(labelText: "Icon Identifier name"),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    minimumSize: const Size(100, 44),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Create", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class EditCategoryDialog extends StatefulWidget {
  final Map<String, dynamic> category;
  final List<dynamic> marketplaces;
  final List<dynamic> mainCategories;
  final String adminId;
  final String endpoint;
  final VoidCallback onChanged;

  const EditCategoryDialog({
    super.key,
    required this.category,
    required this.marketplaces,
    required this.mainCategories,
    required this.adminId,
    required this.endpoint,
    required this.onChanged,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _db = Database();
  late TextEditingController _titleController;
  late TextEditingController _iconController;

  String? _selectedMarketplaceId;
  String? _selectedParentCategory;
  bool _isSaving = false;

  String? _getMarketplaceId(dynamic mkt) {
    if (mkt is! Map) return null;
    return (mkt['id'] ?? mkt['marketplace_id'] ?? mkt['mkt_id'])?.toString();
  }

  String _getMarketplaceName(dynamic mkt) {
    if (mkt is! Map) return 'Marketplace';
    return (mkt['display_name'] ?? mkt['marketplace_name'] ?? mkt['name'] ?? mkt['title'] ?? "Marketplace #${_getMarketplaceId(mkt) ?? ''}").toString();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.category['title'] ?? '');
    _iconController = TextEditingController(text: widget.category['icon'] ?? 'Icons.category');

    _selectedMarketplaceId = (widget.category['marketplace_id'] ?? widget.category['mkt_id'])?.toString();

    if (_selectedMarketplaceId != null && widget.marketplaces.isNotEmpty) {
      final exists = widget.marketplaces.any((m) => _getMarketplaceId(m) == _selectedMarketplaceId);
      if (!exists) {
        if (widget.marketplaces.isNotEmpty) {
          _selectedMarketplaceId = _getMarketplaceId(widget.marketplaces.first);
        } else {
          _selectedMarketplaceId = null;
        }
      }
    }

    _selectedParentCategory = widget.category['parent'];

    if (_selectedParentCategory != null) {
      final exists = widget.mainCategories.any((c) => c['title']?.toString() == _selectedParentCategory);
      if (!exists) {
        _selectedParentCategory = null;
      }
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final params = <String, dynamic>{
        'action': 'edit_category',
        'admin_id': widget.adminId,
        'id': widget.category['id']?.toString() ?? '',
        'marketplace_id': _selectedMarketplaceId ?? '',
        'category_title': title,
        'category_type': widget.category['type'] ?? 'main',
        'icon': _iconController.text.trim(),
      };

      if (widget.category['type'] != 'main' && _selectedParentCategory != null) {
        params['parent_category'] = _selectedParentCategory;
      }

      final response = await _db.getData(params, endpoint: widget.endpoint);

      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category updated successfully!"), backgroundColor: Colors.green),
        );
        widget.onChanged();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to save edits"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error editing category: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Category Node",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedMarketplaceId,
              decoration: const InputDecoration(labelText: "Marketplace"),
              items: widget.marketplaces.map((m) {
                final id = _getMarketplaceId(m);
                final name = _getMarketplaceName(m);
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMarketplaceId = val;
                });
              },
            ),
            const SizedBox(height: 12),
            if (widget.category['type'] != 'main' && _selectedParentCategory != null) ...[
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedParentCategory,
                decoration: const InputDecoration(labelText: "Parent Category"),
                items: widget.mainCategories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['title']?.toString(),
                    child: Text(c['title'] ?? ''),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedParentCategory = val;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Category Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _iconController,
              decoration: const InputDecoration(labelText: "Icon Identifier name"),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    minimumSize: const Size(100, 44),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DeleteCategoryDialog extends StatefulWidget {
  final String categoryId;
  final String adminId;
  final String endpoint;
  final VoidCallback onChanged;

  const DeleteCategoryDialog({
    super.key,
    required this.categoryId,
    required this.adminId,
    required this.endpoint,
    required this.onChanged,
  });

  @override
  State<DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends State<DeleteCategoryDialog> {
  final _db = Database();
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() {
      _isDeleting = true;
    });
    try {
      final res = await _db.getData({
        'action': 'delete_category',
        'admin_id': widget.adminId,
        'id': widget.categoryId,
      }, endpoint: widget.endpoint);

      if (res['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category deleted successfully!"), backgroundColor: Colors.green),
        );
        widget.onChanged();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']?.toString() ?? "Failed to delete category"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Error deleting category: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text(
                  "Delete Category",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Are you sure you want to permanently delete this category and all nested categories? This action cannot be undone.",
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isDeleting ? null : _delete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(100, 44),
                  ),
                  child: _isDeleting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HierarchyMapDialog extends StatelessWidget {
  final List<dynamic> categories;
  final List<dynamic> marketplaces;

  const HierarchyMapDialog({
    super.key,
    required this.categories,
    required this.marketplaces,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree_outlined, color: Color(0xff006565)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Hierarchy Visual Map",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1B1B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Interactive visualization of your live catalog structure",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                child: Text(
                  "No catalog entries to visualize",
                  style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                ),
              )
                  : ListView(
                children: [
                  _buildMapNode("Root Catalog Directory", isRoot: true),
                  ...categories.map((cat) {
                    final subs = cat['children'] as List? ?? [];
                    return Column(
                      children: [
                        _buildConnector(),
                        _buildMapNode(
                          cat['title'] ?? '',
                          subtitle: "${subs.length} subcategories",
                        ),
                        if (subs.isNotEmpty) ...[
                          _buildConnectorBranch(),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Column(
                              children: subs.map((sub) {
                                final childs = sub['children'] as List? ?? [];
                                return Column(
                                  children: [
                                    _buildMapNode(
                                      sub['title'] ?? '',
                                      isLeaf: true,
                                      subtitle: childs.isNotEmpty ? "${childs.length} child categories" : null,
                                    ),
                                    if (childs.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20, top: 4),
                                        child: Column(
                                          children: childs.map((ch) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.subdirectory_arrow_right, size: 12, color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      ch['title'] ?? '',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapNode(String label, {String? subtitle, bool isRoot = false, bool isLeaf = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isRoot
            ? const Color(0xff006565)
            : isLeaf
            ? const Color(0xffe5f7f7)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRoot
              ? const Color(0xff006565)
              : isLeaf
              ? const Color(0xff006565).withOpacity(0.2)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isRoot
                ? Icons.folder_open
                : isLeaf
                ? Icons.subdirectory_arrow_right
                : Icons.folder,
            color: isRoot ? Colors.white : const Color(0xff006565),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isRoot ? Colors.white : const Color(0xFF1C1B1B),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 2,
      height: 15,
      color: const Color(0xffBDC9C8),
    );
  }

  Widget _buildConnectorBranch() {
    return Container(
      width: 2,
      height: 15,
      color: const Color(0xffBDC9C8),
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 48),
    );
  }
}