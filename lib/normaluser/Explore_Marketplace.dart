

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trading_ecommerce_admin/normaluser/B2B_HomeScreen.dart';

import '../admin/job_application.dart';
import '../normaluser/B2C_HomeScreen.dart';
import '../normaluser/Branding_shop.dart';
import '../normaluser/combo_shop.dart';
import 'Job_Section.dart';
import 'TranningScreen.dart';
import 'opportunity_marketplace.dart';



class ExploreMarketplaceUser extends StatefulWidget {
  final VoidCallback onMenuPressed;

  const ExploreMarketplaceUser({Key? key,required this.onMenuPressed}) : super(key: key,);

  @override
  State<ExploreMarketplaceUser> createState() => _ExploreMarketplaceUserState();
}

class _ExploreMarketplaceUserState extends State<ExploreMarketplaceUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: widget.onMenuPressed, // opens the shared drawer
        ),
        title: Text(
          'Explore Market',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedHeroCard(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'News & Articles'),
            const SizedBox(height: 16),
            _buildHorizontalArticleList(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Browse by Category'),
            const SizedBox(height: 16),
            _buildCategoryGrid(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=600'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.85),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF006565),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'FEATURED MARKETPLACE',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tech Innovation Hub',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with top-tier silicon valley startups looking for enterprise strategic partnerships.',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeaturedMarketplaceScreen(),
                  ),
                );
              },
              child: Text(
                'Explore Hub',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.manrope(
            color: const Color(0xFF006565),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllArticlesScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            'VIEW ALL',
            style: GoogleFonts.inter(
              color: const Color(0xFF006565),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalArticleList(BuildContext context) {
    final articles = [
      {
        'tag': 'Market Trends',
        'title': 'The Future of B2B Marketplaces in 2026',
        'img':
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&q=80&w=400',
        'author': 'David Chen',
        'date': 'OCT 24, 2025'
      },
      {
        'tag': 'Leadership',
        'title': 'Strategic Alliances: Global Expansion Paths',
        'img':
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&q=80&w=400',
        'author': 'Sarah Jenkins',
        'date': 'OCT 22, 2025'
      }
    ];

    return SizedBox(
      height: 350,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = articles[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(
                    title: item['title']!,
                    author: item['author']!,
                    date: item['date']!,
                    tag: item['tag']!,
                    imageUrl: item['img']!,
                  ),
                ),
              );
            },
            child: Container(
              width: 290,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E2E2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Image.network(
                      item['img']!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB0EEED),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['tag']!.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF306E6D),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['title']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF1A1C1C),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFFE2E2E2),
                              child: const Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['author']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1C1C),
                                  ),
                                ),
                                Text(
                                  item['date']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: const Color(0xFF3E4949),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE0E2E2), height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.visibility_outlined,
                                    size: 16, color: Color(0xFF3E4949)),
                                const SizedBox(width: 4),
                                Text('1.2k',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF3E4949))),
                                const SizedBox(width: 12),
                                const Icon(Icons.favorite_border,
                                    size: 16, color: Color(0xFF3E4949)),
                                const SizedBox(width: 4),
                                Text('45',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF3E4949))),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.share_outlined,
                                    size: 18, color: const Color(0xFF3E4949)),
                                const SizedBox(width: 8),
                                Icon(Icons.bookmark_border_outlined,
                                    size: 18, color: const Color(0xFF3E4949)),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {'icon': Icons.shopping_bag_outlined, 'label': 'Shop', 'screen': const BTCMarketplaceScreen()},
      {'icon': Icons.business_outlined, 'label': 'B2B Shop', 'screen': const BTBMarketplaceScreen()},
      {'icon': Icons.storefront_outlined, 'label': 'Combo Shop', 'screen': const  ComboMarketplaceScreena()},
       {'icon': Icons.brush_outlined, 'label': 'Branding', 'screen': const BrandingMarketplaceScreen()},
       {'icon': Icons.school_outlined, 'label': 'Training', 'screen': const TranningSection()},
       {'icon': Icons.lightbulb, 'label': 'Opportunity', 'screen': const OpportunitiesMarketplaceScreen()},
      {'icon': Icons.sell, 'label': 'Job', 'screen': const SereneJobsScreen()},
      // {'icon': Icons.bubble_chart_rounded, 'label': 'Charity', 'screen': const CharityScreen()},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E2E2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => cat['screen'] as Widget,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    color: const Color(0xFF006565),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF1A1C1C),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }}

// Category Shop Screen
class CategoryShopScreen extends StatelessWidget {
  final String category;
  final IconData icon;

  const CategoryShopScreen({
    Key? key,
    required this.category,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          category,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: const Color(0xFF006565),
            ),
            const SizedBox(height: 20),
            Text(
              '$category Marketplace',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Browse and discover amazing $category products and services',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF3E4949),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Go Back',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Featured Marketplace Screen
class FeaturedMarketplaceScreen extends StatelessWidget {
  const FeaturedMarketplaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Tech Innovation Hub',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=600',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'About Tech Innovation Hub',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tech Innovation Hub is a premier marketplace connecting enterprises with cutting-edge silicon valley startups. Our platform facilitates strategic partnerships, investments, and technology transfers.',
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: const Color(0xFF3E4949),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Key Features',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1C1C),
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.verified, 'Verified Startups'),
            _buildFeatureItem(Icons.handshake, 'Strategic Partnerships'),
            _buildFeatureItem(Icons.trending_up, 'Investment Opportunities'),
            _buildFeatureItem(Icons.people, 'Network with Industry Leaders'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006565), size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
    );
  }
}

// All Articles Screen
class AllArticlesScreen extends StatelessWidget {
  const AllArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'All Articles',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildArticleListItem(
            context,
            'The Future of B2B Marketplaces in 2026',
            'Market Trends',
            'David Chen',
            'OCT 24, 2025',
          ),
          _buildArticleListItem(
            context,
            'Strategic Alliances: Global Expansion Paths',
            'Leadership',
            'Sarah Jenkins',
            'OCT 22, 2025',
          ),
          _buildArticleListItem(
            context,
            'Digital Transformation in Enterprise Sales',
            'Technology',
            'Michael Rodriguez',
            'OCT 20, 2025',
          ),
          _buildArticleListItem(
            context,
            'Building Trust in B2B Relationships',
            'Strategy',
            'Emily Thompson',
            'OCT 18, 2025',
          ),
        ],
      ),
    );
  }

  Widget _buildArticleListItem(BuildContext context, String title, String tag, String author, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1C1C),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB0EEED),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag.toUpperCase(),
                style: GoogleFonts.inter(
                  color: const Color(0xFF306E6D),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              '$author • $date',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF3E4949),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(
                title: title,
                author: author,
                date: date,
                tag: tag,
                imageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&q=80&w=400',
              ),
            ),
          );
        },
      ),
    );
  }
}

// Article Detail Screen
class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String tag;
  final String imageUrl;

  const ArticleDetailScreen({
    Key? key,
    required this.title,
    required this.author,
    required this.date,
    required this.tag,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Article',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0EEED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF306E6D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE2E2E2),
                        child: const Icon(Icons.person, size: 20, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            author,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                          Text(
                            date,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.8,
                      color: const Color(0xFF3E4949),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.8,
                      color: const Color(0xFF3E4949),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}