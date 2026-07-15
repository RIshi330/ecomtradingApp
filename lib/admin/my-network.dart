import 'package:flutter/material.dart';

class mynetwork extends StatelessWidget {
  const mynetwork({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact Material 3 Color Schema mapped directly from your Tailwind config tokens
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
      title: 'Serene Corporate Network',
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
      home: const MyNetworkScreen(),
    );
  }
}

class MyNetworkScreen extends StatefulWidget {
  const MyNetworkScreen({super.key});

  @override
  State<MyNetworkScreen> createState() => _MyNetworkScreenState();
}

class _MyNetworkScreenState extends State<MyNetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Interactive UI Mock Data States
  bool _isFollowingDavid = true;
  final Map<int, bool> _followedBackState = {0: false};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update highlighted text tabs states
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: theme.colorScheme.primary,
          onPressed: () {},
        ),
        title: Text(
          'My Network',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: theme.colorScheme.primary,
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=80',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.colorScheme.outlineVariant.withOpacity(0.5), height: 1),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 800 ? 40.0 : 16.0;
          final crossAxisCount = constraints.maxWidth > 1024
              ? 3
              : (constraints.maxWidth > 640 ? 2 : 1);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  children: [
                    // Sticky/Fixed Segmented Search & Controls Header
                    _buildFilterAndSearchRow(theme, constraints),
                    const SizedBox(height: 24),

                    // Dynamic Tab Content Management Wrapper
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        if (_tabController.index == 0) {
                          return _buildFollowersGrid(theme, crossAxisCount);
                        } else {
                          return _buildFollowingGrid(theme, crossAxisCount);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterAndSearchRow(ThemeData theme, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 720;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Text-based Custom Segmented Pill Tab Bar Controls
          Row(
            children: [
              _buildTextTabButton('FOLLOWERS', '1.2k', 0, theme),
              const SizedBox(width: 24),
              _buildTextTabButton('FOLLOWING', '842', 1, theme),
            ],
          ),
          if (isMobile) const SizedBox(height: 16),
          // Custom Responsive Search Box Module
          Container(
            constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 380),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name or title...',
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF6E7979)),
                filled: true,
                fillColor: const Color(0xFFF4F3F3),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDC9C8), width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBDC9C8), width: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTabButton(String label, String count, int index, ThemeData theme) {
    final isActive = _tabController.index == index;

    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? theme.colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
            children: [
              TextSpan(text: label),
              const TextSpan(text: ' '),
              TextSpan(
                text: count,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(isActive ? 1.0 : 0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowersGrid(ThemeData theme, int crossAxisCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: 2.8,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Follower Card Item 1
        _buildNetworkCard(
          theme: theme,
          name: 'Elena Rodriguez',
          title: 'Strategy Director @ GlobalFlow',
          avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
          actionWidget: ElevatedButton(
            onPressed: () {
              setState(() {
                _followedBackState[0] = !(_followedBackState[0] ?? false);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (_followedBackState[0] ?? false) ? Colors.white : theme.colorScheme.primary,
              foregroundColor: (_followedBackState[0] ?? false) ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
              side: (_followedBackState[0] ?? false) ? BorderSide(color: theme.colorScheme.primary) : null,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              (_followedBackState[0] ?? false) ? 'FOLLOWING' : 'FOLLOW BACK',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          showMoreMenu: true,
        ),

        // Follower Card Item 2
        _buildNetworkCard(
          theme: theme,
          name: 'Marcus Chen',
          title: 'Head of Operations @ TechStream',
          avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
          actionWidget: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              side: const BorderSide(color: Color(0xFF6E7979)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('REMOVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          showMoreMenu: true,
        ),

        // Follower Card Item 3
        _buildNetworkCard(
          theme: theme,
          name: 'Sarah Jenkins',
          title: 'Community Lead @ InnovateHQ',
          avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
          actionWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'MUTUAL',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
          ),
          showMoreMenu: true,
        ),
      ],
    );
  }

  Widget _buildFollowingGrid(ThemeData theme, int crossAxisCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: 2.8,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Following Card Item 1
        _buildNetworkCard(
          theme: theme,
          name: 'David Vance',
          title: 'Managing Partner @ CoreEquity',
          avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
          actionWidget: ElevatedButton(
            onPressed: () {
              setState(() {
                _isFollowingDavid = !_isFollowingDavid;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollowingDavid ? Colors.white : theme.colorScheme.primary,
              foregroundColor: _isFollowingDavid ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
              side: BorderSide(color: theme.colorScheme.primary),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              _isFollowingDavid ? 'FOLLOWING' : 'FOLLOW',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          showMoreMenu: true,
        ),
      ],
    );
  }

  Widget _buildNetworkCard({
    required ThemeData theme,
    required String name,
    required String title,
    required String avatarUrl,
    required Widget actionWidget,
    required bool showMoreMenu,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Structural Teal Accent Line Layer
            Container(width: 4, color: const Color(0xFF008080)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Member Custom Image Container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Core Credentials Information Block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6E7979)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Functional Context Interaction Widget Buttons Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionWidget,
                        if (showMoreMenu) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF6E7979)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showCardActionBottomSheet(name, theme),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Native Platform Action Menu Handling
  void _showCardActionBottomSheet(String userName, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('View Profile', style: TextStyle(fontSize: 14)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('Message', style: TextStyle(fontSize: 14)),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.block, color: theme.colorScheme.error),
                title: Text('Block User', style: TextStyle(color: theme.colorScheme.error, fontSize: 14)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.report_problem_outlined, color: theme.colorScheme.error),
                title: Text('Report', style: TextStyle(color: theme.colorScheme.error, fontSize: 14)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}