import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/index.dart';

class EventMarketplaceScreen extends StatefulWidget {
  final bool isEmbedded;
  const EventMarketplaceScreen({super.key, this.isEmbedded = false});

  @override
  State<EventMarketplaceScreen> createState() => _EventMarketplaceScreenState();
}

class _EventMarketplaceScreenState extends State<EventMarketplaceScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Events';
  double _maxPriceFilter = 1000.0;
  List<String> _selectedFilterCategories = [];
  String _selectedDateFilter = 'All'; // 'All', 'Today', 'This Week', 'Next Month'
  
  // Set to track favorited event titles
  final Set<String> _favoritedEvents = {};

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Global Tech Innovators 2024',
      'category': 'CONFERENCE',
      'price': 299.00,
      'priceDisplay': r'$299',
      'organizer': 'Jane Doe Events',
      'organizerInitials': 'JD',
      'date': 'Oct 24',
      'dateFull': 'Oct 24, 2024',
      'time': '09:00 AM - 05:00 PM',
      'location': 'NY',
      'locationFull': 'Grand Convention Center, NY',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuArYsWiwRgpAb4MQtQ25fR5umxh1z8z8d-IlkHtAMiD2OfZaXmqem9sMeybtOF4gBOs-yVAZVKHhWkPXf6YCA88IXrgcGBnwmT0xYcywS3neYsCcb4VYjONRiZnfx7WKB1JnrqnS8QZ_ottOSG3xdV91QNGcXV1zkoUgk0VDEw7euvDpyeXtv_hfze9QFYHZoKyJPXN0LutuRTKd70oVy-e9bxkhSLBsydEuJtZwyBx_yM7SvSqbuzyTz7Fp6jKFk_A00ihtwfB85g',
      'organizerImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDmoOu1G9uIlwgGgknzmgcbzYqwf67jzt8kSW9IJ0wXQrurhhLAXA49QDYWPAo8dHp3K1ZC6Wm7kvByBdxbVmYRtVbAiQtYxX1uWIJf1aV1dgmwjaxjIfrEqW1PSdgYVIo6fsx4Mf1X04R3kFM-_cG_8pvVHoCVwyG0SKnRJ_-8zy_5kQco_fVfJSEhOKJ630KY2gRhANjPEsqYmgWDT_1flGn7buGfAgFmVy87nPY2E_4npQo3hz0_Pg3se1ZhD8aU59JchG-1cn8',
      'rating': 4.8,
      'reviewsCount': 120,
      'about': 'The Global Tech Summit 2024 is the premier destination for visionaries, technologists, and entrepreneurs. This year, we\'re diving deep into generative AI, sustainable computing, and the future of decentralized networks. Join us for a day of transformative keynotes, interactive workshops, and high-level networking designed to shape the next decade of technology.',
      'tags': ['ArtificialIntelligence', 'SustainableTech', 'Networking'],
    },
    {
      'title': 'Mindful Pottery Masterclass',
      'category': 'WORKSHOP',
      'price': 45.00,
      'priceDisplay': r'$45',
      'organizer': 'Artisan Studio',
      'organizerInitials': 'AS',
      'date': 'Nov 12',
      'dateFull': 'Nov 12, 2024',
      'time': '10:00 AM - 02:00 PM',
      'location': 'London',
      'locationFull': 'Crafts & Clay Studio, London',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA1ObENaoCDMsehxkMcAHPzxPD9oi-pCn0iSLywtT90OzlXVh8k5GB0a-M48vPfdW785O0finRiA7K0VVoNI4JNZpWzK3nUUFwRoD7L4hMjFBqXH0HzQRUgTPTicqGQvN1etcWTBjeqD7yXxRpRFtoiZYzWJarjOts_PSbuNXdW7sRW-Ab4Rx0i4He_V1BJUD8Zk6RrJFjsgM2hzjioIZ-cwonfXPA4beUVRXz8u9sd_V-6Au4hRPA7mCpyXT1pM_dPO2kbYNyTGMc',
      'organizerImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDmoOu1G9uIlwgGgknzmgcbzYqwf67jzt8kSW9IJ0wXQrurhhLAXA49QDYWPAo8dHp3K1ZC6Wm7kvByBdxbVmYRtVbAiQtYxX1uWIJf1aV1dgmwjaxjIfrEqW1PSdgYVIo6fsx4Mf1X04R3kFM-_cG_8pvVHoCVwyG0SKnRJ_-8zy_5kQco_fVfJSEhOKJ630KY2gRhANjPEsqYmgWDT_1flGn7buGfAgFmVy87nPY2E_4npQo3hz0_Pg3se1ZhD8aU59JchG-1cn8',
      'rating': 4.9,
      'reviewsCount': 42,
      'about': 'Discover the ancient art of wheel throwing and handbuilding pottery. This mindful session focuses on tactile grounding and organic design under the guidance of master potters. All materials and post-firing glazing are included.',
      'tags': ['Pottery', 'Mindfulness', 'Artisan'],
    },
    {
      'title': 'Exec Connect: Winter Mixer',
      'category': 'NETWORKING',
      'price': 0.00,
      'priceDisplay': 'FREE',
      'organizer': 'Business Network',
      'organizerInitials': 'BN',
      'date': 'Dec 05',
      'dateFull': 'Dec 05, 2024',
      'time': '06:00 PM - 09:00 PM',
      'location': 'Chicago',
      'locationFull': 'Skyline Executive Club, Chicago',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAaxyS12YFQQVZAP9nUy51_TQ1sbrJqiU-7emRpYIcLqfDNsabkN9IFSneJs6XVJh9qcQfwAvdXhZ8Q3rp1P1r7HNVn1hFEVCZob8mQuopfEZe26bnulDLSyZYUS0DFJnTw2sCE_vSoHwMzeAfMxbMDh7GQj-ztWvSx3xu_F5P2IHuIeVpI8f_Dgv2dMfsekKlSlsmvUVddOwsV6JUKls6oDTDEV2OfVd-pwD59LSvqX79rpY4a2EPU3ZEFHnHDaHSn3VzDvsBseW8',
      'organizerImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDmoOu1G9uIlwgGgknzmgcbzYqwf67jzt8kSW9IJ0wXQrurhhLAXA49QDYWPAo8dHp3K1ZC6Wm7kvByBdxbVmYRtVbAiQtYxX1uWIJf1aV1dgmwjaxjIfrEqW1PSdgYVIo6fsx4Mf1X04R3kFM-_cG_8pvVHoCVwyG0SKnRJ_-8zy_5kQco_fVfJSEhOKJ630KY2gRhANjPEsqYmgWDT_1flGn7buGfAgFmVy87nPY2E_4npQo3hz0_Pg3se1ZhD8aU59JchG-1cn8',
      'rating': 4.7,
      'reviewsCount': 85,
      'about': 'Connect with regional industry leaders, high-growth startups, and established enterprises in an informal evening setup. Facilitated matchmaking and curated discussion circles ensure productive networking opportunities.',
      'tags': ['Business', 'Networking', 'Mixer'],
    },
    {
      'title': 'Abstract Horizons: Opening Night',
      'category': 'ART',
      'price': 15.00,
      'priceDisplay': r'$15',
      'organizer': 'Modern Gallery',
      'organizerInitials': 'MG',
      'date': 'Oct 28',
      'dateFull': 'Oct 28, 2024',
      'time': '07:00 PM - 10:00 PM',
      'location': 'NY',
      'locationFull': 'Contemporary Art Hall, NY',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCjyQdfM9IhQa4pGK-oTjmj-gZVB4wZhn_6qyQt9aZOKZij1m22qOgaS9V41HLJ3ahqcFmYlNwD_hCO2mPsA-bov3IJ2bYKGV1i_MQdtNM6O2VP3U2M1MiWOdHh9-BBqvX4XIh6zkNQ9sPIHvl-tOtME2VM5f33rdugpvehf8dZyhvJijVy5mOU7zZzN5JMd_KiHAKIIvhHbzy7FVHLQ7t-IcFYalEUhvE9k8js06RPT1jb4R6B5pcwcM9YuWs2A7BbNSvWy4Q16rc',
      'organizerImageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDmoOu1G9uIlwgGgknzmgcbzYqwf67jzt8kSW9IJ0wXQrurhhLAXA49QDYWPAo8dHp3K1ZC6Wm7kvByBdxbVmYRtVbAiQtYxX1uWIJf1aV1dgmwjaxjIfrEqW1PSdgYVIo6fsx4Mf1X04R3kFM-_cG_8pvVHoCVwyG0SKnRJ_-8zy_5kQco_fVfJSEhOKJ630KY2gRhANjPEsqYmgWDT_1flGn7buGfAgFmVy87nPY2E_4npQo3hz0_Pg3se1ZhD8aU59JchG-1cn8',
      'rating': 4.6,
      'reviewsCount': 30,
      'about': 'Join the visual art community for the opening night of "Abstract Horizons." Experience multi-medium installations, interactive installations, and engage directly with the artists over complimentary cocktails.',
      'tags': ['Art', 'Exhibition', 'Contemporary'],
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    return _events.where((event) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final title = event['title'].toString().toLowerCase();
        final organizer = event['organizer'].toString().toLowerCase();
        final location = event['locationFull'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!title.contains(query) && !organizer.contains(query) && !location.contains(query)) {
          return false;
        }
      }

      // 2. Quick Chips Filter
      if (_selectedCategory != 'All Events') {
        final chipCategory = _selectedCategory.toLowerCase();
        final eventCategory = event['category'].toString().toLowerCase();
        
        // Match plural forms like 'Workshops' to 'WORKSHOP', 'Conferences' to 'CONFERENCE', etc.
        if (chipCategory == 'workshops' && eventCategory != 'workshop') return false;
        if (chipCategory == 'conferences' && eventCategory != 'conference') return false;
        if (chipCategory == 'networking' && eventCategory != 'networking') return false;
        if (chipCategory == 'music' && eventCategory != 'music') return false;
        if (chipCategory == 'art' && eventCategory != 'art') return false;
      }

      // 3. Filter Drawer - Categories
      if (_selectedFilterCategories.isNotEmpty) {
        final eventCategory = event['category'].toString().toLowerCase();
        final matched = _selectedFilterCategories.any((cat) => cat.toLowerCase() == eventCategory);
        if (!matched) return false;
      }

      // 4. Filter Drawer - Price
      if (event['price'] > _maxPriceFilter) {
        return false;
      }

      // 5. Filter Drawer - Date (Mock Logic)
      if (_selectedDateFilter != 'All') {
        final dateStr = event['date'].toString().toLowerCase();
        if (_selectedDateFilter == 'Today' && !dateStr.contains('oct 24')) return false;
        if (_selectedDateFilter == 'This Week' && !(dateStr.contains('oct 24') || dateStr.contains('oct 28'))) return false;
        if (_selectedDateFilter == 'Next Month' && !dateStr.contains('nov')) return false;
      }

      return true;
    }).toList();
  }

  void _toggleFavorite(String title) {
    setState(() {
      if (_favoritedEvents.contains(title)) {
        _favoritedEvents.remove(title);
      } else {
        _favoritedEvents.add(title);
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Price Range
                    const Text(
                      "PRICE RANGE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₹0", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        Text("₹${_maxPriceFilter.toInt()}+", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _maxPriceFilter,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.secondaryContainer,
                      onChanged: (val) {
                        setModalState(() {
                          _maxPriceFilter = val;
                        });
                        setState(() {
                          _maxPriceFilter = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Category Checklist
                    const Text(
                      "CATEGORY",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Workshop', 'Conference', 'Networking', 'Exhibition'].map((cat) {
                        final isSelected = _selectedFilterCategories.contains(cat);
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppTheme.primary.withOpacity(0.15),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : AppTheme.outline,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                _selectedFilterCategories.add(cat);
                              } else {
                                _selectedFilterCategories.remove(cat);
                              }
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Date Selectors
                    const Text(
                      "DATE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...['All', 'Today', 'This Week', 'Next Month'].map((dateOpt) {
                      return RadioListTile<String>(
                        title: Text(dateOpt, style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
                        value: dateOpt,
                        groupValue: _selectedDateFilter,
                        activeColor: AppTheme.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              _selectedDateFilter = val;
                            });
                            setState(() {
                              _selectedDateFilter = val;
                            });
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 32),

                    // Reset and Apply Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setModalState(() {
                                _maxPriceFilter = 1000.0;
                                _selectedFilterCategories = [];
                                _selectedDateFilter = 'All';
                              });
                              setState(() {
                                _maxPriceFilter = 1000.0;
                                _selectedFilterCategories = [];
                                _selectedDateFilter = 'All';
                              });
                            },
                            child: const Text("Reset", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Apply Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEvents;

    Widget content = Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text(
                "Serene Events",
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0.5,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.primary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: AppTheme.primary),
                  onPressed: _showFilterSheet,
                ),
              ],
            ),
      body: Column(
        children: [
          // Header / Search Bar (Only shown if embedded or as static header)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search events...",
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _showFilterSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tune, color: AppTheme.primary, size: 20),
                        SizedBox(width: 6),
                        Text(
                          "Filter",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories Horizontal Quick Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                'All Events',
                'Workshops',
                'Conferences',
                'Networking',
                'Music',
                'Art',
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surfaceContainer.withOpacity(0.5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Grid View
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "No Events Found",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Try resetting your filters or search keywords.",
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 0.54,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final ev = filtered[idx];
                      final isFavorited = _favoritedEvents.contains(ev['title']);
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: ev);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                            border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero image with badge & favorite button
                              Expanded(
                                flex: 5,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        image: DecorationImage(
                                          image: NetworkImage(ev['imageUrl'] as String),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Image overlay black shadow gradient
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.4),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Favorite button
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white.withOpacity(0.85),
                                        child: IconButton(
                                          icon: Icon(
                                            isFavorited ? Icons.favorite : Icons.favorite_border,
                                            size: 16,
                                            color: Colors.redAccent,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _toggleFavorite(ev['title'] as String),
                                        ),
                                      ),
                                    ),
                                    // Category badge
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryContainer.withOpacity(0.95),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          ev['category'] as String,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Text content & buy button
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ev['title'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            ev['priceDisplay'] as String,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.primaryContainer,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    ev['organizerInitials'] as String,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  ev['organizer'] as String,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textSecondary),
                                              const SizedBox(width: 4),
                                              Text(
                                                ev['date'] as String,
                                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textSecondary),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(
                                                  ev['location'] as String,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: ev);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          minimumSize: const Size.fromHeight(34),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          ev['price'] == 0 ? "Reserve Spot" : "Buy Tickets",
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isEmbedded
          ? null
          : BottomNavigationBar(
              currentIndex: 0,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: AppTheme.textSecondary,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: "Explore",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  label: "Tickets",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_outline),
                  label: "Saved",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: "Profile",
                ),
              ],
            ),
    );

    return widget.isEmbedded ? content : SafeArea(child: content);
  }
}
