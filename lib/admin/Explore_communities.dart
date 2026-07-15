import 'package:flutter/material.dart';
import 'dart:ui';


class DossierHQApp extends StatelessWidget {
  const DossierHQApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom Color Palette mapped directly from your Tailwind config
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
    );

    return MaterialApp(
      title: 'DossierHQ',
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
      home: const ManageCommunitiesScreen(),
    );
  }
}

class ManageCommunitiesScreen extends StatefulWidget {
  const ManageCommunitiesScreen({super.key});

  @override
  State<ManageCommunitiesScreen> createState() => _ManageCommunitiesScreenState();
}

class _ManageCommunitiesScreenState extends State<ManageCommunitiesScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  // GlobalKeys to calculate positions dynamically for Tab Switching & Scrolling
  final GlobalKey _myCommunitiesKey = GlobalKey();
  final GlobalKey _forYouKey = GlobalKey();
  final GlobalKey _discoverKey = GlobalKey();

  bool _showBackToTop = false;
  bool _isProgrammaticScroll = false;

  // Track bookmarked match card indices
  final Set<int> _bookmarkedCards = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Mimics JavaScript IntersectionObserver to keep tabs synced during active scrolls
  void _handleScroll() {
    if (_scrollController.offset > 300 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.offset <= 300 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }

    if (_isProgrammaticScroll) return;

    final myCommPos = _getWidgetOffset(_myCommunitiesKey);
    final forYouPos = _getWidgetOffset(_forYouKey);
    final discoverPos = _getWidgetOffset(_discoverKey);

    // Dynamic thresholds tracking top visibility layers
    if (discoverPos <= 160) {
      if (_tabController.index != 1) _tabController.animateTo(1);
    } else if (forYouPos <= 160) {
      if (_tabController.index != 2) _tabController.animateTo(2);
    } else if (myCommPos <= 160) {
      if (_tabController.index != 0) _tabController.animateTo(0);
    }
  }

  double _getWidgetOffset(GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return double.maxFinite;
    return renderBox.localToGlobal(Offset.zero).dy;
  }

  // Programmatic offset handling on Tab clicking
  void _scrollToSection(GlobalKey key, int tabIndex) async {
    setState(() => _isProgrammaticScroll = true);
    _tabController.animateTo(tabIndex);

    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero).dy + _scrollController.offset;
      // Subtract sticky navbar space definitions (~140.0)
      await _scrollController.animateTo(
        position - 140.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    setState(() => _isProgrammaticScroll = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Row(
      //     children: [
      //       Container(
      //         padding: const EdgeInsets.all(8),
      //         decoration: BoxDecoration(
      //           color: theme.colorScheme.primary.withOpacity(0.1),
      //           borderRadius: BorderRadius.circular(12),
      //         ),
      //         child: Icon(Icons.hub_outlined, color: theme.colorScheme.primary),
      //       ),
      //       const SizedBox(width: 12),
      //       Text(
      //         'Communities',
      //         style: theme.textTheme.titleMedium?.copyWith(
      //           fontFamily: 'Manrope',
      //           fontWeight: FontWeight.bold,
      //           color: theme.colorScheme.primary,
      //           fontSize: 22,
      //         ),
      //       ),
      //     ],
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.search),
      //       onPressed: () {},
      //       color: theme.colorScheme.onSurfaceVariant,
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.notifications_none),
      //       onPressed: () {},
      //       color: theme.colorScheme.onSurfaceVariant,
      //     ),
      //     const SizedBox(width: 8),
      //   ],
      //   elevation: 0,
      //   backgroundColor: theme.colorScheme.surface,
      //   surfaceTintColor: Colors.transparent,
      // ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive padding dynamically
          final horizontalPadding = constraints.maxWidth > 600 ? 40.0 : 20.0;

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Sticky Tabs Bar with glassmorphism blur effect
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(48),
                      child: Container(
                        color: theme.colorScheme.surface.withOpacity(0.8),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: TabBar(
                              controller: _tabController,
                              onTap: (index) {
                                if (index == 0) _scrollToSection(_myCommunitiesKey, 0);
                                if (index == 1) _scrollToSection(_discoverKey, 1);
                                if (index == 2) _scrollToSection(_forYouKey, 2);
                              },
                              indicatorColor: theme.colorScheme.primary,
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                              tabs: const [
                                Tab(text: 'MY COMMUNITIES'),
                                Tab(text: 'DISCOVER'),
                                Tab(text: 'FOR YOU'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Main Content Stream
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSearchAndFilters(theme),
                        const SizedBox(height: 32),

                        // Section 1: My Communities
                        // Container(key: _myCommunitiesKey, child: _buildMyCommunitiesSection(theme)),
                        // const SizedBox(height: 40),

                        // Section 2: Matched Intelligence (For You)
                        Container(key: _forYouKey, child: _buildMatchedIntelligenceSection(theme, constraints)),
                        const SizedBox(height: 40),

                        // Section 3: Trending Globally (Discover)
                        Container(key: _discoverKey, child: _buildTrendingSection(theme, constraints)),
                        const SizedBox(height: 100), // Extended layout baseline offset
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),

      // Multi-layer FAB Architecture matching original layout specification rules
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showBackToTop) ...[
            FloatingActionButton.small(
              heroTag: 'btn_top',
              onPressed: () => (),
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimary,
              child: const Icon(Icons.arrow_upward),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: 'btn_add',
            onPressed: () {},
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add, size: 28),
          ),
          const SizedBox(height: 56), // Elevate over Persistent Bottom Navigation
        ],
      ),

      // Bottom Navigation Component Mapping
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search dossiers or networks...',
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.outline),
            filled: true,
            fillColor: const Color(0xFFF4F3F3), // tonal-layer-2 layout specification
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.6)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterPill(theme, 'All', isActive: true),
              _buildFilterPill(theme, 'My Communities'),
              _buildFilterPill(theme, 'Discover'),
              _buildFilterPill(theme, 'Recommendations'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFilterPill(ThemeData theme, String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) {},
        selectedColor: theme.colorScheme.primary,
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(
          fontSize: 12,
          color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: isActive ? Colors.transparent : theme.colorScheme.outlineVariant,
        ),
      ),
    );
  }

  // Widget _buildMyCommunitiesSection(ThemeData theme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text('Your Dossiers', style: theme.textTheme.titleMedium?.copyWith(fontSize: 20)),
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //             decoration: BoxDecoration(
  //               color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
  //               borderRadius: BorderRadius.circular(4),
  //             ),
  //             child: Text(
  //               '3 ACTIVE',
  //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
  //             ),
  //           )
  //         ],
  //       ),
  //       const SizedBox(height: 16),
  //       _buildCommunityCard(theme, 'Global Fintech Strategists', '1,240 Members', Icons.corporate_fare),
  //       const SizedBox(height: 12),
  //       _buildCommunityCard(theme, 'Market Analysis Hub', '856 Members', Icons.insights),
  //     ],
  //   );
  // }

  Widget _buildCommunityCard(ThemeData theme, String title, String members, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: theme.colorScheme.primary), // Left accent border layer line
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                        ),
                        child: Icon(icon, color: theme.colorScheme.primary, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.group, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(members, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('MANAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchedIntelligenceSection(ThemeData theme, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Matched Intelligence', style: theme.textTheme.titleMedium?.copyWith(fontSize: 20)),
                Text('Based on your activity and interests', style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            TextButton.icon(
              onPressed: () {},
              label: const Text('See More'),
              icon: const Icon(Icons.arrow_forward, size: 14),
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
            )
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildMatchCard(theme, 0, '98% Match Score', 'Premium Dossier', 'Sustainable Venture Lab', ['#ESG', '#VENTURE', '+4'], const Color(0xFF15803D), Icons.verified),
              const SizedBox(width: 16),
              _buildMatchCard(theme, 1, '92% Match Score', 'High Growth', 'PropTech Disruptors', ['#AI', '#RETECH'], const Color(0xFF6750A4), Icons.trending_up),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(ThemeData theme, int index, String score, String tag, String title, List<String> hashtags, Color accentColor, IconData tagIcon) {
    final isBookmarked = _bookmarkedCards.contains(index);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F3), // tonal-layer-2 definition mapping
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(score, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                color: isBookmarked ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.6)),
                onPressed: () {
                  setState(() {
                    if (isBookmarked) {
                      _bookmarkedCards.remove(index);
                    } else {
                      _bookmarkedCards.add(index);
                    }
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(tagIcon, size: 18, color: accentColor),
              const SizedBox(width: 4),
              Text(tag.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: accentColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.headlineLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            children: hashtags.map((h) => Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(h, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Request Access', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrendingSection(ThemeData theme, BoxConstraints constraints) {
    // Structural layout alignment rule matching Grid view responsiveness definitions
    final isDesktop = constraints.maxWidth > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trending Globally', style: theme.textTheme.titleMedium?.copyWith(fontSize: 20)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.colorScheme.error, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildDiscoverCard(theme, 'Global Equity Forum', 'Connecting institutional investors and policy makers...', 'FINANCE', '12k Active', 'https://images.unsplash.com/photo-1591696205602-2f950c417cb9?w=500')),
              const SizedBox(width: 24),
              Expanded(child: _buildDiscoverCard(theme, 'AI Ethics & Governance', 'Structured discourse on the implementation...', 'TECHNOLOGY', '5.8k Active', 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=500', isTech: true)),
            ],
          )
        else
          Column(
            children: [
              _buildDiscoverCard(theme, 'Global Equity Forum', 'Connecting institutional investors and policy makers in a high-security environment with verified administrative access.', 'FINANCE', '12k Active', 'https://images.unsplash.com/photo-1591696205602-2f950c417cb9?w=500'),
              const SizedBox(height: 24),
              _buildDiscoverCard(theme, 'AI Ethics & Governance', 'Structured discourse on the implementation of administrative AI standards and regulatory compliance frameworks.', 'TECHNOLOGY', '5.8k Active', 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=500', isTech: true),
            ],
          ),
      ],
    );
  }

  Widget _buildDiscoverCard(ThemeData theme, String title, String description, String category, String activeCount, String imageUrl, {bool isTech = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 192,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isTech ? const Color(0xFF6750A4) : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(activeCount, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: theme.textTheme.headlineLarge?.copyWith(fontSize: 18)),
                    Icon(isTech ? Icons.psychology : Icons.auto_graph, color: isTech ? theme.colorScheme.primary : const Color(0xFF008080)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('JOIN NETWORK', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}