import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/index.dart';

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
  
  // Dummy matched communities (For You)
  final List<Map<String, dynamic>> _matchedCommunities = [
    {
      "title": "Sustainable Venture Lab",
      "score": "98% Match",
      "type": "Premium Dossier",
      "tags": ["#ESG", "#VENTURE", "#GREEN"],
      "color": Color(0xFF15803D),
    },
    {
      "title": "PropTech Disruptors",
      "score": "92% Match",
      "type": "High Growth",
      "tags": ["#AI", "#RETECH", "#PROPTECH"],
      "color": Color(0xFF6750A4),
    },
    {
      "title": "Clean Energy Forum",
      "score": "88% Match",
      "type": "Strategic Dossier",
      "tags": ["#SOLAR", "#HYDROGEN"],
      "color": Color(0xFF008080),
    }
  ];

  // Dummy globally trending communities (Discover)
  final List<Map<String, dynamic>> _trendingCommunities = [
    {
      "title": "Global Equity Forum",
      "category": "FINANCE",
      "members": "12k Active",
      "description": "Connecting institutional investors and policy makers in a high-security environment with verified administrative access.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuDcjd7i3W_Y5Os150xTKhE8kQm-qPl0WIZEcR3rWKfV7vulRYv96MymvMQ_sDmk_8wwzNH-mqRNNrPvJpl2ySZQD7DhrVFgWe9evdVS_CkVYl7RaZ4oocbiWE75SvqBXXJO_OYDUw5g5OVkErZjgEAgmxpLPzMdFtwzcO-WLZYyx1jLNa5Kd68P3ROhg_jmzXjEAywSFPt89FL731hijFWBqkqrWQ85eOUDtywPYqJrsDRRm6W8Q9CW",
      "icon": Icons.auto_graph_rounded,
    },
    {
      "title": "AI Ethics & Governance",
      "category": "TECHNOLOGY",
      "members": "5.8k Active",
      "description": "Structured discourse on the implementation of administrative AI standards and regulatory compliance frameworks.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuARbZGEt6KWsysmbJ8AfNNX20EZOreccwj3RetrmdCxwEGYO1QiIOECTpqnSyllWhbqFLcAkTPEllsdH5YXOfcDHOW23nI0Yoa-xvlq9kTTtxG5R8nzJAX78OxdSVlDJFKn3OvWSolOaGbOV-PnJ0C40dqmGGPOZNFR7OgcOySvHua7ppae3yvXzyb2FcJz55OKNdaXptf2Nv07dnyGrDDMg4wWVoQ7XqsIRZSgtGYzn2xYhvbvBDVb",
      "icon": Icons.psychology_rounded,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        'action': 'get_my_communities',
      }, endpoint: 'new_apis/community_dashboard_api.php');
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
    const textOnSurfaceVariant = Color(0xFF3E4949);
    const outlineVariant = Color(0xFFBDC9C8);
    const bgContainerLow = Color(0xFFF4F3F3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isEmbedded 
          ? null 
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "Explore Communities",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search Input field
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: textOnSurfaceVariant),
                    hintText: "Search dossiers or networks...",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: bgContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Pills Scroll list
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildQuickPill("All", true),
                      const SizedBox(width: 8),
                      _buildQuickPill("My Communities", false, onTap: () => _tabController.animateTo(0)),
                      const SizedBox(width: 8),
                      _buildQuickPill("Discover", false, onTap: () => _tabController.animateTo(1)),
                      const SizedBox(width: 8),
                      _buildQuickPill("Recommendations", false, onTap: () => _tabController.animateTo(2)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom top tab navigation matching the HTML layout sticky bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF4F3F3), width: 1.5)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelColor: primaryColor,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              unselectedLabelColor: textOnSurfaceVariant,
              tabs: const [
                Tab(text: "MY COMMUNITIES"),
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
    return ActionChip(
      label: Text(text),
      onPressed: onTap ?? () {},
      backgroundColor: active ? primaryColor : Colors.white,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: active ? Colors.white : const Color(0xFF3E4949),
      ),
      side: active ? BorderSide.none : const BorderSide(color: Color(0xFFBDC9C8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  // Section 1: My Communities Tab view
  Widget _buildMyCommunitiesSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF006565)));
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
              const Icon(Icons.hub_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _searchQuery.isEmpty ? "You do not own any communities yet." : "No communities found matching your search.",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final c = filteredList[index];
        final String title = c['community_title']?.toString() ?? 'Community';
        final String desc = c['community_description']?.toString() ?? '';
        final String members = c['members_count']?.toString() ?? '0';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFBDC9C8)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFF006565), width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F3F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.corporate_fare_rounded, color: Color(0xFF006565), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.group_outlined, size: 14, color: Color(0xFF3E4949)),
                          const SizedBox(width: 4),
                          Text(
                            "$members Members",
                            style: const TextStyle(color: Color(0xFF3E4949), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("MANAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Section 2: Discover Tab view
  Widget _buildDiscoverSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trendingCommunities.length,
      itemBuilder: (context, index) {
        final c = _trendingCommunities[index];
        final String title = c['title'];
        final String cat = c['category'];
        final String members = c['members'];
        final String desc = c['description'];
        final String image = c['image'];
        final IconData icon = c['icon'];

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFBDC9C8)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFEEEEED)),
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
                      bottom: 12,
                      left: 12,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006565),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cat,
                              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              members,
                              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Card details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                        Icon(icon, color: const Color(0xFF006565), size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: const TextStyle(color: Color(0xFF3E4949), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("JOIN NETWORK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 8),
                          Icon(Icons.login_rounded, size: 16),
                        ],
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
      padding: const EdgeInsets.all(16),
      itemCount: _matchedCommunities.length,
      itemBuilder: (context, index) {
        final c = _matchedCommunities[index];
        final String title = c['title'];
        final String score = c['score'];
        final String type = c['type'];
        final List<String> tags = c['tags'];
        final Color scoreColor = c['color'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFBDC9C8)),
          ),
          color: const Color(0xFFF4F3F3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: scoreColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            score,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_outline_rounded, size: 20, color: Color(0xFF3E4949)),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 16, color: scoreColor),
                    const SizedBox(width: 4),
                    Text(
                      type.toUpperCase(),
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: scoreColor, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006565).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(fontSize: 9, color: Color(0xFF006565), fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF006565),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFBDC9C8)),
                    ),
                  ),
                  child: const Text("Request Access", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
