import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

// ============================================================================
// SMALL HELPERS
//
// The PHP layer runs ensureStringTypes() on most payloads, so numbers and
// bools arrive as strings ('1' / '0' / '8420'). These helpers normalise that.
// ============================================================================
String _s(dynamic v) {
  if (v == null) return '';
  final s = v.toString().trim();
  return s == 'null' ? '' : s;
}

bool _truthy(dynamic v) {
  final s = _s(v).toLowerCase();
  return s == '1' || s == 'true' || s == 'yes';
}

int _i(dynamic v) {
  final s = _s(v);
  return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0;
}

/// First non-empty value among several candidate keys.
String _pick(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = _s(m[k]);
    if (v.isNotEmpty) return v;
  }
  return '';
}

Map<String, dynamic> _asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> _asMapList(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

List<String> _csv(String v) =>
    v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

String _cap(String v) => v.isEmpty ? v : v[0].toUpperCase() + v.substring(1);

bool _isHttp(String v) => v.startsWith('http://') || v.startsWith('https://');

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

String _compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M'.replaceAll(RegExp(r'\.0(?=M)'), '');
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k'.replaceAll(RegExp(r'\.0(?=k)'), '');
  return '$n';
}

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

DateTime? _parseDate(String raw) => raw.isEmpty ? null : DateTime.tryParse(raw);

String _monthYear(String raw) {
  final d = _parseDate(raw);
  return d == null ? '' : '${_months[d.month - 1]} ${d.year}';
}

String _shortDate(String raw) {
  final d = _parseDate(raw);
  return d == null ? raw : '${_months[d.month - 1]} ${d.day}';
}

String _timeAgo(String raw) {
  final d = _parseDate(raw);
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7}w ago';
  return _monthYear(raw);
}

bool _isFreeCommunity(Map<String, dynamic> c) {
  final rule = _s(c['joining_rule']);
  return rule == 'free' || rule == 'free_to_join';
}

String _ruleLabel(Map<String, dynamic> c) {
  final rule = _s(c['joining_rule']);
  if (rule.isEmpty) return '';
  return _isFreeCommunity(c) ? 'Open Enrollment' : 'Approval Required';
}

String _feeText(Map<String, dynamic> c) {
  final fee = double.tryParse(_s(c['joining_fee'])) ?? 0;
  if (fee <= 0) return 'Free';
  final cur = _pick(c, ['joining_currency', 'currency']);
  final symbol = cur.isEmpty ? '\$' : '$cur ';
  return '$symbol${fee.toStringAsFixed(0)}';
}

String _categoryLabel(Map<String, dynamic> c) {
  final industries = _s(c['industries']);
  if (industries.isNotEmpty) return industries.split(',').first.trim();
  final type = _s(c['type']);
  return type.isNotEmpty ? _cap(type) : 'Community';
}

IconData _iconForType(Map<String, dynamic> c) {
  final type = _s(c['type']).toLowerCase();
  if (type.contains('market')) return Icons.storefront;
  if (type.contains('hybrid')) return Icons.hub;
  return Icons.groups;
}

const List<List<Color>> _avatarPalette = [
  [Color(0xFFCDE6F4), Color(0xFF004349)],
  [Color(0xFFF2E7FE), Color(0xFF4A2882)],
  [Color(0xFFE0F2F1), Color(0xFF004D40)],
  [Color(0xFFFFF1D6), Color(0xFF7A4B00)],
];

Widget _avatar(String name, String picUrl, int seed, {double radius = 18}) {
  final colors = _avatarPalette[seed.abs() % _avatarPalette.length];
  return CircleAvatar(
    radius: radius,
    backgroundColor: colors[0],
    foregroundImage: _isHttp(picUrl) ? NetworkImage(picUrl) : null,
    onForegroundImageError: _isHttp(picUrl) ? (_, __) {} : null,
    child: Text(
      _initials(name),
      style: TextStyle(color: colors[1], fontWeight: FontWeight.w700, fontSize: radius * 0.66),
    ),
  );
}

// ============================================================================
// API SERVICE — community_details_api.php
//
// Actions covered (same list as the PHP router):
//   community_details, toggle_bookmark, join_community, leave_community,
//   cancel_join_request, fetch_members, fetch_feed, toggle_like_post,
//   record_share, record_view, fetch_community_opportunities,
//   matching_communities
// ============================================================================
class CommunityDetailsException implements Exception {
  final String message;
  CommunityDetailsException(this.message);
  @override
  String toString() => message;
}

class CommunityDetailsApiService {
  CommunityDetailsApiService._internal();
  static final CommunityDetailsApiService instance = CommunityDetailsApiService._internal();

  // TODO: confirm path. If you call through the router file (the one with the
  // in_array([...]) action list) instead, point this at that file.
  static const String _endpoint = 'new_apis/community_details_api.php';

  // TODO: set your site's public URL (used by `record_share` to build
  // "<base>/community/<id>"). Left empty, the link comes back as "/community/<id>".
  static const String shareBaseUrl = '';

  final Database _db = Database();

  int get _vendorId => int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final result = await _db.getData({
      ...body,
      'vendor_id': _vendorId,
    }, endpoint: _endpoint);

