import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/index.dart';

import 'manage_my_commu.dart';

class ExploreCommunitiesScreen extends StatefulWidget {
  final bool isEmbedded;
  const ExploreCommunitiesScreen({super.key, this.isEmbedded = false});

  @override
  State<ExploreCommunitiesScreen> createState() => _ExploreCommunitiesScreenState();
}

class _ExploreCommunitiesScreenState extends State<ExploreCommunitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _myCommunities = [];
  bool _isLoading = false;
  String _searchQuery = "";
  String _activeFilter = "All";

  // Track bookmarked item indices locally for micro-interactions
  final Set<int> _bookmarkedRecommendations = {};

  final List<Map<String, dynamic>> _matchedCommunities = [
    {
      "title": "Sustainable Venture Lab",
      "score": "98% Match Score",
      "type": "Premium Dossier",
      "tags": ["#ESG", "#VENTURE", "#GREEN"],
      "color": Color(0xFF15803D),
    },
    {
      "title": "PropTech Disruptors",
      "score": "92% Match Score",
      "type": "High Growth",
      "tags": ["#AI", "#RETECH", "#PROPTECH"],
      "color": Color(0xFF6750A4),
    },
    {
      "title": "Clean Energy Forum",
      "score": "88% Match Score",
      "type": "Strategic Dossier",
      "tags": ["#SOLAR", "#HYDROGEN"],
      "color": Color(0xFF008080),
    }
  ];

  final List<Map<String, dynamic>> _trendingCommunities = [
    {
      "title": "Global Equity ",
      "category": "FINANCE",
      "members": "12k Active",
      "description": "Connecting institutional investors and policy makers in a high-security environment with verified administrative access.",
      "image": "https://images.unsplash.com/photo-1591696205602-2f950c417cb9?w=600",
      "icon": Icons.auto_graph_rounded,
    },
    {
      "title": "AI Ethics & Governance",
      "category": "TECHNOLOGY",
      "members": "5.8k Active",
      "description": "Structured discourse on the implementation of administrative AI standards and regulatory compliance frameworks.",
      "image": "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=600",
      "icon": Icons.psychology_rounded,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _fetchMyCommunities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyCommunities() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'fetch_own_communities',
      }, endpoint: 'new_apis/create_community_API.php');
      if (response != null && (response['success'] == true || response.containsKey('data'))) {
        setState(() {
          _myCommunities = response['data'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching communities in explore: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);
    const primaryDark = Color(0xFF004747);
    const textOnSurfaceVariant = Color(0xFF3E4949);
    const bgContainerLow = Color(0xFFF4F3F3);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          "Explore Communities",
          style: TextStyle(
            color: primaryDark,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFBDC9C8).withOpacity(0.2), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search Box & Horizontal Quick Pills Stream Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded, color: primaryColor, size: 22),
                      hintText: "Search dossiers or networks...",
                      hintStyle: const TextStyle(color: Color(0xFF6E7979), fontSize: 14, fontFamily: 'Inter'),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      filled: true,
                      fillColor: bgContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Custom top tab navigation matching the web UX structure rules perfectly
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFBDC9C8), width: 0.4)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: primaryColor,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, fontFamily: 'Inter'),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, fontFamily: 'Inter'),
              unselectedLabelColor: textOnSurfaceVariant,
              tabs: const [
                Tab(text: "MY DOSSIERS"),
                Tab(text: "DISCOVER"),
                Tab(text: "FOR YOU"),
              ],
            ),
          ),

          // Scrollable Sections view
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyCommunitiesSection(),
                _buildDiscoverSection(),
                _buildForYouSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPill(String text, bool active, {VoidCallback? onTap}) {
    const primaryColor = Color(0xFF006565);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(text),
        selected: active,
        onSelected: (_) => onTap?.call(),
        selectedColor: primaryColor,
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : const Color(0xFF3E4949),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: active ? Colors.transparent : const Color(0xFFBDC9C8),
          width: 0.8,
        ),
        showCheckmark: false,
      ),
    );
  }

  // Section 1: My Communities Tab view
  Widget _buildMyCommunitiesSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF006565), strokeWidth: 3));
    }

    final filteredList = _myCommunities.where((c) {
      final name = c['community_title']?.toString()?.toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF006565).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hub_outlined, size: 36, color: Color(0xFF006565)),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? "You do not own any communities yet." : "No communities found matching your search.",
                style: const TextStyle(color: Color(0xFF3E4949), fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final c = filteredList[index];
        final String title = c['community_title']?.toString() ?? c['title']?.toString() ?? 'Community';
        final String members = c['members_count']?.toString() ?? '0';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(width: 4, height: 80, color: const Color(0xFF006565)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3F3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.corporate_fare_rounded, color: Color(0xFF006565), size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C1C), fontFamily: 'Manrope', letterSpacing: -0.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.group, size: 14, color: Color(0xFF3E4949)),
                                const SizedBox(width: 4),
                                Text(
                                  "$members Members",
                                  style: const TextStyle(color: Color(0xFF3E4949), fontSize: 13, fontWeight: FontWeight.w400, fontFamily: 'Inter'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (
                              context) => CommunityIntelApp(),));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("MANAGE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Section 2: Discover Tab view
  Widget _buildDiscoverSection() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _trendingCommunities.length,
      itemBuilder: (context, index) {
        final c = _trendingCommunities[index];
        final String title = c['title'];
        final String cat = c['category'];
        final String members = c['members'];
        final String desc = c['description'];
        final String image = c['image'];
        final IconData icon = c['icon'];

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFEEEEED),
                        child: Icon(icon, size: 40, color: const Color(0xFF006565).withOpacity(0.3)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006565),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cat,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Inter'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              members,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1C1C), fontFamily: 'Manrope', letterSpacing: -0.3),
                          ),
                        ),
                        Icon(icon, color: const Color(0xFF008080), size: 22),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: const TextStyle(color: Color(0xFF3E4949), fontSize: 14, height: 1.5, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text("JOIN NETWORK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5, fontFamily: 'Inter')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Section 3: For You Tab view (Recommendations)
  Widget _buildForYouSection() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _matchedCommunities.length,
      itemBuilder: (context, index) {
        final c = _matchedCommunities[index];
        final String title = c['title'];
        final String score = c['score'];
        final String type = c['type'];
        final List<String> tags = c['tags'];
        final Color scoreColor = c['color'];
        final isBookmarked = _bookmarkedRecommendations.contains(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3F3), // exact tonal-layer-2 configuration
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: scoreColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            score,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A1C1C), fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, size: 20),
                      color: isBookmarked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.6)),
                      onPressed: () {
                        setState(() {
                          if (isBookmarked) {
                            _bookmarkedRecommendations.remove(index);
                          } else {
                            _bookmarkedRecommendations.add(index);
                          }
                        });
                      },
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.verified_rounded, size: 16, color: scoreColor),
                    const SizedBox(width: 4),
                    Text(
                      type.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scoreColor, letterSpacing: 1.2, fontFamily: 'Inter'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1C1C), fontFamily: 'Manrope', letterSpacing: -0.3),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006565).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF006565), fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF006565),
                      side: BorderSide(color: const Color(0xFF006565).withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text("Request Access", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.2, fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}