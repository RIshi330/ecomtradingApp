import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

/// OpportunityHub — manage listings, applicants, and offers.
///
/// Fully wired to the marketplace_opportunity PHP API using the same
/// Database().getData(...) pattern as BusinessUserProfileScreen:
///   - get_all_opportunities        -> list + search + filter + paginate
///   - get_opportunity_filters      -> populate the filter panel
///   - get_opportunity_applicants   -> applicants list + stats for a job
///   - change_opportunity_status    -> activate / deactivate a listing
///   - update_application_status    -> approve / reject / reset an applicant
///
/// Visual language: a quiet, "dusk sky" palette — deep indigo used sparingly
/// as the signature accent against a soft teal/near-white surface, generous
/// spacing, and one consistent card language throughout.
class manageopportunity extends StatefulWidget {
  const manageopportunity({super.key});

  @override
  State<manageopportunity> createState() => _OpportunityHubScreenState();
}

class _OpportunityHubScreenState extends State<manageopportunity> {
  // ---------------------------------------------------------------------
  // Point this at wherever the PHP file lives, same pattern as
  // `_profileEndpoint` in BusinessUserProfileScreen.
  // ---------------------------------------------------------------------
  static const String _endpoint = 'new_apis/vendor/marketplace_opportunity_api.php';

  // ---------------------- Design tokens ----------------------
  static const Color ink = Color(0xFF141A2E); // near-black indigo, primary text
  static const Color inkSoft = Color(0xFF6E7488); // secondary text
  static const Color teal = Color(0xFF0E6E6A); // primary brand
  static const Color tealDeep = Color(0xFF0A5652);
  static const Color dusk = Color(0xFF4C4FC7); // signature celestial accent
  static const Color duskSoft = Color(0xFFEEEEFB);
  static const Color amber = Color(0xFFB8860B);
  static const Color rose = Color(0xFFB3261E);
  static const Color sage = Color(0xFF2E7D4F);
  static const Color surface = Colors.white;
  static const Color canvasTop = Color(0xFFF3F7F8);
  static const Color canvasBottom = Color(0xFFF8F7FC);
  static const Color hairline = Color(0xFFE6E9EF);
  static const Color chip = Color(0xFFF3F4F8);

