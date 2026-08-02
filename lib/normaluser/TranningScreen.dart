import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/normaluser/tranning_details_screen.dart';
import '../Database/Database.dart';

/// ============================================================
/// API ENDPOINT
/// ============================================================
const String trainingEndpoint = 'new_apis/marketplace_trainings_api.php';

/// ------------------------------------------------------------
/// MODELS
/// ------------------------------------------------------------
class TrainingItem {
  final String id;
  final String title;
  final String category;
  final String mode;
  final String type;
  final String city;
  final String duration;
  final String fee;
  final String vendorName;
  final String imageUrl;
  final double avgRating;
  final int reviewCount;

  TrainingItem({
    required this.id,
    required this.title,
    required this.category,
    required this.mode,
    required this.type,
    required this.city,
    required this.duration,
    required this.fee,
    required this.vendorName,
    required this.imageUrl,
    required this.avgRating,
    required this.reviewCount,
  });

  factory TrainingItem.fromJson(Map json) {
    return TrainingItem(
      id: json['id']?.toString() ?? '',
      title: json['training_title']?.toString() ?? 'Untitled Training',
      category: json['cat_id']?.toString() ?? '',
      mode: json['mode']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      fee: json['fee']?.toString() ?? '0',
      vendorName: json['vendor_name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class TrainingDetails {
  final String id;
  final String title;
  final String category;
  final String mode;
  final String type;
  final String city;
  final String duration;
  final String fee;
  final String description;
  final String vendorName;
  final String imageUrl;
  final double avgRating;
  final int reviewCount;
  final String startDate;
  final String endDate;
  final String scheduleTime;

  TrainingDetails({
    required this.id,
    required this.title,
    required this.category,
    required this.mode,
    required this.type,
    required this.city,
    required this.duration,
    required this.fee,
    required this.description,
    required this.vendorName,
    required this.imageUrl,
    required this.avgRating,
    required this.reviewCount,
    required this.startDate,
    required this.endDate,
    required this.scheduleTime,
  });

  factory TrainingDetails.fromJson(Map json) {
    return TrainingDetails(
      id: json['id']?.toString() ?? '',
      title: json['training_title']?.toString() ?? 'Untitled Training',
      category: json['cat_id']?.toString() ?? 'General',
      mode: json['mode']?.toString() ?? 'Online / Live Session',
      type: json['type']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      fee: json['fee']?.toString() ?? '0',
      description: json['description']?.toString() ??
          'Master the end-to-end process of high-fidelity interface design. This comprehensive course covers advanced interaction patterns, accessibility standards, and professional prototyping workflows.',
      vendorName: json['vendor_name']?.toString() ?? 'Master Instructor',
      imageUrl: json['image_url']?.toString() ?? '',
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      startDate: json['start_date']?.toString() ?? 'Oct 15',
      endDate: json['end_date']?.toString() ?? 'Nov 20, 2026',
      scheduleTime: json['schedule_time']?.toString() ?? '6:00 PM - 8:00 PM IST',
    );
  }
}

class SimilarTraining {
  final String id;
  final String title;
  final String category;
  final String fee;
  final String vendorName;
  final String imageUrl;
  final double avgRating;

  SimilarTraining({
    required this.id,
    required this.title,
    required this.category,
    required this.fee,
    required this.vendorName,
    required this.imageUrl,
    required this.avgRating,
  });

  factory SimilarTraining.fromJson(Map json) {
    return SimilarTraining(
      id: json['id']?.toString() ?? '',
      title: json['training_title']?.toString() ?? '',
      category: json['cat_id']?.toString() ?? 'UI DESIGN',
      fee: json['fee']?.toString() ?? '0',
      vendorName: json['vendor_name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0,
    );
  }
}

/// ------------------------------------------------------------
/// SCREEN 1: MAIN TRAINING SECTION
/// ------------------------------------------------------------
class TranningSection extends StatefulWidget {
  const TranningSection({super.key});

  @override
  State<TranningSection> createState() => _TranningSectionState();
}

class _TranningSectionState extends State<TranningSection> {
  final Database _db = Database();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCurrency = 'INR';

  List<String> _categories = [];
  List<String> _modes = [];
  List<String> _types = [];
  List<String> _cities = [];

  String? _selectedCategory;
  List<String> _selectedModes = [];
  List<String> _selectedTypes = [];
  List<String> _selectedCities = [];
  double _maxPrice = 50000;
  String _sort = 'created_date DESC';

  List<TrainingItem> _trainings = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadTrainings(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoading &&
        _page < _totalPages) {
      _loadTrainings(reset: false);
    }
  }

  Future<void> _loadFilters() async {
    try {
      final result = await _db.getData(
        {'action': 'getFilters'},
        endpoint: trainingEndpoint,
      );
      if (result['success'] == true) {
        final data = result['data'] as Map? ?? {};
        setState(() {
          _categories = List<String>.from(data['categories'] ?? []);
          _modes = List<String>.from(data['modes'] ?? []);
          _types = List<String>.from(data['types'] ?? []);
          _cities = List<String>.from(data['cities'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading filters: $e');
    }
  }

  Future<void> _loadTrainings({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
        _trainings = [];
      });
    } else {
      setState(() => _isLoadingMore = true);
      _page += 1;
    }

    try {
      final body = {
        'action': 'getTrainings',
        'page': _page,
        'per_page': 6,
        'search': _searchController.text.trim(),
        'category': _selectedCategory ?? '',
        'max_price': _maxPrice,
        'sort': _sort,
        'modes': _selectedModes,
        'types': _selectedTypes,
        'cities': _selectedCities,
      };

      final result = await _db.getJsonData(body, endpoint: trainingEndpoint);

      if (result['success'] == true) {
        final data = result['data'] as Map? ?? {};
        final list = (data['trainings'] as List? ?? [])
            .map((e) => TrainingItem.fromJson(e as Map))
            .toList();

        setState(() {
          if (reset) {
            _trainings = list;
          } else {
            _trainings.addAll(list);
          }
          _totalPages =
              int.tryParse(data['total_pages']?.toString() ?? '1') ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage =
              result['message']?.toString() ?? 'Failed to load trainings';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _openFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        modes: _modes,
        types: _types,
        cities: _cities,
        initialMaxPrice: _maxPrice,
        initialModes: _selectedModes,
        initialTypes: _selectedTypes,
        initialCities: _selectedCities,
      ),
    );

    if (result != null) {
      setState(() {
        _maxPrice = result['maxPrice'] as double;
        _selectedModes = List<String>.from(result['modes'] as List);
        _selectedTypes = List<String>.from(result['types'] as List);
        _selectedCities = List<String>.from(result['cities'] as List);
      });
      _loadTrainings(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),

       title:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Training',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isDense: true,
                      style: const TextStyle(
                        color: Color(0xFF3E4949),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      items: ['INR', 'USD', 'EUR']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() =>
                          _selectedCurrency = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadTrainings(reset: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF8F9FF), Color(0xFFEFF4FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border(
                      bottom:
                      BorderSide(color: Color(0xFFBDC9C8), width: 0.8),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search, color: Color(0xFF3E4949)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) => _loadTrainings(reset: true),
                                decoration: const InputDecoration(
                                  hintText: 'Search professional courses...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF3E4949),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic,
                                  color: Color(0xFF006565)),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Material(
                              color: const Color(0xFF008080),
                              borderRadius: BorderRadius.circular(50),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: _openFilterBottomSheet,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.tune,
                                          size: 18, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Filters',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                setState(() => _sort = value);
                                _loadTrainings(reset: true);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                    value: 'created_date DESC',
                                    child: Text('Newest')),
                                PopupMenuItem(
                                    value: 'fee ASC',
                                    child: Text('Price: Low to High')),
                                PopupMenuItem(
                                    value: 'fee DESC',
                                    child: Text('Price: High to Low')),
                                PopupMenuItem(
                                    value: 'rating DESC',
                                    child: Text('Top Rated')),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFBDC9C8)),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.swap_vert,
                                        size: 18, color: Color(0xFF3E4949)),
                                    SizedBox(width: 4),
                                    Text('Sort',
                                        style: TextStyle(
                                            color: Color(0xFF3E4949),
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: SizedBox(
                                height: 16,
                                child: VerticalDivider(
                                    color: Color(0xFFBDC9C8)),
                              ),
                            ),
                            for (final cat in _categories) ...[
                              _buildCategoryChip(cat),
                              const SizedBox(width: 6),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Trainings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('See all',
                                style: TextStyle(color: Color(0xFF006565))),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward,
                                size: 16, color: Color(0xFF006565)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF006565))),
                  ),
                )
              else if (_errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 40),
                        const SizedBox(height: 8),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _loadTrainings(reset: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_trainings.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: Text('No trainings found')),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final t = _trainings[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrainingDetailsScreen(
                                    trainingId: t.id, // ✅ Navigates cleanly
                                  ),
                                ),
                              );
                            },
                            child: CourseCard(
                              title: t.title,
                              category: t.category,
                              mode: t.mode.isEmpty ? '-' : t.mode,
                              badge: t.reviewCount > 100 ? 'Bestseller' : null,
                              rating: t.avgRating,
                              reviews: t.reviewCount.toString(),
                              price: '₹${t.fee}',
                              imageUrl: t.imageUrl,
                            ),
                          );
                        },
                        childCount: _trainings.length,
                      ),
                    ),
                  ),
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF006565))),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = selected ? category : null);
        _loadTrainings(reset: true);
      },
      selectedColor: const Color(0xFF006565),
      backgroundColor: const Color(0xFFE5EEFF),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF3E4949),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}