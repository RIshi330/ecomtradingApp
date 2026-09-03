import 'package:flutter/material.dart';

import '../Database/Database.dart';
import '../core/theme/app_theme.dart';
import '../services/auth_User_and_Business_Session.dart';

class ModuleModel {
  final String id;
  final String title;
  final String category;
  final String rating;
  final List<String> features;
  final String price;
  final String originalPrice;
  final IconData icon;

  ModuleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.features,
    required this.price,
    required this.originalPrice,
    required this.icon,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    // Parse features safely whether string or list
    List<String> parsedFeatures = [];
    if (json['features'] != null) {
      if (json['features'] is List) {
        parsedFeatures = List<String>.from(json['features']);
      } else if (json['features'] is String && json['features'].toString().isNotEmpty) {
        parsedFeatures = (json['features'] as String)
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    final double rawPrice = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
    final double finalPrice = double.tryParse(json['final_price']?.toString() ?? '0') ?? rawPrice;

    return ModuleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Module #${json['id']}',
      category: json['marketplace_id'] != null
          ? 'Marketplace #${json['marketplace_id']}'
          : 'General',
      rating: json['rating']?.toString() ?? '4.5',
      features: parsedFeatures,
      price: '₹${finalPrice.toStringAsFixed(2)}',
      originalPrice: rawPrice > finalPrice ? '₹${rawPrice.toStringAsFixed(2)}' : '₹${finalPrice.toStringAsFixed(2)}',
      icon: Icons.extension,
    );
  }
}


class MarketplaceModulesScreen extends StatefulWidget {
  final bool isEmbedded;
  const MarketplaceModulesScreen({super.key, this.isEmbedded = false});

  @override
  State<MarketplaceModulesScreen> createState() =>
      _MarketplaceModulesScreenState();
}

class _MarketplaceModulesScreenState extends State<MarketplaceModulesScreen> {
  int selectedCategory = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _marketplaces = [];
  List<ModuleModel> _modulesList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMarketplacesAndModules();
  }

  Future<void> _fetchMarketplacesAndModules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = Database();
      final res = await db.getData(
        {"action": "get_marketplaces",        'vendor_id': UserSessionSet.instance.vendorId,
        },
        endpoint: "new_apis/module_marketplace_api.php",
      );

      if (res['success'] == true) {
        final rawList = (res['data'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        // Extract marketplace_id as returned by your PHP SQL statement
        _marketplaces = rawList.map((row) {
          final mId = row['marketplace_id']?.toString() ?? '';
          return {
            'id': mId,
            'name': 'Marketplace $mId',
          };
        }).toList();
      } else {
        _marketplaces = [];
        _errorMessage = res['message']?.toString() ?? "Failed to load marketplaces";
      }

      await _fetchModules();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load data: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchModules() async {
    final db = Database();

    try {
      if (selectedCategory == 0) {
        // "All Modules" selected: Fetch from all available marketplace_ids in parallel
        if (_marketplaces.isEmpty) {
          _modulesList = [];
          return;
        }

        final futures = _marketplaces.map((m) {
          return db.getData(
            {
              "action": "get_marketplace_modules",
              "marketplace_id": m['id'],
              'vendor_id': UserSessionSet.instance.vendorId,

            },
            endpoint: "new_apis/module_marketplace_api.php",
          );
        }).toList();

        final results = await Future.wait(futures);
        List<ModuleModel> combinedModules = [];

        for (var res in results) {
          if (res['success'] == true) {
            final rawModules = res['data'] as List? ?? [];
            combinedModules.addAll(
              rawModules.map((e) => ModuleModel.fromJson(Map<String, dynamic>.from(e))),
            );
          }
        }
        _modulesList = combinedModules;
      } else {
        // Single marketplace selected
        String selectedId = _marketplaces[selectedCategory - 1]['id'] ?? '';
        final res = await db.getData(
          {
            "action": "get_marketplace_modules",
            "marketplace_id": selectedId,
            'vendor_id': UserSessionSet.instance.vendorId,

          },
          endpoint: "new_apis/module_marketplace_api.php",
        );

        if (res['success'] == true) {
          final rawModules = res['data'] as List? ?? [];
          _modulesList = rawModules
              .map((e) => ModuleModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } else {
          _modulesList = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      _modulesList = [];
    }
  }

  List<String> get categoriesList {
    return [
      "All Modules",
      ..._marketplaces.map((m) => m['name'] as String),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
        title: const Text(
          "ModuleMarket",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppTheme.textPrimary),
            onPressed: showFilterSheet,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.secondaryContainer,
              child: Icon(Icons.person, color: AppTheme.primary),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMarketplacesAndModules,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // HERO SECTION
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Featured Module",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "E-com Revolution\nMarketplace Engine",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ChoiceChip(
                        label: Text(
                          categoriesList[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceContainer,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                        onSelected: (_) async {
                          if (selectedCategory == index) return;
                          setState(() {
                            selectedCategory = index;
                            _isLoading = true;
                          });
                          await _fetchModules();
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recommended For You",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                )
              else if (_errorMessage != null && _modulesList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: AppTheme.error), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _fetchMarketplacesAndModules,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              else if (_modulesList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text("No modules found in this category.", style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _modulesList.length,
                    itemBuilder: (context, index) {
                      return ModuleCard(
                        module: _modulesList[index],
                      );
                    },
                  ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.isEmbedded
          ? null
          : BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary.withOpacity(0.6),
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/module_manager');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Marketplace",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_component),
            label: "Manager",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }

  void showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) => const FilterSheet(),
    );
  }
}

class ModuleCard extends StatelessWidget {
  final ModuleModel module;

  const ModuleCard({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  module.icon,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      module.rating,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (module.features.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: module.features
                  .map(
                    (e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (module.originalPrice != module.price) ...[
                    Text(
                      module.originalPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    module.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(110, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/module_details', arguments: module);
                },
                child: const Text(
                  "View Details",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Filter Modules",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Price Range",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                    ),
                    onPressed: () {},
                    child: const Text("Free"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text("Paid"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Sort By",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilterChip(
                  label: const Text("Popularity"),
                  selected: true,
                  selectedColor: AppTheme.primary.withOpacity(0.12),
                  checkmarkColor: AppTheme.primary,
                  labelStyle: const TextStyle(color: AppTheme.primary),
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text("Newest"),
                  selected: false,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text("Rating"),
                  selected: false,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text("Price"),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}