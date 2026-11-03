import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';
import 'explore_Community_Details_screen.dart';

// ============================================================================
// API SERVICE
//
// Wraps the community discovery/join actions from the PHP files you shared.
//
// Two backend files are involved:
//  * `_endpoint`        -> discovery: industries, search, for-you, joined list
//  * `_detailsEndpoint` -> membership actions: join / leave / cancel request
// ============================================================================
class ExploreCommunitiesException implements Exception {
  final String message;
  ExploreCommunitiesException(this.message);
  @override
  String toString() => message;
}

class ExploreCommunitiesApiService {
  ExploreCommunitiesApiService._internal();
  static final ExploreCommunitiesApiService instance = ExploreCommunitiesApiService._internal();

  // Discovery / search / for-you / joined list.
  // TODO: confirm this matches the real path to the discovery PHP file.
  static const String _endpoint = 'new_apis/community_app_master_api.php';

  // join_community / leave_community / cancel_join_request.
  // (Same file the details screen talks to.)
  static const String _detailsEndpoint = 'new_apis/community_details_api.php';

  final Database _db = Database();

  int get _vendorId => int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body, {String? endpoint}) async {
    final result = await _db.getData({
      ...body,
      'vendor_id': _vendorId,
    }, endpoint: endpoint ?? _endpoint);

    if (result == null) {
      throw ExploreCommunitiesException('No response from server.');
    }
    if (result['success'] != true) {
      throw ExploreCommunitiesException(
        result['message']?.toString() ?? 'Request failed. Please try again.',
      );
    }
    return Map<String, dynamic>.from(result);
  }

  /// `get_job_industries` — used to build the category pills for real,
  /// instead of a fixed list of made-up categories.
  Future<List<Map<String, dynamic>>> getJobIndustries() async {
    final res = await _call({'action': 'get_job_industries'});
    final raw = res['data']?['industries'];
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return const [];
  }

  /// `search_communities` — the general browse/search list. Keyword search
  /// covers title/description/tags server-side.
  Future<List<Map<String, dynamic>>> searchCommunities({
    String keyword = '',
    int page = 1,
    int limit = 30,
  }) async {
    final res = await _call({
      'action': 'search_communities',
      'keyword': keyword,
      'page': page,
      'limit': limit,
    });
    final raw = res['data']?['communities'];
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return const [];
  }

  /// `communities_for_you` — personalized recommendations based on the
  /// vendor's own preferred vendor type / industries / tags (server-side
  /// matching, nothing computed on the client).
  Future<List<Map<String, dynamic>>> communitiesForYou({int page = 1, int limit = 20}) async {
    final res = await _call({'action': 'communities_for_you', 'page': page, 'limit': limit});
    final raw = res['data']?['communities'];
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return const [];
  }

  /// `fetch_joined_communities` — communities I'm an actual approved (or
  /// otherwise recorded) member of. Used to mark cards as "Joined" for
  /// real, instead of local-only toggle state.
  Future<List<Map<String, dynamic>>> fetchJoinedCommunities() async {
    final res = await _call({'action': 'fetch_joined_communities'});
    final raw = res['data'];
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return const [];
  }

  /// `join_community` — joins immediately when joining_rule is free
  /// (data.status == 'joined'), otherwise files a join request
  /// (data.status == 'pending').
  Future<Map<String, dynamic>> joinCommunity({
    required int groupId,
    String requestMessage = '',
  }) {
    return _call({
      'action': 'join_community',
      'group_id': groupId,
      'request_message': requestMessage,
    }, endpoint: _detailsEndpoint);
  }

  /// `leave_community` — an approved member exits the community.
  /// The server refuses if the caller is the community creator
  /// (error message is surfaced to the user).
  Future<Map<String, dynamic>> leaveCommunity({required int groupId}) {
    return _call({
      'action': 'leave_community',
      'group_id': groupId,
    }, endpoint: _detailsEndpoint);
  }

  /// `cancel_join_request` — withdraws my pending join request.
  Future<Map<String, dynamic>> cancelJoinRequest({required int groupId}) {
    return _call({
      'action': 'cancel_join_request',
      'group_id': groupId,
    }, endpoint: _detailsEndpoint);
  }
}

// ============================================================================
// SCREEN
// ============================================================================
class ExploreCommunitiesScreen extends StatefulWidget {
  final bool isEmbedded;

  const ExploreCommunitiesScreen({Key? key, this.isEmbedded = false})
      : super(key: key);

