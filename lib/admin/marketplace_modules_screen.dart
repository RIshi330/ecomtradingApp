import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../model/module_model.dart';

class MarketplaceModulesScreen extends StatefulWidget {
  const MarketplaceModulesScreen({super.key});

  @override
  State<MarketplaceModulesScreen> createState() =>
      _MarketplaceModulesScreenState();
}

class _MarketplaceModulesScreenState
    extends State<MarketplaceModulesScreen> {
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
        {"action": "get_marketplaces"},
        endpoint: "new_apis/module_marketplace_api.php",
      );

      if (res['success'] == true || res['status'] == 200 || res.containsKey('data')) {
        final rawList = res['data'] ?? res['marketplaces'] ?? [];
        if (rawList is List) {
          _marketplaces = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }

      await _fetchModules();
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load marketplaces: $e";
      });
      // Load fallback mock modules if network fails
      _modulesList = _getMockModules();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchModules() async {
    if (_marketplaces.isEmpty) {
      _modulesList = _getMockModules();
      return;
    }

    String selectedId = '';
    if (selectedCategory > 0 && selectedCategory <= _marketplaces.length) {
      selectedId = _marketplaces[selectedCategory - 1]['id']?.toString() ?? '';
    } else {
      selectedId = _marketplaces.first['id']?.toString() ?? '';
    }

    try {
      final db = Database();
      final res = await db.getData(
        {
          "action": "get_marketplace_id",
          "marketplace_id": selectedId,
        },
        endpoint: "new_apis/module_marketplace_api.php",
      );

      if (res['success'] == true || res['status'] == 200 || res.containsKey('data') || res.containsKey('modules')) {
        final rawModules = res['data'] ?? res['modules'] ?? [];
        if (rawModules is List) {
          _modulesList = rawModules.map((e) => ModuleModel.fromJson(Map<String, dynamic>.from(e))).toList();
        } else {
          _modulesList = [];
        }
      } else {
        _modulesList = [];
      }
    } catch (e) {
      print("Error fetching modules: $e");
      _modulesList = _getMockModules();
    }
  }

  List<ModuleModel> _getMockModules() {
    return [
      ModuleModel(
        id: "1",
        title: "E-com Marketplace Engine",
        price: "₹3,999/mo",
        rating: "4.9",
        installs: "2.4k Installs",
        badge: "20% OFF",
        icon: Icons.shopping_cart,
        iconName: "shopping_cart",
        features: ["Multi-vendor", "UPI/Cards Sync", "SEO Ready", "Admin Panel"],
        category: "E-commerce",
      ),
      ModuleModel(
        id: "2",
        title: "Job Portal Pro",
        price: "₹2,499/mo",
        rating: "4.8",
        installs: "1.8k Installs",
        badge: "15% OFF",
        icon: Icons.work,
        iconName: "work",
        features: ["Resume Parsing", "ATS Integration", "Email Alerts", "Bulk Import"],
        category: "Job Board",
      ),
      ModuleModel(
        id: "3",
        title: "Event Hub Connect",
        price: "₹1,999/mo",
        rating: "5.0",
        installs: "940 Installs",
        badge: "NEW",
        icon: Icons.event,
        iconName: "event",
        features: ["QR Ticketing", "Live Stream", "Zoom Sync", "Analytics"],
        category: "Events",
      ),
    ];
  }

  List<String> get categoriesList {
    return [
      "All Modules",
      ..._marketplaces.map((m) => m['name']?.toString() ?? ''),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9FF),
      appBar: AppBar(
        title: const Text("ModuleMarket"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: showFilterSheet,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              child: Icon(Icons.person),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMarketplacesAndModules,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // HERO SECTION
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff7C83FD),
                      Color(0xffA3A9FF),
                    ],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text("Featured Module"),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "E-com Revolution\nMarketplace Engine",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ChoiceChip(
                        label: Text(categoriesList[index]),
                        selected: selectedCategory == index,
                        onSelected: (_) async {
                          setState(() {
                            selectedCategory = index;
                            _isLoading = true;
                          });
                          await _fetchModules();
                          setState(() {
                            _isLoading = false;
                          });
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7C83FD)),
                    ),
                  ),
                )
              else if (_errorMessage != null && _modulesList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
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
                    child: Text("No modules found in this category."),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xff7C83FD),
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xffF1F2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  module.icon,
                  color: const Color(0xff7C83FD),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff7C83FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  module.rating,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              module.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: module.features
                .map(
                  (e) => Chip(
                    label: Text(e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                module.price,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/module_details', arguments: module);
                },
                child: const Text("View Details"),
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
    return Padding(
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Free"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
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
                backgroundColor: const Color(0xff7C83FD),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Apply Filters",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
