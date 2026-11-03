import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'marketplace_job_details.dart';

// ============================================================================
// marketplace_jobs_API.php  →  UI
//   getCategories / getPositions / getWorkTypes / getLocations   filter sheet options
//   getLatestJobs                                                 "Featured Opportunities"
//   getJobs (category[], position[], type[], location[], sort,
//            offset, limit)                                       "All Opportunities" + paging
// Job ids come back base64-encoded; they are decoded before opening the details
// screen, because jobDetailAPI expects the RAW id.
// ============================================================================

const _kEndpoint = 'new_apis/marketplaceJobs_API.php';

const _teal = Color(0xFF006565);
const _tealBg = Color(0xFFEBFDFC);
const _ink = Color(0xFF1A1C1C);
const _muted = Color(0xFF3E4949);
const _line = Color(0xFFBDC9C8);
const _red = Color(0xFFBA1A1A);

const _pageSize = 10;
const _sortOptions = <List<String>>[
  ['id desc', 'Newest first'],
  ['sal_min asc', 'Salary: low to high'],
  ['sal_min desc', 'Salary: high to low'],
];

// ── Helpers ─────────────────────────────────────────────────────────────────
int _i(dynamic v, [int d = 0]) {
  if (v == null) return d;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? d;
}

String _s(dynamic v) => (v ?? '').toString();
Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<dynamic> _l(dynamic v) => v is List ? v : const [];
List<Map<String, dynamic>> _maps(dynamic v) => _l(v).map(_m).toList();

// The API htmlspecialchars()'s its output; decode for display AND for filter values
// (the SQL filter compares against the raw DB text).
String _unescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#039;', "'")
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&');

String _decodeId(String b64) {
  try {
    final d = utf8.decode(base64.decode(base64.normalize(b64)));
    if (RegExp(r'^\d+$').hasMatch(d)) return d;
  } catch (_) {}
  return b64;
}

String _compactNum(double v) {
  String t(double n) => n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
  if (v >= 1e7) return '${t(v / 1e7)}Cr';
  if (v >= 1e5) return '${t(v / 1e5)}L';
  if (v >= 1e3) return '${t(v / 1e3)}k';
  return t(v);
}

String _salary(dynamic min, dynamic max) {
  final a = _s(min).trim(), b = _s(max).trim();
  final x = double.tryParse(a), y = double.tryParse(b);
  String f(double v) => '₹${_compactNum(v)}';
  if (x != null && y != null) {
    if (x <= 0 && y <= 0) return 'Not disclosed';
    if (x <= 0) return 'Up to ${f(y)}';
    if (y <= 0 || y == x) return f(x);
    return '${f(x)} - ${f(y)}';
  }
  if (a.isEmpty && b.isEmpty) return 'Not disclosed';
  return [a, b].where((e) => e.isNotEmpty).map(_unescape).join(' - ');
}

// ============================================================================
// SCREEN
// ============================================================================
class MarketplaceJobScreen extends StatefulWidget {
  const MarketplaceJobScreen({super.key});

  @override
  State<MarketplaceJobScreen> createState() => _MarketplaceJobScreenState();
}

class _MarketplaceJobScreenState extends State<MarketplaceJobScreen> {
  final _scroll = ScrollController();
  final _featScroll = ScrollController();
  final _searchCtrl = TextEditingController();

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;
  int _offset = 0;

  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _latest = [];
  List<String> _categories = [], _positions = [], _types = [], _locations = [];

  Set<String> _fCat = {}, _fPos = {}, _fType = {}, _fLoc = {};
  String _sort = 'id desc';
  String _query = '';

