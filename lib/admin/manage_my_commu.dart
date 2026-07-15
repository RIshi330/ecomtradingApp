import 'package:flutter/material.dart';


class CommunityIntelApp extends StatelessWidget {
  const CommunityIntelApp({super.key});

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
      surfaceVariant: const Color(0xFFE2E2E2),
      onSurfaceVariant: const Color(0xFF3E4949),
      outline: const Color(0xFF6E7979),
      outlineVariant: const Color(0xFFBDC9C8),
      error: const Color(0xFFBA1A1A),
      errorContainer: const Color(0xFFFFDAD6),
      inverseSurface: const Color(0xFF2F3131),
    );

    return MaterialApp(
      title: 'Community Intel',
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
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ScrollController _statsScrollController = ScrollController();
  final TextEditingController _deleteVerificationController = TextEditingController();

  void _showNotification(String message, {String type = 'default'}) {
    final theme = Theme.of(context);
    IconData icon = Icons.info_outline;
    Color iconColor = theme.colorScheme.primary;

    if (type == 'success') {
      icon = Icons.check_circle_outline;
      iconColor = const Color(0xFF15803D);
    } else if (type == 'error') {
      icon = Icons.error_outline;
      iconColor = theme.colorScheme.error;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _statsScrollController.dispose();
    _deleteVerificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: theme.colorScheme.primary,
            onPressed: () => _showNotification("Back action triggered"),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.analytics_outlined, color: theme.colorScheme.primary, size: 26),
            const SizedBox(width: 8),
            Text(
              'Community Intel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => _showNotification("No new system updates"),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: theme.colorScheme.error, shape: BoxShape.circle),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=80',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.colorScheme.outlineVariant.withOpacity(0.4), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalMetricsSection(theme),
            const SizedBox(height: 24),
            _buildPublishingHub(theme),
            const SizedBox(height: 24),
            _buildCommunityIdentity(theme),
            const SizedBox(height: 24),
            _buildAdministrativeOversight(theme),
            const SizedBox(height: 24),
            _buildModerationQueue(theme),
            const SizedBox(height: 24),
            _buildRevenueInventory(theme),
            const SizedBox(height: 24),
            _buildDangerZone(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalMetricsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Global Metrics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontFamily: 'Manrope',
                )
            ),
            Row(
              children: [
                _buildSliderNavButton(Icons.chevron_left, () {
                  _statsScrollController.animateTo(_statsScrollController.offset - 260, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                }),
                const SizedBox(width: 8),
                _buildSliderNavButton(Icons.chevron_right, () {
                  _statsScrollController.animateTo(_statsScrollController.offset + 260, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                }),
              ],
            )
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          controller: _statsScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildMetricCard(theme, 'TOTAL MEMBERS', '12,482', '4.2%', true, const Color(0xFF006565)),
              const SizedBox(width: 14),
              _buildMetricCard(theme, 'ACTIVE CAMPAIGNS', '24', '8 High-Priority', false, const Color(0xFF6750A4)),
              const SizedBox(width: 14),
              _buildMetricCard(theme, 'MONTHLY REVENUE', '¾4.2L', '8.1%', true, const Color(0xFFB45309)),
              const SizedBox(width: 14),
              _buildMetricCard(theme, 'GROWTH RATE', '+18.4%', 'Peak Organic', false, const Color(0xFF008080)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSliderNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDC9C8)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF3E4949)),
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, String rateText, bool isPercentageRate, Color accentColor) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
          ]
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        title,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Color(0xFF6E7979), fontFamily: 'Inter')
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            value,
                            style: theme.textTheme.displayLarge?.copyWith(fontSize: 26, color: theme.colorScheme.onSurface, fontFamily: 'Manrope', fontWeight: FontWeight.bold)
                        ),
                        if (isPercentageRate)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_upward, size: 12, color: Color(0xFF15803D)),
                                const SizedBox(width: 2),
                                Text(rateText, style: const TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(rateText, style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _showNotification("Opening structural report breakdown..."),
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                            'VIEW REPORT ª',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 0.6, fontFamily: 'Inter')
                        ),
                      ),
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

  Widget _buildPublishingHub(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Publishing Hub', style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEEEED), borderRadius: BorderRadius.circular(6)),
                child: const Text('Last draft: 14 mins ago', style: TextStyle(fontSize: 10, color: Color(0xFF3E4949), fontFamily: 'Inter')),
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildPublishItem(theme, Icons.push_pin_outlined, 'Welcome Post', 'Audience: All New (Weekly)', 'Current Reach: 1,204 members', 'EDIT DRAFT'),
          const SizedBox(height: 12),
          _buildPublishItem(theme, Icons.calendar_month_outlined, 'Schedule Content', 'Next up: "Tech Trends Q4"', 'Scheduled: Oct 24, 09:00 AM', 'MANAGE QUEUE'),
          const SizedBox(height: 12),
          _buildPublishItem(theme, Icons.bolt_outlined, 'Create Update', 'Instant Broadcast Blast', 'Max Characters: 280 (SMS/Push)', 'LAUNCH NOW'),
        ],
      ),
    );
  }

  Widget _buildPublishItem(ThemeData theme, IconData icon, String title, String row1, String row2, String actionLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Manrope')),
            ],
          ),
          const SizedBox(height: 8),
          Text(row1, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949), fontFamily: 'Inter')),
          Text(row2, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949), fontFamily: 'Inter')),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showNotification('Composer initialized for $title', type: 'success'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommunityIdentity(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Community Identity', style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 20),
                onPressed: () => _showIdentityConfigSheet(theme),
              )
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.6)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 36, color: theme.colorScheme.outline),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)),
                      child: const Text('PREMIUM COVER ART', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildIdentityMetaLabel('NAME', 'Global Innovators Hub'),
          const SizedBox(height: 14),
          const Text('TAGS & CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E7979), letterSpacing: 0.5, fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['STRATEGY', 'TECH', 'LEADERSHIP'].map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(6)),
              child: Text(tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), fontFamily: 'Inter')),
            )).toList(),
          ),
          const SizedBox(height: 14),
          _buildIdentityMetaLabel('PRIMARY LANGUAGE', 'English (United Kingdom)'),
          const SizedBox(height: 14),
          _buildIdentityMetaLabel('RULES SUMMARY', 'Verified professionals only. No external linking without moderation approval. 24h cooldown on repeated promo content.'),
        ],
      ),
    );
  }

  Widget _buildIdentityMetaLabel(String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6E7979), letterSpacing: 0.5, fontFamily: 'Inter')),
        const SizedBox(height: 4),
        Text(data, style: const TextStyle(fontSize: 13.5, color: Color(0xFF1A1C1C), height: 1.4, fontFamily: 'Inter')),
      ],
    );
  }

  Widget _buildAdministrativeOversight(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Administrative Oversight', style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          TextField(
            style: const TextStyle(fontSize: 13, fontFamily: 'Inter'),
            decoration: InputDecoration(
              hintText: 'Filter team or members...',
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: const Color(0xFFF4F3F3),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          _buildTeamMemberRow(
              theme,
              'Elena Rodriguez',
              'Strategic Member',
              'PRO PLAN',
              'Active Now',
              'Joined: 12 Oct \'23',
              const Color(0xFF15803D),
              'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=120'
          ),
          const Divider(height: 24, color: Color(0xFFE2E2E2)),
          _buildTeamMemberRow(
              theme,
              'Julian Drayton',
              'System Admin',
              'ROOT ACCESS',
              'Away',
              'Founded: 05 Jan \'22',
              const Color(0xFF6E7979),
              'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=120'
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberRow(ThemeData theme, String name, String subRole, String badgeLabel, String statusText, String joinedDate, Color statusColor, String avatarUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(avatarUrl, width: 42, height: 42, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Manrope')),
              Text(subRole.toUpperCase(), style: const TextStyle(fontSize: 9, color: Color(0xFF6E7979), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                    child: Text(badgeLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontFamily: 'Inter')),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(statusText, style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949), fontFamily: 'Inter')),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text(joinedDate, style: const TextStyle(fontSize: 11, color: Color(0xFF6E7979), fontFamily: 'Inter')),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.mail_outline, size: 18), onPressed: () => _showNotification("Direct mail configuration setup locked")),
            IconButton(icon: const Icon(Icons.settings_outlined, size: 18), onPressed: () => _showNotification("Oversight credentials locked")),
          ],
        )
      ],
    );
  }

  Widget _buildModerationQueue(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Queue: High Priority Moderation', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error, fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: theme.colorScheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(22)),
                child: Text('4 REPORTS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.error, fontFamily: 'Inter')),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 18),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('Flagged Post: "Market Manipulation Insights"', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Manrope'))),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4))),
                  child: const Text(
                    '"...and that\'s why we should all move our tokens to this private wallet address before the midnight surge. Absolute guaranteed 10x returns if you act..."',
                    style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: Color(0xFF3E4949), fontFamily: 'Inter'),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('VIOLATION: Potential Financial Scam', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A), fontFamily: 'Inter')),
                const Text('REPORTED BY: Sarah Jenkins + 2 others', style: TextStyle(fontSize: 10, color: Color(0xFF3E4949), fontFamily: 'Inter')),
                const Text('AUTHOR: @crypto_king_01', style: TextStyle(fontSize: 10, color: Color(0xFF3E4949), fontFamily: 'Inter')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showNotification('Content approved', type: 'success'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008080),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        child: const Text('APPROVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showNotification('Content purged permanently', type: 'error'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        child: const Text('BAN AUTHOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRevenueInventory(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Revenue: Promotional Inventory', style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () => _showNotification('Slot manager config initialized'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('ADD NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildRevenueSlotItem(theme, 'Weekly Spotlight Package', 'Top Sticky Header (7 Days)', '¾29.9k', '1 of 4 slots remaining', '¾89.7k', 0.25),
          const SizedBox(height: 14),
          _buildRevenueSlotItem(theme, 'Newsletter Sponsored Feature', '45k+ Subscriber List Space', '¾45.0k', 'Next Slot: Nov 01 (Booked)', '~12.5k opens', 0.8, fillColor: const Color(0xFF008080)),
        ],
      ),
    );
  }

  Widget _buildRevenueSlotItem(ThemeData theme, String title, String subtitle, String cost, String availability, String totalMtd, double progress, {Color fillColor = const Color(0xFF006565)}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Manrope')),
                    Text(subtitle.toUpperCase(), style: const TextStyle(fontSize: 9, color: Color(0xFF6E7979), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(cost, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary, fontFamily: 'Manrope')),
                  const Text('PER BLAST', style: TextStyle(fontSize: 8, color: Color(0xFF6E7979), fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFEEEEED), color: fillColor, minHeight: 6),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(availability, style: const TextStyle(fontSize: 10.5, color: Color(0xFF3E4949), fontFamily: 'Inter')),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF3E4949), fontFamily: 'Inter'),
                  children: [
                    const TextSpan(text: 'REV (MTD): '),
                    TextSpan(text: totalMtd, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDangerZone(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gpp_maybe_outlined, color: theme.colorScheme.error, size: 24),
              const SizedBox(width: 8),
              Text('Critical: Danger Zone', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error, fontSize: 18, fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Deleting this community is an irreversible process. It will permanently purge 12,482 user accounts, all historical content, financial logs, and active promotion agreements.',
            style: TextStyle(fontSize: 13, color: Color(0xFF3E4949), height: 1.4, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showTeardownConfirmationDialog(theme),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text('DESTROY COMMUNITY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8, fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }

  void _showIdentityConfigSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identity Configuration', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontSize: 18, fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('COMMUNITY NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), fontFamily: 'Inter')),
              const SizedBox(height: 6),
              TextFormField(initialValue: 'Global Innovators Hub', decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF4F3F3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none))),
              const SizedBox(height: 14),
              const Text('CHARTER & DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), fontFamily: 'Inter')),
              const SizedBox(height: 6),
              TextFormField(maxLines: 3, initialValue: 'A premier executive network for global strategy, technological transformation, and industry leadership.', decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF4F3F3), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text('DISCARD', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showNotification('Identity modifications deployed live', type: 'success');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
                      child: const Text('DEPLOY', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showTeardownConfirmationDialog(ThemeData theme) {
    _deleteVerificationController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text('Permanent Deletion?', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Manrope')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('All records, subscription lists, and historical parameters will be completely destroyed.', style: TextStyle(fontSize: 13, color: Color(0xFF3E4949), fontFamily: 'Inter')),
              const SizedBox(height: 16),
              const Center(child: Text("Type 'CONFIRM DELETE' to proceed", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), fontFamily: 'Inter'))),
              const SizedBox(height: 6),
              TextField(
                controller: _deleteVerificationController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Verification phrase',
                  filled: true,
                  fillColor: const Color(0xFFF4F3F3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: Color(0xFFBDC9C8))),
                ),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF6E7979), fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () {
                if (_deleteVerificationController.text.trim().toUpperCase() == 'CONFIRM DELETE') {
                  Navigator.pop(context);
                  _showNotification('PURGE SEQUENCE INITIATED', type: 'error');
                } else {
                  _showNotification('Invalid phrase entered', type: 'error');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), elevation: 0),
              child: const Text('INITIATE PURGE', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }
}