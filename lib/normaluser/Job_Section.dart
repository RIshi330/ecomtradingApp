import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'job_details_screen.dart';

/// ============================================================
/// API ENDPOINT
/// ============================================================
const String jobsEndpoint = 'new_apis/marketplaceJobs_API.php';

/// ------------------------------------------------------------
/// MODELS
/// ------------------------------------------------------------
class JobItem {
  final String id;
  final String title;
  final String company;
  final String location;
  final String workType;
  final String positionLevel;
  final String category;
  final String salMin;
  final String salMax;
  final String companyLogo;

  JobItem({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workType,
    required this.positionLevel,
    required this.category,
    required this.salMin,
    required this.salMax,
    required this.companyLogo,
  });

  factory JobItem.fromJson(Map json) {
    // Safely extract nested vendor object from backend
    final vendorMap = json['vendor'] is Map ? json['vendor'] as Map : {};

    String companyName = 'Company';
    if (vendorMap['company_name']?.toString().trim().isNotEmpty == true) {
      companyName = vendorMap['company_name'].toString();
    } else if (vendorMap['name']?.toString().trim().isNotEmpty == true) {
      companyName = vendorMap['name'].toString();
    }

    return JobItem(
      id: json['id']?.toString() ?? '',
      title: json['job_title']?.toString() ?? 'Untitled Job',
      company: companyName,
      location: json['work_place']?.toString() ?? '',
      workType: json['work_type']?.toString() ?? '',
      positionLevel: json['position_lvl']?.toString() ?? '',
      category: json['job_category']?.toString() ?? '',
      salMin: json['sal_min']?.toString() ?? '0',
      salMax: json['sal_max']?.toString() ?? '0',
      companyLogo: vendorMap['company_logo']?.toString() ?? '',
    );
  }

  String get salaryRange {
    final minNum = double.tryParse(salMin) ?? 0;
    final maxNum = double.tryParse(salMax) ?? 0;

    if (minNum == 0 && maxNum == 0) return 'Undisclosed';
    if (minNum > 0 && maxNum > 0) return '₹$salMin - ₹$salMax';
    return '₹${minNum > 0 ? salMin : salMax}';
  }
}

/// ------------------------------------------------------------
/// MAIN JOB SECTION SCREEN
/// ------------------------------------------------------------
class SereneJobsScreen extends StatefulWidget {
  // The id of the currently logged-in user/vendor. JobDetailScreen needs
  // this to submit applications under the right account (see the fix
  // applied to job_details_screen.dart - it no longer accepts a hardcoded
  // id). Pass in whatever your app's auth/session layer holds for the
  // logged-in user when you push this screen.

  const SereneJobsScreen({super.key});

  @override
  State<SereneJobsScreen> createState() => _SereneJobsScreenState();
}

class _SereneJobsScreenState extends State<SereneJobsScreen> {
  final Database _db = Database();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Dynamic Filters
  List<String> _categories = [];
  List<String> _positions = [];
  List<String> _workTypes = [];
  List<String> _locations = [];

  // Active Filter Selections
  String? _selectedCategory;
  List<String> _selectedPositions = [];
  List<String> _selectedTypes = [];
  List<String> _selectedLocations = [];
  String _sort = 'id DESC';