    if (result == null) {
      throw CommunityDetailsException('No response from server.');
    }
    if (result['success'] != true) {
      throw CommunityDetailsException(
        result['message']?.toString().isNotEmpty == true
            ? result['message'].toString()
            : 'Request failed. Please try again.',
      );
    }
    return Map<String, dynamic>.from(result);
  }

  /// `community_details` — full record + is_member / has_pending_request /
  /// is_bookmarked / is_creator / preview_members / opportunities.
  Future<Map<String, dynamic>> communityDetails(int groupId) async {
    final res = await _call({'action': 'community_details', 'group_id': groupId});
    return _asMap(res['data']);
  }

  /// `toggle_bookmark` — data.bookmarked tells the new state.
  Future<bool> toggleBookmark(int groupId) async {
    final res = await _call({'action': 'toggle_bookmark', 'group_id': groupId});
    return _truthy(_asMap(res['data'])['bookmarked']);
  }

  /// `join_community` — data.status is 'joined' (free) or 'pending'.
  Future<Map<String, dynamic>> joinCommunity({
    required int groupId,
    String requestMessage = '',
  }) {
    return _call({
      'action': 'join_community',
      'group_id': groupId,
      'request_message': requestMessage,
    });
  }

  /// `leave_community` — refused for the creator (server message is shown).
  Future<Map<String, dynamic>> leaveCommunity(int groupId) {
    return _call({'action': 'leave_community', 'group_id': groupId});
  }

  /// `cancel_join_request` — withdraws my pending request.
  Future<Map<String, dynamic>> cancelJoinRequest(int groupId) {
    return _call({'action': 'cancel_join_request', 'group_id': groupId});
  }

  /// `fetch_members` — approved members, admins first. Server-side search.
  Future<List<Map<String, dynamic>>> fetchMembers({
    required int groupId,
    String search = '',
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _call({
      'action': 'fetch_members',
      'group_id': groupId,
      'search': search,
      'page': page,
      'limit': limit,
    });
    return _asMapList(res['data']);
  }

  /// `fetch_feed` — community posts (admin/moderator posts are pinned first).
  Future<List<Map<String, dynamic>>> fetchFeed({
    required int groupId,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _call({
      'action': 'fetch_feed',
      'group_id': groupId,
      'page': page,
      'limit': limit,
    });
    return _asMapList(res['data']);
  }

  /// `toggle_like_post` — returns the new liked state.
  Future<bool> toggleLikePost(int postId) async {
    final res = await _call({'action': 'toggle_like_post', 'post_id': postId});
    return _truthy(_asMap(res['data'])['liked']);
  }

  /// `record_share` — logs a share (when post_id > 0) and returns share_url + title.
  Future<Map<String, dynamic>> recordShare({required int groupId, int postId = 0}) async {
    final res = await _call({
      'action': 'record_share',
      'group_id': groupId,
      'post_id': postId,
      'base_url': shareBaseUrl,
    });
    return _asMap(res['data']);
  }

  /// `record_view` — increments the community's view counter.
  Future<void> recordView(int groupId) async {
    await _call({'action': 'record_view', 'group_id': groupId});
  }

  /// `fetch_community_opportunities` — paginated list; returns {items, total, page, limit}.
  Future<Map<String, dynamic>> fetchCommunityOpportunities({
    required int groupId,
    int page = 1,
    int limit = 5,
  }) async {
    final res = await _call({
      'action': 'fetch_community_opportunities',
      'group_id': groupId,
      'page': page,
      'limit': limit,
    });
    return _asMap(res['data']);
  }

  /// `matching_communities` — similar communities (by tag overlap with group_id).
  Future<List<Map<String, dynamic>>> matchingCommunities({
    required int groupId,
    int limit = 8,
  }) async {
    final res = await _call({
      'action': 'matching_communities',
      'group_id': groupId,
      'limit': limit,
    });
    return _asMapList(res['data']);
  }
}

// ============================================================================
// SCREEN
// ============================================================================

/// Called whenever the user's membership in a community changes from this
/// screen, so the screen that opened it (Explore) can stay in sync.
typedef CommunityMembershipChanged = void Function(
    int communityId, {
    required bool joined,
    required bool pending,
    required int membersCount,
    });

class CommunityDetailScreen extends StatefulWidget {
  /// `marketplace_communities.id`
  final int communityId;

  /// Optional card data from the list screen — lets the header render
  /// instantly while the full details are still loading.
  final Map<String, dynamic>? initialCommunity;

  final CommunityMembershipChanged? onMembershipChanged;

  /// Optional: open your opportunity detail screen. The "View Opportunity"
  /// link is only shown when this is provided.
  final void Function(Map<String, dynamic> opportunity)? onOpenOpportunity;

  const CommunityDetailScreen({
    Key? key,
    required this.communityId,
    this.initialCommunity,
    this.onMembershipChanged,
    this.onOpenOpportunity,
  }) : super(key: key);

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final _api = CommunityDetailsApiService.instance;

  int get _groupId => widget.communityId;

  // --- details ---
  Map<String, dynamic>? _community;
  bool _loadingDetails = true;
  bool _detailsLoaded = false;
  String? _detailsError;
  bool _viewRecorded = false;

  int _activeTabIndex = 0;

  // --- membership / bookmark (all from server) ---
  bool _isMember = false;
  bool _hasPending = false;
  bool _isCreator = false;
  bool _isBookmarked = false;
  bool _bookmarkBusy = false;

  // community ids with a join / leave / cancel call in flight (main + matching)
  final Set<int> _busyIds = {};

  // --- overview data ---
  List<Map<String, dynamic>> _previewMembers = [];
  List<Map<String, dynamic>> _opportunities = [];
  int _opportunitiesTotal = 0;
  int _oppPage = 1;
  static const int _oppPageSize = 5;
  bool _loadingMoreOpps = false;

  // --- members tab ---
  final TextEditingController _memberSearchCtrl = TextEditingController();
  Timer? _memberDebounce;
  int _membersReq = 0;
  List<Map<String, dynamic>> _members = [];
  bool _membersLoaded = false;
  bool _loadingMembers = false;
  bool _loadingMoreMembers = false;
  bool _membersHasMore = false;
  String? _membersError;
  int _membersPage = 1;
  static const int _membersPageSize = 20;

  // --- feed tab ---
  List<Map<String, dynamic>> _posts = [];
  bool _feedLoaded = false;
  bool _loadingFeed = false;
  bool _loadingMoreFeed = false;
  bool _feedHasMore = false;
  String? _feedError;
  int _feedPage = 1;
  static const int _feedPageSize = 10;
  final Set<String> _likeInFlight = {};

  // --- matching communities ---
  List<Map<String, dynamic>> _matching = [];
  bool _loadingMatching = true;
  String? _matchingError;
  final Set<int> _matchJoined = {};
  final Set<int> _matchPending = {};

  @override
  void initState() {
    super.initState();
    _community = widget.initialCommunity;
    _loadDetails();
    _loadMatching();
  }

  @override
  void dispose() {
    _memberSearchCtrl.dispose();
    _memberDebounce?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Toasts
  // --------------------------------------------------------------------------
  void _showToast(String message, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 24, right: 24),
        backgroundColor: const Color(0xFF191C1D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFF8FAFA), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFF8FAFA),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) => _showToast(message, Icons.info);

  // --------------------------------------------------------------------------
  // Data loading
  // --------------------------------------------------------------------------
  Future<void> _loadDetails({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loadingDetails = true;
        _detailsError = null;
      });
    }
    try {
      final data = await _api.communityDetails(_groupId);
      if (!mounted) return;
      setState(() {
        _community = data;
        _isMember = _truthy(data['is_member']);
        _hasPending = _truthy(data['has_pending_request']);
        _isBookmarked = _truthy(data['is_bookmarked']);
        _isCreator = _truthy(data['is_creator']);
        _previewMembers = _asMapList(data['preview_members']);
        _opportunities = _asMapList(data['opportunities']);
        _opportunitiesTotal = _i(data['opportunities_count']);
        _oppPage = 1;
        _loadingDetails = false;
        _detailsLoaded = true;
      });
      _recordViewOnce();
    } on CommunityDetailsException catch (e) {
      if (!mounted || silent) return;
      setState(() {
        _detailsError = e.message;
        _loadingDetails = false;
      });
    } catch (e) {
      if (!mounted || silent) return;
      setState(() {
        _detailsError = 'Failed to load community.';
        _loadingDetails = false;
      });
    }
  }

  void _recordViewOnce() {
    if (_viewRecorded) return;
    _viewRecorded = true;
    _api.recordView(_groupId).then((_) {
      if (!mounted || _community == null) return;
      setState(() => _community!['views'] = _i(_community!['views']) + 1);
    }).catchError((_) {
      // Non-fatal: view counting must never break the screen.
    });
  }

  Future<void> _loadMatching() async {
    setState(() {
      _loadingMatching = true;
      _matchingError = null;
    });
    try {
      final list = await _api.matchingCommunities(groupId: _groupId);
      if (!mounted) return;
      final filtered = list.where((c) => _i(c['id']) != _groupId).toList();
      setState(() {
        _matching = filtered;
        _matchJoined
          ..clear()
          ..addAll(filtered.where((c) => _truthy(c['already_joined'])).map((c) => _i(c['id'])));
        _matchPending.clear();
        _loadingMatching = false;
      });
    } on CommunityDetailsException catch (e) {
      if (!mounted) return;
      setState(() {
        _matchingError = e.message;
        _loadingMatching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _matchingError = 'Failed to load matching communities.';
        _loadingMatching = false;
      });
    }
  }

  Future<void> _loadMembers({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loadingMembers = true;
        _membersError = null;
      });
    } else {
      if (_loadingMoreMembers || !_membersHasMore) return;
      setState(() => _loadingMoreMembers = true);
    }
    final req = ++_membersReq;
    final page = reset ? 1 : _membersPage + 1;
    try {
      final list = await _api.fetchMembers(
        groupId: _groupId,
        search: _memberSearchCtrl.text.trim(),
        page: page,
        limit: _membersPageSize,
      );
      if (!mounted || req != _membersReq) return;
      setState(() {
        _members = reset ? list : [..._members, ...list];
        _membersPage = page;
        _membersHasMore = list.length >= _membersPageSize;
        _membersLoaded = true;
        _loadingMembers = false;
        _loadingMoreMembers = false;
      });
    } on CommunityDetailsException catch (e) {
      if (!mounted || req != _membersReq) return;
      setState(() {
        _membersError = e.message;
        _loadingMembers = false;
        _loadingMoreMembers = false;
      });
    } catch (e) {
      if (!mounted || req != _membersReq) return;
      setState(() {
        _membersError = 'Failed to load members.';
        _loadingMembers = false;
        _loadingMoreMembers = false;
      });
    }
  }

  void _onMemberSearchChanged(String _) {
    _memberDebounce?.cancel();
    _memberDebounce = Timer(const Duration(milliseconds: 400), () => _loadMembers());
  }

  Future<void> _loadFeed({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loadingFeed = true;
        _feedError = null;
      });
    } else {
      if (_loadingMoreFeed || !_feedHasMore) return;
      setState(() => _loadingMoreFeed = true);
    }
    final page = reset ? 1 : _feedPage + 1;
    try {
      final list = await _api.fetchFeed(groupId: _groupId, page: page, limit: _feedPageSize);
      if (!mounted) return;
      setState(() {
        _posts = reset ? list : [..._posts, ...list];
        _feedPage = page;
        _feedHasMore = list.length >= _feedPageSize;
        _feedLoaded = true;
        _loadingFeed = false;
        _loadingMoreFeed = false;
      });
    } on CommunityDetailsException catch (e) {
      if (!mounted) return;
      setState(() {
        _feedError = e.message;
        _loadingFeed = false;
        _loadingMoreFeed = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _feedError = 'Failed to load feed.';
        _loadingFeed = false;
        _loadingMoreFeed = false;
      });
    }
  }

  Future<void> _loadMoreOpportunities() async {
    if (_loadingMoreOpps) return;
    setState(() => _loadingMoreOpps = true);
    try {
      final data = await _api.fetchCommunityOpportunities(
        groupId: _groupId,
        page: _oppPage + 1,
        limit: _oppPageSize,
      );
      if (!mounted) return;
      setState(() {
        _opportunities = [..._opportunities, ..._asMapList(data['items'])];
        _opportunitiesTotal = _i(data['total']);
        _oppPage += 1;
        _loadingMoreOpps = false;
      });
    } on CommunityDetailsException catch (e) {
      if (!mounted) return;
      setState(() => _loadingMoreOpps = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMoreOpps = false);
      _showError('Failed to load opportunities.');
    }
  }

  bool get _oppHasMore => _oppPage * _oppPageSize < _opportunitiesTotal;

  Future<void> _refreshAll() async {
    _membersLoaded = false;
    _feedLoaded = false;
    await Future.wait<void>([
      _loadDetails(),
      _loadMatching(),
      if (_activeTabIndex == 1) _loadMembers(),
      if (_activeTabIndex == 2) _loadFeed(),
    ]);
  }

  void _selectTab(int index) {
    setState(() => _activeTabIndex = index);
    if (index == 1 && !_membersLoaded && !_loadingMembers) _loadMembers();
    if (index == 2 && !_feedLoaded && !_loadingFeed) _loadFeed();
  }

  // --------------------------------------------------------------------------
  // Bookmark / share
  // --------------------------------------------------------------------------
  Future<void> _toggleBookmark() async {
    if (_bookmarkBusy) return;
    setState(() => _bookmarkBusy = true);
    try {
      final bookmarked = await _api.toggleBookmark(_groupId);
      if (!mounted) return;
      setState(() => _isBookmarked = bookmarked);
      _showToast(
        bookmarked ? 'Community saved to your bookmarks' : 'Removed from bookmarks',
        bookmarked ? Icons.bookmark : Icons.bookmark_remove,
      );
    } on CommunityDetailsException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to update bookmark.');
    } finally {
      if (mounted) setState(() => _bookmarkBusy = false);
    }
  }

  Future<void> _shareCommunity({int postId = 0}) async {
    try {
      final data = await _api.recordShare(groupId: _groupId, postId: postId);
      final url = _s(data['share_url']);
      final title = _s(data['title']);
      await Clipboard.setData(ClipboardData(text: title.isEmpty ? url : '$title\n$url'));
      if (!mounted) return;
      if (postId > 0) {
        final idx = _posts.indexWhere((p) => _i(p['id']) == postId);
        if (idx != -1) {
          setState(() => _posts[idx]['share_count'] = _i(_posts[idx]['share_count']) + 1);
        }
      }
      _showToast('Community link copied to clipboard!', Icons.content_copy);
    } on CommunityDetailsException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to share.');
    }
  }

  // --------------------------------------------------------------------------
  // Like
  // --------------------------------------------------------------------------
  Future<void> _toggleLike(Map<String, dynamic> post) async {
    final key = _s(post['id']);
    final postId = _i(post['id']);
    if (postId == 0 || _likeInFlight.contains(key)) return;

    final wasLiked = _truthy(post['liked_by_me']);
    final baseCount = _i(post['likes_count']) - (wasLiked ? 1 : 0);

    setState(() {
      _likeInFlight.add(key);
      post['liked_by_me'] = wasLiked ? '0' : '1';
      post['likes_count'] = baseCount + (wasLiked ? 0 : 1);
    });
    try {
      final liked = await _api.toggleLikePost(postId);
      if (!mounted) return;
      setState(() {
        post['liked_by_me'] = liked ? '1' : '0';
        post['likes_count'] = (baseCount < 0 ? 0 : baseCount) + (liked ? 1 : 0);
      });
    } on CommunityDetailsException catch (e) {
      if (mounted) {
        setState(() {
          post['liked_by_me'] = wasLiked ? '1' : '0';
          post['likes_count'] = baseCount + (wasLiked ? 1 : 0);
        });
      }
      _showError(e.message);
    } catch (e) {
      if (mounted) {
        setState(() {
          post['liked_by_me'] = wasLiked ? '1' : '0';
          post['likes_count'] = baseCount + (wasLiked ? 1 : 0);
        });
      }
      _showError('Failed to update like.');
    } finally {
      if (mounted) setState(() => _likeInFlight.remove(key));
    }
  }

  // --------------------------------------------------------------------------
  // Membership: join / cancel request / leave
  // (generic — used by the main bottom bar AND the matching-community cards)
  // --------------------------------------------------------------------------

  /// Returns 'joined', 'pending', or null (cancelled / failed).
  Future<String?> _runJoin(int id, Map<String, dynamic> community) async {
    final isFree = _isFreeCommunity(community);
    var requestMessage = '';

    if (!isFree) {
      final msg = await _askRequestMessage(
          _s(community['title']).isEmpty ? 'this community' : _s(community['title']));
      if (msg == null) return null;
      requestMessage = msg;
    }

    setState(() => _busyIds.add(id));
    try {
      final res = await _api.joinCommunity(groupId: id, requestMessage: requestMessage);
      final status = _s(_asMap(res['data'])['status']);
      final joined = status == 'joined' || (status.isEmpty && isFree);
      final serverMsg = _s(res['message']);
      _showToast(
        serverMsg.isNotEmpty ? serverMsg : (joined ? 'Joined successfully' : 'Request sent'),
        joined ? Icons.celebration : Icons.send,
      );
      return joined ? 'joined' : 'pending';
    } on CommunityDetailsException catch (e) {
      final m = e.message.toLowerCase();
      _showError(e.message);
      // Server state differs from ours — align with it.
      if (m.contains('pending join request')) return 'pending';
      if (m.contains('already joined')) return 'joined';
      return null;
    } catch (e) {
      _showError('Failed to join. Please try again.');
      return null;
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  /// Returns true if the user is no longer a member.
  Future<bool> _runLeave(int id, String title) async {
    final confirmed = await _confirmLeave(title.isEmpty ? 'this community' : title);
    if (!confirmed || !mounted) return false;

    setState(() => _busyIds.add(id));
    try {
      final res = await _api.leaveCommunity(id);
      final serverMsg = _s(res['message']);
      _showToast(serverMsg.isNotEmpty ? serverMsg : 'You have left the community', Icons.info);
      return true;
    } on CommunityDetailsException catch (e) {
      _showError(e.message); // e.g. creator cannot leave
      return false;
    } catch (e) {
      _showError('Failed to leave. Please try again.');
      return false;
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  /// Returns true if there is no longer a pending request.
  Future<bool> _runCancel(int id) async {
    setState(() => _busyIds.add(id));
    try {
      final res = await _api.cancelJoinRequest(id);
      final serverMsg = _s(res['message']);
      _showToast(serverMsg.isNotEmpty ? serverMsg : 'Join request cancelled', Icons.info);
      return true;
    } on CommunityDetailsException catch (e) {
      _showError(e.message);
      // Request was already handled (approved/rejected) — nothing left to cancel.
      return e.message.toLowerCase().contains('no pending');
    } catch (e) {
      _showError('Failed to cancel request. Please try again.');
      return false;
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  Future<String?> _askRequestMessage(String communityTitle) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('SEND REQUEST'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmLeave(String communityTitle) async {
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

  // --- main community (bottom bar) ---
  Future<void> _mainAction() async {
    final c = _community;
    if (c == null || !_detailsLoaded || _isCreator || _busyIds.contains(_groupId)) return;

    if (_isMember) {
      final left = await _runLeave(_groupId, _s(c['title']));
      if (!left || !mounted) return;
      setState(() {
        _isMember = false;
        _hasPending = false;
        _bumpMembers(-1);
      });
      _afterMembershipChange();
    } else if (_hasPending) {
      final ok = await _runCancel(_groupId);
      if (!ok || !mounted) return;
      setState(() => _hasPending = false);
      _afterMembershipChange();
    } else {
      final result = await _runJoin(_groupId, c);
      if (result == null || !mounted) return;
      setState(() {
        if (result == 'joined') {
          _isMember = true;
          _hasPending = false;
          _bumpMembers(1);
        } else {
          _hasPending = true;
        }
      });
      _afterMembershipChange();
    }
  }

  void _bumpMembers(int delta) {
    final c = _community;
    if (c == null) return;
    final next = _i(c['members_count']) + delta;
    c['members_count'] = next < 0 ? 0 : next;
  }

  void _afterMembershipChange() {
    widget.onMembershipChanged?.call(
      _groupId,
      joined: _isMember,
      pending: _hasPending,
      membersCount: _i(_community?['members_count']),
    );
    _membersLoaded = false;
    if (_activeTabIndex == 1) _loadMembers();
    _loadDetails(silent: true); // resync counts / preview members from server
  }

  // --- matching community cards ---
  Future<void> _matchAction(Map<String, dynamic> c) async {
    final id = _i(c['id']);
    if (id == 0 || _busyIds.contains(id)) return;

    if (_matchJoined.contains(id)) {
      final left = await _runLeave(id, _s(c['title']));
      if (!left || !mounted) return;
      setState(() {
        _matchJoined.remove(id);
        _bumpMatchCount(c, -1);
      });
    } else if (_matchPending.contains(id)) {
      final ok = await _runCancel(id);
      if (!ok || !mounted) return;
      setState(() => _matchPending.remove(id));
    } else {
      final result = await _runJoin(id, c);
      if (result == null || !mounted) return;
      setState(() {
        if (result == 'joined') {
          _matchJoined.add(id);
          _matchPending.remove(id);
          _bumpMatchCount(c, 1);
        } else {
          _matchPending.add(id);
        }
      });
    }
    widget.onMembershipChanged?.call(
      id,
      joined: _matchJoined.contains(id),
      pending: _matchPending.contains(id),
      membersCount: _matchMembers(c),
    );
  }

  int _matchMembers(Map<String, dynamic> c) =>
      _s(c['live_member_count']).isNotEmpty ? _i(c['live_member_count']) : _i(c['members_count']);

  void _bumpMatchCount(Map<String, dynamic> c, int delta) {
    final next = _matchMembers(c) + delta;
    c['live_member_count'] = next < 0 ? 0 : next;
    c['members_count'] = next < 0 ? 0 : next;
  }

  void _openCommunity(Map<String, dynamic> c) {
    final id = _i(c['id']);
    if (id == 0) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityDetailScreen(
          communityId: id,
          initialCommunity: c,
          onOpenOpportunity: widget.onOpenOpportunity,
          onMembershipChanged: (cid, {required joined, required pending, required membersCount}) {
            if (mounted) {
              setState(() {
                joined ? _matchJoined.add(cid) : _matchJoined.remove(cid);
                pending ? _matchPending.add(cid) : _matchPending.remove(cid);
              });
            }
            widget.onMembershipChanged
                ?.call(cid, joined: joined, pending: pending, membersCount: membersCount);
          },
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFA).withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191C1D)),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          'COMMUNITY PROFILE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4A626D),
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: const Color(0xFF4A626D),
            ),
            onPressed: _community == null ? null : _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF4A626D)),
            onPressed: _community == null ? null : () => _shareCommunity(),
          ),
        ],
      ),
      body: _buildBody(),
      bottomSheet: _community == null ? null : _buildBottomActionBar(),
    );
  }

  Widget _buildBody() {
    final c = _community;
    if (c == null) {
      if (_loadingDetails) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF004349)));
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _errorBox(_detailsError ?? 'Community not found.', _loadDetails),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(c),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: _buildQuickStats(c),
              ),
            ),
            if (_detailsError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _errorBox(_detailsError!, _loadDetails),
              ),
            _buildTabNavigation(c),
            const SizedBox(height: 16),
            if (_activeTabIndex == 0) _buildOverviewTab(c),
            if (_activeTabIndex == 1) _buildMembersTab(),
            if (_activeTabIndex == 2) _buildFeedTab(),
            const SizedBox(height: 24),
            _buildMatchingCommunitiesSection(),
          ],
        ),
      ),
    );
  }

  Widget _errorBox(String message, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A4A626D)),
      ),
      child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF4A626D))),
    );
  }

  Widget _loader() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 28),
    child: Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF004349)),
      ),
    ),
  );

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A4A626D)),
      ),
      child: child,
    );
  }

  // --------------------------------------------------------------------------
  // Hero
  // --------------------------------------------------------------------------
  Widget _buildHeroHeader(Map<String, dynamic> c) {
    final title = _s(c['title']).isEmpty ? 'Untitled Community' : _s(c['title']);
    final description = _s(c['description']);
    final verified = _truthy(c['verified']) || _truthy(c['is_verified']);
    final logoUrl = _pick(c, ['logo', 'logo_url', 'image', 'icon', 'profile_image']);
    final coverUrl = _pick(c, ['cover_image', 'banner', 'banner_image', 'cover']);
    final rule = _ruleLabel(c);
    final visibility = _s(c['visibility']);
    final category = _categoryLabel(c);
    final location = _pick(c, ['location', 'city', 'address', 'country']);
    final established = _parseDate(_pick(c, ['created_date', 'created_at']))?.year;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004349), Color(0xFF0D5C63), Color(0xFF1A383B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: _isHttp(coverUrl)
            ? DecorationImage(
          image: NetworkImage(coverUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken),
        )
            : null,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: _isHttp(logoUrl)
                    ? Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(_iconForType(c), color: const Color(0xFF004349), size: 32),
                )
                    : Icon(_iconForType(c), color: const Color(0xFF004349), size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                    if (rule.isNotEmpty) _heroBadge(rule, highlight: _isFreeCommunity(c)),
                    if (visibility.isNotEmpty)
                      _heroBadge(_cap(visibility), icon: visibility == 'public' ? Icons.public : Icons.lock_outline),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (verified) ...const [
                SizedBox(width: 4),
                Icon(Icons.verified, color: Color(0xFF7DD3FC), size: 20),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xCCFFFFFF),
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetaTag(Icons.category, category),
              if (location.isNotEmpty) _buildMetaTag(Icons.location_on, location),
              if (established != null) _buildMetaTag(Icons.calendar_month, 'Est. $established'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(String text, {IconData? icon, bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF10B981).withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? const Color(0xFF34D399).withOpacity(0.3) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: highlight ? const Color(0xFF6EE7B7) : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFA5F3FC)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Stats
  // --------------------------------------------------------------------------
  Widget _buildQuickStats(Map<String, dynamic> c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: _buildStatColumn(Icons.groups, _compact(_i(c['members_count'])), 'MEMBERS')),
          Container(height: 24, width: 1, color: const Color(0x1A4A626D)),
          Expanded(child: _buildStatColumn(Icons.visibility, _compact(_i(c['views'])), 'VIEWS')),
          Container(height: 24, width: 1, color: const Color(0x1A4A626D)),
          Expanded(child: _buildStatColumn(Icons.forum, _compact(_i(c['post_count'])), 'POSTS')),
        ],
      ),
    );
  }

  Widget _buildStatColumn(IconData icon, String val, String label) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF004349)),
            const SizedBox(width: 4),
            Text(
              val,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF191C1D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A626D),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Tabs
  // --------------------------------------------------------------------------
  Widget _buildTabNavigation(Map<String, dynamic> c) {
    final tabs = <({IconData icon, String label})>[
      (icon: Icons.info, label: 'Overview'),
      (icon: Icons.group, label: 'Members (${_compact(_i(c['members_count']))})'),
      (icon: Icons.feed, label: 'Feed'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x1A4A626D))),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _activeTabIndex == index;
          final color = isSelected ? const Color(0xFF004349) : const Color(0xFF4A626D);
          return Expanded(
            child: InkWell(
              onTap: () => _selectTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF004349) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tabs[index].icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tabs[index].label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF004349)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A626D),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Overview tab
  // --------------------------------------------------------------------------
  Widget _buildOverviewTab(Map<String, dynamic> c) {
    final description = _s(c['description']);
    final visibility = _s(c['visibility']);
    final rule = _ruleLabel(c);
    final tags = _csv(_s(c['tags']));
    final industries = _csv(_s(c['industries']));

    final infoItems = <({String label, String value, IconData icon, Color color})>[
      if (visibility.isNotEmpty)
        (
        label: 'Access Type',
        value: _cap(visibility),
        icon: visibility == 'public' ? Icons.lock_open : Icons.lock_outline,
        color: const Color(0xFF059669),
        ),
      if (rule.isNotEmpty)
        (label: 'Joining', value: rule, icon: Icons.how_to_reg, color: const Color(0xFF004349)),
      (label: 'Joining Fee', value: _feeText(c), icon: Icons.payments_outlined, color: const Color(0xFF004349)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // ABOUT
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.description, 'ABOUT THE COMMUNITY'),
                const SizedBox(height: 8),
                Text(
                  description.isEmpty ? 'No description added yet.' : description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF3F484A), height: 1.4),
                ),
                if (industries.isNotEmpty || tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in industries) _chip(t, filled: true),
                      for (final t in tags) _chip('#$t'),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0x1A4A626D)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in infoItems)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label, style: const TextStyle(fontSize: 11, color: Color(0xFF4A626D))),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(item.icon, size: 14, color: item.color),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.value,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF191C1D),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          if (!_detailsLoaded && _loadingDetails) _loader(),

          // OPPORTUNITIES
          if (_opportunities.isNotEmpty || _opportunitiesTotal > 0) ...[
            const SizedBox(height: 12),
            _buildOpportunitiesCard(),
          ],

          // KEY MEMBERS
          if (_previewMembers.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildKeyMembersCard(c),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF004349).withOpacity(0.1) : const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: filled ? const Color(0xFF004349) : const Color(0xFF4A626D),
        ),
      ),
    );
  }

  Widget _buildOpportunitiesCard() {
    final count = _opportunitiesTotal > 0 ? _opportunitiesTotal : _opportunities.length;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(Icons.campaign, 'ACTIVE OPPORTUNITY'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF004349).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count Open',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF004349),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in _opportunities) ...[
            _buildOpportunityItem(item),
            const SizedBox(height: 8),
          ],
          if (_oppHasMore)
            Center(
              child: TextButton(
                onPressed: _loadingMoreOpps ? null : _loadMoreOpportunities,
                child: _loadingMoreOpps
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Load more', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOpportunityItem(Map<String, dynamic> item) {
    final opp = _asMap(item['opportunity']);
    final stats = _asMap(item['stats']);
    final pricing = _asMap(item['pricing']);
    final application = _asMap(item['application']);

    const dateKeys = [
      'deadline', 'closing_date', 'application_deadline', 'closes_on', 'end_date', 'last_date'
    ];
    final title = _pick(opp, ['title', 'opportunity_title', 'name', 'heading']);
    final desc = _pick(opp, ['description', 'short_description', 'summary', 'details']);
    final label = _s(opp['label_name']);
    final closes = _pick(application, dateKeys).isNotEmpty ? _pick(application, dateKeys) : _pick(opp, dateKeys);
    final apps = _i(stats['total_applications']);
    final applied = _s(opp['application_status']) == 'applied';

    final pricingType = _s(pricing['pricing_type']);
    final priceAmount = _s(pricing['price_amount']);
    final currency = _s(pricing['currency']);
    final priceText = pricingType.isEmpty
        ? ''
        : (pricingType == 'paid' && priceAmount.isNotEmpty
        ? '${currency.isEmpty ? '' : '$currency '}$priceAmount'
        : _cap(pricingType));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x1A4A626D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'Opportunity #${_s(opp['id'])}' : title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191C1D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(fontSize: 11, color: Color(0xFF3F484A)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _oppMeta(
                      Icons.schedule,
                      closes.isNotEmpty ? 'Closes ${_shortDate(closes)}' : '$apps application${apps == 1 ? '' : 's'}',
                    ),
                    if (priceText.isNotEmpty) _oppMeta(Icons.sell_outlined, priceText),
                    if (applied) _oppMeta(Icons.check_circle_outline, 'Applied'),
                  ],
                ),
              ),
              if (widget.onOpenOpportunity != null)
                InkWell(
                  onTap: () => widget.onOpenOpportunity!(item),
                  child: Row(
                    children: const [
                      Text(
                        'View Opportunity',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF004349),
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 12, color: Color(0xFF004349)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _oppMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF4A626D)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF4A626D))),
      ],
    );
  }

  Widget _buildKeyMembersCard(Map<String, dynamic> c) {
    return _sectionCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle(Icons.contacts, 'KEY MEMBERS'),
              InkWell(
                onTap: () => _selectTab(1),
                child: Text(
                  'View All (${_i(c['members_count'])})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF004349),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _previewMembers.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Color(0x1A4A626D)),
              ),
            _buildMemberRow(_previewMembers[i], i, c),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberRow(Map<String, dynamic> m, int seed, Map<String, dynamic> community) {
    final name = _s(m['name']).isEmpty ? 'Member' : _s(m['name']);
    final role = _s(m['role']).toLowerCase();
    final isStaff = role == 'admin' || role == 'moderator';
    final subtitle = [
      _s(m['designation']),
      _s(m['company_name']).isNotEmpty ? _s(m['company_name']) : _s(m['city']),
    ].where((e) => e.isNotEmpty).join(' • ');
    final isFounder = _s(m['vendor_id']).isNotEmpty && _s(m['vendor_id']) == _s(community['created_by']);
    final tag = isFounder ? 'Founder' : _cap(role);
    final verified = _truthy(m['verified']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _avatar(name, _s(m['profile_pic']), seed),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF191C1D),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (verified) ...const [
                          SizedBox(width: 3),
                          Icon(Icons.verified, size: 13, color: Color(0xFF0D5C63)),
                        ],
                        if (isStaff) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004349),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              _cap(role),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF4A626D)),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (tag.isNotEmpty)
          Text(
            tag,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A626D),
            ),
          ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Members tab
  // --------------------------------------------------------------------------
  Widget _buildMembersTab() {
    final community = _community ?? <String, dynamic>{};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _sectionCard(
        child: Column(
          children: [
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x334A626D)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: Color(0xFF4A626D)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _memberSearchCtrl,
                      onChanged: _onMemberSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search members by name, designation, city...',
                        hintStyle: TextStyle(fontSize: 12, color: Color(0xFF4A626D)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loadingMembers)
              _loader()
            else if (_membersError != null)
              _errorBox(_membersError!, _loadMembers)
            else if (_members.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No members found.', style: TextStyle(fontSize: 12, color: Color(0xFF4A626D))),
                )
              else ...[
                  for (var i = 0; i < _members.length; i++) ...[
                    if (i > 0) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                    _buildMemberListItem(_members[i], i, community),
                  ],
                  if (_membersHasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: _loadingMoreMembers ? null : () => _loadMembers(reset: false),
                        child: _loadingMoreMembers
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Load more', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberListItem(Map<String, dynamic> m, int seed, Map<String, dynamic> community) {
    final joined = _monthYear(_s(m['joined_at']));
    final name = _s(m['name']).isEmpty ? 'Member' : _s(m['name']);
    final role = _s(m['role']).toLowerCase();
    final isStaff = role == 'admin' || role == 'moderator';
    final subtitle = [
      _s(m['designation']),
      _s(m['company_name']),
      _s(m['city']),
    ].where((e) => e.isNotEmpty).join(' • ');
    final verified = _truthy(m['verified']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _avatar(name, _s(m['profile_pic']), seed),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF191C1D)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (verified) ...const [
                          SizedBox(width: 3),
                          Icon(Icons.verified, size: 13, color: Color(0xFF0D5C63)),
                        ],
                        if (isStaff) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004349),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              _cap(role),
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF4A626D)),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (joined.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            'Joined $joined',
            style: const TextStyle(fontSize: 10, color: Color(0xFF4A626D)),
          ),
        ],
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Feed tab
  // --------------------------------------------------------------------------
  Widget _buildFeedTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Builder(builder: (context) {
        if (_loadingFeed) return _loader();
        if (_feedError != null) return _errorBox(_feedError!, _loadFeed);
        if (_posts.isEmpty) return _emptyBox('No posts in this community yet.');
        return Column(
          children: [
            for (final post in _posts) ...[
              _buildPostCard(post),
              const SizedBox(height: 10),
            ],
            if (_feedHasMore)
              TextButton(
                onPressed: _loadingMoreFeed ? null : () => _loadFeed(reset: false),
                child: _loadingMoreFeed
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Load more', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final pinned = _truthy(post['pinned']);
    final authorRole = _s(post['author_role']).toLowerCase();
    final author = _s(post['author_name']).isEmpty ? 'Member' : _s(post['author_name']);
    final label = _s(post['label']);
    final contentType = _s(post['content_type']);
    final tags = _csv(_s(post['tags']));
    final location = _s(post['location']);
    final video = _s(post['youtube_url']);
    final liked = _truthy(post['liked_by_me']);
    final busyLike = _likeInFlight.contains(_s(post['id']));
    final time = _timeAgo(_s(post['created_date']));

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (pinned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004349).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.push_pin, size: 10, color: Color(0xFF004349)),
                      const SizedBox(width: 3),
                      Text(
                        authorRole.isEmpty ? 'Pinned' : 'Pinned • ${_cap(authorRole)}',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF004349)),
                      ),
                    ],
                  ),
                )
              else if (contentType.isNotEmpty)
                _chip(_cap(contentType), filled: true),
              if (time.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF4A626D))),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _avatar(author, _s(post['author_pic']), _i(post['vendor_id']), radius: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  author,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF191C1D)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF191C1D)),
            ),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 13, color: Color(0xFF4A626D)),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(location,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A626D)),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          if (video.isNotEmpty) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: video));
                _showToast('Video link copied to clipboard', Icons.content_copy);
              },
              child: Row(
                children: const [
                  Icon(Icons.play_circle_outline, size: 16, color: Color(0xFF004349)),
                  SizedBox(width: 4),
                  Text(
                    'Video attached • tap to copy link',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF004349)),
                  ),
                ],
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [for (final t in tags) _chip('#$t')]),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: busyLike ? null : () => _toggleLike(post),
                child: Row(
                  children: [
                    Icon(
                      liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 14,
                      color: liked ? const Color(0xFF004349) : const Color(0xFF4A626D),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_i(post['likes_count'])}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: liked ? FontWeight.w700 : FontWeight.w400,
                        color: liked ? const Color(0xFF004349) : const Color(0xFF4A626D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.mode_comment_outlined, size: 14, color: Color(0xFF4A626D)),
              const SizedBox(width: 4),
              Text('${_i(post['comments_count'])}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF4A626D))),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => _shareCommunity(postId: _i(post['id'])),
                child: Row(
                  children: [
                    const Icon(Icons.share_outlined, size: 14, color: Color(0xFF4A626D)),
                    const SizedBox(width: 4),
                    Text(
                      _i(post['share_count']) > 0 ? '${_i(post['share_count'])}' : 'Share',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A626D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Matching communities
  // --------------------------------------------------------------------------
  Widget _buildMatchingCommunitiesSection() {
    if (!_loadingMatching && _matchingError == null && _matching.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: Color(0xFF004349)),
                        SizedBox(width: 4),
                        Text(
                          'MATCHING COMMUNITIES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A626D),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Similar communities you may like',
                      style: TextStyle(fontSize: 11, color: Color(0xFF4A626D)),
                    ),
                  ],
                ),
              ),
              if (Navigator.canPop(context))
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF004349),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_loadingMatching)
          SizedBox(height: 120, child: _loader())
        else if (_matchingError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _errorBox(_matchingError!, _loadMatching),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _matching.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _buildSliderCard(_matching[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildSliderCard(Map<String, dynamic> c) {
    final id = _i(c['id']);
    final name = _s(c['title']).isEmpty ? 'Untitled Community' : _s(c['title']);
    final subtitle = _categoryLabel(c);
    final score = _s(c['match_score']);
    final members = _compact(_matchMembers(c));
    final location = _pick(c, ['location', 'city', 'address', 'country']);
    final joined = _matchJoined.contains(id);
    final pending = !joined && _matchPending.contains(id);
    final busy = _busyIds.contains(id);
    final free = _isFreeCommunity(c);

    final Color bg = joined
        ? const Color(0xFFECEEEE)
        : pending
        ? const Color(0xFFE1E3E3)
        : const Color(0xFF004349);
    final Color fg = joined
        ? const Color(0xFF4A626D)
        : pending
        ? const Color(0xFF004349)
        : Colors.white;
    final IconData btnIcon = joined
        ? Icons.check
        : pending
        ? Icons.close
        : (free ? Icons.add : Icons.send);
    final String btnLabel = joined
        ? 'Joined'
        : pending
        ? 'Cancel Request'
        : (free ? 'Join' : 'Request');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCommunity(c),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x1A4A626D)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_iconForType(c), color: const Color(0xFF004349), size: 20),
                    ),
                    if (score.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$score% Match',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191C1D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF4A626D)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.group, size: 12, color: Color(0xFF4A626D)),
                    const SizedBox(width: 2),
                    Text(members, style: const TextStyle(fontSize: 10, color: Color(0xFF4A626D))),
                    if (location.isNotEmpty) ...[
                      const Text(' • ', style: TextStyle(fontSize: 10, color: Color(0xFF4A626D))),
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF4A626D)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF4A626D)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: busy ? null : () => _matchAction(c),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: bg,
                  foregroundColor: fg,
                  disabledBackgroundColor: bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: EdgeInsets.zero,
                ),
                child: busy
                    ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(btnIcon, size: 14),
                    const SizedBox(width: 4),
                    Text(btnLabel,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Bottom action bar
  // --------------------------------------------------------------------------
  Widget _buildBottomActionBar() {
    final c = _community!;
    final busy = _busyIds.contains(_groupId);
    final free = _isFreeCommunity(c);

    String label;
    IconData icon;
    Color bg;
    var enabled = true;

    if (!_detailsLoaded) {
      label = 'Loading…';
      icon = Icons.hourglass_empty;
      bg = const Color(0xFF4A626D);
      enabled = false;
    } else if (_isCreator) {
      label = 'You own this community';
      icon = Icons.workspace_premium;
      bg = const Color(0xFF059669);
      enabled = false;
    } else if (_isMember) {
      label = 'Member • Joined';
      icon = Icons.check_circle;
      bg = const Color(0xFF059669);
    } else if (_hasPending) {
      label = 'Cancel Request';
      icon = Icons.close;
      bg = const Color(0xFF4A626D);
    } else {
      label = free ? 'Join Community' : 'Request to Join';
      icon = free ? Icons.group_add : Icons.send;
      bg = const Color(0xFF004349);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0x1A4A626D))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            InkWell(
              onTap: _bookmarkBusy ? null : _toggleBookmark,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x334A626D)),
                ),
                child: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: const Color(0xFF4A626D),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _shareCommunity(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x334A626D)),
                ),
                child: const Icon(Icons.share_outlined, color: Color(0xFF4A626D), size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: (enabled && !busy) ? _mainAction : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: bg,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: bg,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: busy
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}