  int get _activeFilters => _fCat.length + _fPos.length + _fType.length + _fLoc.length;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        _loadMore();
      }
    });
    _loadAll();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _featScroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── API ───────────────────────────────────────────────────────────────────
  // `json` = send a JSON body (needed for the array filters of getJobs).
  Future<Map<String, dynamic>> _call(
      String action, [
        Map<String, dynamic> extra = const {},
        bool json = false,
      ]) async {
    final payload = {
      'action': action,
      'vendor_id': _i(UserSessionSet.instance.vendorId),
      'admin_id': _i(UserSessionSet.instance.adminId),
      ...extra,
    };
    try {
      final dynamic res = json
          ? await Database().getJsonData(payload, endpoint: _kEndpoint)
          : await Database().getData(payload, endpoint: _kEndpoint);
      return res is Map
          ? Map<String, dynamic>.from(res)
          : {'success': false, 'message': 'Invalid server response'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<void> _loadAll({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    String? jobsError;

    await Future.wait([
      _loadFilterOptions(),
      _loadLatest(),
      _fetchJobs(reset: true).then<void>((e) => jobsError = e),
    ]);

    _error = jobsError;
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadFilterOptions() async {
    List<String> pick(Map<String, dynamic> r, String key) => r['success'] == true
        ? _l(r['data']).map((e) => _unescape(_s(_m(e)[key]))).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final res = await Future.wait([
      _call('getCategories'),
      _call('getPositions'),
      _call('getWorkTypes'),
      _call('getLocations'),
    ]);
    _categories = pick(res[0], 'category');
    _positions = pick(res[1], 'position');
    _types = pick(res[2], 'type');
    _locations = pick(res[3], 'location');
  }

  Future<void> _loadLatest() async {
    final r = await _call('getLatestJobs');
    _latest = r['success'] == true ? _maps(r['data']) : [];
  }

  /// Returns an error message, or null on success.
  Future<String?> _fetchJobs({bool reset = false}) async {
    final off = reset ? 0 : _offset;
    final r = await _call('getJobs', {
      'category': _fCat.toList(),
      'position': _fPos.toList(),
      'type': _fType.toList(),
      'location': _fLoc.toList(),
      'sort': _sort,
      'offset': off,
      'limit': _pageSize,
    }, true);

    if (r['success'] != true) {
      final msg = _s(r['message']);
      return msg.isEmpty ? 'Could not load jobs.' : msg;
    }
    final d = _m(r['data']);
    final list = _maps(d['jobs']);
    if (reset) {
      _jobs = list;
    } else {
      final seen = _jobs.map((e) => _s(e['id'])).toSet();
      _jobs = [..._jobs, ...list.where((e) => !seen.contains(_s(e['id'])))];
    }
    _offset = off + _i(d['count'], list.length);
    _hasMore = list.length >= _pageSize;
    return null;
  }

  Future<void> _reloadJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final e = await _fetchJobs(reset: true);
    if (!mounted) return;
    setState(() {
      _error = e;
      _loading = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading || _error != null) return;
    setState(() => _loadingMore = true);
    final e = await _fetchJobs();
    if (!mounted) return;
    setState(() => _loadingMore = false);
    if (e != null) _toast(e);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _red),
    );
  }

  // The API has no text-search parameter, so the search box filters what is loaded.
  List<Map<String, dynamic>> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _jobs;
    return _jobs.where((j) {
      final hay = [
        j['job_title'],
        j['job_category'],
        j['position_lvl'],
        j['work_type'],
        j['work_place'],
      ].map((e) => _unescape(_s(e)).toLowerCase()).join(' ');
      return hay.contains(q);
    }).toList();
  }

  void _open(Map<String, dynamic> job, {bool apply = false}) {
    final raw = _decodeId(_s(job['id']));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailsScreen(jobId: raw, openApply: apply)),
    );
  }

  void _scrollFeatured(int dir) {
    if (!_featScroll.hasClients) return;
    final target = (_featScroll.offset + dir * 300)
        .clamp(0.0, _featScroll.position.maxScrollExtent)
        .toDouble();
    _featScroll.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        color: _teal,
        onRefresh: () => _loadAll(silent: true),
        child: SingleChildScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _searchRow(),
            if (_activeFilters > 0) _activeFilterBar(),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator(color: _teal)),
              )
            else ...[
              if (_latest.isNotEmpty) ...[_featuredSection(), const SizedBox(height: 32)],
              _allHeader(visible.length),
              const SizedBox(height: 16),
              if (_error != null)
                _errorState()
              else if (visible.isEmpty)
                _emptyState()
              else ...[
                  for (int i = 0; i < visible.length; i++) ...[
                    OpportunityTile(
                      job: visible[i],
                      onTap: () => _open(visible[i]),
                      onApply: () => _open(visible[i], apply: true),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_loadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator(color: _teal, strokeWidth: 2)),
                    )
                  else if (_hasMore)
                    Center(
                      child: TextButton.icon(
                        onPressed: _loadMore,
                        icon: const Icon(Icons.expand_more, color: _teal),
                        label: const Text('Load more', style: TextStyle(color: _teal)),
                      ),
                    ),
                ],
            ],
          ]),
        ),
      ),
    );
  }

  Widget _searchRow() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search loaded opportunities...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6E7979)),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _query = '');
              },
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Color(0xFF6E7979))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Color(0xFF6E7979))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: _teal)),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Stack(clipBehavior: Clip.none, children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: const Color(0xFF6E7979)),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: _teal),
            onPressed: _showFilterSheet,
          ),
        ),
        if (_activeFilters > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
              child: Text('$_activeFilters',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
      ]),
    ]);
  }

  Widget _activeFilterBar() {
    final all = [..._fCat, ..._fPos, ..._fType, ..._fLoc];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 30,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final f in all)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(f, style: const TextStyle(fontSize: 11, color: _teal)),
                    backgroundColor: _tealBg,
                    side: const BorderSide(color: _teal),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ]),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _fCat = {};
              _fPos = {};
              _fType = {};
              _fLoc = {};
            });
            _reloadJobs();
          },
          child: const Text('Clear', style: TextStyle(color: _teal)),
        ),
      ]),
    );
  }

  Widget _featuredSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(
          child: Text('Featured Opportunities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink)),
        ),
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _scrollFeatured(-1)),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _scrollFeatured(1)),
      ]),
      const SizedBox(height: 12),
      SizedBox(
        height: 200,
        child: ListView.separated(
          controller: _featScroll,
          scrollDirection: Axis.horizontal,
          itemCount: _latest.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, i) => FeaturedOpportunityCard(
            job: _latest[i],
            onTap: () => _open(_latest[i]),
          ),
        ),
      ),
    ]);
  }

  Widget _allHeader(int shown) {
    final plus = _hasMore && _query.trim().isEmpty ? '+' : '';
    return Row(children: [
      const Expanded(
        child: Text('All Opportunities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ink)),
      ),
      Text('Showing $shown$plus results', style: const TextStyle(fontSize: 12, color: _muted)),
    ]);
  }

  Widget _emptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 40),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _line),
    ),
    child: Column(children: [
      const Icon(Icons.work_off_outlined, size: 36, color: _muted),
      const SizedBox(height: 8),
      Text(
        _query.isNotEmpty || _activeFilters > 0
            ? 'No opportunities match your search or filters.'
            : 'No opportunities available right now.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: _muted),
      ),
    ]),
  );

  Widget _errorState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _line),
    ),
    child: Column(children: [
      const Icon(Icons.cloud_off, size: 36, color: _muted),
      const SizedBox(height: 8),
      Text(_error ?? '', textAlign: TextAlign.center),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: _reloadJobs, child: const Text('Retry')),
    ]),
  );

  // ── Filter sheet (options from getCategories / getPositions / ...) ────────
  void _showFilterSheet() {
    var cat = {..._fCat}, pos = {..._fPos}, type = {..._fType}, loc = {..._fLoc};
    var sort = _sort;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        Widget group(String title, List<String> options, Set<String> sel) {
          if (options.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _muted)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 4, children: [
                for (final o in options)
                  FilterChip(
                    label: Text(o, style: TextStyle(fontSize: 12, color: sel.contains(o) ? _teal : _ink)),
                    selected: sel.contains(o),
                    selectedColor: _tealBg,
                    checkmarkColor: _teal,
                    side: BorderSide(color: sel.contains(o) ? _teal : _line),
                    onSelected: (v) => setM(() => v ? sel.add(o) : sel.remove(o)),
                  ),
              ]),
            ]),
          );
        }

        final count = cat.length + pos.length + type.length + loc.length;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Filter Opportunities',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(children: [
                    TextButton(
                      onPressed: () => setM(() {
                        cat.clear();
                        pos.clear();
                        type.clear();
                        loc.clear();
                        sort = 'id desc';
                      }),
                      child: const Text('Reset', style: TextStyle(color: _teal)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ]),
                ]),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 8),
                      const Text('SORT BY',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _muted)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: [
                        for (final o in _sortOptions)
                          ChoiceChip(
                            label: Text(o[1], style: TextStyle(fontSize: 12, color: sort == o[0] ? _teal : _ink)),
                            selected: sort == o[0],
                            selectedColor: _tealBg,
                            side: BorderSide(color: sort == o[0] ? _teal : _line),
                            onSelected: (_) => setM(() => sort = o[0]),
                          ),
                      ]),
                      const SizedBox(height: 16),
                      group('CATEGORY', _categories, cat),
                      group('POSITION LEVEL', _positions, pos),
                      group('JOB TYPE', _types, type),
                      group('LOCATION', _locations, loc),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _fCat = cat;
                      _fPos = pos;
                      _fType = type;
                      _fLoc = loc;
                      _sort = sort;
                    });
                    _reloadJobs();
                  },
                  child: Text(count > 0 ? 'Apply $count Filter${count == 1 ? '' : 's'}' : 'Show Results'),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }
}

