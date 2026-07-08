import 'package:flutter/material.dart';
import '../Database/Database.dart';
import 'job_applications_screen.dart';
import 'job_form.dart';

/// ---------------------------------------------------------------------
/// COLORS
/// ---------------------------------------------------------------------
class AppColors {
  static const background = Color(0xFFF9F9F9);
  static const outlineVariant = Color(0xFFBDC9C8);
  static const surface = Color(0xFFF9F9F9);
  static const onErrorContainer = Color(0xFF93000A);
  static const error = Color(0xFFBA1A1A);
  static const statusNegotiation = Color(0xFFB45309);
  static const surfaceVariant = Color(0xFFE2E2E2);
  static const secondary = Color(0xFF296767);
  static const onBackground = Color(0xFF1A1C1C);
  static const onSecondaryContainer = Color(0xFF306E6D);
  static const primary = Color(0xFF006565);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF008080);
  static const outline = Color(0xFF6E7979);
  static const containerTeal = Color(0xFFE3FFFE);
  static const surfaceContainerLow = Color(0xFFF4F3F3);
  static const onSurface = Color(0xFF1A1C1C);
  static const onSurfaceVariant = Color(0xFF3E4949);
  static const onPrimaryContainer = Color(0xFFE3FFFE);
}

/// ---------------------------------------------------------------------
/// DATA MODELS
/// ---------------------------------------------------------------------

class JobPosting {
  final String id;
  final String category;
  final String title;
  final String location;
  final String salary;
  final String experience;
  final String companyName;
  final String imageUrl;
  final String jobDescPreview;
  final String validityLabel;
  final List<String> skills;
  final int totalApplicants;
  final String detailUrl;
  final String status;
  final String createdDate;
  final String expiryDate;
  final int shortlisted;
  final int applied;
  final int screened;
  final int interviewed;
  final int hire;
  final int notInterested;
  final int onboard;
  final int totalResponses;
  final String packageMessage;

  const JobPosting({
    required this.id,
    required this.category,
    required this.title,
    required this.location,
    this.salary = '',
    this.experience = '',
    this.companyName = '',
    this.imageUrl = '',
    this.jobDescPreview = '',
    this.validityLabel = '',
    this.skills = const [],
    this.totalApplicants = 0,
    this.detailUrl = '',
    this.status = '1',
    this.createdDate = '',
    this.expiryDate = '',
    this.shortlisted = 0,
    this.applied = 0,
    this.screened = 0,
    this.interviewed = 0,
    this.hire = 0,
    this.notInterested = 0,
    this.onboard = 0,
    this.totalResponses = 0,
    this.packageMessage = '',
  });

  bool get isExpired {
    if (expiryDate.isEmpty) return false;
    try {
      final expiry = DateTime.parse(expiryDate);
      return expiry.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool get isActive => status == '1';

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'];
    return JobPosting(
      id: json['id']?.toString() ?? '',
      category: (json['job_type'] ?? json['category'] ?? 'General').toString().toUpperCase(),
      title: json['job_title']?.toString() ?? 'Untitled Role',
      location: json['location']?.toString() ?? 'Remote',
      salary: json['salary']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? 'Unknown Company',
      imageUrl: json['img_url']?.toString() ?? json['image_url']?.toString() ?? '',
      jobDescPreview: json['job_desc_preview']?.toString() ??
          (json['job_desc']?.toString() ?? '').substring(0, 100),
      validityLabel: json['package_message']?.toString() ?? json['validity_days']?.toString() ?? '',
      skills: rawSkills is List
          ? rawSkills
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList()
          : const [],
      totalApplicants: int.tryParse(json['total_responses']?.toString() ??
          json['count_applied']?.toString() ?? '0') ?? 0,
      detailUrl: json['detail_url']?.toString() ?? '',
      status: json['status']?.toString() ?? '1',
      createdDate: json['created_date']?.toString() ?? '',
      expiryDate: json['expiry_date']?.toString() ?? '',
      shortlisted: int.tryParse(json['shortlisted']?.toString() ?? '0') ?? 0,
      applied: int.tryParse(json['applied']?.toString() ?? '0') ?? 0,
      screened: int.tryParse(json['screened']?.toString() ?? '0') ?? 0,
      interviewed: int.tryParse(json['interviewed']?.toString() ?? '0') ?? 0,
      hire: int.tryParse(json['hire']?.toString() ?? '0') ?? 0,
      notInterested: int.tryParse(json['not_interested']?.toString() ?? '0') ?? 0,
      onboard: int.tryParse(json['onboard']?.toString() ?? '0') ?? 0,
      totalResponses: int.tryParse(json['total_responses']?.toString() ?? '0') ?? 0,
      packageMessage: json['package_message']?.toString() ?? '',
    );
  }
}

/// ---------------------------------------------------------------------
/// MAIN SCREEN
/// ---------------------------------------------------------------------
class JobManagementHub extends StatefulWidget {
  final bool isEmbedded;
  const JobManagementHub({super.key, this.isEmbedded = true});

