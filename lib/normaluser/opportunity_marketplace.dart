import 'dart:async';

import 'package:flutter/material.dart';

import '../Database/Database.dart'; // adjust import path to match your project

/// ============================================================
/// API ENDPOINT
/// ============================================================
const String opportunityEndpoint = 'new_apis/marketplace_opportunity_api.php';

/// ─────────────────────────────────────────────────────────────
/// MODEL
/// Thin wrapper around the raw JSON the backend returns for each
/// opportunity: { opportunity, vendor, compensation, application, media }
/// Kept defensive (lots of `?? fallback`) since several backend columns
/// (compensation amount, posted-at timestamp, etc.) weren't visible in
/// the PHP file, so exact key names may need a tweak once you confirm
/// the DB schema.
/// ─────────────────────────────────────────────────────────────
class Opportunity {
  final Map<String, dynamic> raw;
  final Map<String, dynamic> opportunity;
  final Map<String, dynamic>? vendor;
  final Map<String, dynamic>? compensation;
  final Map<String, dynamic>? application;
  final Map<String, dynamic>? media;

  Opportunity(this.raw)
      : opportunity = Map<String, dynamic>.from(raw['opportunity'] ?? {}),
        vendor = raw['vendor'] != null ? Map<String, dynamic>.from(raw['vendor']) : null,
        compensation = raw['compensation'] != null ? Map<String, dynamic>.from(raw['compensation']) : null,
        application = raw['application'] != null ? Map<String, dynamic>.from(raw['application']) : null,
        media = raw['media'] != null ? Map<String, dynamic>.from(raw['media']) : null;

  String get id => opportunity['id']?.toString() ?? '';
  String get title => opportunity['title']?.toString() ?? 'Untitled opportunity';
  String get description =>
      opportunity['full_description']?.toString() ??
          opportunity['description']?.toString() ??
          '';
  String get location => opportunity['location']?.toString() ?? '';
  String get type => opportunity['type']?.toString() ?? '';
  String get industry => opportunity['industry']?.toString() ?? '';
  String get labelName => opportunity['label_name']?.toString() ?? '';
  String get categoryTitle => opportunity['category_title']?.toString() ?? '';
  int get totalApplications => int.tryParse(opportunity['total_applications']?.toString() ?? '') ?? 0;

  List<String> get skills {
    final list = opportunity['skills_array'];
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }

  String get posterName =>
      vendor?['company_name']?.toString().trim().isNotEmpty == true
          ? vendor!['company_name'].toString()
          : (vendor?['name']?.toString() ?? 'Vendor');

  String? get posterImageUrl =>
      (vendor?['company_logo']?.toString().isNotEmpty ?? false)
          ? vendor!['company_logo'].toString()
          : (vendor?['profile_pic']?.toString().isNotEmpty ?? false)
          ? vendor!['profile_pic'].toString()
          : null;

  String? get coverImage => media?['cover_image']?.toString();

  String get payoutType => compensation?['payout_type']?.toString() ?? '';
  String get paymentFrequency => compensation?['payment_frequency']?.toString() ?? '';
  String get priceModel => opportunity['price_model']?.toString() ?? '';

  /// Best-effort human readable pay line. The exact numeric-amount column
  /// on marketplace_opportunity_compensation wasn't visible in the API
  /// file — check the map for common key names and fall back to
  /// payout type / price model text if none match.
  String get payDisplay {
    if (compensation != null) {
      for (final key in ['amount', 'rate', 'salary', 'pay_amount', 'min_amount']) {
        final v = compensation![key];
        if (v != null && v.toString().isNotEmpty) {
          final freq = paymentFrequency.isNotEmpty ? ' / $paymentFrequency' : '';
          return '$v$freq';
        }
      }
    }
    if (payoutType.isNotEmpty) return payoutType;
    if (priceModel.isNotEmpty) return priceModel;
    return 'Compensation not specified';
  }

