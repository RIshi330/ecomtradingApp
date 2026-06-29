import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'training_details_screen.dart';
import 'create_training_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceTrainingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const MarketplaceTrainingsScreen({super.key, this.isEmbedded = false});

  @override
  State<MarketplaceTrainingsScreen> createState() => _MarketplaceTrainingsScreenState();
}

class _MarketplaceTrainingsScreenState extends State<MarketplaceTrainingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Theme styling constants
  static const Color primaryTeal = Color(0xFF006565);
  static const Color selectedBg = Color(0xFFE3FFFE);
  static const Color textDark = Color(0xFF0B1C30);
  static const Color textLight = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color background = Color(0xFFF8F9FF);

  // Filters State from API
  List<String> _categories = [];
  List<String> _modes = [];
  List<String> _types = [];
  List<String> _cities = [];

  // Applied Filters State
  String _selectedCategory = '';
  List<String> _selectedModes = [];
  List<String> _selectedTypes = [];
  List<String> _selectedCities = [];
  double _maxPrice = 50000.0;
  String _selectedSort = 'created_date DESC';
  
  // Listings state
  List<dynamic> _trainings = [];
  bool _isLoadingFilters = true;
  bool _isLoadingTrainings = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalTrainings = 0;

  @override
  void initState() {
    super.initState();
    _fetchFilters();
    _fetchTrainings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFilters() async {
    setState(() => _isLoadingFilters = true);
    try {
      final res = await Database().getData({
        'action': 'getFilters',
      }, endpoint: 'new_apis/marketplace_training_API.php');

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        setState(() {
          _categories = List<String>.from(data['categories'] ?? []);
          _modes = List<String>.from(data['modes'] ?? []);
          _types = List<String>.from(data['types'] ?? []);
          _cities = List<String>.from(data['cities'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error fetching filters: $e");
    } finally {
      setState(() => _isLoadingFilters = false);
    }
  }

  Future<void> _fetchTrainings() async {
    setState(() => _isLoadingTrainings = true);
    try {
      final postData = {
        'action': 'getTrainings',
        'page': _currentPage,
        'per_page': 6,
        'search': _searchController.text.trim(),
        'category': _selectedCategory,
        'max_price': _maxPrice,
        'sort': _selectedSort,
        'modes': _selectedModes,
        'types': _selectedTypes,
        'cities': _selectedCities,
      };

      final res = await Database().getData(
        postData,
        endpoint: 'new_apis/marketplace_training_API.php',
      );

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        setState(() {
          _trainings = data['trainings'] ?? [];
          _currentPage = int.tryParse(data['page']?.toString() ?? '1') ?? 1;
          _totalPages = int.tryParse(data['total_pages']?.toString() ?? '1') ?? 1;
          _totalTrainings = int.tryParse(data['total']?.toString() ?? '0') ?? 0;
        });
      } else {
        setState(() {
          _trainings = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching trainings: $e");
      setState(() => _trainings = []);
    } finally {
      setState(() => _isLoadingTrainings = false);
    }
  }

  void _resetAllFilters() {
    setState(() {
      _selectedCategory = '';
      _selectedModes = [];
      _selectedTypes = [];
      _selectedCities = [];
      _maxPrice = 50000.0;
      _searchController.clear();
      _currentPage = 1;
    });
    _fetchTrainings();
  }

  void _openFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle line
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: outlineVariant,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetAllFilters();
                            Navigator.pop(context);
                          },
                          child: const Text("Reset All", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Price range slider
                    const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₹0", style: TextStyle(color: textLight, fontSize: 12)),
                        Text("₹${_maxPrice.toStringAsFixed(0)}", style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _maxPrice,
                      min: 0,
                      max: 50000,
                      divisions: 50,
                      activeColor: primaryTeal,
                      inactiveColor: outlineVariant,
                      onChanged: (val) {
                        setModalState(() {
                          _maxPrice = val;
                        });
                        setState(() {
                          _maxPrice = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Modes list
                    if (_modes.isNotEmpty) ...[
                      const Text("Learning Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _modes.map((m) {
                          final isSelected = _selectedModes.contains(m);
                          return FilterChip(
                            label: Text(m),
                            selected: isSelected,
                            selectedColor: selectedBg,
                            checkmarkColor: primaryTeal,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: isSelected ? primaryTeal : outlineVariant),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedModes.add(m);
                                } else {
                                  _selectedModes.remove(m);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Types list
                    if (_types.isNotEmpty) ...[
                      const Text("Training Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _types.map((t) {
                          final isSelected = _selectedTypes.contains(t);
                          return FilterChip(
                            label: Text(t),
                            selected: isSelected,
                            selectedColor: selectedBg,
                            checkmarkColor: primaryTeal,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: isSelected ? primaryTeal : outlineVariant),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedTypes.add(t);
                                } else {
                                  _selectedTypes.remove(t);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Cities list
                    if (_cities.isNotEmpty) ...[
                      const Text("Locations/Cities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _cities.map((c) {
                          final isSelected = _selectedCities.contains(c);
                          return FilterChip(
                            label: Text(c),
                            selected: isSelected,
                            selectedColor: selectedBg,
                            checkmarkColor: primaryTeal,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: isSelected ? primaryTeal : outlineVariant),
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedCities.add(c);
                                } else {
                                  _selectedCities.remove(c);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _currentPage = 1;
                          _fetchTrainings();
                        },
                        child: const Text("Apply Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Sort Trainings By", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('created_date DESC', 'Latest / Newest'),
              _buildSortOption('fee ASC', 'Price: Low to High'),
              _buildSortOption('fee DESC', 'Price: High to Low'),
              _buildSortOption('rating DESC', 'Highest Rated'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String val, String label) {
    return ListTile(
      title: Text(label, style: TextStyle(color: _selectedSort == val ? primaryTeal : textDark, fontWeight: _selectedSort == val ? FontWeight.bold : FontWeight.normal)),
      trailing: _selectedSort == val ? const Icon(Icons.check, color: primaryTeal) : null,
      onTap: () {
        setState(() {
          _selectedSort = val;
          _currentPage = 1;
        });
        Navigator.pop(context);
        _fetchTrainings();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        // Search & Filters Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: outlineVariant, width: 0.5)),
          ),
          child: Column(
            children: [
              // Search input
              TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search professional courses...",
                  prefixIcon: const Icon(Icons.search, color: textLight, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            _currentPage = 1;
                            _fetchTrainings();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: background,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: outlineVariant, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: outlineVariant, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryTeal, width: 1),
                  ),
                ),
                onSubmitted: (_) {
                  setState(() => _currentPage = 1);
                  _fetchTrainings();
                },
              ),
              const SizedBox(height: 10),

              // Scrollable row of Filters/Sort and Category tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Filters button
                    ActionChip(
                      onPressed: _openFiltersModal,
                      avatar: const Icon(Icons.tune, color: textDark, size: 16),
                      label: const Text("Filters", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                      backgroundColor: outlineVariant.withOpacity(0.2),
                      side: BorderSide.none,
                    ),
                    const SizedBox(width: 8),

                    // Sort button
                    ActionChip(
                      onPressed: _openSortDialog,
                      avatar: const Icon(Icons.swap_vert, color: textDark, size: 16),
                      label: Text(
                        "Sort: ${_selectedSort == 'created_date DESC' ? 'New' : _selectedSort == 'fee ASC' ? 'Price ↑' : _selectedSort == 'fee DESC' ? 'Price ↓' : 'Rating'}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: textDark),
                      ),
                      backgroundColor: outlineVariant.withOpacity(0.2),
                      side: BorderSide.none,
                    ),
                    const SizedBox(width: 8),

                    if (_categories.isNotEmpty) ...[
                      Container(width: 1, height: 16, color: outlineVariant),
                      const SizedBox(width: 8),
                      // All Categories option
                      ChoiceChip(
                        label: const Text("All"),
                        selected: _selectedCategory == '',
                        selectedColor: primaryTeal,
                        labelStyle: TextStyle(color: _selectedCategory == '' ? Colors.white : textLight),
                        side: BorderSide.none,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = '';
                              _currentPage = 1;
                            });
                            _fetchTrainings();
                          }
                        },
                      ),
                      const SizedBox(width: 8),

                      ..._categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            selectedColor: primaryTeal,
                            labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : textLight),
                            side: BorderSide.none,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? cat : '';
                                _currentPage = 1;
                              });
                              _fetchTrainings();
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Grid of items
        Expanded(
          child: _isLoadingTrainings
              ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryTeal)))
              : _trainings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("No trainings match your filters.", style: TextStyle(color: textLight, fontSize: 16)),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: primaryTeal, side: const BorderSide(color: primaryTeal)),
                            onPressed: _resetAllFilters,
                            child: const Text("Clear Filters"),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: primaryTeal,
                      onRefresh: () async {
                        await _fetchFilters();
                        await _fetchTrainings();
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _trainings.length,
                              itemBuilder: (context, idx) {
                                return _buildTrainingCard(_trainings[idx]);
                              },
                            ),
                          ),
                          // Pagination Controls
                          _buildPaginationControls(),
                        ],
                      ),
                    ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Marketplace Trainings", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTrainingScreen()),
        ).then((_) => _fetchTrainings()),
        elevation: 6,
        child: const Icon(Icons.add),
      ),
      body: content,
    );
  }

  Widget _buildTrainingCard(Map<String, dynamic> tr) {
    final double fee = double.tryParse(tr['fee']?.toString() ?? '0') ?? 0.0;
    final double origFee = double.tryParse(tr['original_fee']?.toString() ?? (fee * 1.5).toStringAsFixed(0)) ?? (fee * 1.5);
    final double savings = origFee - fee;
    final double savingsPercent = origFee > 0 ? (savings / origFee * 100) : 0;
    
    final String image = tr['image_url']?.toString() ?? '';
    final String title = tr['training_title']?.toString() ?? 'Professional Course';
    final String cat = tr['cat_id']?.toString() ?? 'Business';
    final String mode = tr['mode']?.toString() ?? 'Online';
    final double rating = double.tryParse(tr['avg_rating']?.toString() ?? '0') ?? 0.0;
    final int reviews = int.tryParse(tr['review_count']?.toString() ?? '0') ?? 0;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainingDetailsScreen(training: tr),
            ),
          ).then((_) => _fetchTrainings());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aspect ratio square image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  image.isNotEmpty
                      ? Image.network(
                          image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            color: primaryTeal.withOpacity(0.1),
                            child: const Icon(Icons.school, color: primaryTeal, size: 48),
                          ),
                        )
                      : Container(
                          color: primaryTeal.withOpacity(0.1),
                          child: const Icon(Icons.school, color: primaryTeal, size: 48),
                        ),
                  // Bestseller badge
                  if (fee < 5000)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryTeal.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Bestseller",
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category & Mode
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "$cat • $mode",
                            style: const TextStyle(fontSize: 9, color: textLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Star Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : "4.8",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "(${reviews > 0 ? reviews : 420})",
                          style: const TextStyle(fontSize: 9, color: textLight),
                        )
                      ],
                    ),

                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "₹${fee.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryTeal),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "₹${origFee.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 9, color: textLight, decoration: TextDecoration.lineThrough),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: outlineVariant, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _fetchTrainings();
                  }
                : null,
          ),
          Text(
            "Page $_currentPage of $_totalPages",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _fetchTrainings();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
