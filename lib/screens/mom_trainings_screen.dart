import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'create_training_screen.dart';

class MomTrainingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const MomTrainingsScreen({super.key, this.isEmbedded = false});

  @override
  State<MomTrainingsScreen> createState() => _MomTrainingsScreenState();
}

class _MomTrainingsScreenState extends State<MomTrainingsScreen> {
  // Visual Theme Styling constants
  static const Color primaryTeal = Color(0xFF006565);
  static const Color background = Color(0xFFF8F9FF);
  static const Color textDark = Color(0xFF0B1C30);
  static const Color textLight = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color coralAlert = Color(0xFFBA1A1A);

  bool _isLoading = true;
  List<dynamic> _featuredPrograms = [];
  List<dynamic> _categories = [];
  List<dynamic> _trainers = [];
  List<dynamic> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchFeaturedPrograms(),
      _fetchCategories(),
      _fetchTrainers(),
      _fetchArticles(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchFeaturedPrograms() async {
    try {
      final res = await Database().getData({
        'action': 'getFeaturedPrograms',
      }, endpoint: 'new_apis/mom_trainings_API.php');
      if (res['success'] == true && res['data'] != null) {
        _featuredPrograms = res['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint("Error fetching featured programs: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await Database().getData({
        'action': 'getCategories',
      }, endpoint: 'new_apis/mom_trainings_API.php');
      if (res['success'] == true && res['data'] != null) {
        _categories = res['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint("Error fetching training categories: $e");
    }
  }

  Future<void> _fetchTrainers() async {
    try {
      final res = await Database().getData({
        'action': 'getTrainers',
      }, endpoint: 'new_apis/mom_trainings_API.php');
      if (res['success'] == true && res['data'] != null) {
        _trainers = res['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint("Error fetching trainers: $e");
    }
  }

  Future<void> _fetchArticles() async {
    try {
      // Action is literally space ' ' as defined in php backend file
      final res = await Database().getData({
        'action': ' ',
      }, endpoint: 'new_apis/mom_trainings_API.php');
      if (res['success'] == true && res['data'] != null) {
        _articles = res['data'] as List<dynamic>;
      }
    } catch (e) {
      debugPrint("Error fetching articles: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              title: const Text(
                "MOM Training",
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: textDark),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryTeal))
          : RefreshIndicator(
              onRefresh: _loadAllData,
              color: primaryTeal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHero(),
                    const SizedBox(height: 24),
                    _buildFeaturedProgramsSection(),
                    const SizedBox(height: 24),
                    _buildCustomPathRecommendation(),
                    const SizedBox(height: 24),
                    _buildCategoriesSection(),
                    const SizedBox(height: 24),
                    _buildTrainersSection(),
                    const SizedBox(height: 24),
                    _buildArticlesSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Training Hub",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        SizedBox(height: 2),
        Text(
          "Level up your professional game with world-class experts.",
          style: TextStyle(
            fontSize: 12,
            color: textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProgramsSection() {
    if (_featuredPrograms.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Featured Programs",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "View all",
                style: TextStyle(
                  fontSize: 12,
                  color: primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredPrograms.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final prog = _featuredPrograms[index];
              return _buildFeaturedProgramCard(prog);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProgramCard(dynamic prog) {
    final title = prog['title'] ?? 'Strategic Leadership';
    final desc = prog['description'] ?? '';
    final imageUrl = prog['image_url'] ?? '';
    final mode = prog['mode'] ?? 'Live';
    final slots = int.tryParse(prog['slots']?.toString() ?? '0') ?? 0;
    final rating = double.tryParse(prog['avg_rating']?.toString() ?? '0.0') ?? 0.0;

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.school, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          rating > 0 ? rating.toStringAsFixed(1) : "N/A",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 8),
                if (slots > 0)
                  Row(
                    children: [
                      const Icon(Icons.group, color: coralAlert, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "$slots Slots Left",
                        style: const TextStyle(
                          fontSize: 10,
                          color: coralAlert,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "₹24,999",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Enroll",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPathRecommendation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryTeal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Training for You",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Based on your interest in Strategy and Design, we recommend these specialized tracks.",
            style: TextStyle(
              fontSize: 11,
              color: textLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCustomPathCard(
                  title: "Product Roadmap Mastery",
                  desc: "Master digital lifecycles.",
                  modules: "12 modules • 15 hours",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCustomPathCard(
                  title: "Visual Storytelling",
                  desc: "Communicate complex data.",
                  modules: "8 modules • 10 hours",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPathCard({
    required String title,
    required String desc,
    required String modules,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            modules,
            style: const TextStyle(
              fontSize: 9,
              color: primaryTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {},
              child: const Text("Start Path", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Browse by Category",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return _buildCategoryChip(cat);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(dynamic cat) {
    final name = cat['name'] ?? '';
    final count = cat['count'] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "$count Programs",
            style: const TextStyle(
              fontSize: 9,
              color: textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersSection() {
    if (_trainers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Trainers",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _trainers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final trainer = _trainers[index];
              return _buildTrainerCard(trainer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerCard(dynamic trainer) {
    final name = trainer['name'] ?? 'Trainer';
    final title = trainer['title'] ?? 'Mentor';
    final pic = trainer['profile_pic'] ?? '';
    final count = trainer['programs'] ?? 0;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(pic),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$count Programs",
            style: const TextStyle(
              fontSize: 9,
              color: primaryTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 22,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryTeal),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Profile",
                style: TextStyle(
                  color: primaryTeal,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesSection() {
    if (_articles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Articles & Insights",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final art = _articles[index];
            return _buildArticleTile(art);
          },
        ),
      ],
    );
  }

  Widget _buildArticleTile(dynamic art) {
    final title = art['title'] ?? '';
    final category = art['category'] ?? 'General';
    final summary = art['summary'] ?? '';
    final image = art['featured_image'] ?? '';
    final author = art['author'] ?? 'Admin';
    final date = art['date'] ?? '';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 70,
                width: 70,
                color: Colors.grey.shade200,
                child: const Icon(Icons.article, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: primaryTeal,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "By $author • $date",
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                      ),
                    ),
                    const Text(
                      "Read More",
                      style: TextStyle(
                        fontSize: 9,
                        color: primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