// ============================================================
//  SHARED BITS
// ============================================================
Widget _logoBox(String url, {double size = 48, Color bg = _tealBg}) {
  final fallback = Icon(Icons.business, color: _teal, size: size * 0.58);
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: _line),
    ),
    clipBehavior: Clip.antiAlias,
    child: url.isEmpty
        ? Center(child: fallback)
        : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: fallback)),
  );
}

Widget _pill(String t) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(color: _tealBg, borderRadius: BorderRadius.circular(12)),
  child: Text(t, style: const TextStyle(fontSize: 11, color: _teal, fontWeight: FontWeight.w600)),
);

// ============================================================
//  FEATURED OPPORTUNITY CARD  (getLatestJobs)
// ============================================================
class FeaturedOpportunityCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const FeaturedOpportunityCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _logoBox(_s(job['company_logo'])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(4)),
                  child: const Text('LATEST',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 12),
              Text(_unescape(_s(job['job_title'])),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.payments_outlined, size: 16, color: _muted),
                const SizedBox(width: 6),
                Text(_salary(job['sal_min'], job['sal_max']),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _muted)),
              ]),
            ]),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: onTap,
                child: const Text('View Details', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  OPPORTUNITY TILE  (getJobs)
// ============================================================
class OpportunityTile extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;
  final VoidCallback onApply;

  const OpportunityTile({super.key, required this.job, required this.onTap, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final category = _unescape(_s(job['job_category']));
    final position = _unescape(_s(job['position_lvl']));
    final type = _unescape(_s(job['work_type']));
    final place = _unescape(_s(job['work_place']));

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _logoBox(_s(job['company_logo']), bg: const Color(0xFFEEEEED)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_unescape(_s(job['job_title'])),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (category.isNotEmpty)
                  Text(category, style: const TextStyle(color: _muted, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (place.isNotEmpty)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.location_on, size: 13, color: _muted),
                      const SizedBox(width: 2),
                      Text(place, style: const TextStyle(fontSize: 11, color: _muted)),
                    ]),
                  if (type.isNotEmpty) _pill(type),
                  if (position.isNotEmpty) _pill(position),
                ]),
                const SizedBox(height: 8),
                Text(_salary(job['sal_min'], job['sal_max']),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _muted)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _teal),
                foregroundColor: _teal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: onTap,
              child: const Text('Details', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: onApply,
              child: const Text('Apply', style: TextStyle(fontSize: 12)),
            ),
          ]),
        ]),
      ),
    );
  }
}