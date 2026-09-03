import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

const String _endpoint = 'new_apis/grow_community_api.php';

class GrowCommunity extends StatelessWidget {
  const GrowCommunity({super.key});

  @override
  Widget build(BuildContext context) {
    final customColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF006565),
      primary: const Color(0xFF006565),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF008080),
      onPrimaryContainer: const Color(0xFFE3FFFE),
      secondary: const Color(0xFF296767),
      secondaryContainer: const Color(0xFFB0EEED),
      onSecondaryContainer: const Color(0xFF306E6D),
      surface: const Color(0xFFF9F9F9),
      onSurface: const Color(0xFF1A1C1C),
      surfaceContainerHighest: const Color(0xFFE2E2E2),
      onSurfaceVariant: const Color(0xFF3E4949),
      outline: const Color(0xFF6E7979),
      outlineVariant: const Color(0xFFBDC9C8),
      error: const Color(0xFFBA1A1A),
      inverseSurface: const Color(0xFF2F3131),
      onInverseSurface: const Color(0xFFF1F1F0),
    );

    return MaterialApp(
      title: 'Serene Corporate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: customColorScheme,
        scaffoldBackgroundColor: customColorScheme.surface,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 18),
          bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16),
          bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
      ),
      home: const GrowCommunityScreen(
        communityId: 0,
        communityTitle: 'Your Community',
      ),
    );
  }
}

class GrowCommunityScreen extends StatefulWidget {
  final int communityId;
  final String communityTitle;

  const GrowCommunityScreen({
    super.key,
    required this.communityId,
    required this.communityTitle,
  });

  @override
  State<GrowCommunityScreen> createState() => _GrowCommunityScreenState();
}

class _GrowCommunityScreenState extends State<GrowCommunityScreen> {
  final TextEditingController _inviteController = TextEditingController();
  Timer? _debounce;

  int get _myVendorId =>
      int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

  bool _isLoadingLink = false;
  String? _linkError;
  String? _joinLink;

  bool _isLoadingStats = false;
  int _sent = 0, _pending = 0, _joined = 0;

  bool _isLoadingUsers = false;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _suggested = [];
  List<Map<String, dynamic>> _searchMatches = [];

