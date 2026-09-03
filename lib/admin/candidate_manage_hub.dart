import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // add file_picker to pubspec.yaml

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Database/Database.dart';
import '../app_constants.dart';
import '../services/auth_User_and_Business_Session.dart'; // for baseUrl, appId — adjust path if these live elsewhere

/// ---------------------------------------------------------------------
/// TYPED MODELS
/// ---------------------------------------------------------------------

class SeekerPagination {
  final int totalRecords;
  final int recordsPerPage;
  final int currentPage;
  final int totalPages;

  SeekerPagination({
    required this.totalRecords,
    required this.recordsPerPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory SeekerPagination.fromMap(Map map) {
    int _i(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    return SeekerPagination(
      totalRecords: _i(map['total_records']),
      recordsPerPage: _i(map['records_per_page']),
      currentPage: _i(map['current_page']),
      totalPages: _i(map['total_pages']),
    );
  }

  bool get hasMore => currentPage < totalPages;
}

/// A single row from `fetch_seekers`. Kept loose (backed by the raw map)
/// since the exact marketplace_seeker columns aren't fully known — access
/// getters below for the fields the UI actually uses, or reach into `raw`
/// for anything else your schema returns.
class Seeker {
  final Map raw;
  Seeker(this.raw);

  String get id => raw['id']?.toString() ?? '';
  String get name => (raw['name'] ?? 'Unknown').toString();
  String get email => (raw['email'] ?? '').toString();
  String get whatsapp => (raw['whatsapp'] ?? raw['mob_no'] ?? '').toString();
  String get batch => (raw['batch'] ?? '').toString();
  String get stream => (raw['stream_name'] ?? '').toString();
  String get collegeName => (raw['college_name'] ?? '').toString();
  String get photoUrl => (raw['photo_url'] ?? '').toString();
  String get bio => (raw['bio'] ?? '').toString();
  String get label => (raw['label'] ?? '').toString();
  String get status => raw['status']?.toString() ?? '';
  bool get verified => raw['verified']?.toString() == '1';
  double get price => double.tryParse(raw['price']?.toString() ?? '') ?? 0;

  List<String> get keySkills {
    final v = raw['key_skills'];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String && v.isNotEmpty) return v.split(',');
    return [];
  }
}

class SeekerListResult {
  final List<Seeker> seekers;
  final SeekerPagination pagination;
  SeekerListResult(this.seekers, this.pagination);
}

class ClientResult {
  final Map raw;
  ClientResult(this.raw);

  String get id => raw['id']?.toString() ?? '';
  String get name => (raw['name'] ?? '').toString();
  String get email => (raw['email'] ?? '').toString();
  String get mobile => (raw['mobile'] ?? '').toString();
  bool get alreadyShared => raw['shared'] == true;
}

/// ---------------------------------------------------------------------
/// SERVICE
/// ---------------------------------------------------------------------
class SeekerService {
  final Database _db = Database();

  /// action: isset($input['fetch_seekers'])
  /// NOTE: the PHP checks isset() on the key, not its value — so the value
  /// itself doesn't matter, but a key must be present. We send `'true'`.
  Future<SeekerListResult> fetchSeekers({int page = 1, String search = ''}) async {
    final res = await _db.getData({
      'fetch_seekers': 'true',
      'page': page.toString(),
      'search': search,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? res['data'] ?? 'Failed to load candidates');
    }
    final data = Map.from(res['data'] ?? {});
    final list = List.from(data['seekers'] ?? []);
    return SeekerListResult(
      list.map((e) => Seeker(Map.from(e))).toList(),
      SeekerPagination.fromMap(Map.from(data['pagination'] ?? {})),
    );
  }

  /// action: get_seeker_details
  Future<Seeker> getSeekerDetails(String seekerId) async {
    final res = await _db.getData({
      'action': 'get_seeker_details',
      'seeker_id': seekerId,'vendor_id': UserSessionSet.instance.vendorId,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to load candidate details');
    }
    return Seeker(Map.from(res['data'] ?? {}));
  }

  /// action: insert — registers a brand-new candidate/seeker.
  Future<bool> insertSeeker({
    required String batch,
    required String stream,
    required String seekerName,
    required String collegeName,
    required String skills,
    required String seekerEmail,
    required String mobNo,
  }) async {
    final res = await _db.getData({
      'action': 'insert',
      'batch': batch,
      'stream': stream,
      'seeker_name': seekerName,
      'college_name': collegeName,
      'skills': skills,
      'seeker_email': seekerEmail,
      'mob_no': mobNo,'vendor_id': UserSessionSet.instance.vendorId,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to register candidate');
    }
    return true;
  }

  /// action: updateSeeker — note this endpoint expects a multipart request
  /// if a new profile image is attached (`newImage`); for text-only edits
  /// a normal POST works fine.
  Future<bool> updateSeeker({
    required String seekerId,
    required String vendorId,
    required String batch,
    required String stream,
    required String seekerName,
    required String collegeName,
    required String skills,
    required String mobNo,
  }) async {
    final res = await _db.getData({
      'action': 'updateSeeker',
      'updateSeeker': seekerId,
      'vid': vendorId,
      'batch': batch,
      'stream': stream,
      'seeker_name': seekerName,
      'college_name': collegeName,
      'skills': skills,
      'mob_no': mobNo,'vendor_id': UserSessionSet.instance.vendorId,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to update candidate');
    }
    return true;
  }

  /// isset($input['deleteSeeker'])
  Future<bool> deleteSeeker(String id) async {
    final res = await _db.getData({'deleteSeeker': id});
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to delete candidate');
    }
    return true;
  }

  /// isset($input['updateStatus'])
  Future<bool> updateStatus({required String productId, required String status}) async {
    final res = await _db.getData({
      'updateStatus': status,
      'product': productId,
    });
    return res['success'] == true;
  }

  /// isset($input['updateLabel']) — 0=None, 1=Featured, 2=Sponsored, 3=Promoted
  Future<bool> updateLabel({required String productId, required String labelCode}) async {
    final res = await _db.getData({
      'updateLabel': labelCode,
      'product': productId,
    });
    return res['success'] == true;
  }

  /// isset($input['toggleVerified'])
  Future<bool> toggleVerified(String productId) async {
    final res = await _db.getData({'toggleVerified': productId});
    return res['success'] == true;
  }

  /// isset($input['price_row_set']) — sets price for one specific row.
  Future<bool> setRowPrice({required String rowId, required double price}) async {
    final res = await _db.getData({
      'price_row_set': 'true',
      'rowid': rowId,
      'price': price.toString(),
    });
    return res['success'] == true;
  }

  /// isset($input['add_price']) — WARNING: the PHP behind this updates
  /// price for every row in marketplace_seeker with no WHERE clause
  /// (`UPDATE marketplace_seeker SET price = $price` — no `WHERE id = ...`).
  /// That looks like a bug server-side; prefer `setRowPrice` above for a
  /// single candidate. Only use this if the server fix confirms it's meant
  /// to be a bulk-set action.
  Future<bool> bulkSetPrice(double price) async {
    final res = await _db.getData({'add_price': price.toString()});
    return res['success'] == true;
  }

  /// isset($input['searchClient'])
  Future<List<ClientResult>> searchClient({required String keyword, required String relatedItemId}) async {
    final res = await _db.getData({
      'searchClient': keyword,
      'rid': relatedItemId,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Search failed');
    }
    final data = Map.from(res['data'] ?? {});
    final list = List.from(data['clients'] ?? []);
    return list.map((e) => ClientResult(Map.from(e))).toList();
  }

  /// isset($input['send_msg']) — contact a candidate directly.
  Future<bool> sendMessage({required String vendorId, required String message}) async {
    final res = await _db.getData({
      'send_msg': 'true',
      'vid': vendorId,
      'message': message,
    });
    return res['success'] == true;
  }

  /// action: shareJobs — share one or more job IDs with a seeker.
  /// NOTE: works as written server-side, unlike share_job/share_profile below.
  Future<bool> shareJobs({required String seekerId, required List<String> jobIds}) async {
    final res = await _db.getData({
      'action': 'shareJobs',
      'shareJobs': jobIds.join(','),
      'seeker': seekerId,'vendor_id': UserSessionSet.instance.vendorId,
    });
    return res['success'] == true;
  }

  /// action: shareIndividualProfile — share a seeker's profile against job IDs.
  Future<bool> shareIndividualProfile({required String profileId, required List<String> jobIds}) async {
    final res = await _db.getData({
      'action': 'shareIndividualProfile',
      'shareIndividualProfile': profileId,
      'job_ids': jobIds.join(','),'vendor_id': UserSessionSet.instance.vendorId,
    });
    return res['success'] == true;
  }

  /// action: share_profile — BROKEN SERVER-SIDE as of the current PHP:
  /// the shared_items insert path references $vendor_id which is never
  /// set from $input in that block. Calling this will likely produce a
  /// PHP warning/undefined-variable error rather than a real share.
  /// Wire this up once the server reads vendor_id from the session (it
  /// already has $vid = $_SESSION['vendor_id'] at the top of the file —
  /// that just needs to be used instead of the undefined $vendor_id).
  Future<bool> shareProfile({
    required String seekerId,
    String targetEmail = '',
    List<String> userIds = const [],
  }) async {
    final res = await _db.getData({
      'action': 'share_profile',
      'seeker_id': seekerId,
      'email': targetEmail,
      'user_ids': userIds,'vendor_id': UserSessionSet.instance.vendorId,
    });
    return res['success'] == true;
  }

  /// action: uploadExcelSheet — bulk-register candidates from an .xls/.xlsx
  /// file. This one needs a real multipart upload (Database.getData only
  /// sends string fields), so it's implemented directly here with
  /// http.MultipartRequest, reusing the same session the rest of the app uses.
  Future<Map<String, dynamic>> uploadExcelSheet({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final sessionId = await _db.getSessionId();
    final uri = Uri.parse(baseUrl);

    final request = http.MultipartRequest('POST', uri)
      ..fields['action'] = 'uploadExcelSheet'
      ..headers['APP_ID'] = appId.toString()
      ..headers['SESSION-ID'] = sessionId ?? ''
      ..files.add(http.MultipartFile.fromBytes(
        'uploadExcelSheetFile',
        fileBytes,
        filename: fileName,
      ));

    if (sessionId != null && sessionId.isNotEmpty) {
      request.headers['Cookie'] = 'PHPSESSID=$sessionId';
    }

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    Map<String, dynamic> result;
    try {
      result = Map<String, dynamic>.from(jsonDecode(body));
    } catch (_) {
      throw Exception('Server returned an unexpected response: $body');
    }

    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Failed to process the spreadsheet');
    }
    return Map<String, dynamic>.from(result['data'] ?? {});
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serene Candidate Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF006565),
          surface: Color(0xFFF9F9F9),
          secondary: Color(0xFF296767),
          error: Color(0xFFBA1A1A),
          outline: Color(0xFF6E7979),
          surfaceVariant: Color(0xFFE2E2E2),
          onSurface: Color(0xFF1A1C1C),
          onSurfaceVariant: Color(0xFF3E4949),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF008080),
          tertiary: Color(0xFF595B5A),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9F9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02,
            color: Color(0xFF006565),
          ),
        ),
      ),
      home: const CandidateHubScreen(),
    );
  }
}

