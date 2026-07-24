import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';


class Btcshop extends StatefulWidget {
  const Btcshop({super.key});

  @override
  State<Btcshop> createState() => _BtcShopestate();
}

class _BtcShopestate extends State<Btcshop> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      // Integrated persistent BottomNavigationBar Shell
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: theme.colorScheme.surface,
            selectedItemColor: theme.colorScheme.onSecondaryContainer,
            unselectedItemColor: theme.colorScheme.onSurfaceVariant,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Symbols.home, true),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Symbols.category, false),
                label: 'Category',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Symbols.shopping_bag, false),
                label: 'Order',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Symbols.wallet, false),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Symbols.light, false),
                label: 'Opportunity',
              ),
            ],
          ),
        ),
      ),
      body: const MarketHomeScreen(),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive) {
    if (!isActive) return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Icon(icon));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E6E5), // secondary-container
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Icon(icon, fill: 1),
    );
  }
}

class MarketHomeScreen extends StatelessWidget {
  const MarketHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // Responsive App Header with persistent Search bar Row
        SliverAppBar(
          floating: true,
          pinned: true,
          snap: false,
          expandedHeight: 140,
          backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Symbols.arrow_back, color: theme.colorScheme.primary),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Serene Market',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: -0.5),
              ),
              Row(
                children: [
                  Icon(Symbols.location_on, size: 12, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 2),
                  Text('San Francisco, CA  •  Oct 24, 2023', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                ],
              )
            ],
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Symbols.shopping_bag, color: theme.colorScheme.primary),
                  onPressed: () {},
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3F2), // surface-container-low
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Symbols.search, color: theme.colorScheme.outline),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search for organic foods...',
                                hintStyle: TextStyle(fontSize: 14, color: Color(0xFF6E7979)),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          Icon(Symbols.mic, color: theme.colorScheme.outline),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Primary Content Stream
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildCategorySlider(theme),
              const SizedBox(height: 32),
              _buildTopSellingProducts(theme),
              const SizedBox(height: 32),
              _buildDealOfTheDay(theme),
              const SizedBox(height: 32),
              _buildRecommendedSellers(theme),
              const SizedBox(height: 32),
              _buildNewArrivals(theme),
              const SizedBox(height: 32),
              _buildTestimonialCard(theme),
              const SizedBox(height: 32),
              _buildIndustryNews(theme),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  // Section 1: Browse Categories Slider
  Widget _buildCategorySlider(ThemeData theme) {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Fresh Food', 'icon': Symbols.eco},
      {'label': 'Electronics', 'icon': Symbols.devices},
      {'label': 'Lifestyle', 'icon': Symbols.local_florist},
      {'label': 'Wellness', 'icon': Symbols.spa},
      {'label': 'Fashion', 'icon': Symbols.checkroom},
      {'label': 'Kitchen', 'icon': Symbols.countertops},
    ];

    return Column(
      children: [
        Row(
          children: [
            Text('Browse Categories', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: TextStyle(color: theme.colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4E6E5), // secondary-container
                        shape: BoxShape.circle,
                      ),
                      child: Icon(categories[index]['icon'] as IconData, color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(categories[index]['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // Section 2: Top Selling Products
  Widget _buildTopSellingProducts(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Text('Top Selling Products', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Symbols.chevron_left, size: 20)),
            IconButton(onPressed: () {}, icon: const Icon(Symbols.chevron_right, size: 20)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 270,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildProductCard(theme, 'Serene Pro Laptop X1', 'Electronics', 'Lumina Tech', '\$1,299.00', '\$1,599.00', 'SAVE 20%', Symbols.laptop, true),
              _buildProductCard(theme, 'Organic Linen Overcoat', 'Fashion', 'EcoWeave', '\$89.00', null, 'NEW ARRIVAL', Symbols.checkroom, false),
              _buildProductCard(theme, 'Serene Acoustics H1', 'Audio', 'Sonic Bloom', '\$349.00', '\$399.00', 'SAVE 15%', Symbols.headphones, false),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProductCard(ThemeData theme, String name, String category, String seller, String price, String? oldPrice, String tag, IconData icon, bool showHeart) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0EDED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                color: const Color(0xFFF6F3F2),
                child: Icon(icon, size: 44, color: const Color(0xFFBDC9C8)),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(99)),
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
              if (showHeart)
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: Icon(Symbols.favorite, size: 16, color: theme.colorScheme.primary, fill: 1),
                  ),
                )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.toUpperCase(), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Sold by: $seller', style: TextStyle(color: theme.colorScheme.outline, fontSize: 11)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(price, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                        if (oldPrice != null) Text(oldPrice, style: TextStyle(color: theme.colorScheme.outline, fontSize: 11, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Symbols.add_shopping_cart, size: 18, color: Colors.white),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Section 3: Deal of the Day (Grid Stack Optimizations)
  Widget _buildDealOfTheDay(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deal of the Day', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
          Text('Handpicked essentials at competitive rates.', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('ENDS IN: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,)),
              _buildTimeBlock(theme, '12'),
              const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeBlock(theme, '45'),
              const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTimeBlock(theme, '32'),
            ],
          ),
          const SizedBox(height: 16),
          _buildDealCard(theme, 'Organic Fruit Box', 'Fresh from our local farms', '\$24.99', 'HOT DEAL', Symbols.restaurant),
          const SizedBox(height: 12),
          _buildDealCard(theme, 'Smart Speaker Pro', 'AI-driven audio excellence', '\$129.00', 'TECH PICK', Symbols.smart_toy),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(ThemeData theme, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(6)),
      child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildDealCard(ThemeData theme, String title, String subtitle, String price, String banner, IconData icon) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 140,
              height: double.infinity,
              color: const Color(0xFFF6F3F2).withOpacity(0.15),
              child: Icon(icon, color: Colors.white, size: 54),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black, Colors.transparent], begin: Alignment.centerLeft, end: Alignment.centerRight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: banner == 'HOT DEAL' ? const Color(0xFFBA1A1A) : theme.colorScheme.primary,
                  child: Text(banner, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Grab Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Section 4: Recommended Sellers
  Widget _buildRecommendedSellers(ThemeData theme) {
    final sellers = [
      {'name': 'Lumina Global', 'badge': '#1', 'rating': '4.9', 'deals': '(12k+)', 'tag': 'PREMIUM SELLER', 'color': theme.colorScheme.primary},
      {'name': 'EcoWeave Arts', 'badge': '#2', 'rating': '4.8', 'deals': '(8k+)', 'tag': 'VERIFIED MERCHANT', 'color': theme.colorScheme.secondary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recommended Sellers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('Explore More', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: sellers.map((seller) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAE7E7)),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(radius: 26, backgroundColor: Colors.white, child: Icon(Symbols.store, color: Color(0xFF006565))),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: seller['color'] as Color, shape: BoxShape.circle),
                            child: Text(seller['badge'] as String, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(seller['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Symbols.star, size: 12, color: Colors.amber, fill: 1),
                        Text(' ${seller['rating']} ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(seller['deals'] as String, style: TextStyle(color: theme.colorScheme.outline, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(seller['tag'] as String, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // Section 5: New Arrivals
  Widget _buildNewArrivals(ThemeData theme) {
    final products = [
      {'title': 'AeroSprint Runner', 'price': '\$129.00', 'icon': Symbols.steps},
      {'title': 'Serene Studio Buds', 'price': '\$199.00', 'icon': Symbols.earbuds},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('New Arrivals', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('Explore New', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: products.map((item) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFFF6F3F2), borderRadius: BorderRadius.circular(16)),
                      child: Icon(item['icon'] as IconData, color: const Color(0xFFBDC9C8), size: 40),
                    ),
                    const SizedBox(height: 6),
                    Text(item['title'].toString()!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(item['price'].toString()!, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // Section 6: Client Testimonials
  Widget _buildTestimonialCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Text('What Our Clients Say', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF0EDED))),
            child: Column(
              children: [
                CircleAvatar(backgroundColor: theme.colorScheme.primary, radius: 14, child: const Icon(Symbols.format_quote, size: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (_) => const Icon(Symbols.star, size: 14, color: Colors.amber, fill: 1)),
                ),
                const SizedBox(height: 8),
                Text(
                  '"The delivery was incredibly fast and the packaging was completely sustainable. Serene Market has truly changed how I shop."',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: const BoxDecoration(color: Color(0xFFF0EDED), shape: BoxShape.circle),
                      child: const Text('SC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sarah Chen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('PREMIUM MEMBER', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Section 7: Industry News & Updates
  Widget _buildIndustryNews(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Industry News & Trends', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('Read Journal', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0EDED)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 130, color: const Color(0xFFF0EDED), width: double.infinity, child: const Icon(Symbols.agriculture, size: 44, color: Color(0xFFBDC9C8))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                      child: const Text('SUSTAINABILITY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF576867))),
                    ),
                    const SizedBox(height: 8),
                    const Text('The Future of Vertical Farming in Urban Areas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(radius: 12, backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: const Text('JD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 6),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('James Dorian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('Oct 20, 2023', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        Icon(Symbols.visibility, size: 16, color: theme.colorScheme.outline),
                        const SizedBox(width: 10),
                        Icon(Symbols.share, size: 16, color: theme.colorScheme.outline),
                        const SizedBox(width: 10),
                        Icon(Symbols.bookmark, size: 16, color: theme.colorScheme.outline),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}