  final Map<int, bool> _invitedContacts = {};

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _inviteController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _inviteController.removeListener(_onSearchChanged);
    _inviteController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchJoinLink(),
      _fetchStats(),
      _fetchUsers(),
    ]);
  }

  void _showToast(String message) {
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF93F2F2)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchJoinLink() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLink = true;
      _linkError = null;
    });

    try {
      final response = await Database().getData({
        'action': 'share_invite_link',
        'vendor_id': _myVendorId,
        'community_id': widget.communityId,
        'validity_days': 10,
        'id':8,
      }, endpoint: _endpoint);

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        setState(() {
          _joinLink = response['data']?['invite_link']?.toString();
          _isLoadingLink = false;
        });
      } else {
        setState(() {
          _linkError = response?['message']?.toString() ?? 'Could not load link';
          _isLoadingLink = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _linkError = 'Could not load link: $e';
        _isLoadingLink = false;
      });
    }
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);

    try {
      final response = await Database().getData({
        'action': 'fetch_shared_invites_admin',
        'vendor_id': _myVendorId,
        'id':8,

      }, endpoint: _endpoint);

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        final List<dynamic> communities = response['data'] is List ? response['data'] : [];
        final match = communities.firstWhere(
              (c) => c['community_id'].toString() == widget.communityId.toString(),
          orElse: () => null,
        );

        if (match == null) {
          setState(() {
            _sent = 0;
            _pending = 0;
            _joined = 0;
            _isLoadingStats = false;
          });
        } else {
          final List<dynamic> invites = match['invites'] is List ? match['invites'] : [];
          setState(() {
            _sent = (match['share_count'] as int?) ?? invites.length;
            _pending = invites.where((i) => i['status'] == 'Invited').length;
            _joined = invites.where((i) => i['status'] == 'Accepted').length;
            _isLoadingStats = false;
          });
        }
      } else {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoadingUsers = true);

    try {
      final response = await Database().getData({
        'action': 'get_users_list',
        'vendor_id': _myVendorId,
        'id':8,

      }, endpoint: _endpoint);

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        final data = response['data'] ?? {};
        final List<dynamic> general = data['general_users'] is List ? data['general_users'] : [];
        final List<dynamic> business = data['business_users'] is List ? data['business_users'] : [];
        final all = [...general, ...business].cast<Map<String, dynamic>>().toList();

        final candidates = all.where((u) {
          final id = int.tryParse(u['id']?.toString() ?? '0') ?? 0;
          if (id == _myVendorId) return false;
          final List<dynamic> communityList = u['community_list'] is List ? u['community_list'] : [];
          final alreadyMember = communityList.any(
                (c) => c['group_id']?.toString() == widget.communityId.toString(),
          );
          return !alreadyMember;
        }).toList();

        setState(() {
          _allUsers = all;
          _suggested = candidates.take(3).toList();
          _isLoadingUsers = false;
        });
      } else {
        setState(() => _isLoadingUsers = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  void _onSearchChanged() {
    final query = _inviteController.text.trim().toLowerCase();
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() => _searchMatches = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _searchMatches = _allUsers.where((u) {
          final id = int.tryParse(u['id']?.toString() ?? '0') ?? 0;
          if (id == _myVendorId) return false;
          final name = (u['name']?.toString() ?? '').toLowerCase();
          final email = (u['email']?.toString() ?? '').toLowerCase();
          return name.contains(query) || email.contains(query);
        }).take(5).toList();
      });
    });
  }

  Future<void> _sendInviteTo(Map<String, dynamic> user) async {
    final vendorId = int.tryParse(user['id']?.toString() ?? '0') ?? 0;
    if (vendorId == 0) return;

    try {
      final response = await Database().getData({
        'action': 'generate_invite_link',
        'vendor_id': _myVendorId,
        'community_id': widget.communityId,
        'invite_vendor_id': vendorId,
        'validity_days': 10,
        'id':8,

      }, endpoint: _endpoint);

      if (!mounted) return;

      final success = response != null && response['success'] == true;
      final msg = response?['message']?.toString() ??
          (success ? 'Invite sent successfully' : 'Failed to send invite');

      if (success) {
        setState(() {
          _invitedContacts[vendorId] = true;
          _suggested = _suggested.where((u) => u['id']?.toString() != user['id']?.toString()).toList();
        });
        _fetchStats();
      }
      _showToast(msg);
    } catch (e) {
      _showToast('Failed to send invite. Please try again.');
    }
  }

  Future<void> _sendDirectInvite() async {
    final text = _inviteController.text.trim();
    if (text.isEmpty) return;

    Map<String, dynamic>? match;
    if (_searchMatches.isNotEmpty) {
      match = _searchMatches.first;
    } else {
      final lower = text.toLowerCase();
      for (final u in _allUsers) {
        final name = (u['name']?.toString() ?? '').toLowerCase();
        final email = (u['email']?.toString() ?? '').toLowerCase();
        if (name == lower || email == lower) {
          match = u;
          break;
        }
      }
    }

    if (match == null) {
      _showToast('No matching user found for "$text"');
      return;
    }

    await _sendInviteTo(match);
    _inviteController.clear();
    setState(() => _searchMatches = []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.colorScheme.primary,
          onPressed: () => Navigator.of(context).pop(),
        )
            : null,
        title: Text(
          'Grow Community',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: theme.colorScheme.primary,
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.colorScheme.outlineVariant, height: 1),
        ),
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: _fetchAllData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            final sidePadding = isDesktop ? 40.0 : 16.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFFF4F3F3),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Flex(
                          direction: isDesktop ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: isDesktop ? 2 : 0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: theme.textTheme.headlineLarge?.copyWith(
                                        fontSize: isDesktop ? 40 : 28,
                                        color: theme.colorScheme.onSurface,
                                        height: 1.2,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Invite your network to join ',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        TextSpan(
                                          text: widget.communityTitle,
                                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Shape the future of our professional community. Invite visionary leaders and strategic minds to share insights and foster collective growth.',
                                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            if (!isDesktop) const SizedBox(height: 24),
                            if (isDesktop) const SizedBox(width: 32),
                            Expanded(
                              flex: isDesktop ? 1 : 0,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ColorFiltered(
                                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                        child: Opacity(
                                          opacity: 0.4,
                                          child: Image.network(
                                            'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Container(color: theme.colorScheme.primary.withOpacity(0.1)),
                                      Center(
                                        child: Icon(
                                          Icons.group_add,
                                          size: 48,
                                          color: theme.colorScheme.primary,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShareLinkCard(theme, isDesktop),
                          const SizedBox(height: 32),
                          _buildSocialQuickShareRow(theme),
                          const SizedBox(height: 32),
                          _buildReferralStatsSlider(theme),
                          const SizedBox(height: 32),
                          _buildDirectInviteForm(theme),
                          const SizedBox(height: 40),
                          _buildSuggestedContactsList(theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShareLinkCard(ThemeData theme, bool isDesktop) {
    final linkText = _isLoadingLink
        ? 'Generating your link…'
        : (_linkError != null ? _linkError! : (_joinLink ?? ''));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: theme.colorScheme.primaryContainer),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Community Join Link',
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
                        ),
                        if (_linkError != null)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: _fetchJoinLink,
                            tooltip: 'Retry',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flex(
                      direction: isDesktop ? Axis.horizontal : Axis.vertical,
                      children: [
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F3F3),
                              border: Border.all(color: theme.colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    linkText,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                                  ),
                                ),
                                const Icon(Icons.link, color: Color(0xFFBDC9C8)),
                              ],
                            ),
                          ),
                        ),
                        if (!isDesktop) const SizedBox(height: 12),
                        if (isDesktop) const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: (_isLoadingLink || _joinLink == null)
                              ? null
                              : () {
                            Clipboard.setData(ClipboardData(text: _joinLink!));
                            _showToast('Link copied to clipboard');
                          },
                          icon: const Icon(Icons.content_copy, size: 18),
                          label: const Text('COPY LINK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialQuickShareRow(ThemeData theme) {
    return Column(
      children: [
        const Center(
          child: Text(
            'QUICK SHARE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Color(0xFF3E4949)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialCircleButton(Icons.chat_bubble_outline),
            const SizedBox(width: 16),
            _buildSocialCircleButton(Icons.business_center_outlined),
            const SizedBox(width: 16),
            _buildSocialCircleButton(Icons.alternate_email),
            const SizedBox(width: 16),
            _buildSocialCircleButton(Icons.mail_outline, isNativeIcon: true, theme: theme),
          ],
        )
      ],
    );
  }

  Widget _buildSocialCircleButton(IconData icon, {bool isNativeIcon = false, ThemeData? theme}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: isNativeIcon ? theme?.colorScheme.primary : const Color(0xFF6E7979),
        onPressed: () {
          if (_joinLink == null) {
            _showToast('Link not ready yet');
            return;
          }
          Clipboard.setData(ClipboardData(text: _joinLink!));
          _showToast('Link copied — paste it to share');
        },
      ),
    );
  }

  Widget _buildReferralStatsSlider(ThemeData theme) {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF006565))),
      );
    }
    final total = _sent == 0 ? 1 : _sent;
    final convPct = ((_joined / total) * 100).round();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatCard(
            theme,
            'INVITES SENT',
            '$_sent',
            bottomWidget: const Text('Total shares', style: TextStyle(color: Color(0xFF3E4949), fontSize: 14)),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            theme,
            'PENDING',
            '$_pending',
            bottomWidget: const Text('Awaiting response', style: TextStyle(color: Color(0xFF3E4949), fontSize: 14)),
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            theme,
            'JOINED',
            '$_joined',
            isPrimaryValue: true,
            bottomWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF008080).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('$convPct% CONV.', style: const TextStyle(color: Color(0xFF008080), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String counter, {required Widget bottomWidget, bool isPrimaryValue = false}) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3E4949), letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(
            counter,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 28,
              color: isPrimaryValue ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _buildDirectInviteForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Direct Invite', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _inviteController,
            decoration: InputDecoration(
              hintText: 'Enter Email or Name...',
              prefixIcon: const Icon(Icons.person_search, color: Color(0xFF6E7979)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
          ),
          if (_searchMatches.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: _searchMatches.map((u) {
                  final name = u['name']?.toString() ?? '';
                  final email = u['email']?.toString() ?? '';
                  return Material(
                    color: Colors.white,
                    child: ListTile(
                      dense: true,
                      title: Text(name.isNotEmpty ? name : email),
                      subtitle: Text(email),
                      onTap: () {
                        _inviteController.text = name.isNotEmpty ? name : email;
                        setState(() => _searchMatches = [u]);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoadingUsers ? null : _sendDirectInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('SEND INVITE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSuggestedContactsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Suggested Members', style: theme.textTheme.titleMedium),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
              child: const Text('VIEW ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingUsers)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF006565))),
          )
        else if (_suggested.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
            ),
            child: Text(
              'No suggestions right now.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < _suggested.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  _buildContactItem(theme, _suggested[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContactItem(ThemeData theme, Map<String, dynamic> user) {
    final vendorId = int.tryParse(user['id']?.toString() ?? '0') ?? 0;
    final isInvited = _invitedContacts[vendorId] ?? false;
    final name = user['name']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final displayName = name.isNotEmpty ? name : email;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3E4949)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(email, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isInvited ? null : () => _sendInviteTo(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: isInvited ? const Color(0xFFEEEEED) : theme.colorScheme.primary,
              foregroundColor: isInvited ? const Color(0xFF3E4949) : theme.colorScheme.onPrimary,
              disabledBackgroundColor: const Color(0xFFEEEEED),
              disabledForegroundColor: const Color(0xFF3E4949),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              isInvited ? 'INVITED' : 'INVITE',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}