  /// Numeric value used for best-effort "Highest Pay" client-side sort.
  double get payNumeric {
    if (compensation == null) return -1;
    for (final key in ['amount', 'rate', 'salary', 'pay_amount', 'min_amount']) {
      final v = compensation![key];
      final parsed = double.tryParse(v?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return -1;
  }
}

/// ─────────────────────────────────────────────────────────────
/// SCREEN
/// ─────────────────────────────────────────────────────────────
class OpportunitiesMarketplaceScreen extends StatefulWidget {
  const OpportunitiesMarketplaceScreen({super.key});

  @override
  State<OpportunitiesMarketplaceScreen> createState() =>
      _OpportunitiesMarketplaceScreenState();
}

class _OpportunitiesMarketplaceScreenState
    extends State<OpportunitiesMarketplaceScreen> {
  final Database _db = Database();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  // Data
  List<Opportunity> _opportunities = [];
  Map<String, dynamic> _filterOptions = {};

  // Paging
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isFilterLoading = true;
  String? _errorMessage;

  // Active filters
  String _search = '';
  String _type = '';
  String _industry = '';
  String _location = '';
  String _opportunityFor = '';
  String _categoryId = '';
  String _skill = '';
  String _label = '';
  String _sortBy = 'newest'; // 'newest' | 'highest_pay'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFilters();
    _loadOpportunities(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _page < _totalPages) {
      _loadOpportunities();
    }
  }

  Future<void> _loadFilters() async {
    try {
      final result = await _db.getData(
        {'action': 'get_opportunity_filters'},
        endpoint: opportunityEndpoint,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map? ?? {};
        setState(() {
          _isFilterLoading = false;
          _filterOptions = Map<String, dynamic>.from(data);
        });
      } else {
        setState(() => _isFilterLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading opportunity filters: $e');
      if (mounted) setState(() => _isFilterLoading = false);
    }
  }

  Future<void> _loadOpportunities({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
        _opportunities = [];
      });
    } else {
      setState(() => _isLoadingMore = true);
      if (_page < _totalPages) _page += 1;
    }

    try {
      final body = <String, dynamic>{
        'action': 'get_all_opportunities',
        'page': _page,
        'limit': 10,
        'search': _search,
        'type': _type,
        'industry': _industry,
        'location': _location,
        'opportunity_for': _opportunityFor,
        'category_id': _categoryId,
        'skill': _skill,
        'label': _label,
      };

      final result = await _db.getJsonData(body, endpoint: opportunityEndpoint);

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'] as Map? ?? {};
        final fetched = (data['opportunities'] as List? ?? [])
            .map((e) => Opportunity(Map<String, dynamic>.from(e)))
            .toList();

        setState(() {
          _opportunities = reset ? fetched : [..._opportunities, ...fetched];
          _totalPages = int.tryParse(data['total_pages']?.toString() ?? '1') ?? 1;
          _errorMessage = null;
          _isLoading = false;
          _isLoadingMore = false;

          if (_sortBy == 'highest_pay') {
            _opportunities.sort((a, b) => b.payNumeric.compareTo(a.payNumeric));
          }
        });
      } else {
        setState(() {
          _errorMessage = result['message']?.toString() ?? 'Failed to load opportunities';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search = value.trim();
      _loadOpportunities(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: const Text(
          'Opportunities',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadOpportunities(reset: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search opportunities...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE6E6F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE6E6F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showFilterBottomSheet(context),
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: Text(_activeFilterCount > 0
                                ? 'Filters ($_activeFilterCount)'
                                : 'Filters'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF464653),
                              side: const BorderSide(color: Color(0xFFE6E6F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showSortBottomSheet(context),
                            icon: const Icon(Icons.swap_vert, size: 18),
                            label: const Text('Sort By'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF464653),
                              side: const BorderSide(color: Color(0xFFE6E6F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  int get _activeFilterCount => [
    _type,
    _industry,
    _location,
    _opportunityFor,
    _categoryId,
    _skill,
    _label,
  ].where((f) => f.isNotEmpty).length;

  Widget _buildBody() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Color(0xFF474DC5))),
      );
    }

    if (_errorMessage != null && _opportunities.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.grey),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadOpportunities(reset: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_opportunities.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No opportunities match your search.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == _opportunities.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: _isLoadingMore
                      ? const CircularProgressIndicator(color: Color(0xFF474DC5))
                      : const SizedBox.shrink(),
                ),
              );
            }
            final item = _opportunities[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OpportunityCard(
                opportunity: item,
                onAction: () => _showActionDialog(context, item),
              ),
            );
          },
          childCount: _opportunities.length + 1,
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, Opportunity item) {
    final bool hasApplication = item.application != null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF1F2FF),
              child: Icon(
                hasApplication ? Icons.send : Icons.visibility,
                color: const Color(0xFF474DC5),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              item.description.isNotEmpty ? item.description : 'No description provided.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF474DC5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Local copies so the sheet can be edited without mutating state
    // until "Apply Filters" is pressed.
    String type = _type;
    String industry = _industry;
    String location = _location;

    final types = (_filterOptions['types'] as List? ?? []).cast<String>();
    final industries = (_filterOptions['industries'] as List? ?? []).cast<String>();
    final locations = (_filterOptions['locations'] as List? ?? []).cast<String>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => setSheetState(() {
                            type = '';
                            industry = '';
                            location = '';
                          }),
                          child: const Text('Reset', style: TextStyle(color: Color(0xFF474DC5))),
                        )
                      ],
                    ),
                    if (_isFilterLoading) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 20),
                    ] else ...[
                      if (types.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: types.map((t) {
                            return FilterChip(
                              label: Text(t),
                              selected: type == t,
                              onSelected: (val) => setSheetState(() => type = val ? t : ''),
                            );
                          }).toList(),
                        ),
                      ],
                      if (industries.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Industry', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: industries.map((i) {
                            return FilterChip(
                              label: Text(i),
                              selected: industry == i,
                              onSelected: (val) => setSheetState(() => industry = val ? i : ''),
                            );
                          }).toList(),
                        ),
                      ],
                      if (locations.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: locations.map((l) {
                            return FilterChip(
                              label: Text(l),
                              selected: location == l,
                              onSelected: (val) => setSheetState(() => location = val ? l : ''),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF474DC5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            _type = type;
                            _industry = industry;
                            _location = location;
                          });
                          Navigator.pop(context);
                          _loadOpportunities(reset: true);
                        },
                        child: const Text('Apply Filters',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
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

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Sort By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'Newest First',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _sortBy == 'newest' ? const Color(0xFF474DC5) : Colors.black87,
                  ),
                ),
                trailing: _sortBy == 'newest' ? const Icon(Icons.check, color: Color(0xFF474DC5)) : null,
                tileColor: _sortBy == 'newest' ? const Color(0xFFF1F2FF) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  setState(() => _sortBy = 'newest');
                  Navigator.pop(context);
                  _loadOpportunities(reset: true);
                },
              ),
              ListTile(
                title: Text(
                  'Highest Pay',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _sortBy == 'highest_pay' ? const Color(0xFF474DC5) : Colors.black87,
                  ),
                ),
                trailing: _sortBy == 'highest_pay' ? const Icon(Icons.check, color: Color(0xFF474DC5)) : null,
                tileColor: _sortBy == 'highest_pay' ? const Color(0xFFF1F2FF) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  setState(() {
                    _sortBy = 'highest_pay';
                    _opportunities.sort((a, b) => b.payNumeric.compareTo(a.payNumeric));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// CARD
/// ─────────────────────────────────────────────────────────────
class OpportunityCard extends StatefulWidget {
  final Opportunity opportunity;
  final VoidCallback onAction;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onAction,
  });

  @override
  State<OpportunityCard> createState() => _OpportunityCardState();
}

class _OpportunityCardState extends State<OpportunityCard> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.opportunity;
    final tags = <String>[
      if (item.labelName.isNotEmpty) item.labelName,
      if (item.categoryTitle.isNotEmpty) item.categoryTitle,
      ...item.skills.take(3),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF151C27)),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? const Color(0xFF474DC5) : Colors.grey,
                ),
                onPressed: () => setState(() => isBookmarked = !isBookmarked),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF1F2FF),
                backgroundImage: item.posterImageUrl != null ? NetworkImage(item.posterImageUrl!) : null,
                child: item.posterImageUrl == null
                    ? const Icon(Icons.storefront, size: 16, color: Color(0xFF474DC5))
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.posterName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) {
                final bool isHighlight = tag == item.labelName;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHighlight ? const Color(0xFFF1F2FF) : const Color(0xFFF0F3FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                      color: isHighlight ? const Color(0xFF474DC5) : const Color(0xFF444651),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF464653), fontSize: 14),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE6E6F0), height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (item.location.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    item.payDisplay,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF151C27)),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${item.totalApplications} Applied', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: widget.onAction,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('View Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}