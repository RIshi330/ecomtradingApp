import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PackageBuilderScreen extends StatefulWidget {
  const PackageBuilderScreen({super.key});

  @override
  State<PackageBuilderScreen> createState() => _PackageBuilderScreenState();
}

class _PackageBuilderScreenState extends State<PackageBuilderScreen> {
  static const Color primaryTeal = Color(0xFF006565);
  static const Color lightTeal = Color(0xFFD4E6E5);
  static const Color bgLight = Color(0xFFFCF9F8);

  bool _isLoading = true;
  List<dynamic> _packages = [];
  List<dynamic> _categories = [];
  String _searchQuery = '';
  String _selectedSort = ''; // '', 'low', 'high'
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPackages();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Database().getJsonData({
        'action': 'get_categories',
      }, endpoint: 'new_apis/package_builder_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _categories = response['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> _fetchPackages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await Database().getJsonData({
        'action': 'get_services',
        'search': _searchQuery,
        'sort': _selectedSort,
        'cat_id': _selectedCategory,
      }, endpoint: 'new_apis/package_builder_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _packages = response['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching packages: $e");
      Fluttertoast.showToast(msg: "Error loading packages");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sort By Price",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.star_outline, color: primaryTeal),
                title: const Text("Recommended"),
                selected: _selectedSort == '',
                onTap: () {
                  setState(() {
                    _selectedSort = '';
                  });
                  _fetchPackages();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up, color: primaryTeal),
                title: const Text("Price: Low to High"),
                selected: _selectedSort == 'low',
                onTap: () {
                  setState(() {
                    _selectedSort = 'low';
                  });
                  _fetchPackages();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_down, color: primaryTeal),
                title: const Text("Price: High to Low"),
                selected: _selectedSort == 'high',
                onTap: () {
                  setState(() {
                    _selectedSort = 'high';
                  });
                  _fetchPackages();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter By Category",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = '';
                          });
                          _fetchPackages();
                          Navigator.pop(ctx);
                        },
                        child: const Text("Clear", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: _categories.isEmpty
                        ? const Center(child: Text("No categories found"))
                        : ListView.builder(
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = _selectedCategory == cat['id']?.toString();
                              return ListTile(
                                title: Text(cat['name'] ?? ''),
                                trailing: isSelected
                                    ? const Icon(Icons.check, color: primaryTeal)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = cat['id']?.toString() ?? '';
                                  });
                                  _fetchPackages();
                                  Navigator.pop(ctx);
                                },
                              );
                            },
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

  void _showEditModal({Map<String, dynamic>? package}) {
    final bool isEdit = package != null;
    final titleController = TextEditingController(text: isEdit ? package['name'] : '');
    final priceController = TextEditingController(text: isEdit ? package['price']?.toString() : '');
    final descController = TextEditingController(text: isEdit ? package['desc'] : '');
    final benefitsController = TextEditingController(text: isEdit ? package['benefits'] : '');
    final timelineController = TextEditingController(text: isEdit ? package['timeline'] : '');
    final modeController = TextEditingController(text: isEdit ? package['mode'] : '');
    final tagsController = TextEditingController(text: isEdit ? package['tags'] : '');
    final discountController = TextEditingController(text: isEdit ? package['discount']?.toString() : '0');
    final imgController = TextEditingController(text: isEdit ? package['img'] : '');

    String discountType = isEdit ? (package['discountType'] ?? '%') : '%';
    String saveType = isEdit ? (package['save_type'] ?? 'TEMPLATE') : 'TEMPLATE';
    String? categoryId = isEdit ? package['cat_id']?.toString() : null;

    List<TextEditingController> featureControllers = [];
    if (isEdit && package['deliverables'] != null && package['deliverables'].toString().isNotEmpty) {
      final list = package['deliverables'].toString().split(',');
      for (final item in list) {
        featureControllers.add(TextEditingController(text: item.trim()));
      }
    }
    if (featureControllers.isEmpty) {
      featureControllers.add(TextEditingController());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? "Edit Package" : "Create Package",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTeal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Package Image URL
                            const Text("PACKAGE COVER IMAGE URL",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: imgController,
                              decoration: InputDecoration(
                                hintText: "Paste cover image URL",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Category Dropdown
                            const Text("CATEGORY",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: categoryId,
                              items: _categories.map<DropdownMenuItem<String>>((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat['id']?.toString(),
                                  child: Text(cat['name'] ?? ''),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setModalState(() {
                                  categoryId = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Select Category",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title
                            const Text("PACKAGE TITLE",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                hintText: "Enter package title",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Price and Discount
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("BASE PRICE (INR)",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: priceController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: "Base Price",
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("DISCOUNT",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: discountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: "Discount Value",
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("TYPE",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: discountType,
                                        items: const [
                                          DropdownMenuItem(value: "%", child: Text("%")),
                                          DropdownMenuItem(value: "flat", child: Text("Flat")),
                                        ],
                                        onChanged: (val) {
                                          setModalState(() {
                                            discountType = val!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Description
                            const Text("DESCRIPTION",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: descController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Describe your package value...",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // What's Inside (Deliverables)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("WHAT'S INSIDE (DELIVERABLES)",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                TextButton.icon(
                                  onPressed: () {
                                    setModalState(() {
                                      featureControllers.add(TextEditingController());
                                    });
                                  },
                                  icon: const Icon(Icons.add, size: 16, color: primaryTeal),
                                  label: const Text("Add", style: TextStyle(color: primaryTeal, fontSize: 12)),
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            Column(
                              children: List.generate(featureControllers.length, (idx) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: featureControllers[idx],
                                          decoration: InputDecoration(
                                            hintText: "Deliverable item ${idx + 1}",
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                      if (featureControllers.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () {
                                            setModalState(() {
                                              featureControllers[idx].dispose();
                                              featureControllers.removeAt(idx);
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),

                            // Benefits, Timeline, Mode
                            const Text("BENEFITS",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: benefitsController,
                              decoration: InputDecoration(
                                hintText: "Key benefits",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("TIMELINE",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: timelineController,
                                        decoration: InputDecoration(
                                          hintText: "e.g. 7 Days",
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("MODE",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: modeController,
                                        decoration: InputDecoration(
                                          hintText: "e.g. Online / Standard",
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Tags (comma separated)
                            const Text("TAGS (COMMA SEPARATED)",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: tagsController,
                              decoration: InputDecoration(
                                hintText: "e.g. Ads, Growth, Banner",
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Save Type & Save Action Button
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("SAVE TYPE",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: saveType,
                                        items: const [
                                          DropdownMenuItem(value: "TEMPLATE", child: Text("Template")),
                                          DropdownMenuItem(value: "ORG", child: Text("Original Production Pack")),
                                        ],
                                        onChanged: (val) {
                                          setModalState(() {
                                            saveType = val!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () async {
                              final title = titleController.text.trim();
                              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                              final discountVal = double.tryParse(discountController.text.trim()) ?? 0.0;

                              if (title.isEmpty || price <= 0.0) {
                                Fluttertoast.showToast(msg: "Title and base price are required.");
                                return;
                              }

                              final deliverablesStr = featureControllers
                                  .map((c) => c.text.trim())
                                  .where((t) => t.isNotEmpty)
                                  .join(',');

                              final body = {
                                'action': isEdit ? 'edit_service' : 'save_service',
                                'title': title,
                                'price': price,
                                'discount': discountVal,
                                'discountType': discountType,
                                'description': descController.text.trim(),
                                'benefits': benefitsController.text.trim(),
                                'deliverables': deliverablesStr,
                                'timeline': timelineController.text.trim(),
                                'mode': modeController.text.trim(),
                                'tags': tagsController.text.trim(),
                                'image': imgController.text.trim(),
                                'save_type': saveType,
                                'cat_id': categoryId ?? '',
                              };

                              if (isEdit) {
                                body['service_id'] = package['id'];
                              }

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator(color: primaryTeal)),
                              );

                              try {
                                final response = await Database().getJsonData(body, endpoint: 'new_apis/package_builder_api.php');
                                Navigator.pop(context); // close loading indicator

                                if (response['success'] == true) {
                                  Fluttertoast.showToast(msg: isEdit ? "Package updated successfully!" : "Package saved successfully!");
                                  Navigator.pop(context); // close modal
                                  _fetchPackages(); // refresh
                                } else {
                                  Fluttertoast.showToast(msg: response['message']?.toString() ?? "Operation failed");
                                }
                              } catch (e) {
                                Navigator.pop(context);
                                Fluttertoast.showToast(msg: "Error: $e");
                              }
                            },
                            child: const Text("Save Package", style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Package Builder Hub",
          style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: primaryTeal),
        elevation: 0.5,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDED),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                            _fetchPackages();
                          },
                          decoration: const InputDecoration(
                            hintText: "Search packages...",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _showSortSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE7E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sort, color: primaryTeal, size: 20),
                              SizedBox(width: 8),
                              Text("Sort Price", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryTeal)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _showFilterSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE7E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.filter_alt, color: primaryTeal, size: 20),
                              SizedBox(width: 8),
                              Text("Filter Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryTeal)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Packages List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryTeal),
                  )
                : _packages.isEmpty
                    ? const Center(
                        child: Text("No packages available. Create one to begin!"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _packages.length,
                        itemBuilder: (context, idx) {
                          final package = _packages[idx];
                          final name = package['name'] ?? '';
                          final price = double.tryParse(package['price']?.toString() ?? '0') ?? 0.0;
                          final desc = package['desc'] ?? '';
                          final imgUrl = package['img']?.toString() ?? '';
                          final tagsStr = package['tags']?.toString() ?? '';
                          final deliverablesStr = package['deliverables']?.toString() ?? '';

                          final List<String> tags = tagsStr.isNotEmpty
                              ? tagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                              : [];
                          final List<String> deliverables = deliverablesStr.isNotEmpty
                              ? deliverablesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                              : [];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cover Image
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: imgUrl.isNotEmpty
                                          ? Image.network(
                                              imgUrl,
                                              height: 150,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                height: 150,
                                                color: primaryTeal.withOpacity(0.08),
                                                child: const Icon(Icons.image, size: 50, color: primaryTeal),
                                              ),
                                            )
                                          : Container(
                                              height: 150,
                                              color: primaryTeal.withOpacity(0.08),
                                              child: const Center(
                                                child: Icon(Icons.inventory_2, size: 60, color: primaryTeal),
                                              ),
                                            ),
                                    ),
                                    if (package['save_type'] == 'TEMPLATE')
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: primaryTeal,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            "TEMPLATE",
                                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                // Body
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B)),
                                            ),
                                          ),
                                          Text(
                                            "₹${price.toStringAsFixed(0)}",
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        desc,
                                        style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                                      ),
                                      const SizedBox(height: 12),

                                      // Tags
                                      if (tags.isNotEmpty) ...[
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: tags.map((tag) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: lightTeal.withOpacity(0.4),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                tag,
                                                style: const TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 12),
                                      ],

                                      // Deliverables Checklists
                                      if (deliverables.isNotEmpty) ...[
                                        const Divider(height: 20),
                                        const Text(
                                          "WHAT'S INSIDE",
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          children: deliverables.map((item) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 6.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.check_circle, color: primaryTeal, size: 16),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      // Edit Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 44,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showEditModal(package: package),
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text("Customize & Edit", style: TextStyle(fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryTeal,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showEditModal(),
      ),
    );
  }
}