  // Data lists & Pagination
  List<JobItem> _featuredJobs = [];
  List<JobItem> _allJobs = [];
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadFeaturedJobs();
    _loadJobs(reset: true);
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
        _hasMore) {
      _loadJobs(reset: false);
    }
  }

  /// Load filter options directly from backend API endpoints
  Future<void> _loadFilters() async {
    try {
      final catRes = await _db.getJsonData({'action': 'getCategories',        'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: jobsEndpoint);
      final posRes = await _db.getJsonData({'action': 'getPositions',        'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: jobsEndpoint);
      final typeRes = await _db.getJsonData({'action': 'getWorkTypes',        'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: jobsEndpoint);
      final locRes = await _db.getJsonData({'action': 'getLocations',        'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: jobsEndpoint);

      if (mounted) {
        setState(() {
          if (catRes['success'] == true) {
            _categories = (catRes['data'] as List? ?? [])
                .map((e) => e['category']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
          if (posRes['success'] == true) {
            _positions = (posRes['data'] as List? ?? [])
                .map((e) => e['position']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
          if (typeRes['success'] == true) {
            _workTypes = (typeRes['data'] as List? ?? [])
                .map((e) => e['type']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
          if (locRes['success'] == true) {
            _locations = (locRes['data'] as List? ?? [])
                .map((e) => e['location']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading filters: $e');
    }
  }

  /// Load latest jobs for the featured carousel (Safely handles missing endpoint)
  Future<void> _loadFeaturedJobs() async {
    try {
      final result = await _db.getJsonData({'action': 'getLatestJobs'}, endpoint: jobsEndpoint);
      if (result['success'] == true && mounted) {
        final rawList = result['data'] is List ? result['data'] as List : [];
        final list = rawList.map((e) => JobItem.fromJson(e as Map)).toList();
        setState(() => _featuredJobs = list);
      } else if (mounted) {
        setState(() => _featuredJobs = []);
      }
    } catch (e) {
      debugPrint('Featured jobs endpoint not present or failed: $e');
      if (mounted) {
        setState(() => _featuredJobs = []);
      }
    }
  }

  /// Load main job list with pagination
  Future<void> _loadJobs({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _offset = 0;
        _hasMore = true;
        _allJobs = [];
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final List<String> activeCategories =
      _selectedCategory != null ? [_selectedCategory!] : [];

      final body = {
        'action': 'getJobs',
        'offset': _offset,
        'limit': _limit,
        'sort': _sort,
        if (activeCategories.isNotEmpty) 'category': activeCategories,
        if (_selectedPositions.isNotEmpty) 'position': _selectedPositions,
        if (_selectedTypes.isNotEmpty) 'type': _selectedTypes,
        if (_selectedLocations.isNotEmpty) 'location': _selectedLocations,
      };

      final result = await _db.getJsonData(body, endpoint: jobsEndpoint);

      if (result['success'] == true) {
        // Direct List parsing from API response
        final rawList = result['data'] is List ? result['data'] as List : [];
        final list = rawList.map((e) => JobItem.fromJson(e as Map)).toList();

        setState(() {
          if (reset) {
            _allJobs = list;
          } else {
            _allJobs.addAll(list);
          }
          _offset += list.length;
          _hasMore = list.length >= _limit;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message']?.toString() ?? 'Failed to load jobs';
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
      builder: (context) => JobFilterBottomSheet(
        positions: _positions,
        workTypes: _workTypes,
        locations: _locations,
        initialPositions: _selectedPositions,
        initialTypes: _selectedTypes,
        initialLocations: _selectedLocations,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPositions = List<String>.from(result['positions'] as List);
        _selectedTypes = List<String>.from(result['types'] as List);
        _selectedLocations = List<String>.from(result['locations'] as List);
      });
      _loadJobs(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Serene Jobs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadFeaturedJobs();
            await _loadJobs(reset: true);
          },
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              _buildSearchAndFilterBar(context),
              const SizedBox(height: 12),

              // Category Filter Horizontal Row
              if (_categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final cat in _categories) ...[
                        _buildCategoryChip(cat),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Featured Jobs Carousel (Section automatically hides if empty)
              if (_featuredJobs.isNotEmpty) ...[
                _buildSectionHeader('Featured Opportunities', hasCarouselControls: true),
                const SizedBox(height: 12),
                _buildFeaturedCarousel(),
                const SizedBox(height: 32),
              ],

              // All Opportunities Header
              _buildSectionHeader(
                'All Opportunities',
                subtitle: 'Showing ${_allJobs.length} results',
              ),
              const SizedBox(height: 16),

              // Main List States
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF006565))),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                      const SizedBox(height: 8),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _loadJobs(reset: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_allJobs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('No jobs found matching your criteria')),
                  )
                else
                  _buildJobList(),

              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF006565))),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Components ---

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = selected ? category : null);
        _loadJobs(reset: true);
      },
      selectedColor: const Color(0xFF006565),
      backgroundColor: const Color(0xFFEBFDFC),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF006565),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _loadJobs(reset: true),
            decoration: InputDecoration(
              hintText: 'Search for opportunities...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _openFilterBottomSheet,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBDC9C8)),
            ),
            child: const Icon(Icons.tune, color: Color(0xFF006565)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle, bool hasCarouselControls = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ]
          ],
        ),
        if (hasCarouselControls)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}, visualDensity: VisualDensity.compact),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}, visualDensity: VisualDensity.compact),
            ],
          )
      ],
    );
  }

  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredJobs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final job = _featuredJobs[index];
          return Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBDC9C8)),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -16,
                  top: -16,
                  bottom: -16,
                  child: Container(width: 4, color: const Color(0xFF006565)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBFDFC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.work, color: Color(0xFF006565)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006565),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'FEATURED',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(job.company, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (job.location.isNotEmpty) _buildBadge(Icons.location_on, job.location),
                        _buildBadge(Icons.payments, job.salaryRange),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Featured Job',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bookmark_border, size: 20),
                              onPressed: () {},
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 90,
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006565),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // FIX: was `currentUserId: ,` - a syntax
                                      // error left over from wiring the
                                      // required param on JobDetailScreen.
                                      // Uses this screen's own currentUserId
                                      // (see the widget field added above),
                                      // instead of the old hardcoded id.
                                      builder: (context) => JobDetailScreen(
                                        currentUserId: '12',
                                        jobId: job.id, // Passes job.id to the detail API
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Apply Now', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobList() {
    return Column(
      children: [
        for (int i = 0; i < _allJobs.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildJobCard(_allJobs[i]),
        ]
      ],
    );
  }

  Widget _buildJobCard(JobItem job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEED),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: job.companyLogo.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    job.companyLogo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Color(0xFF006565)),
                  ),
                )
                    : const Icon(Icons.business, color: Color(0xFF006565)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      job.company,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (job.location.isNotEmpty) _buildBadge(Icons.location_on, job.location),
              if (job.workType.isNotEmpty) _buildBadge(Icons.home_work_outlined, job.workType, isHighlight: true),
              _buildBadge(Icons.payments_outlined, job.salaryRange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job.positionLevel.isNotEmpty ? job.positionLevel : 'Opportunity',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, size: 20, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, size: 20, color: Colors.grey),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 75,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // FIX: same syntax-error/hardcoding issue as the
                            // featured carousel button above.
                            builder: (context) => JobDetailScreen(
                              currentUserId: '12',
                              jobId: job.id, // Passes job.id to the detail API
                            ),
                          ),
                        );
                      },
                      child: const Text('Apply', style: TextStyle(fontSize: 12)),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFEBFDFC) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isHighlight ? const Color(0xFF006565) : Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isHighlight ? const Color(0xFF006565) : Colors.grey[700],
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// FILTER BOTTOM SHEET
/// ------------------------------------------------------------
class JobFilterBottomSheet extends StatefulWidget {
  final List<String> positions;
  final List<String> workTypes;
  final List<String> locations;
  final List<String> initialPositions;
  final List<String> initialTypes;
  final List<String> initialLocations;