  @override
  State<ExploreCommunitiesScreen> createState() =>
      _ExploreCommunitiesScreenState();
}

enum _SortOption { newest, mostMembers }

class _ExploreCommunitiesScreenState extends State<ExploreCommunitiesScreen> {
  final _api = ExploreCommunitiesApiService.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  // Category pills: 'All' and 'Matches Profile' are fixed modes, everything
  // after them is a real industry title fetched from the server.
  static const String _kAll = 'All';
  static const String _kMatches = 'Matches Profile';

  bool _loadingCategories = true;
  String? _categoriesError;
  List<String> _industryCategories = [];
  String _selectedCategory = _kAll;

  bool _loadingForYou = true;
  String? _forYouError;
  List<Map<String, dynamic>> _forYou = [];

  bool _loadingCommunities = true;
  String? _communitiesError;
  List<Map<String, dynamic>> _communities = [];

  bool _loadingJoined = true;
  // community id -> joined record (role/join_status/joined_at)
  Map<int, Map<String, dynamic>> _joinedById = {};

  // Session-only "pending request" flags. The backend has no endpoint to
  // read back pending join requests in bulk (they go into a separate
  // `group_join_requests` table), so this reflects what happened in this
  // session. If the user taps Join on a community that already has a
  // pending request, the server's "already pending" reply flips this on.
  final Set<int> _pendingThisSession = {};

  // Community ids with a join / cancel / leave call currently running.
  final Set<int> _joiningInFlight = {};

