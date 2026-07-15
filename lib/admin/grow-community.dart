import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SereneCorporateApp extends StatelessWidget {
  const SereneCorporateApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact Material 3 Color Schema mapped directly from your Tailwind tokens
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
      surfaceVariant: const Color(0xFFE2E2E2),
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
      home: const GrowCommunityScreen(),
    );
  }
}

class GrowCommunityScreen extends StatefulWidget {
  const GrowCommunityScreen({super.key});

  @override
  State<GrowCommunityScreen> createState() => _GrowCommunityScreenState();
}

class _GrowCommunityScreenState extends State<GrowCommunityScreen> {
  final TextEditingController _inviteController = TextEditingController();

  // Local states mimicking the JavaScript interaction logic
  final Map<int, bool> _invitedContacts = {0: false, 1: false, 2: false};

  void _showToast(String message) {
    final theme = Theme.of(context);
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
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.only(bottom: 24, left: 40, right: 40),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: theme.colorScheme.primary,
          onPressed: () {},
        ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          final sidePadding = isDesktop ? 40.0 : 16.0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Layout Block
                Container(
                  color: const Color(0xFFF4F3F3), // surface-container-low
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
                                      const TextSpan(text: 'Invite your network to join '),
                                      TextSpan(
                                        text: 'Executive Strategy Hub',
                                        style: TextStyle(color: theme.colorScheme.primary),
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

                // Core Form Actions & Suggested Modules Grid
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
    );
  }

  Widget _buildShareLinkCard(ThemeData theme, bool isDesktop) {
    const linkText = 'serene.corp/join/exec-strat-hub-2024';

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
                    Text(
                      'Community Join Link',
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
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
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    linkText,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                                  ),
                                ),
                                Icon(Icons.link, color: Color(0xFFBDC9C8)),
                              ],
                            ),
                          ),
                        ),
                        if (!isDesktop) const SizedBox(height: 12),
                        if (isDesktop) const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: linkText));
                            _showToast('Link copied to clipboard');
                          },
                          icon: const Icon(Icons.content_copy, size: 18),
                          label: const Text('COPY LINK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            _buildSocialCircleButton(Icons.chat_bubble_outline), // Simulating WhatsApp fallback
            const SizedBox(width: 16),
            _buildSocialCircleButton(Icons.business_center_outlined), // Simulating LinkedIn fallback
            const SizedBox(width: 16),
            _buildSocialCircleButton(Icons.alternate_email), // Simulating Twitter fallback
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
        onPressed: () => _showToast('Opening share handler...'),
      ),
    );
  }

  Widget _buildReferralStatsSlider(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildStatCard(
              theme,
              'INVITES SENT',
              '142',
              bottomWidget: const Row(
                children: [
                  Icon(Icons.trending_up, color: Color(0xFF15803D), size: 16),
                  SizedBox(width: 4),
                  Text('+12%', style: TextStyle(color: Color(0xFF15803D), fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              )
          ),
          const SizedBox(width: 16),
          _buildStatCard(
              theme,
              'PENDING',
              '28',
              bottomWidget: const Text('Active focus', style: TextStyle(color: Color(0xFF3E4949), fontSize: 14))
          ),
          const SizedBox(width: 16),
          _buildStatCard(
              theme,
              'JOINED',
              '114',
              isPrimaryValue: true,
              bottomWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF008080).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('80% CONV.', style: TextStyle(color: Color(0xFF008080), fontSize: 10, fontWeight: FontWeight.bold)),
              )
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
                  color: isPrimaryValue ? theme.colorScheme.primary : theme.colorScheme.onSurface
              )
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
        color: const Color(0xFFE8E8E8).withOpacity(0.3), // surface-container-high 30%
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_inviteController.text.isNotEmpty) {
                  _showToast('Invite sent successfully to ${_inviteController.text}');
                  _inviteController.clear();
                } else {
                  _showToast('Invite sent successfully');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildContactItem(theme, 0, 'Sarah Jenkins', 'VP of Operations @ Zenith', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150'),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              _buildContactItem(theme, 1, 'David Chen', 'Strategic Advisor', 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150'),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              _buildContactItem(theme, 2, 'Elena Rossi', 'Head of Growth @ Neura', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildContactItem(ThemeData theme, int index, String name, String role, String avatarUrl) {
    final isInvited = _invitedContacts[index] ?? false;

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
              image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(role, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isInvited
                ? null
                : () {
              setState(() {
                _invitedContacts[index] = true;
              });
              _showToast('Invite sent to ${name.split(' ')[0]}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isInvited ? const Color(0xFFEEEEED) : theme.colorScheme.primary,
              foregroundColor: isInvited ? const Color(0xFF3E4949) : theme.colorScheme.onPrimary,
              disabledBackgroundColor: const Color(0xFFEEEEED),
              disabledForegroundColor: const Color(0xFF3E4949),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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