  static const double rLg = 20;
  static const double rMd = 14;
  static const double rSm = 10;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0A141A2E), blurRadius: 24, offset: Offset(0, 10)),
  ];

  // Search
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  // Opportunities list state
  bool _isLoadingOpportunities = true;
  bool _isLoadingMore = false;
  String? _loadError;
  List<dynamic> _opportunities = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;

  // Filters
  Map<String, dynamic> _filterOptions = {};
  bool _isLoadingFilters = false;
  bool _isFilterModalVisible = false;
  String _selectedType = '';
  String _selectedIndustry = '';
  String _selectedLocation = '';
  String _selectedOpportunityFor = '';
  String _selectedCategoryId = '';
  String _selectedLabel = '';
  String _explore = '';

  // Applicants modal state
  bool _isApplicantsModalVisible = false;
  Map<String, dynamic>? _activeOpportunity;
  List<dynamic> _applicants = [];
  Map<String, dynamic> _applicantStats = {
    "total": 0,
    "pending": 0,
    "approved": 0,
    "rejected": 0,
  };
  bool _isLoadingApplicants = false;
  int _applicantsPage = 1;
  int _applicantsTotalPages = 1;
  String _applicantStatusFilter = '';
  bool _isUpdatingApplication = false;

  // Toast
  bool _isToastVisible = false;
  String _toastMessage = '';
  bool _toastIsError = false;

  @override
  void initState() {
    super.initState();
    _fetchFilters();
    _fetchOpportunities(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // =======================================================================
  // API CALLS
  // =======================================================================

  Future<void> _fetchFilters() async {
    setState(() => _isLoadingFilters = true);
    try {
      final res = await Database().getData(
        {'action': 'get_opportunity_filters'},
        endpoint: _endpoint,
      );
      if (res['success'] == true && res['data'] != null) {
        setState(() {
          _filterOptions = Map<String, dynamic>.from(res['data']);
        });
      }
    } catch (e) {
      debugPrint('Error fetching filters: $e');
    } finally {
      if (mounted) setState(() => _isLoadingFilters = false);
    }
  }

  Future<void> _fetchOpportunities({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoadingOpportunities = true;
        _loadError = null;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final res = await Database().getData({
        'action': 'get_all_opportunities',
        'page': _currentPage,
        'limit': 10,
        'search': _searchController.text.trim(),
        'type': _selectedType,
        'industry': _selectedIndustry,
        'location': _selectedLocation,
        'opportunity_for': _selectedOpportunityFor,
        'category_id': _selectedCategoryId,
        'label': _selectedLabel,
        'explore': _explore,
      }, endpoint: _endpoint);

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final list = (data['opportunities'] as List?) ?? [];
        setState(() {
          if (reset) {
            _opportunities = list;
          } else {
            _opportunities = [..._opportunities, ...list];
          }
          _totalPages = int.tryParse(data['total_pages']?.toString() ?? '1') ?? 1;
          _totalRecords = int.tryParse(data['total_records']?.toString() ?? '0') ?? 0;
          _loadError = null;
        });
      } else {
        setState(() {
          _loadError = res['message']?.toString() ?? 'Failed to load opportunities';
        });
      }
    } catch (e) {
      setState(() => _loadError = 'Network error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOpportunities = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreOpportunities() async {
    if (_currentPage >= _totalPages || _isLoadingMore || _isLoadingOpportunities) return;
    _currentPage += 1;
    await _fetchOpportunities();
  }

  Future<void> _toggleOpportunityStatus(Map<String, dynamic> opp) async {
    final opportunity = opp['opportunity'];
    final currentStatus = int.tryParse(opportunity['opportunity_status']?.toString() ?? '1') ?? 1;
    final newStatus = currentStatus == 1 ? 0 : 1;

    setState(() => opportunity['opportunity_status'] = newStatus);

    try {
      final res = await Database().getData({
        'action': 'change_opportunity_status',
        'opportunity_id': opportunity['id'],
        'status': newStatus,
      }, endpoint: _endpoint);

      if (res['success'] == true) {
        _showToast(newStatus == 1 ? 'Listing activated' : 'Listing deactivated');
      } else {
        setState(() => opportunity['opportunity_status'] = currentStatus);
        _showToast(res['message']?.toString() ?? 'Couldn\'t update status', isError: true);
      }
    } catch (e) {
      setState(() => opportunity['opportunity_status'] = currentStatus);
      _showToast('Network error: $e', isError: true);
    }
  }

  Future<void> _openApplicantsModal(Map<String, dynamic> opp) async {
    setState(() {
      _activeOpportunity = opp;
      _isApplicantsModalVisible = true;
      _applicants = [];
      _applicantsPage = 1;
      _applicantStatusFilter = '';
    });
    await _fetchApplicants(reset: true);
  }

  Future<void> _fetchApplicants({bool reset = false}) async {
    if (_activeOpportunity == null) return;
    if (reset) {
      _applicantsPage = 1;
    }
    setState(() => _isLoadingApplicants = true);
    try {
      final res = await Database().getData({
        'action': 'get_opportunity_applicants',
        'opportunity_id': _activeOpportunity!['opportunity']['id'],
        'page': _applicantsPage,
        'limit': 10,
        'status': _applicantStatusFilter,
      }, endpoint: _endpoint);

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final list = (data['applicants'] as List?) ?? [];
        setState(() {
          if (reset) {
            _applicants = list;
          } else {
            _applicants = [..._applicants, ...list];
          }
          _applicantStats = Map<String, dynamic>.from(data['stats'] ?? _applicantStats);
          _applicantsTotalPages = int.tryParse(data['total_pages']?.toString() ?? '1') ?? 1;
        });
      } else {
        _showToast(res['message']?.toString() ?? 'Couldn\'t load applicants', isError: true);
      }
    } catch (e) {
      _showToast('Network error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingApplicants = false);
    }
  }

  Future<void> _loadMoreApplicants() async {
    if (_applicantsPage >= _applicantsTotalPages || _isLoadingApplicants) return;
    _applicantsPage += 1;
    await _fetchApplicants();
  }

  Future<void> _updateApplicationStatus(Map<String, dynamic> entry, int status) async {
    final application = entry['application'];
    setState(() => _isUpdatingApplication = true);
    try {
      final res = await Database().getData({
        'action': 'update_application_status',
        'application_id': application['id'],
        'status': status,
      }, endpoint: _endpoint);

      if (res['success'] == true) {
        setState(() {
          application['status'] = status;
          application['status_label'] = res['data']?['status_text'] ?? application['status_label'];
        });
        _showToast(
          status == 1
              ? 'Application approved'
              : status == -1
              ? 'Application rejected'
              : 'Application marked pending',
        );
        await _fetchApplicants(reset: true);
      } else {
        _showToast(res['message']?.toString() ?? 'Couldn\'t update application', isError: true);
      }
    } catch (e) {
      _showToast('Network error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingApplication = false);
    }
  }

  // =======================================================================
  // HELPERS
  // =======================================================================

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchOpportunities(reset: true);
    });
  }

  void _toggleFilterModal() => setState(() => _isFilterModalVisible = !_isFilterModalVisible);

  void _closeApplicantsModal() => setState(() => _isApplicantsModalVisible = false);

  void _applyFilters() {
    setState(() => _isFilterModalVisible = false);
    _fetchOpportunities(reset: true);
  }

  void _resetFilters() {
    setState(() {
      _selectedType = '';
      _selectedIndustry = '';
      _selectedLocation = '';
      _selectedOpportunityFor = '';
      _selectedCategoryId = '';
      _selectedLabel = '';
      _explore = '';
    });
  }

  void _showToast(String message, {bool isError = false}) {
    setState(() {
      _toastMessage = message;
      _toastIsError = isError;
      _isToastVisible = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isToastVisible = false);
    });
  }

  int get _activeCount => _opportunities.where((o) {
    final s = int.tryParse(o['opportunity']['opportunity_status']?.toString() ?? '1') ?? 1;
    return s == 1;
  }).length;

  int get _applicationsSum => _opportunities.fold<int>(
    0,
        (sum, o) => sum + (int.tryParse(o['opportunity']['total_applications']?.toString() ?? '0') ?? 0),
  );

  int _countByLabel(int label) => _opportunities.where((o) {
    return int.tryParse(o['opportunity']['label']?.toString() ?? '0') == label;
  }).length;

  bool get _hasActiveFilters =>
      _selectedType.isNotEmpty ||
          _selectedIndustry.isNotEmpty ||
          _selectedLocation.isNotEmpty ||
          _selectedOpportunityFor.isNotEmpty ||
          _selectedCategoryId.isNotEmpty ||
          _selectedLabel.isNotEmpty;

  // =======================================================================
  // BUILD
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 860;
    final horizontalPadding = isDesktop ? 48.0 : 20.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [canvasTop, canvasBottom],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                color: dusk,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await _fetchFilters();
                  await _fetchOpportunities(reset: true);
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildStatusSlider(),
                          const SizedBox(height: 28),
                          _buildSearchBar(),
                          const SizedBox(height: 28),
                          _buildOpportunitiesSection(),
                          const SizedBox(height: 96),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isFilterModalVisible) _buildFilterModal(),
              if (_isApplicantsModalVisible) _buildApplicantsModal(),
              if (_isToastVisible) _buildToast(),
            ],
          ),
        ),
      ),
    );
  }


  // ---------------------- Status slider (derived from live data) ----------------------
  Widget _buildStatusSlider() {
    final items = [
      {'icon': Icons.dashboard_customize_outlined, 'label': 'Total listings', 'count': '$_totalRecords', 'tint': teal},
      {'icon': Icons.bolt_rounded, 'label': 'Active now', 'count': '$_activeCount', 'tint': sage},
      {'icon': Icons.groups_2_outlined, 'label': 'Applicants', 'count': '$_applicationsSum', 'tint': dusk},
      {'icon': Icons.star_rounded, 'label': 'Featured', 'count': '${_countByLabel(1)}', 'tint': amber},
      {'icon': Icons.campaign_outlined, 'label': 'Sponsored', 'count': '${_countByLabel(2)}', 'tint': teal},
      {'icon': Icons.workspace_premium_rounded, 'label': 'Premium', 'count': '${_countByLabel(3)}', 'tint': dusk},
    ];

    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final Color tint = item['tint'] as Color;
          return Container(
            width: 148,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(rMd),
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: tint.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
                  child: Icon(item['icon'] as IconData, color: tint, size: 16),
                ),
                const Spacer(),
                Text(
                  item['count'] as String,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.4),
                ),
                const SizedBox(height: 2),
                Text(
                  item['label'] as String,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: inkSoft, letterSpacing: 0.1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------- Search + filters ----------------------
  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(rLg),
            boxShadow: cardShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: inkSoft, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _fetchOpportunities(reset: true),
                  style: const TextStyle(fontSize: 14, color: ink, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: 'Search listings, industries, or skills…',
                    hintStyle: TextStyle(fontSize: 14, color: inkSoft, fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    _searchController.clear();
                    _fetchOpportunities(reset: true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close_rounded, size: 16, color: inkSoft),
                  ),
                ),
              const SizedBox(width: 2),
              Container(height: 22, width: 1, color: hairline),
              const SizedBox(width: 6),
              InkWell(
                onTap: _toggleFilterModal,
                borderRadius: BorderRadius.circular(rSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, color: _hasActiveFilters ? dusk : inkSoft, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _hasActiveFilters ? dusk : inkSoft,
                        ),
                      ),
                      if (_hasActiveFilters) ...[
                        const SizedBox(width: 5),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: dusk, shape: BoxShape.circle)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildExploreChip('Featured', 'featured', Icons.star_rounded),
            const SizedBox(width: 8),
            _buildExploreChip('Sponsored', 'sponsored', Icons.campaign_outlined),
            const SizedBox(width: 8),
            _buildExploreChip('Premium', 'premium', Icons.workspace_premium_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildExploreChip(String label, String value, IconData icon) {
    final selected = _explore == value;
    return InkWell(
      onTap: () {
        setState(() => _explore = selected ? '' : value);
        _fetchOpportunities(reset: true);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? dusk : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? dusk : hairline),
          boxShadow: selected ? const [BoxShadow(color: Color(0x334C4FC7), blurRadius: 12, offset: Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? Colors.white : inkSoft),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : inkSoft,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- Opportunities section ----------------------
  Widget _buildOpportunitiesSection() {
    if (_isLoadingOpportunities) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 72),
        child: Center(child: CircularProgressIndicator(color: dusk, strokeWidth: 2.5)),
      );
    }

    if (_loadError != null) {
      return _buildStatePanel(
        icon: Icons.cloud_off_rounded,
        iconColor: rose,
        title: 'Couldn\'t load listings',
        message: _loadError!,
        actionLabel: 'Try again',
        onAction: () => _fetchOpportunities(reset: true),
      );
    }

    if (_opportunities.isEmpty) {
      return _buildStatePanel(
        icon: Icons.inbox_rounded,
        iconColor: dusk,
        title: 'No opportunities yet',
        message: _hasActiveFilters || _searchController.text.isNotEmpty
            ? 'Nothing matches your search or filters. Try clearing them.'
            : 'Listings you create will show up here.',
        actionLabel: (_hasActiveFilters || _searchController.text.isNotEmpty) ? 'Clear filters' : null,
        onAction: (_hasActiveFilters || _searchController.text.isNotEmpty)
            ? () {
          _searchController.clear();
          _resetFilters();
          _fetchOpportunities(reset: true);
        }
            : null,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 980 ? 3 : (constraints.maxWidth > 640 ? 2 : 1);
        return Column(
          children: [
            Row(
              children: [
                Text(
                  '$_totalRecords listing${_totalRecords == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _opportunities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 236,
              ),
              itemBuilder: (context, index) => _buildOpportunityCard(_opportunities[index]),
            ),
            const SizedBox(height: 20),
            if (_currentPage < _totalPages)
              Center(
                child: OutlinedButton(
                  onPressed: _isLoadingMore ? null : _loadMoreOpportunities,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: hairline),
                    backgroundColor: surface,
                    foregroundColor: ink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 28),
                  ),
                  child: _isLoadingMore
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: dusk))
                      : const Text('Show more', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatePanel({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(rLg), boxShadow: cardShadow),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: inkSoft, height: 1.5)),
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: dusk,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
              ),
              child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opp) {
    final Map opportunity = opp['opportunity'] ?? {};
    final Map? vendor = opp['vendor'];
    final Map? compensation = opp['compensation'];
    final List skills = (opportunity['skills_array'] as List?) ?? [];
    final int status = int.tryParse(opportunity['opportunity_status']?.toString() ?? '1') ?? 1;
    final String? labelName = opportunity['label_name']?.toString();

    String? amount;
    if (compensation != null) {
      amount = (compensation['amount'] ?? compensation['budget'] ?? compensation['salary'])?.toString();
    }

    final String? logoUrl = vendor != null ? (vendor['company_logo'] ?? vendor['profile_pic'])?.toString() : null;
    final bool hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(rMd), boxShadow: cardShadow),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: teal.withOpacity(0.1),
                  onBackgroundImageError: hasLogo ? (_, __) {} : null,
                  child: hasLogo ? null : const Icon(Icons.business_center_rounded, color: teal, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity['title']?.toString() ?? 'Untitled opportunity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.1),
                      ),
                      Text(
                        opportunity['category_title']?.toString() ?? opportunity['type']?.toString() ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: inkSoft),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.72,
                  child: Switch(
                    value: status == 1,
                    activeColor: sage,
                    onChanged: (_) => _toggleOpportunityStatus(opp),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (labelName != null) ...[
                  _pill(labelName, _labelTint(opportunity['label']?.toString())),
                  const SizedBox(width: 6),
                ],
                const Icon(Icons.place_outlined, size: 12, color: inkSoft),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    opportunity['location']?.toString().isNotEmpty == true
                        ? opportunity['location'].toString()
                        : 'Remote',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: inkSoft, fontWeight: FontWeight.w500),
                  ),
                ),
                if (amount != null)
                  Text(
                    '₹$amount',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: teal, letterSpacing: -0.2),
                  ),
              ],
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: skills.take(3).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: chip, borderRadius: BorderRadius.circular(7)),
                  child: Text(s.toString(), style: const TextStyle(fontSize: 9.5, color: inkSoft, fontWeight: FontWeight.w600)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Container(height: 1, color: hairline),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.groups_2_outlined, size: 13, color: inkSoft),
                const SizedBox(width: 4),
                Text(
                  '${opportunity['total_applications'] ?? 0} applicants',
                  style: const TextStyle(fontSize: 11, color: inkSoft, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _openApplicantsModal(opp),
                  borderRadius: BorderRadius.circular(rSm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [teal, tealDeep]),
                      borderRadius: BorderRadius.circular(rSm),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Review', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _labelTint(String? label) {
    switch (label) {
      case '1':
        return amber;
      case '2':
        return teal;
      case '3':
        return dusk;
      default:
        return inkSoft;
    }
  }

  Widget _pill(String label, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: tint.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: tint, letterSpacing: 0.2)),
    );
  }

  // ---------------------- Filter panel ----------------------
  Widget _buildFilterModal() {
    final types = (_filterOptions['types'] as List?) ?? [];
    final industries = (_filterOptions['industries'] as List?) ?? [];
    final locations = (_filterOptions['locations'] as List?) ?? [];
    final opportunityFors = (_filterOptions['opportunity_for'] as List?) ?? [];
    final categories = (_filterOptions['categories'] as List?) ?? [];
    final labels = (_filterOptions['labels'] as List?) ?? [];

    return GestureDetector(
      onTap: _toggleFilterModal,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: Container(
          color: ink.withOpacity(0.35),
          child: GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.86,
                heightFactor: 1.0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filters', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3)),
                          InkWell(
                            onTap: _toggleFilterModal,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: chip, borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.close_rounded, size: 18, color: inkSoft),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _isLoadingFilters
                            ? const Center(child: CircularProgressIndicator(color: dusk, strokeWidth: 2.5))
                            : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _filterSection('Type', types.map((t) => t.toString()).toList(), _selectedType,
                                      (v) => setState(() => _selectedType = _selectedType == v ? '' : v)),
                              _filterSection('Industry', industries.map((t) => t.toString()).toList(), _selectedIndustry,
                                      (v) => setState(() => _selectedIndustry = _selectedIndustry == v ? '' : v)),
                              _filterSection('Location', locations.map((t) => t.toString()).toList(), _selectedLocation,
                                      (v) => setState(() => _selectedLocation = _selectedLocation == v ? '' : v)),
                              _filterSection('Opportunity for', opportunityFors.map((t) => t.toString()).toList(),
                                  _selectedOpportunityFor, (v) => setState(() => _selectedOpportunityFor = _selectedOpportunityFor == v ? '' : v)),
                              _buildFilterGroupLabel('Category'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categories.map((c) {
                                  final id = c['id'].toString();
                                  final selected = _selectedCategoryId == id;
                                  return _chip(c['category_title']?.toString() ?? '', selected,
                                          () => setState(() => _selectedCategoryId = selected ? '' : id));
                                }).toList(),
                              ),
                              const SizedBox(height: 22),
                              _buildFilterGroupLabel('Label'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: labels.map((l) {
                                  final id = l['id'].toString();
                                  final selected = _selectedLabel == id;
                                  return _chip(l['name']?.toString() ?? '', selected,
                                          () => setState(() => _selectedLabel = selected ? '' : id));
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(_resetFilters),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: hairline),
                                foregroundColor: ink,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Reset', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: dusk,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Apply filters', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterGroupLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ink, letterSpacing: 0.1)),
    );
  }

  Widget _filterSection(String title, List<String> values, String selectedValue, ValueChanged<String> onTap) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterGroupLabel(title),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((v) => _chip(v, selectedValue == v, () => onTap(v))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? dusk.withOpacity(0.1) : chip,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? dusk : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 13, color: dusk),
              const SizedBox(width: 4),
            ],
            Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? dusk : inkSoft)),
          ],
        ),
      ),
    );
  }

  // ---------------------- Applicants modal ----------------------
  Widget _buildApplicantsModal() {
    final opportunity = _activeOpportunity?['opportunity'];
    return GestureDetector(
      onTap: _closeApplicantsModal,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: Container(
          color: ink.withOpacity(0.4),
          child: GestureDetector(
            onTap: () {},
            child: Center(
              child: Container(
                width: 540,
                constraints: BoxConstraints(maxWidth: 540, maxHeight: MediaQuery.of(context).size.height * 0.86),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Color(0x33141A2E), blurRadius: 40, offset: Offset(0, 20))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Applicants', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: inkSoft, letterSpacing: 0.4)),
                                const SizedBox(height: 2),
                                Text(
                                  opportunity?['title']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _closeApplicantsModal,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: chip, borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.close_rounded, size: 18, color: inkSoft),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          _statPill('Total', _applicantStats['total'], ink),
                          const SizedBox(width: 8),
                          _statPill('Pending', _applicantStats['pending'], amber),
                          const SizedBox(width: 8),
                          _statPill('Approved', _applicantStats['approved'], sage),
                          const SizedBox(width: 8),
                          _statPill('Rejected', _applicantStats['rejected'], rose),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          _statusFilterChip('All', ''),
                          const SizedBox(width: 8),
                          _statusFilterChip('Pending', '0'),
                          const SizedBox(width: 8),
                          _statusFilterChip('Approved', '1'),
                          const SizedBox(width: 8),
                          _statusFilterChip('Rejected', '-1'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: hairline),
                    Flexible(
                      child: _isLoadingApplicants && _applicants.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator(color: dusk, strokeWidth: 2.5)),
                      )
                          : _applicants.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(Icons.person_search_rounded, color: inkSoft, size: 28),
                              SizedBox(height: 10),
                              Text('No applicants match this view', style: TextStyle(color: inkSoft, fontSize: 12.5, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                        itemCount: _applicants.length + (_applicantsPage < _applicantsTotalPages ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == _applicants.length) {
                            return Center(
                              child: TextButton(
                                onPressed: _isLoadingApplicants ? null : _loadMoreApplicants,
                                child: _isLoadingApplicants
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: dusk))
                                    : const Text('Load more', style: TextStyle(color: dusk, fontWeight: FontWeight.w700, fontSize: 12.5)),
                              ),
                            );
                          }
                          return _buildApplicantRow(_applicants[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(String label, dynamic value, Color tint) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: tint.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text('${value ?? 0}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tint, letterSpacing: -0.2)),
            const SizedBox(height: 1),
            Text(label, style: const TextStyle(fontSize: 9, color: inkSoft, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _statusFilterChip(String label, String value) {
    final selected = _applicantStatusFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _applicantStatusFilter = value);
        _fetchApplicants(reset: true);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? ink : chip,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : inkSoft)),
      ),
    );
  }

  Widget _buildApplicantRow(Map<String, dynamic> entry) {
    final Map application = entry['application'] ?? {};
    final Map? applicant = entry['applicant'];
    final int status = int.tryParse(application['status']?.toString() ?? '0') ?? 0;
    final String statusLabel = application['status_label']?.toString() ?? 'Pending';

    Color statusColor = status == 1 ? sage : (status == -1 ? rose : amber);
    final String? picUrl = applicant?['profile_pic']?.toString();
    final bool hasPic = picUrl != null && picUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: canvasTop,
        borderRadius: BorderRadius.circular(rMd),
        border: Border.all(color: hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: dusk.withOpacity(0.1),
            backgroundImage: hasPic ? NetworkImage(picUrl) : null,
            onBackgroundImageError: hasPic ? (_, __) {} : null,
            child: hasPic ? null : const Icon(Icons.person_rounded, color: dusk, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        applicant?['name']?.toString() ?? applicant?['company_name']?.toString() ?? 'Applicant',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _pill(statusLabel, statusColor),
                  ],
                ),
                if (applicant?['email'] != null) ...[
                  const SizedBox(height: 2),
                  Text(applicant!['email'].toString(), style: const TextStyle(fontSize: 11, color: inkSoft, fontWeight: FontWeight.w500)),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _actionButton('Approve', Icons.check_rounded, sage, status == 1, () => _updateApplicationStatus(entry, 1)),
                    const SizedBox(width: 6),
                    _actionButton('Reject', Icons.close_rounded, rose, status == -1, () => _updateApplicationStatus(entry, -1)),
                    const SizedBox(width: 6),
                    _actionButton('Pending', Icons.schedule_rounded, amber, status == 0, () => _updateApplicationStatus(entry, 0)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: _isUpdatingApplication || active ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.14) : surface,
          border: Border.all(color: active ? color.withOpacity(0.3) : hairline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: active ? color : inkSoft),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? color : inkSoft)),
          ],
        ),
      ),
    );
  }

  // ---------------------- Toast ----------------------
  Widget _buildToast() {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedOpacity(
          opacity: _isToastVisible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ink,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x33141A2E), blurRadius: 20, offset: Offset(0, 8))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _toastIsError ? Icons.error_rounded : Icons.check_circle_rounded,
                  color: _toastIsError ? const Color(0xFFFF6B6B) : const Color(0xFF6EE7B7),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _toastMessage,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}