class CandidateHubScreen extends StatefulWidget {
  final bool isEmbedded;
  const CandidateHubScreen({super.key, this.isEmbedded = true});

  @override
  State<CandidateHubScreen> createState() => _CandidateHubScreenState();
}

class _CandidateHubScreenState extends State<CandidateHubScreen> {
  final SeekerService _service = SeekerService();
  final TextEditingController _searchController = TextEditingController();

  bool _isFabOpen = false;
  final List<String> _selectedCandidates = [];

  List<Seeker> _seekers = [];
  SeekerPagination? _pagination;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadSeekers(reset: true);
  }

  Future<void> _loadSeekers({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    }
    try {
      final result = await _service.fetchSeekers(
        page: _page,
        search: _searchController.text.trim(),
      );
      setState(() {
        _seekers = reset ? result.seekers : [..._seekers, ...result.seekers];
        _pagination = result.pagination;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_pagination == null || !_pagination!.hasMore || _loadingMore) return;
    setState(() {
      _loadingMore = true;
      _page += 1;
    });
    await _loadSeekers();
  }

  void _toggleFab() => setState(() => _isFabOpen = !_isFabOpen);

  void _toggleCandidateSelection(String id) {
    setState(() {
      if (_selectedCandidates.contains(id)) {
        _selectedCandidates.remove(id);
      } else {
        _selectedCandidates.add(id);
      }
    });
  }

  void _clearSelection() => setState(() => _selectedCandidates.clear());

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEmbedded
          ? null
          : AppBar(
        title: const Text('Serene Candidate Hub'),
        actions: [
          IconButton(
            onPressed: () => _loadSeekers(reset: true),
            icon: const Icon(Icons.refresh),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _loadSeekers(reset: true),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                  _loadMore();
                }
                return false;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'Could not load candidates: $_error',
                            style: const TextStyle(color: Color(0xFFBA1A1A)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (_seekers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: Text('No candidates found.')),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _seekers.length,
                          itemBuilder: (context, index) => _buildCandidateCard(_seekers[index]),
                        ),
                    if (_loadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedCandidates.isNotEmpty) _buildSelectionFooter(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.search_outlined, color: Color(0xFF6E7979)),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadSeekers(reset: true),
              decoration: const InputDecoration(
                hintText: 'Search by name, skills, or batch...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                hintStyle: TextStyle(fontSize: 16, color: Color(0xFF6E7979)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _loadSeekers(reset: true),
              icon: const Icon(Icons.search),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(Seeker candidate) {
    final isSelected = _selectedCandidates.contains(candidate.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleCandidateSelection(candidate.id),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: candidate.photoUrl.isNotEmpty
                      ? Image.network(
                    candidate.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40),
                  )
                      : const Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(candidate.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      if (candidate.email.isNotEmpty)
                        Text(candidate.email,
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      if (candidate.whatsapp.isNotEmpty)
                        Text(candidate.whatsapp,
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF6E7979)),
                  onSelected: (value) => _handleCandidateAction(value, candidate),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: 'view',
                        child: Row(children: [
                          Icon(Icons.visibility_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('View Profile')
                        ])),
                    PopupMenuItem(
                        value: 'share_job',
                        child: Row(children: [
                          Icon(Icons.share_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Share Job with Candidate')
                        ])),
                    PopupMenuItem(
                        value: 'share_employer',
                        child: Row(children: [
                          Icon(Icons.forward_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Share Profile with Employer')
                        ])),
                    PopupMenuDivider(),
                    PopupMenuItem(
                        value: 'price',
                        child: Row(children: [
                          Icon(Icons.payments_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Set Profile Price')
                        ])),
                    PopupMenuItem(
                        value: 'contact',
                        child: Row(children: [
                          Icon(Icons.mail_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Contact Candidate')
                        ])),
                    PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red))
                        ])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: candidate.keySkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3FFFE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
                  ),
                  child: Text(skill.trim().toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Color(0xFF296767))),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(candidate.collegeName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleVerified(candidate),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: candidate.verified ? const Color(0xFF006565) : const Color(0xFFB45309),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(candidate.verified ? 'VERIFIED' : 'UNVERIFIED',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: candidate.verified ? const Color(0xFF006565) : const Color(0xFFB45309))),
                  ],
                ),
                Text('\$${candidate.price.toStringAsFixed(0)}/hr',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCandidateAction(String action, Seeker candidate) async {
    switch (action) {
      case 'view':
        _showProfileDialog(candidate);
        break;
      case 'share_job':
        _showJobIdsDialog(
          title: 'Share job with ${candidate.name}',
          onSubmit: (jobIds) async {
            try {
              await _service.shareJobs(seekerId: candidate.id, jobIds: jobIds);
              _showSnack('Job(s) shared with ${candidate.name}');
            } catch (e) {
              _showSnack('Failed to share job: $e');
            }
          },
        );
        break;
      case 'share_employer':
        _showJobIdsDialog(
          title: 'Share ${candidate.name}\'s profile with employers',
          onSubmit: (jobIds) async {
            try {
              await _service.shareIndividualProfile(profileId: candidate.id, jobIds: jobIds);
              _showSnack('Profile shared');
            } catch (e) {
              _showSnack('Failed to share profile: $e');
            }
          },
        );
        break;
      case 'price':
        _showPriceDialog(candidate);
        break;
      case 'contact':
        _showContactDialog(candidate);
        break;
      case 'delete':
        _confirmDelete(candidate);
        break;
    }
  }

  Future<void> _toggleVerified(Seeker candidate) async {
    try {
      await _service.toggleVerified(candidate.id);
      _loadSeekers(reset: true);
    } catch (e) {
      _showSnack('Failed to update verification: $e');
    }
  }

  void _showProfileDialog(Seeker candidate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(candidate.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${candidate.email}'),
            Text('WhatsApp: ${candidate.whatsapp}'),
            Text('College: ${candidate.collegeName}'),
            Text('Batch: ${candidate.batch}'),
            Text('Stream: ${candidate.stream}'),
            Text('Skills: ${candidate.keySkills.join(", ")}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE'))],
      ),
    );
  }

  void _showJobIdsDialog({required String title, required Future<void> Function(List<String>) onSubmit}) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Job IDs (comma-separated)',
            hintText: 'e.g. 12,14,19',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final ids = ctrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              Navigator.pop(ctx);
              if (ids.isNotEmpty) await onSubmit(ids);
            },
            child: const Text('SHARE'),
          ),
        ],
      ),
    );
  }

  void _showPriceDialog(Seeker candidate) {
    final ctrl = TextEditingController(text: candidate.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set price for ${candidate.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ ', labelText: 'Rate per hour'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(ctrl.text) ?? 0;
              Navigator.pop(ctx);
              try {
                await _service.setRowPrice(rowId: candidate.id, price: price);
                _loadSeekers(reset: true);
              } catch (e) {
                _showSnack('Failed to set price: $e');
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(Seeker candidate) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Message ${candidate.name}'),
        content: TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Type your message...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final msg = ctrl.text.trim();
              Navigator.pop(ctx);
              if (msg.isEmpty) return;
              try {
                await _service.sendMessage(vendorId: candidate.id, message: msg);
                _showSnack('Message sent to ${candidate.name}');
              } catch (e) {
                _showSnack('Failed to send message: $e');
              }
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Seeker candidate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete candidate?'),
        content: Text('This will permanently remove ${candidate.name} from your candidate list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _service.deleteSeeker(candidate.id);
                _loadSeekers(reset: true);
              } catch (e) {
                _showSnack('Failed to delete: $e');
              }
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _showAddCandidateDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mobCtrl = TextEditingController();
    final batchCtrl = TextEditingController();
    final streamCtrl = TextEditingController();
    final collegeCtrl = TextEditingController();
    final skillsCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Add new candidate'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: mobCtrl, decoration: const InputDecoration(labelText: 'WhatsApp / mobile')),
                TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch')),
                TextField(controller: streamCtrl, decoration: const InputDecoration(labelText: 'Stream')),
                TextField(controller: collegeCtrl, decoration: const InputDecoration(labelText: 'College')),
                TextField(controller: skillsCtrl, decoration: const InputDecoration(labelText: 'Skills (comma-separated)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: submitting ? null : () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                setState(() => submitting = true);
                try {
                  await _service.insertSeeker(
                    batch: batchCtrl.text,
                    stream: streamCtrl.text,
                    seekerName: nameCtrl.text,
                    collegeName: collegeCtrl.text,
                    skills: skillsCtrl.text,
                    seekerEmail: emailCtrl.text,
                    mobNo: mobCtrl.text,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _showSnack('Candidate added');
                  _loadSeekers(reset: true);
                } catch (e) {
                  setState(() => submitting = false);
                  _showSnack('Failed to add candidate: $e');
                }
              },
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('ADD'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _pickAndUploadExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) {
      _showSnack('Could not read the selected file');
      return;
    }

    _showSnack('Uploading ${file.name}...');
    try {
      final summary = await _service.uploadExcelSheet(fileBytes: bytes, fileName: file.name);
      _showSnack(
        'Processed ${summary['total_rows']} rows: '
            '${summary['inserted_rows']} added, '
            '${summary['already_registered_records']} already registered, '
            '${summary['insertion_failed']} failed.',
      );
      _loadSeekers(reset: true);
    } catch (e) {
      _showSnack('Upload failed: $e');
    }
  }


  Widget _fabActionChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: Color(0xFF296767))),
          const SizedBox(width: 8),
          Icon(icon, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildSelectionFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text('${_selectedCandidates.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF006565))),
                      const SizedBox(width: 4),
                      Text('Profiles Selected', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _clearSelection,
                  child: Text('Clear All',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _showJobIdsDialog(
                    title: 'Share selected profiles with employers',
                    onSubmit: (jobIds) async {
                      var ok = true;
                      for (final id in _selectedCandidates) {
                        try {
                          await _service.shareIndividualProfile(profileId: id, jobIds: jobIds);
                        } catch (_) {
                          ok = false;
                        }
                      }
                      _showSnack(ok ? 'Shared all selected profiles' : 'Some profiles failed to share');
                      _clearSelection();
                    },
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Share Selection', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Create Package', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}