  @override
  State<JobManagementHub> createState() => _JobManagementHubState();
}

class _JobManagementHubState extends State<JobManagementHub> {
  final Database _db = Database();

  bool _searchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  String _categoryFilter = 'All Categories';
  List<String> _categoryOptions = ['All Categories'];
  String _query = '';

  List<JobPosting> _jobs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  int _lastPage = 1;
  int _totalJobs = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _searchFocused = _searchFocusNode.hasFocus);
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _fetchJobs();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs({bool append = false}) async {
    if (!append) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final result = await _db.getJobs(
        page: _page,
        category: _categoryFilter == 'All Categories' ? null : _categoryFilter,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final rawData = (result['data'] as List?) ?? [];
        final fetched = rawData
            .map((e) => JobPosting.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();

        // Extract categories from the response if available
        final filters = (result['filters'] as Map?) ?? {};
        final categories = List<String>.from(
          (filters['job_types'] ?? filters['categories'] ?? []) as List,
        );

        setState(() {
          if (append) {
            _jobs = [..._jobs, ...fetched];
          } else {
            _jobs = fetched;
          }
          _totalJobs = (result['total'] as num?)?.toInt() ?? _jobs.length;
          _lastPage = (result['last_page'] as num?)?.toInt() ?? 1;
          _hasMore = fetched.length == 12;
          if (categories.isNotEmpty && _categoryOptions.length == 1) {
            _categoryOptions = ['All Categories', ...categories];
          }
          _error = null;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _error = result['message']?.toString() ?? 'Failed to load jobs';
          _isLoading = false;
          _isLoadingMore = false;
          if (!append) _jobs = [];
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: ${e.toString()}';
        _isLoading = false;
        _isLoadingMore = false;
        if (!append) _jobs = [];
      });
    }
  }

  Future<void> _handleRefresh() async {
    _page = 1;
    _hasMore = true;
    await _fetchJobs();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _page++;
    await _fetchJobs(append: true);
  }

  List<JobPosting> get _filteredJobs {
    if (_query.isEmpty) return _jobs;
    return _jobs.where((job) {
      return job.title.toLowerCase().contains(_query) ||
          job.category.toLowerCase().contains(_query) ||
          job.location.toLowerCase().contains(_query) ||
          job.companyName.toLowerCase().contains(_query);
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        String category = _categoryFilter;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Filter Jobs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 20),
                const Text('Category',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 0.5)),
                const SizedBox(height: 6),
                _dropdownField(
                  value: category,
                  items: _categoryOptions,
                  onChanged: (v) => setSheetState(() => category = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          side: const BorderSide(color: AppColors.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setSheetState(() {
                            category = 'All Categories';
                          });
                        },
                        child: const Text('Reset', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            _categoryFilter = category;
                            _page = 1;
                            _hasMore = true;
                          });
                          Navigator.pop(sheetContext);
                          _fetchJobs();
                        },
                        child: const Text('Apply Filters',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
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
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.outline),
          style: const TextStyle(fontSize: 13, color: AppColors.onBackground),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;
    final hasActiveFilters = _categoryFilter != 'All Categories';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isEmbedded ? null : _buildAppBar(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSummaryStats(),
                    const SizedBox(height: 20),
                    _buildHeaderAndSearch(hasActiveFilters),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (_isLoading && _jobs.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_error != null && _jobs.isEmpty)
                SliverFillRemaining(
                  child: _buildErrorState(_error!),
                )
              else if (jobs.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        if (index < jobs.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: JobCardWidget(
                              job: jobs[index],
                              onStatusChanged: _handleRefresh,
                              onDelete: _handleRefresh,
                            ),
                          );
                        } else if (_hasMore) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: _isLoadingMore
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                                  : TextButton(
                                onPressed: _loadMore,
                                child: const Text('Load more jobs'),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                      childCount: jobs.length + (_hasMore ? 1 : 0),
                    ),
                  ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      titleSpacing: 16,
      shape: const Border(
        bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withOpacity(0.15),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Text(
            'Serene Recruiter',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.primary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSummaryStats() {
    final totalApplicants = _jobs.fold<int>(
        0,
            (sum, j) => sum + j.totalApplicants
    );

    final stats = <_StatTile>[
      _StatTile('POSTED JOBS', '$_totalJobs', Icons.work, AppColors.primary,
          AppColors.primary, Colors.white),
      _StatTile(
          'TOTAL APPLICANTS',
          '$totalApplicants',
          Icons.group,
          AppColors.primary,
          AppColors.primary,
          Colors.white),
      _StatTile('LOADED', '${_jobs.length} of $_totalJobs', Icons.list_alt,
          AppColors.statusNegotiation, AppColors.statusNegotiation, Colors.white),
    ];

    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final s = stats[i];
          final filled = s.bgColor != Colors.white;
          return Container(
            width: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: s.bgColor,
              borderRadius: BorderRadius.circular(14),
              border: filled ? null : Border.all(color: AppColors.outlineVariant),
              boxShadow: filled
                  ? [
                BoxShadow(
                  color: s.textColor.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: filled
                              ? s.textColor.withOpacity(0.85)
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(s.icon, size: 20, color: s.iconColor),
                  ],
                ),
                Text(
                  s.value,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: s.textColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderAndSearch(bool hasActiveFilters) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active Postings',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                '${_filteredJobs.length} of ${_jobs.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _searchFocused
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      width: _searchFocused ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Search jobs...',
                            hintStyle: TextStyle(
                                fontSize: 14, color: AppColors.onSurfaceVariant),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: const Icon(Icons.close,
                              color: AppColors.outline, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _FilterButton(
                active: hasActiveFilters,
                onTap: _openFilterSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Retry',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off, color: AppColors.outline, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'No jobs match your filters',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onBackground),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or clearing filters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _categoryFilter = 'All Categories';
                _searchController.clear();
                _page = 1;
              });
              _fetchJobs();
            },
            child: const Text('Clear all filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostOpportunityScreen()),
        );
      },
      child: const Icon(Icons.add, size: 28),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FilterButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: active ? AppColors.primary : AppColors.outlineVariant),
          ),
          child: Icon(Icons.tune,
              color: active ? Colors.white : AppColors.outline, size: 20),
        ),
      ),
    );
  }
}

class _StatTile {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color bgColor;
  _StatTile(this.label, this.value, this.icon, this.iconColor, this.textColor,
      this.bgColor);
}

/// ---------------------------------------------------------------------
/// JOB CARD WIDGET
/// ---------------------------------------------------------------------
class JobCardWidget extends StatelessWidget {
  final JobPosting job;
  final VoidCallback? onStatusChanged;
  final VoidCallback? onDelete;

