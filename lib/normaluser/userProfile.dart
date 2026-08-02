import 'dart:ui';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────
class _T {
  static const primary = Color(0xFF0F6659); // deep teal
  static const primaryLight = Color(0xFF17A398); // gradient end
  static const accent = Color(0xFFFF6B4A); // single warm highlight
  static const bg = Color(0xFFF6F5F1); // ivory
  static const surface = Colors.white;
  static const ink = Color(0xFF1C2521);
  static const muted = Color(0xFF6B7570);
  static const border = Color(0xFFE7E4DA);
  static const display = 'Manrope';
}

class MemberProfileScreen extends StatefulWidget {
  final VoidCallback onMenuPressed;

  const MemberProfileScreen({super.key, required this.onMenuPressed});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  int _currentBottomNavIndex = 3; // kept for shared bottom nav highlighting
  int _selectedTab = 0; // 0 Overview · 1 Activity · 2 Settings

  String _profileName = "Marcus Chen";
  String _profileTitle = "Senior Product Strategist";
  String _profileLocation = "San Francisco, CA";
  String _profileBio =
      "Accomplished Product Strategist with over 10 years of experience in the ecommerce sector. Specialist in bridging the gap between user experience and business profitability. Marcus has successfully led cross-functional teams to launch marketplace solutions for Fortune 500 companies. His approach combines deep data empathy with a rigorous market analysis framework to drive sustainable growth.";
  List<String> _expertise = ["E-COMMERCE", "UX STRATEGY", "MARKET ANALYSIS", "RETENTION", "SaaS"];

