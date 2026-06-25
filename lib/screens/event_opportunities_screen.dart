import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/index.dart';

class EventOpportunitiesScreen extends StatefulWidget {
  final bool isEmbedded;
  const EventOpportunitiesScreen({super.key, this.isEmbedded = false});

  @override
  State<EventOpportunitiesScreen> createState() => _EventOpportunitiesScreenState();
}

class _EventOpportunitiesScreenState extends State<EventOpportunitiesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Promotion', 'PR', 'Product Launch', 'Speaking', 'Sponsorship'
  
  final List<Map<String, dynamic>> _opportunities = [
    {
      'title': 'TechInnovate Summit 2024',
      'category': 'Sponsorship',
      'timeLeft': '3 weeks left',
      'date': 'Nov 12-14, 2024',
      'location': 'San Francisco, CA',
      'reach': '85k+ Reach',
      'reachDetails': '85k+ Targeted Professionals',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD_0lDjrDFuIoRM6j_zF81MXqtWHdeCRkk1sSeD-npl-yHn3qNBHDQCz3HtppeMVP-5bAlsxaPO68GDuwT1rTImFFKrjLlzCI_gF77aYoKrJ1mneYYqftx6abZnT6vA88eFDTGIoTHWuULiAXFGdq_61gJsKBhUba-28jKoAiAMD07k89AGLAVIoz40iAJzCymMLFJDfkei39QMhJjQV9eogTMpUQ2ZJw_kiQCmYJmjWpAOUDRn-e0ejHAwpi-7Jcx0KEiyVUQ6mXs',
      'isFeatured': true,
      'description': 'Unlock strategic access to top-tier industry executives and decision-makers. This opportunity allows your brand to place primary visual assets across the main networking lounge and digital signage channels throughout the 3-day activation period.',
      'benefits': [
        'High-visibility logo placement',
        'Lead generation through QR integration',
        'VIP networking dinner invitation',
        'Featured Media Interview',
      ],
      'tiers': [
        {'name': 'Gold Sponsor', 'price': 25000, 'desc': 'Maximum exposure tier including booth and logo placements.'},
        {'name': 'Silver Sponsor', 'price': 12500, 'desc': 'Standard exposure tier with networking access.'},
      ]
    },
    {
      'title': 'NextGen Robotics Expo',
      'category': 'Product Launch', // maps to 'Launch Pad'
      'timeLeft': '2 days left',
      'date': 'Oct 20-22, 2024',
      'location': 'Austin, TX',
      'reach': '15k+ Reach',
      'reachDetails': '15k+ Targeted Professionals',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCP04kmuW0_IAzwK-RkHUBODz0BAMdFyI-VoJ4rAmRBQS6NR-w-rk1jwPvISIi_aFIQgQYQcfg4Ere7INfuVoR_BEcbGx816vZXouNggsY4x4Xbg4N30nu4sbQz9MooPEAFgmSjqwe4HHXWPqif86UaJx6XTHBCwuLegOqzgALxu0DG1nLAHhCkBmf-hCaDR8NGahlVGYx20hzxhmNAEOSoDvlOJnuqrlSGzWI_Ejx2kdYhI8vd0l7WZuLNp4GT9xm_wUgM79sTfc8',
      'isFeatured': false,
      'description': 'A perfect launch pad opportunity for early-stage robotics startups looking to demonstrate key technology directly to qualified corporate enterprise buyers and venture capital groups.',
      'benefits': [
        'Demo Stage Presentation slot',
        'Featured startup profile in event newsletter',
        'Complimentary booth space and badges',
      ],
      'tiers': [
        {'name': 'Launch Partner', 'price': 8000, 'desc': 'Exclusive demo slot and dedicated press coverage.'},
      ]
    },
    {
      'title': 'Global Wellness Festival',
      'category': 'PR',
      'timeLeft': '1 week left',
      'date': 'Sept 15, 2024',
      'location': 'London, UK',
      'reach': '120k+ Attendees',
      'reachDetails': '120k+ General Audience',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDdhnq6Bs5eCjHPmfE57WT7JiCyE_PZ1pqhwZqRN6bU5TUvofYDODTXAeneRJ1mDQXigUfUqA5ogFKIW2JZgTUo2weg7LhcCsMrfOnMDcEMiCszyjkfhSILRIjwBLM3w-Dt3CovwtYwc66F1BnSuCbP2YuTyTV7IRzwibNPC7WABMNvgq7SfbuDbBZfjsEQUXHQpho3axp8DDtkMFbNZOFxFeiwgz-Z3_LfadLnL-63kh3_FpE52YrBN6tHupFvp5gUkiwFKdjs2ns',
      'isFeatured': false,
      'description': 'Tastefully integrate your brand\'s lifestyle and wellness narrative. Maximize visibility via central lounge branding and live experiential sampling areas visited by active, health-conscious consumers.',
      'benefits': [
        'Branded lounge activation zones',
        'Product placement in VIP event gift bags',
        'Integrated social media mention campaign',
      ],
      'tiers': [
        {'name': 'PR Sponsor', 'price': 10000, 'desc': 'Lounge naming rights and continuous video placement.'},
      ]
    },
    {
      'title': 'Data Leaders Forum',
      'category': 'Speaking',
      'timeLeft': 'Closed Soon',
      'date': 'Oct 05, 2024',
      'location': 'Berlin, DE',
      'reach': '5k+ Execs',
      'reachDetails': '5k+ Executive VP level',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB-ZmN1VrMiBrEt3Bv2-552Ryx_H3GeP6PYM2pTURTTcdUeyrsjXgbvrgHKOBzB0ZEJ5fYeeWK3wB_mFZpScCjK_B6qoB4gTHXqG05pnL65u4SFSWmR03jHbRNoKwrNRjdEQX27QPxGFUWNunyGutcy-qNXY0j8UoSpQaaeGOwtFuj3F-1a3CFMmPF7yjkJ1QYe0lEfc1T339-uT3QhVU-s_ZCDvLs4Tt2ftbhHBGxbc4vWIIhCyui63ERNhjgLJy5Z-GKL1SHQI5M',
      'isFeatured': false,
      'description': 'Deliver key insights in enterprise database architectures and analytics pipelines. Position your engineering leadership as domain experts to a highly specialized and technical executive audience.',
      'benefits': [
        '30-minute Main Stage speaking slot',
        'Panel moderator opportunity',
        '2 VIP networking dinner invites',
      ],
      'tiers': [
        {'name': 'Speaking Partner', 'price': 4000, 'desc': 'Moderator slots and speaker logo integration.'},
      ]
    },
    {
      'title': 'International Tennis Open',
      'category': 'Sponsorship',
      'timeLeft': '3 weeks left',
      'date': 'Dec 12-20, 2024',
      'location': 'Miami, FL',
      'reach': '2M+ Reach',
      'reachDetails': '2M+ Broadcast Reach',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBwM6PFw0xA0WR2gA0LOVCiybLBnAWJjaLKDvpuzwY5j-e8M0NB64BTWN86UW--DB-9-LpUOS3kBR9LkHc_nvOdp0qwVdI-qBCcFMxM8FGeqsxznBjhw_vmUQ9nPM48Z5ach_duURBFzRHTDMgtwYGdi0bz_RFbiDxgj5HLmc7NideHzWtPEyLUkn1kDaO-z7AWVT1B-3f6TqEVakaU8vubW4w9LYa3U8GxosbJ9draapHPxkbzeQvqJX4IuyBC1lhc0FpzGMIX81s',
      'isFeatured': false,
      'description': 'A premium global sports event. Showcase your brand across court-side digital panels and exclusive hospitality structures visited by international business executives and high-net-worth players.',
      'benefits': [
        'Court-side perimeter banner logo loops',
        'Hospitality suite branding options',
        'Official program digital insert features',
      ],
      'tiers': [
        {'name': 'Premium Partner', 'price': 30000, 'desc': 'Perimeter digital loops and suite branding options.'},
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredOpps {
    return _opportunities.where((opp) {
      if (_searchQuery.isNotEmpty) {
        final title = opp['title'].toString().toLowerCase();
        final location = opp['location'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!title.contains(query) && !location.contains(query)) {
          return false;
        }
      }

      if (_selectedCategory != 'All') {
        final chipCat = _selectedCategory.toLowerCase();
        final oppCat = opp['category'].toString().toLowerCase();
        
        // Handle "Product Launch" chip category mapping to "product launch"
        if (chipCat == 'product launch' && oppCat != 'product launch') return false;
        if (chipCat != 'product launch' && chipCat != oppCat) return false;
      }

      return true;
    }).toList();
  }

  void _showQuickView(Map<String, dynamic> opp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Quick View", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  opp['imageUrl'] as String,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      opp['category'] as String,
                      style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(opp['timeLeft'] as String, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(opp['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.groups_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(opp['reachDetails'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                opp['description'] as String,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.eventOppDetail, arguments: opp);
                      },
                      child: const Text("Full Details", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showApplyFormModal(opp);
                      },
                      child: const Text("Participate", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApplyFormModal(Map<String, dynamic> opp) {
    final companyController = TextEditingController();
    String selectedObjective = 'Brand Awareness';
    final slotsController = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        const Text("Submit Proposal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: companyController,
                      decoration: const InputDecoration(
                        labelText: "COMPANY NAME",
                        fillColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("PARTNERSHIP OBJECTIVE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    DropdownButton<String>(
                      value: selectedObjective,
                      isExpanded: true,
                      underline: Container(height: 1, color: AppTheme.outline),
                      items: ['Brand Awareness', 'Lead Generation', 'Product Launch', 'Networking / VIP Access'].map((obj) {
                        return DropdownMenuItem<String>(
                          value: obj,
                          child: Text(obj, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedObjective = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: slotsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "REQUESTED SLOTS / TIER",
                        fillColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text("Submit Application", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessOverlay();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.secondaryContainer,
                child: Icon(Icons.check_circle, size: 52, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                "Application Submitted!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Our partnership team will review your proposal and get back to you within 48 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              ...['All', 'Promotion', 'PR', 'Product Launch', 'Speaking', 'Sponsorship'].map((cat) {
                return ListTile(
                  title: Text(cat),
                  dense: true,
                  trailing: _selectedCategory == cat ? const Icon(Icons.check, color: AppTheme.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOpps;

    // Featured Opportunity Card widget
    final featured = _opportunities.firstWhere((opp) => opp['isFeatured'] == true);

    Widget content = Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text(
                "Event Opportunities",
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              backgroundColor: Colors.white,
              elevation: 0.5,
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune, color: AppTheme.primary),
                  onPressed: _showFilterDrawer,
                ),
              ],
            ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Filters Header
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                          hintText: "Search opportunities...",
                          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppTheme.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.secondaryContainer,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _showFilterDrawer,
                  ),
                ],
              ),
            ),

            // Horizontal Categories Quick Chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: ['All', 'Promotion', 'PR', 'Product Launch', 'Speaking', 'Sponsorship'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat == 'Product Launch' ? 'Launch Pad' : cat),
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
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Featured Opportunities Header
            if (_searchQuery.isEmpty && _selectedCategory == 'All') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Featured Opportunities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    TextButton(
                      onPressed: () {},
                      child: const Row(
                        children: [
                          Text("VIEW ALL", style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward, size: 14, color: AppTheme.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Featured Card
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.eventOppDetail, arguments: featured);
                },
                child: Container(
                  height: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                    image: DecorationImage(
                      image: NetworkImage(featured['imageUrl'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                "${featured['category'].toString().toUpperCase()} OPPORTUNITY",
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              featured['title'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(featured['date'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(width: 12),
                                const Icon(Icons.location_on, size: 12, color: Colors.white70),
                                const SizedBox(width: 2),
                                Text(featured['location'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                const SizedBox(width: 12),
                                const Icon(Icons.groups, size: 12, color: AppTheme.primaryContainer),
                                const SizedBox(width: 4),
                                Text(featured['reach'] as String, style: const TextStyle(color: AppTheme.primaryContainer, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Opportunities Grid List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text("All Opportunities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 8),

            filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text("No Opportunities Match Your Filter", style: TextStyle(color: Colors.grey[500])),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final opp = filtered[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    opp['imageUrl'] as String,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      border: Border(left: BorderSide(color: AppTheme.primary, width: 4)),
                                    ),
                                    child: Text(
                                      opp['category'].toString().toUpperCase(),
                                      style: const TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        opp['title'] as String,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule, size: 12, color: Colors.grey),
                                          const SizedBox(width: 2),
                                          Text(opp['timeLeft'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${opp['date']} • ${opp['location']}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Reach: ${opp['reachDetails']}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, thickness: 0.5),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () => _showQuickView(opp),
                                        child: const Text("VIEW DETAILS", style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          elevation: 0,
                                        ),
                                        onPressed: () => _showQuickView(opp),
                                        child: const Text("PARTICIPATE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isEmbedded
          ? null
          : BottomNavigationBar(
              currentIndex: 1,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: AppTheme.textSecondary,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: "Opportunities",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_turned_in_outlined),
                  label: "My Apps",
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