  const JobCardWidget({
    super.key,
    required this.job,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final db = Database();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: const BorderSide(color: AppColors.outlineVariant),
          bottom: const BorderSide(color: AppColors.outlineVariant),
          right: const BorderSide(color: AppColors.outlineVariant),
          left: BorderSide(
            color: job.isExpired ? AppColors.outlineVariant : AppColors.primary,
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category + status badge
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                job.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: job.isExpired
                      ? AppColors.surfaceVariant
                      : AppColors.containerTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: job.isExpired ? AppColors.outline : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.isExpired ? 'EXPIRED' :
                      job.isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: job.isExpired
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if (job.packageMessage.isNotEmpty)
                Text(
                  job.packageMessage,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            job.title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          // Location + salary
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _iconText(Icons.location_on, job.location),
              if (job.salary.isNotEmpty) _iconText(Icons.payments, job.salary),
              if (job.experience.isNotEmpty)
                _iconText(Icons.work_history, job.experience),
            ],
          ),
          if (job.jobDescPreview.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              job.jobDescPreview,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (job.skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Text(skill,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          // Applicant count + actions
          LayoutBuilder(
            builder: (context, constraints) {
              final applicantBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${job.totalApplicants}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                  const Text(
                    'APPLICANTS',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.onSurfaceVariant),
                  ),
                ],
              );

              final actionBlock = Wrap(
                spacing: 6,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobApplicationsScreen(
                            jobId: job.id,
                            jobTitle: job.title,
                            jobLocation: job.location,
                          ),
                        ),
                      );
                    },
                    child: const Text('View Applicants',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant),
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                    onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => PostOpportunityScreen(
                    //         // jobToEdit: job,
                    //       ),
                    //     ),
                    //   );
                     },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: AppColors.onSurfaceVariant),
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => PostOpportunityScreen(
                          //       jobToEdit: job,
                          //     ),
                          //   ),
                          // );
                          break;
                        case 'share':
                          _showShareOptions(context);
                          break;
                        case 'stats':
                          _showStatsDialog(context);
                          break;
                        case 'change_status':
                          _showStatusChangeDialog(context, db);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, db);
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                          value: 'edit',
                          child: _MenuRow(icon: Icons.edit, label: 'Edit')),
                      PopupMenuItem(
                          value: 'share',
                          child: _MenuRow(icon: Icons.share, label: 'Share')),
                      PopupMenuItem(
                          value: 'stats',
                          child: _MenuRow(icon: Icons.bar_chart, label: 'View Stats')),
                      PopupMenuItem(
                          value: 'change_status',
                          child: _MenuRow(icon: Icons.swap_horiz, label: 'Change Status')),
                      PopupMenuItem(
                          value: 'delete',
                          child: _MenuRow(icon: Icons.delete_outline, label: 'Delete')),
                    ],
                  ),
                ],
              );

              if (constraints.maxWidth < 340) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    applicantBlock,
                    const SizedBox(height: 10),
                    actionBlock,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  applicantBlock,
                  const Spacer(),
                  actionBlock,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share Job', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text('Share via Email'),
              onTap: () {
                Navigator.pop(context);
                // Implement email share
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primary),
              title: const Text('Share via...'),
              onTap: () {
                Navigator.pop(context);
                // Implement share via system share
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stats for "${job.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow('Total Applicants', job.totalApplicants),
            _statRow('Shortlisted', job.shortlisted),
            _statRow('Screened', job.screened),
            _statRow('Interviewed', job.interviewed),
            _statRow('Hired', job.hire),
            _statRow('Onboarded', job.onboard),
            _statRow('Not Interested', job.notInterested),
            const Divider(),
            _statRow('Posted', job.createdDate),
            _statRow('Expires', job.expiryDate),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Database db) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: Text('Are you sure you want to delete "${job.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await db.deleteJob(job.id);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job deleted successfully')),
                );
                onDelete?.call();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Failed to delete job')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context, Database db) {
    final statusOptions = [
      {'value': '0', 'label': 'Pending for QC'},
      {'value': '1', 'label': 'Approved'},
      {'value': '2', 'label': 'Assign for QC'},
      {'value': '3', 'label': 'Suspended'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Job Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.map((option) {
            return ListTile(
              title: Text(option['label']!),
              onTap: () async {
                Navigator.pop(context);
                final result = await db.updateJobStatus(
                  jobId: job.id,
                  status: option['value']!,
                );
                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Status updated')),
                  );
                  onStatusChanged?.call();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Failed to update status')),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text,
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurface),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}