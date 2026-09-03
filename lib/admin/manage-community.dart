import 'package:flutter/material.dart';

import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'create_community_screen.dart';

// --- Color Tokens ---
class AppColors {
  static const Color primary = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color onPrimaryContainer = Color(0xFFE3FFFE);
  static const Color background = Color(0xFFF0FCFB);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEBF6F6);
  static const Color surfaceContainer = Color(0xFFEEEEED);
  static const Color surfaceContainerHighest = Color(0xFFD9E5E4);
  static const Color onSurface = Color(0xFF131D1E);
  static const Color onSurfaceVariant = Color(0xFF3E4949);
  static const Color borderLowContrast = Color(0xFFBDC9C8);
  static const Color negotiationAmber = Color(0xFFB45309);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
}

// NOTE: point this at wherever the PHP file you shared actually lives,
// same convention as PaymentScreen's "new_apis/payment_modal_API.php".
const String _communityEndpoint = "new_apis/community_api.php";

class CommunityManagementScreen extends StatefulWidget {
  const CommunityManagementScreen({Key? key}) : super(key: key);

  @override
  State<CommunityManagementScreen> createState() => _CommunityManagementScreenState();
}

class _CommunityManagementScreenState extends State<CommunityManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _active = [];
  List<Map<String, dynamic>> _filteredActive = [];

  bool _loading = true;
  String? _loadError;

  // community_id -> true while an action request is in flight, so we can
  // show a small spinner on just that card instead of a global blocker.
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearchFilter);
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _idOf(Map<String, dynamic> row) => (row['id'] ?? row['community_id'] ?? '').toString();
  String _titleOf(Map<String, dynamic> row) =>
      (row['title'] ?? row['name'] ?? row['community_name'] ?? 'Untitled community').toString();
  String _descriptionOf(Map<String, dynamic> row) =>
      (row['description'] ?? row['bio'] ?? row['about'] ?? '').toString();
  String _logoOf(Map<String, dynamic> row) =>
      (row['logo'] ?? row['profile_pic'] ?? row['image'] ?? '').toString();
  String _dateOf(Map<String, dynamic> row) =>
      (row['created_date'] ?? row['created_at'] ?? '').toString();
  String _vendorIdOf(Map<String, dynamic> row) => (row['vendor_id'] ?? '').toString();
  String _membersOf(Map<String, dynamic> row) {
    final m = row['members_count'] ?? row['members'] ?? row['member_count'];
    if (m == null) return '';
    return '$m Members';
  }

  // ---------------------------------------------------------------------
  // 1. FETCH PENDING + APPROVED COMMUNITIES
  // ---------------------------------------------------------------------
  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final db = Database();
      final vendorId = await UserSessionSet.instance.vendorId;

      final pendingRes = await db.getJsonData(
        {
          "action": "fetch_pending_communities",
          "vendor_id": vendorId,
        },
        endpoint: _communityEndpoint,
      );

      final approvedRes = await db.getJsonData(
        {
          "action": "fetch_approve_communities",
          "vendor_id": vendorId,
        },
        endpoint: _communityEndpoint,
      );

      if (!mounted) return;

      final pendingOk = pendingRes['success'] == true || pendingRes['status'] == 200 || pendingRes.containsKey('data');
      final approvedOk = approvedRes['success'] == true || approvedRes['status'] == 200 || approvedRes.containsKey('data');

      setState(() {
        _pending = pendingOk
            ? List<Map<String, dynamic>>.from(
            (pendingRes['data'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)))
            : [];
        _active = approvedOk
            ? List<Map<String, dynamic>>.from(
            (approvedRes['data'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)))
            : [];
        _filteredActive = _active;
        _loading = false;
        _loadError = (!pendingOk && !approvedOk)
            ? ((pendingRes['message'] ?? approvedRes['message'])?.toString() ?? 'Failed to load communities')
            : null;
      });
    } catch (e) {
      debugPrint("Error loading communities: $e");
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = "Network error: ${e.toString()}";
      });
    }
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredActive = query.isEmpty
          ? _active
          : _active.where((c) => _titleOf(c).toLowerCase().contains(query)).toList();
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 2. APPROVE / DISAPPROVE A PENDING REGISTRATION
  // ---------------------------------------------------------------------
  Future<void> _handleReviewSubmit({
    required String communityId,
    required bool isApprove,
    required String note,
  }) async {
    setState(() => _busyIds.add(communityId));

    try {
      final db = Database();
      final vendorId = await UserSessionSet.instance.vendorId;

      final res = await db.getJsonData(
        {
          "action": "update_community_status",
          "vendor_id": vendorId,
          "community_id": communityId,
          "status": isApprove ? 1 : 2,
          "message": note,
        },
        endpoint: _communityEndpoint,
      );

      if (!mounted) return;
      setState(() => _busyIds.remove(communityId));

      final ok = res['success'] == true || res['status'] == 200;
      _showSnack(res['message']?.toString() ?? (ok ? 'Done' : 'Something went wrong'), isError: !ok);

      if (ok) _loadAll();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyIds.remove(communityId));
      _showSnack("Network error: ${e.toString()}", isError: true);
    }
  }

  // ---------------------------------------------------------------------
  // 3. BLOCK / FEATURE / PROMOTE / SPONSOR AN ACTIVE COMMUNITY
  // ---------------------------------------------------------------------
  Future<void> _handleActiveAction({
    required String communityId,
    required String actionType,
  }) async {
    setState(() => _busyIds.add(communityId));

    try {
      final db = Database();
      final vendorId = await UserSessionSet.instance.vendorId;

      final res = await db.getJsonData(
        {
          "action": "manage_active_community",
          "vendor_id": vendorId,
          "community_id": communityId,
          "action_type": actionType,
          "message": "",
        },
        endpoint: _communityEndpoint,
      );

      if (!mounted) return;
      setState(() => _busyIds.remove(communityId));

      final ok = res['success'] == true || res['status'] == 200;
      _showSnack(res['message']?.toString() ?? (ok ? 'Done' : 'Something went wrong'), isError: !ok);

      if (ok) _loadAll();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyIds.remove(communityId));
      _showSnack("Network error: ${e.toString()}", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCommunityScreen(),));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        color: AppColors.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loadError != null) _buildErrorBanner(_loadError!),
              _buildPendingSection(),
              const SizedBox(height: 24),
              _buildActiveSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
            TextButton(onPressed: _loadAll, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  // --- Pending Approvals Section ---
  Widget _buildPendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Text(
                'Pending Registrations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_pending.length})',
                style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_pending.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'No pending registrations right now.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          )
        else
          SizedBox(
            // NOTE: was 180 — bumped, and the card body below switched to
            // flexible sizing so long titles/descriptions can't push the
            // footer past the bottom edge anymore.
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _pending.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) => _buildPendingCard(_pending[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> community) {
    final communityId = _idOf(community);
    final title = _titleOf(community);
    final description = _descriptionOf(community);
    final date = _dateOf(community);
    final logoUrl = _logoOf(community);
    final isBusy = _busyIds.contains(communityId);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLowContrast),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        image: logoUrl.isNotEmpty
                            ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: logoUrl.isEmpty
                          ? const Icon(Icons.groups_outlined, color: AppColors.onSurfaceVariant, size: 20)
                          : null,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StatusDot(color: AppColors.negotiationAmber),
                            SizedBox(width: 4),
                            Text(
                              'UNDER REVIEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.negotiationAmber,
                              ),
                            ),
                          ],
                        ),
                        if (date.isNotEmpty)
                          Text(date, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                // CHANGED: Expanded instead of a fixed 2-line block + Spacer.
                // This is what previously overflowed — the description could
                // need more room than the card had left once the footer was
                // accounted for. Expanded just takes whatever remains.
                Expanded(
                  child: Text(
                    description.isNotEmpty ? description : 'No description provided.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ),
                const Divider(height: 1, color: AppColors.surfaceContainer),
                Align(
                  alignment: Alignment.centerRight,
                  child: isBusy
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                      : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
                    onSelected: (value) {
                      if (value == 'approve') {
                        _showReviewModal(communityId, title, isApprove: true);
                      } else if (value == 'disapprove') {
                        _showReviewModal(communityId, title, isApprove: false);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'approve', child: Text('Approve')),
                      const PopupMenuItem(
                        value: 'disapprove',
                        child: Text('Disapprove', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Active Communities Section ---
  Widget _buildActiveSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Communities',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search communities...',
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLowContrast),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLowContrast),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_filteredActive.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  _active.isEmpty ? 'No active communities yet.' : 'No matches for that search.',
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredActive.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildActiveCard(_filteredActive[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveCard(Map<String, dynamic> community) {
    final communityId = _idOf(community);
    final title = _titleOf(community);
    final vendorId = _vendorIdOf(community);
    final members = _membersOf(community);
    final logoUrl = _logoOf(community);
    final label = (community['label'] ?? '').toString();
    final isBusy = _busyIds.contains(communityId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLowContrast),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLowContrast),
                  image: logoUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: logoUrl.isEmpty
                    ? const Icon(Icons.groups_outlined, color: AppColors.onSurfaceVariant)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface),
                          ),
                        ),
                        if (vendorId.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'VID: $vendorId',
                              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                        if (label.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              label.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const _StatusDot(color: AppColors.primary),
                        const SizedBox(width: 6),
                        const Text('Active', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        if (members.isNotEmpty) ...[
                          const Text(' • ', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          Flexible(
                            child: Text(
                              members,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLowContrast),
          const SizedBox(height: 8),
          if (isBusy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else
          // CHANGED: wrapped in a horizontally-scrollable row instead of a
          // bare Row(mainAxisAlignment: end). Six icon buttons + a divider
          // sits right on the edge of most phone widths — any device
          // slightly narrower than the design, or a larger system font,
          // pushed this past the right edge. A SingleChildScrollView
          // guarantees it can never overflow.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.campaign_outlined, color: AppColors.onSurfaceVariant),
                    onPressed: () => _confirmActiveAction(
                      communityId: communityId,
                      actionType: 'promote',
                      prompt: 'Promote $title?',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.star_outline, color: AppColors.onSurfaceVariant),
                    onPressed: () => _confirmActiveAction(
                      communityId: communityId,
                      actionType: 'feature',
                      prompt: 'Feature $title?',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.monetization_on_outlined, color: AppColors.onSurfaceVariant),
                    onPressed: () => _confirmActiveAction(
                      communityId: communityId,
                      actionType: 'sponsor',
                      prompt: 'Mark $title as Sponsored?',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_outlined, color: AppColors.onSurfaceVariant),
                    onPressed: () => _showChatModal(communityId, title),
                  ),
                  Container(width: 1, height: 24, color: AppColors.borderLowContrast),
                  IconButton(
                    icon: const Icon(Icons.block, color: AppColors.error),
                    onPressed: () => _confirmActiveAction(
                      communityId: communityId,
                      actionType: 'block',
                      prompt: 'Block $title?',
                      isDestructive: true,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- Interactive Sheet & Dialog Callouts ---
  void _showReviewModal(String communityId, String title, {required bool isApprove}) {
    final noteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isApprove ? 'Approve Registration' : 'Disapprove Registration',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(sheetContext),
                )
              ],
            ),
            Text(
              'Please provide an administrative comment regarding this action for $title.',
              style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter notes...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApprove ? AppColors.primary : AppColors.error,
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _handleReviewSubmit(
                      communityId: communityId,
                      isApprove: isApprove,
                      note: noteController.text.trim(),
                    );
                  },
                  child: Text(
                    isApprove ? 'Approve' : 'Disapprove',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _confirmActiveAction({
    required String communityId,
    required String actionType,
    required String prompt,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text(prompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleActiveAction(communityId: communityId, actionType: actionType);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showChatModal(String communityId, String title) {
    final messageController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _CommunityChatSheet(
        communityId: communityId,
        title: title,
        messageController: messageController,
        onSnack: _showSnack,
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Chat sheet is its own StatefulWidget so it can load + refresh the
/// thread independently of the parent screen's rebuilds. Calls
/// Database().getJsonData(...) directly, same pattern as the rest of
/// this screen and PaymentScreen.
class _CommunityChatSheet extends StatefulWidget {
  final String communityId;
  final String title;
  final TextEditingController messageController;
  final void Function(String message, {bool isError}) onSnack;

  const _CommunityChatSheet({
    required this.communityId,
    required this.title,
    required this.messageController,
    required this.onSnack,
  });

  @override
  State<_CommunityChatSheet> createState() => _CommunityChatSheetState();
}

class _CommunityChatSheetState extends State<_CommunityChatSheet> {
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);

    try {
      final db = Database();
      final vendorId = await UserSessionSet.instance.vendorId;

      final res = await db.getJsonData(
        {
          "action": "community_chat",
          "vendor_id": vendorId,
          "community_id": widget.communityId,
        },
        endpoint: _communityEndpoint,
      );

      if (!mounted) return;

      final ok = res['success'] == true || res['status'] == 200 || res.containsKey('data');
      setState(() {
        _messages = ok
            ? List<Map<String, dynamic>>.from(
            (res['data'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)))
            : [];
        _loading = false;
      });

      if (!ok) {
        widget.onSnack(res['message']?.toString() ?? 'Failed to load chat', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      widget.onSnack("Network error: ${e.toString()}", isError: true);
    }
  }

  Future<void> _send() async {
    final text = widget.messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final db = Database();
      final vendorId = await UserSessionSet.instance.vendorId;

      final res = await db.getJsonData(
        {
          "action": "send_community_message",
          "vendor_id": vendorId,
          "community_id": widget.communityId,
          "message": text,
        },
        endpoint: _communityEndpoint,
      );

      if (!mounted) return;
      setState(() => _sending = false);

      final ok = res['success'] == true || res['status'] == 200;
      if (ok) {
        widget.messageController.clear();
        _loadMessages();
      } else {
        widget.onSnack(res['message']?.toString() ?? 'Failed to send message', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      widget.onSnack("Network error: ${e.toString()}", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          ListTile(
            title: Text('Chat with ${widget.title}'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _messages.isEmpty
                ? const Center(
              child: Text('No messages yet.', style: TextStyle(color: AppColors.onSurfaceVariant)),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMine = (msg['sender']?.toString() ?? '') !=
                    (msg['receiver']?.toString() ?? ''); // best-effort; adjust to your own "me" check
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMine ? AppColors.primaryContainer : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (msg['message'] ?? '').toString(),
                      style: TextStyle(color: isMine ? Colors.white : AppColors.onSurface),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: _sending
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                      : const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sending ? null : _send,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}