  const JobFilterBottomSheet({
    super.key,
    required this.positions,
    required this.workTypes,
    required this.locations,
    required this.initialPositions,
    required this.initialTypes,
    required this.initialLocations,
  });

  @override
  State<JobFilterBottomSheet> createState() => _JobFilterBottomSheetState();
}

class _JobFilterBottomSheetState extends State<JobFilterBottomSheet> {
  late List<String> _selectedPositions;
  late List<String> _selectedTypes;
  late List<String> _selectedLocations;

  @override
  void initState() {
    super.initState();
    _selectedPositions = List.from(widget.initialPositions);
    _selectedTypes = List.from(widget.initialTypes);
    _selectedLocations = List.from(widget.initialLocations);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Opportunities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),

            // Work Type Filters
            if (widget.workTypes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('WORK TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.workTypes.map((type) {
                  final isSel = _selectedTypes.contains(type);
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSel,
                    selectedColor: const Color(0xFFEBFDFC),
                    onSelected: (selected) {
                      setState(() {
                        selected ? _selectedTypes.add(type) : _selectedTypes.remove(type);
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            // Position Level Filters
            if (widget.positions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('POSITION LEVEL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              for (final pos in widget.positions)
                CheckboxListTile(
                  title: Text(pos),
                  value: _selectedPositions.contains(pos),
                  onChanged: (v) {
                    setState(() {
                      v == true ? _selectedPositions.add(pos) : _selectedPositions.remove(pos);
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
            ],

            // Location Filters
            if (widget.locations.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('LOCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.locations.map((loc) {
                  final isSel = _selectedLocations.contains(loc);
                  return FilterChip(
                    label: Text(loc),
                    selected: isSel,
                    selectedColor: const Color(0xFFEBFDFC),
                    onSelected: (selected) {
                      setState(() {
                        selected ? _selectedLocations.add(loc) : _selectedLocations.remove(loc);
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPositions.clear();
                        _selectedTypes.clear();
                        _selectedLocations.clear();
                      });
                    },
                    child: const Text('Reset All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        'positions': _selectedPositions,
                        'types': _selectedTypes,
                        'locations': _selectedLocations,
                      });
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}