  // ── Modals ────────────────────────────────────────────────────────────
  void _showEditProfileModal() {
    final nameController = TextEditingController(text: _profileName);
    final bioController = TextEditingController(text: _profileBio);
    final expertiseController = TextEditingController(text: _expertise.join(', '));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _ModalShell(
          title: 'Edit Profile',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalTextField(label: 'Full Name', controller: nameController),
              _buildModalTextField(label: 'Bio', controller: bioController, maxLines: 4),
              _buildModalTextField(label: 'Expertise', controller: expertiseController),
              const SizedBox(height: 8),
              _PrimaryButton(
                label: 'Save Changes',
                onPressed: () {
                  setState(() {
                    _profileName = nameController.text;
                    _profileBio = bioController.text;
                    _expertise = expertiseController.text
                        .split(',')
                        .map((s) => s.trim().toUpperCase())
                        .where((s) => s.isNotEmpty)
                        .toList();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOtpVerificationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModalShell(
        title: 'Verification Required',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the 6-digit code sent to your registered mobile number to proceed.',
              style: TextStyle(color: _T.muted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpBox()),
            ),
            const SizedBox(height: 24),
            _PrimaryButton(label: 'Verify & Continue', onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Resend Code',
                    style: TextStyle(color: _T.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTextField({required String label, required TextEditingController controller, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(color: _T.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: _T.ink, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: _T.bg,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.transparent)),
              focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _T.primary, width: 1.4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox() {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _T.ink),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: _T.bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _T.primary, width: 1.6)),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: widget.onMenuPressed, // opens the shared drawer
        ),
        title: Text(
          'My Profie',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  children: [
                    _buildIdentityBlock(),
                    const SizedBox(height: 40),
                    _buildStatsRow(isDesktop),
                    // const SizedBox(height: 22),
                    _buildSegmentedControl(),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTabContent(isDesktop),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Normal App Bar ──────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _T.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: widget.onMenuPressed,
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: _T.display,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Avatar + name ────────────────────────────────────────────────────
  Widget _buildIdentityBlock() {
    return Transform.translate(
      offset: const Offset(0, 10),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 108,
                height: 108,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_T.primaryLight, _T.accent]),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: _T.surface),
                  child: const ClipOval(
                    child: Image(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDJ9blqQXZyEj-fIn77w0EVBdB7EPv5sxV9wDaNX9UG1Ik-b0ZIHBI2Vt54tQIMQBrZGddU4OTbloGftRoumkLrV9nnVVMBo8GJzmwokMBarwimkoA_-q4oL42N5g48NG3e1LK5BgyEuWvJwj2oyW_pggRWOaHSz67VKrqH_18LggS57bubIyzwbjpZWKQum2JaExYW5xig2fR8WmXDsf4dbqqx7migV2bf2vg7yZJXdUFmca37LYvj'),
                      fit: BoxFit.cover,
                      width: 108,
                      height: 108,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _T.surface,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.verified_rounded, color: _T.primary, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(_profileName, style: const TextStyle(fontFamily: _T.display, fontSize: 22, fontWeight: FontWeight.w800, color: _T.ink)),
          const SizedBox(height: 2),
          Text(_profileTitle, style: const TextStyle(color: _T.primary, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: _T.muted),
              const SizedBox(width: 3),
              Text(_profileLocation, style: const TextStyle(color: _T.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: _PrimaryButton(label: 'Connect', icon: Icons.person_add_alt_1_rounded, onPressed: () {}, compact: true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OutlineButton(label: 'Message', icon: Icons.mail_outline_rounded, onPressed: () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating glass stats row ────────────────────────────────────────
  Widget _buildStatsRow(bool isDesktop) {
    final stats = const [
      ('POSTS', '124', Icons.article_rounded),
      ('FOLLOWERS', '1.2k', Icons.groups_rounded),
      ('FOLLOWING', '850', Icons.person_search_rounded),
      ('REPUTATION', '4.8k', Icons.emoji_events_rounded),
      ('PARTNERS', '12', Icons.handshake_rounded),
    ];

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.6)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: stats
                      .map((s) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Icon(s.$3, size: 18, color: _T.primary),
                        const SizedBox(height: 4),
                        Text(s.$2,
                            style: const TextStyle(
                                fontFamily: _T.display, fontSize: 17, fontWeight: FontWeight.w800, color: _T.ink)),
                        Text(s.$1, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _T.muted, letterSpacing: 0.4)),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Segmented control ───────────────────────────────────────────────
  Widget _buildSegmentedControl() {
    const labels = ['Overview', 'Activity', 'Settings'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: _T.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)),
        child: Row(
          children: List.generate(labels.length, (i) {
            final selected = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? _T.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: selected ? Colors.white : _T.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent(bool isDesktop) {
    switch (_selectedTab) {
      case 1:
        return _buildActivityTab();
      case 2:
        return _buildSettingsTab();
      default:
        return _buildOverviewTab(isDesktop);
    }
  }

  // ── Overview tab ─────────────────────────────────────────────────────
  Widget _buildOverviewTab(bool isDesktop) {
    return Column(
      children: [
        _SectionCard(
          title: 'Professional Summary',
          child: Text(_profileBio, style: const TextStyle(color: _T.muted, fontSize: 14, height: 1.6)),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Expertise',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _expertise
                .map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_T.primary.withOpacity(0.08), _T.primaryLight.withOpacity(0.08)]),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _T.primary.withOpacity(0.18)),
              ),
              child: Text(tag,
                  style: const TextStyle(color: _T.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Achievements',
          padded: false,
          child: SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildAchievementItem(
                  icon: Icons.verified_user_rounded,
                  color: _T.primary,
                  label: 'VERIFIED STRATEGIST',
                  onTap: _showEditProfileModal,
                ),
                const SizedBox(width: 12),
                _buildAchievementItem(
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFF6750A4),
                  label: 'TOP CONTRIBUTOR',
                  onTap: _showOtpVerificationModal,
                ),
                const SizedBox(width: 12),
                _buildAchievementItem(icon: Icons.workspace_premium_rounded, color: _T.accent, label: '5+ PARTNERSHIPS'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementItem({required IconData icon, required Color color, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 118,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.14)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }

  // ── Activity tab ─────────────────────────────────────────────────────
  Widget _buildActivityTab() {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Text('View All', style: TextStyle(color: _T.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: _T.primary),
                ],
              ),
            ),
          ],
        ),
        _buildContributionArticle(
          category: 'INSIGHT',
          catColor: _T.primary,
          date: 'Oct 24, 2023',
          title: 'Optimizing Checkout Conversion for High-AOV Luxury Goods',
          snippet:
          'Exploring the nuanced psychological triggers that drive multi-thousand dollar conversions in digital environments. Key focus on trust signals and financing UX...',
          likes: '421',
          comments: '56',
          shares: '12',
        ),
        const SizedBox(height: 14),
        _buildContributionArticle(
          category: 'TREND ANALYSIS',
          catColor: const Color(0xFF6750A4),
          date: 'Oct 12, 2023',
          title: 'The Shift Toward Headless Commerce: A 2024 Outlook',
          snippet:
          'As monolithic platforms struggle to keep pace with omnichannel demands, headless architectures are becoming the default for enterprise scale...',
          likes: '1.2k',
          comments: '89',
          shares: '45',
        ),
      ],
    );
  }

  Widget _buildContributionArticle({
    required String category,
    required Color catColor,
    required String date,
    required String title,
    required String snippet,
    required String likes,
    required String comments,
    required String shares,
  }) {
    return _SectionCard(
      title: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                child: Text(category, style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              Text(date, style: const TextStyle(color: _T.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(fontFamily: _T.display, fontSize: 16, fontWeight: FontWeight.w800, color: _T.ink),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(snippet, style: const TextStyle(color: _T.muted, fontSize: 13.5, height: 1.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: _T.border))),
            child: Row(
              children: [
                _buildArticleMetaIcon(Icons.favorite_rounded, likes, _T.accent),
                const SizedBox(width: 18),
                _buildArticleMetaIcon(Icons.chat_bubble_rounded, comments, _T.muted),
                const SizedBox(width: 18),
                _buildArticleMetaIcon(Icons.share_rounded, shares, _T.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleMetaIcon(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(color: _T.muted, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Settings tab ─────────────────────────────────────────────────────
  Widget _buildSettingsTab() {
    return Column(
      children: [
        _buildAccountActionRow(Icons.person_rounded, 'Edit Profile', 'Update name, bio, and expertise', onTap: _showEditProfileModal),
        const SizedBox(height: 10),
        _buildAccountActionRow(Icons.shield_rounded, 'Security', 'Change password & 2FA', onTap: _showOtpVerificationModal),
        const SizedBox(height: 10),
        _buildAccountActionRow(Icons.card_membership_rounded, 'Membership', 'View plan & upgrade'),
        const SizedBox(height: 10),
        _buildAccountActionRow(Icons.account_balance_wallet_rounded, 'Bank & Payments', 'Manage bank details & UPI'),
        const SizedBox(height: 10),
        _buildAccountActionRow(Icons.location_city_rounded, 'Addresses', 'Manage saved addresses'),
        const SizedBox(height: 10),
        _buildAccountActionRow(Icons.no_accounts_rounded, 'Deactivate Account', 'Permanently close account', isDestructive: true),
      ],
    );
  }

  Widget _buildAccountActionRow(IconData icon, String title, String subtitle, {VoidCallback? onTap, bool isDestructive = false}) {
    final color = isDestructive ? const Color(0xFFDC4B3E) : _T.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDestructive ? color.withOpacity(0.2) : _T.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: isDestructive ? color : _T.ink)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: _T.muted), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _T.muted.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SHARED PIECES
// ─────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool padded;

  const _SectionCard({required this.child, this.title, this.padded = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: padded ? const EdgeInsets.all(18) : const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padded ? 0 : 16),
              child: Text(title!, style: const TextStyle(fontFamily: _T.display, fontSize: 15, fontWeight: FontWeight.w800, color: _T.ink)),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool compact;

  const _PrimaryButton({required this.label, required this.onPressed, this.icon, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 42 : 48,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_T.primary, _T.primaryLight]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          icon: icon != null ? Icon(icon, size: 16, color: Colors.white) : const SizedBox.shrink(),
          label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: _T.primary,
          side: const BorderSide(color: _T.primary, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ModalShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _ModalShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontFamily: _T.display, fontSize: 20, fontWeight: FontWeight.w800, color: _T.ink)),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: _T.muted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}