  _SortOption _sortOption = _SortOption.newest;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadJoined();
    _loadForYou();
    _loadCommunities();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showToast(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 16, left: 24, right: 24),
        backgroundColor: const Color(0xFF002B2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- Data loading --------------------------------------------------------

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesError = null;
    });
    try {
      final industries = await _api.getJobIndustries();
      if (!mounted) return;
      setState(() {
        _industryCategories = industries
            .map((e) => (e['industry_title'] ?? '').toString())
            .where((t) => t.isNotEmpty)
            .toList();
        _loadingCategories = false;
      });
    } on ExploreCommunitiesException catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = e.message;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = 'Failed to load categories.';
        _loadingCategories = false;
      });
    }
  }

  Future<void> _loadJoined() async {
    setState(() => _loadingJoined = true);
    try {
      final joined = await _api.fetchJoinedCommunities();
      if (!mounted) return;
      setState(() {
        _joinedById = {
          for (final c in joined)
            if (int.tryParse('${c['id'] ?? ''}') != null) int.parse('${c['id']}'): c,
        };
        _loadingJoined = false;
      });
    } catch (e) {
      // Non-fatal: cards just fall back to "not joined" state.
      if (mounted) setState(() => _loadingJoined = false);
    }
  }

  Future<void> _loadForYou() async {
    setState(() {
      _loadingForYou = true;
      _forYouError = null;
    });
    try {
      final list = await _api.communitiesForYou();
      if (!mounted) return;
      setState(() {
        _forYou = list;
        _loadingForYou = false;
      });
    } on ExploreCommunitiesException catch (e) {
      if (!mounted) return;
      setState(() {
        _forYouError = e.message;
        _loadingForYou = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _forYouError = 'Failed to load matches.';
        _loadingForYou = false;
      });
    }
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _loadingCommunities = true;
      _communitiesError = null;
    });
    try {
      final list = await _api.searchCommunities(keyword: _searchCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _communities = list;
        _loadingCommunities = false;
      });
    } on ExploreCommunitiesException catch (e) {
      if (!mounted) return;
      setState(() {
        _communitiesError = e.message;
        _loadingCommunities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _communitiesError = 'Failed to load communities.';
        _loadingCommunities = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadCommunities);
  }

  // --- Derived data ----------------------------------------------------

  /// Communities filtered by the selected industry pill (client-side,
  /// since `search_communities` only takes a free-text keyword — there's
  /// no server-side industry filter to call instead) and sorted by the
  /// chosen real field.
  List<Map<String, dynamic>> get _visibleCommunities {
    Iterable<Map<String, dynamic>> list = _communities;
    if (_selectedCategory != _kAll && _selectedCategory != _kMatches) {
      list = list.where((c) {
        final industries = (c['industries'] ?? '').toString().toLowerCase();
        return industries.contains(_selectedCategory.toLowerCase());
      });
    }
    final result = list.toList();
    if (_sortOption == _SortOption.mostMembers) {
      result.sort((a, b) =>
          (int.tryParse('${b['members_count'] ?? 0}') ?? 0)
              .compareTo(int.tryParse('${a['members_count'] ?? 0}') ?? 0));
    } else {
      // Newest: rely on server order (created_date DESC) — no re-sort needed.
    }
    return result;
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadCategories(), _loadJoined(), _loadForYou(), _loadCommunities()]);
  }

  // --- Membership actions ----------------------------------------------

  /// Single entry point for the card button — the action depends on state:
  ///  joined  -> leave (with confirmation)
  ///  pending -> cancel request
  ///  else    -> join / request
  Future<void> _handleCardAction(Map<String, dynamic> community) async {
    final state = _joinStateFor(community);
    if (state.joined) return _handleLeave(community);
    if (state.pending) return _handleCancelRequest(community);
    return _handleJoin(community);
  }

  // --- Navigation -------------------------------------------------------

  /// Opens the community detail screen for a card. The card data is passed
  /// along so the header renders instantly; the details screen then loads the
  /// full record from `community_details`.
  Future<void> _openDetails(Map<String, dynamic> community) async {
    final id = int.tryParse('${community['id'] ?? ''}') ?? 0;
    if (id == 0) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityDetailScreen(
          communityId: id,
          initialCommunity: community,
          onMembershipChanged: _onDetailsMembershipChanged,
        ),
      ),
    );

    // Back on Explore: resync joined list from the server.
    if (mounted) _loadJoined();
  }

  /// Keeps Explore's card state in sync when the user joins / leaves /
  /// requests / cancels from inside the details screen.
  void _onDetailsMembershipChanged(
      int id, {
        required bool joined,
        required bool pending,
        required int membersCount,
      }) {
    if (!mounted) return;
    setState(() {
      if (joined) {
        _joinedById[id] = _joinedById[id] ?? {'id': id, 'role': 'member', 'join_status': 'approved'};
        _pendingThisSession.remove(id);
      } else {
        _joinedById.remove(id);
        if (pending) {
          _pendingThisSession.add(id);
        } else {
          _pendingThisSession.remove(id);
        }
      }

      void setCount(List<Map<String, dynamic>> list) {
        for (final c in list) {
          if (int.tryParse('${c['id'] ?? ''}') == id) {
            c['members_count'] = membersCount;
          }
        }
      }

      setCount(_communities);
      setCount(_forYou);
    });
  }

  // Updates members_count on the cards locally (no refetch needed).
  void _adjustMembersCount(int id, int delta) {
    void bump(List<Map<String, dynamic>> list) {
      for (final c in list) {
        if (int.tryParse('${c['id'] ?? ''}') == id) {
          final cur = int.tryParse('${c['members_count'] ?? 0}') ?? 0;
          final next = cur + delta;
          c['members_count'] = next < 0 ? 0 : next;
        }
      }
    }

    bump(_communities);
    bump(_forYou);
  }

  Future<void> _handleJoin(Map<String, dynamic> community) async {
    final id = int.tryParse('${community['id'] ?? ''}') ?? 0;
    if (id == 0 || _joiningInFlight.contains(id)) return;

    final joiningRule = (community['joining_rule'] ?? '').toString();
    final isFree = joiningRule == 'free';
    String requestMessage = '';

    if (!isFree) {
      final message = await _showRequestMessageDialog(community['title']?.toString() ?? 'this community');
      if (message == null) return; // user cancelled
      requestMessage = message;
    }

    setState(() => _joiningInFlight.add(id));
    try {
      final res = await _api.joinCommunity(groupId: id, requestMessage: requestMessage);
      if (!mounted) return;

      final status = (res['data']?['status'] ?? '').toString();
      final joinedNow = status == 'joined' || (status.isEmpty && isFree);
      final msg = res['message']?.toString() ?? (joinedNow ? 'Joined successfully' : 'Request sent');

      setState(() {
        if (joinedNow) {
          // Show "Joined" immediately, then sync real record from server.
          _joinedById[id] = {'id': id, 'role': 'member', 'join_status': 'approved'};
          _adjustMembersCount(id, 1);
        } else {
          _pendingThisSession.add(id);
        }
      });
      if (joinedNow) _loadJoined();
      _showToast(msg);
    } on ExploreCommunitiesException catch (e) {
      // If server state differs from ours, resync.
      final m = e.message.toLowerCase();
      if (m.contains('pending join request')) {
        if (mounted) setState(() => _pendingThisSession.add(id));
      } else if (m.contains('already joined')) {
        _loadJoined();
      }
      _showToast(e.message, isSuccess: false);
    } catch (e) {
      _showToast('Failed to join. Please try again.', isSuccess: false);
    } finally {
      if (mounted) setState(() => _joiningInFlight.remove(id));
    }
  }

  Future<void> _handleCancelRequest(Map<String, dynamic> community) async {
    final id = int.tryParse('${community['id'] ?? ''}') ?? 0;
    if (id == 0 || _joiningInFlight.contains(id)) return;

    setState(() => _joiningInFlight.add(id));
    try {
      final res = await _api.cancelJoinRequest(groupId: id);
      if (!mounted) return;
      // Pending cleared -> button goes back to "Join" / "Request".
      setState(() => _pendingThisSession.remove(id));
      _showToast(res['message']?.toString() ?? 'Join request cancelled');
    } on ExploreCommunitiesException catch (e) {
      // Request may already have been approved/rejected — resync state.
      if (e.message.toLowerCase().contains('no pending')) {
        if (mounted) setState(() => _pendingThisSession.remove(id));
        _loadJoined();
      }
      _showToast(e.message, isSuccess: false);
    } catch (e) {
      _showToast('Failed to cancel request. Please try again.', isSuccess: false);
    } finally {
      if (mounted) setState(() => _joiningInFlight.remove(id));
    }
  }

  Future<void> _handleLeave(Map<String, dynamic> community) async {
    final id = int.tryParse('${community['id'] ?? ''}') ?? 0;
    if (id == 0 || _joiningInFlight.contains(id)) return;

    final title = community['title']?.toString() ?? 'this community';
    final confirmed = await _confirmLeaveDialog(title);
    if (!confirmed || !mounted) return;

    setState(() => _joiningInFlight.add(id));
    try {
      final res = await _api.leaveCommunity(groupId: id);
      if (!mounted) return;
      setState(() {
        _joinedById.remove(id);
        _pendingThisSession.remove(id);
        _adjustMembersCount(id, -1);
      });
      _showToast(res['message']?.toString() ?? 'You have left the community');
    } on ExploreCommunitiesException catch (e) {
      // e.g. "Community creator cannot leave..." — show the server message.
      _showToast(e.message, isSuccess: false);
    } catch (e) {
      _showToast('Failed to leave. Please try again.', isSuccess: false);
    } finally {
      if (mounted) setState(() => _joiningInFlight.remove(id));
    }
  }

  Future<bool> _confirmLeaveDialog(String communityTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave community?'),
        content: Text('Are you sure you want to leave $communityTitle?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<String?> _showRequestMessageDialog(String communityTitle) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request to join $communityTitle'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Optional message to the community admin...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('SEND REQUEST'),
          ),
        ],
      ),
    );
  }

  // Real join-state for a given community: approved membership from
  // `fetch_joined_communities` takes priority; otherwise a pending flag
  // set in this session; otherwise not joined.
  ({bool joined, bool pending, bool isFree}) _joinStateFor(Map<String, dynamic> community) {
    final id = int.tryParse('${community['id'] ?? ''}') ?? 0;
    final joiningRule = (community['joining_rule'] ?? '').toString();
    final isFree = joiningRule == 'free';
    final joinedRecord = _joinedById[id];
    if (joinedRecord != null) {
      final status = (joinedRecord['join_status'] ?? '').toString();
      return (joined: status.isEmpty || status == 'approved', pending: status == 'pending', isFree: isFree);
    }
    if (_pendingThisSession.contains(id)) {
      return (joined: false, pending: true, isFree: isFree);
    }
    return (joined: false, pending: false, isFree: isFree);
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F9),
      appBar: widget.isEmbedded
          ? null
          : PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9F9).withOpacity(0.85),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 1)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (canPop)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF004349)),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const Icon(Icons.hub, color: Color(0xFF004349), size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Explore',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF004349), letterSpacing: -0.5),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 22),
                    color: const Color(0xFF404849),
                    onPressed: _refreshAll,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildSearchAndFilterRow(),
              const SizedBox(height: 12),
              _buildCategoryPills(),
              const SizedBox(height: 20),
              _buildMatchingPreferencesHeader(),
              const SizedBox(height: 12),
              _buildForYouSection(),
              const SizedBox(height: 24),
              _buildAllCommunitiesHeader(),
              const SizedBox(height: 12),
              _buildCommunitiesList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sections --------------------------------------------------------

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF4A626D), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, category...',
                        hintStyle: TextStyle(color: Color(0x99404849), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _showSortSheet,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFF002B2F), size: 19),
                  const SizedBox(width: 6),
                  // Real active-filter count instead of a fixed "2".
                  if (_sortOption != _SortOption.newest || _selectedCategory != _kAll)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(color: const Color(0xFFCDE6F4), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text(
                        '${(_sortOption != _SortOption.newest ? 1 : 0) + (_selectedCategory != _kAll ? 1 : 0)}',
                        style: const TextStyle(color: Color(0xFF506873), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<_SortOption>(
              title: const Text('Newest'),
              value: _SortOption.newest,
              groupValue: _sortOption,
              onChanged: (v) {
                setState(() => _sortOption = v!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<_SortOption>(
              title: const Text('Most Members'),
              value: _SortOption.mostMembers,
              groupValue: _sortOption,
              onChanged: (v) {
                setState(() => _sortOption = v!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    if (_loadingCategories) {
      return const SizedBox(
        height: 36,
        child: Center(child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    final categories = [_kAll, _kMatches, ..._industryCategories];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF002B2F) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category == _kMatches) ...[
                      Icon(Icons.auto_awesome, size: 16, color: isSelected ? Colors.white : const Color(0xFF30666C)),
                      const SizedBox(width: 4),
                    ],
                    Text(category,
                        style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF404849),
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchingPreferencesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: Color(0xFF30666C), size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Matching Preferences',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF002B2F), letterSpacing: -0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Curated based on your profile',
                  style: TextStyle(fontSize: 12, color: Color(0xFF404849)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFCDE6F4).withOpacity(0.4), borderRadius: BorderRadius.circular(4)),
            child: Text(
              _loadingForYou ? '…' : '${_forYou.length} Matches',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4A626D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouSection() {
    if (_loadingForYou) {
      return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator(color: Color(0xFF002B2F))));
    }
    if (_forYouError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _errorBox(_forYouError!, _loadForYou),
      );
    }
    if (_forYou.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Text(
            'No personalized matches yet. Set your vendor type / industries / tags in your profile to get recommendations here.',
            style: TextStyle(color: Color(0xFF404849), fontSize: 13),
          ),
        ),
      );
    }
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _forYou.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildHorizontalCard(_forYou[i]),
        ),
      ),
    );
  }

  Widget _buildAllCommunitiesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explore All Communities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF002B2F), letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _loadingCommunities ? 'Loading…' : '${_visibleCommunities.length} communities',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF404849)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitiesList() {
    if (_loadingCommunities) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF002B2F))),
      );
    }
    if (_communitiesError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _errorBox(_communitiesError!, _loadCommunities),
      );
    }
    final list = _visibleCommunities;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Text('No communities found.', style: TextStyle(color: Color(0xFF404849))),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final c in list) ...[
            _buildVerticalCard(c),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _errorBox(String message, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  // --- Data → presentation helpers -------------------------------------

  /// Badge derived from the real `joining_rule` field instead of a fixed
  /// "Active Today" style label with no backing data.
  ({String text, Color bg, Color textColor}) _ruleBadge(Map<String, dynamic> c) {
    final rule = (c['joining_rule'] ?? '').toString();
    if (rule == 'free') {
      return (text: 'Open Enrollment', bg: const Color(0xFFE8F5E9), textColor: const Color(0xFF002B2F));
    }
    if (rule.isEmpty) {
      return (text: 'Unknown', bg: const Color(0xFFECEEEE), textColor: const Color(0xFF4A626D));
    }
    return (text: 'Approval Required', bg: const Color(0xFFFFF8E1), textColor: const Color(0xFF404849));
  }

  String _categoryLabel(Map<String, dynamic> c) {
    final industries = (c['industries'] ?? '').toString();
    if (industries.isNotEmpty) return industries.split(',').first.trim();
    final type = (c['type'] ?? '').toString();
    return type.isNotEmpty ? type[0].toUpperCase() + type.substring(1) : 'Community';
  }

  String _feeTag(Map<String, dynamic> c) {
    final fee = double.tryParse('${c['joining_fee'] ?? 0}') ?? 0;
    return fee > 0 ? '\$${fee.toStringAsFixed(0)} to join' : 'Free to join';
  }

  IconData _iconFor(Map<String, dynamic> c) {
    final type = (c['type'] ?? '').toString().toLowerCase();
    if (type.contains('market')) return Icons.storefront;
    if (type.contains('hybrid')) return Icons.hub;
    return Icons.groups;
  }

  Widget _buildHorizontalCard(Map<String, dynamic> community) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetails(community),
      child: _horizontalCardBody(community),
    );
  }

  Widget _horizontalCardBody(Map<String, dynamic> community) {
    final badge = _ruleBadge(community);
    final title = (community['title'] ?? 'Untitled Community').toString();
    final members = '${community['members_count'] ?? 0} members';
    final visibility = (community['visibility'] ?? '').toString();
    final state = _joinStateFor(community);
    final id = int.tryParse('${community['id'] ?? ''}') ?? 0;
    final joining = _joiningInFlight.contains(id);

    return Container(
      width: 285,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F4), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_iconFor(community), color: const Color(0xFF002B2F), size: 22),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: badge.bg, borderRadius: BorderRadius.circular(4)),
                    child: Text(badge.text, style: TextStyle(color: badge.textColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF191C1C)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(_categoryLabel(community).toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4A626D), letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              if (visibility.isNotEmpty)
                Row(
                  children: [
                    Icon(visibility == 'public' ? Icons.public : Icons.lock_outline, size: 15, color: const Color(0xFF4A626D)),
                    const SizedBox(width: 6),
                    Text(visibility[0].toUpperCase() + visibility.substring(1),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF404849))),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.group, size: 15, color: Color(0xFF4A626D)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(members, style: const TextStyle(fontSize: 12, color: Color(0xFF404849)), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_feeTag(community),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF4A626D), fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ),
              _buildJoinButton(
                state: state,
                joining: joining,
                onTap: () => _handleCardAction(community),
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalCard(Map<String, dynamic> community) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetails(community),
      child: _verticalCardBody(community),
    );
  }

  Widget _verticalCardBody(Map<String, dynamic> community) {
    final badge = _ruleBadge(community);
    final title = (community['title'] ?? 'Untitled Community').toString();
    final members = '${community['members_count'] ?? 0} members';
    final visibility = (community['visibility'] ?? '').toString();
    final state = _joinStateFor(community);
    final id = int.tryParse('${community['id'] ?? ''}') ?? 0;
    final joining = _joiningInFlight.contains(id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F4), borderRadius: BorderRadius.circular(12)),
            child: Icon(_iconFor(community), color: const Color(0xFF004349), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF191C1C)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: badge.bg, borderRadius: BorderRadius.circular(4)),
                      child: Text(badge.text, style: TextStyle(color: badge.textColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(_categoryLabel(community),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4A626D)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (visibility.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: Color(0xFFBFC8C9), shape: BoxShape.circle),
                      ),
                      Icon(visibility == 'public' ? Icons.public : Icons.lock_outline, size: 13, color: const Color(0xFF4A626D)),
                      const SizedBox(width: 2),
                      Text(visibility, style: const TextStyle(fontSize: 12, color: Color(0xFF404849))),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x1A4A626D)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.group, size: 15, color: Color(0xFF4A626D)),
                          const SizedBox(width: 4),
                          Text(members, style: const TextStyle(fontSize: 12, color: Color(0xFF404849))),
                        ],
                      ),
                      _buildJoinButton(
                        state: state,
                        joining: joining,
                        onTap: () => _handleCardAction(community),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Button states:
  ///  not joined -> "Join" (free) / "Request" (approval needed)
  ///  pending    -> "Cancel Request" (withdraws the request)
  ///  joined     -> "Joined" (tap opens leave confirmation)
  Widget _buildJoinButton({
    required ({bool joined, bool pending, bool isFree}) state,
    required bool joining,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    if (joining) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: Padding(
          padding: EdgeInsets.all(6),
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF002B2F)),
        ),
      );
    }

    final Color bg = state.joined
        ? const Color(0xFFECEEEE)
        : state.pending
        ? const Color(0xFFE1E3E3)
        : const Color(0xFF002B2F);
    final Color fg = state.joined
        ? const Color(0xFF4A626D)
        : state.pending
        ? const Color(0xFF002B2F)
        : Colors.white;

    final IconData icon = state.joined
        ? Icons.check
        : state.pending
        ? Icons.close
        : (state.isFree ? Icons.add : Icons.send);

    final String label = state.joined
        ? 'Joined'
        : state.pending
        ? 'Cancel Request'
        : (state.isFree ? 'Join' : 'Request');

    return ElevatedButton(
      onPressed: onTap, // tappable in every state now
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 15 : 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}