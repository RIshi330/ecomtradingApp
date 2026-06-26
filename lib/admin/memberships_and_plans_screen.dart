import 'package:flutter/material.dart';

class MembershipsAndPlansScreen extends StatefulWidget {
  final bool isEmbedded;
  const MembershipsAndPlansScreen({super.key, this.isEmbedded = false});

  @override
  State<MembershipsAndPlansScreen> createState() => _MembershipsAndPlansScreenState();
}

class _MembershipsAndPlansScreenState extends State<MembershipsAndPlansScreen> {
  bool _isAnnual = true;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Visual Styling constants matching app theme
  static const Color primaryTeal = Color(0xff006565);
  static const Color accentTeal = Color(0xff008080);
  static const Color containerTeal = Color(0xffe3fffe);
  static const Color surfaceWhite = Colors.white;
  static const Color borderTeal = Color(0xffbdc9c8);
  static const Color textDark = Color(0xff1a1c1c);
  static const Color textMuted = Color(0xff3e4949);
  static const Color bgLight = Color(0xfff9f9f9);
  static const Color darkTeal = Color(0xff2f3131);

  // Active Member Directory mock data
  final List<Map<String, dynamic>> _allMembers = [
    {
      "name": "Apex Logistics",
      "category": "Industrial Supply",
      "initials": "AL",
      "tier": "STRATEGIC",
      "status": "Active",
      "date": "Oct 12, 2021",
      "revenue": "₹12 Cr",
    },
    {
      "name": "Vivid Media",
      "category": "Digital Services",
      "initials": "VM",
      "tier": "GOLD",
      "status": "Active",
      "date": "Jan 05, 2023",
      "revenue": "₹2 Cr",
    },
    {
      "name": "Solaris Tech",
      "category": "Sustainable Hardware",
      "initials": "ST",
      "tier": "SILVER",
      "status": "Pending Review",
      "date": "Mar 22, 2024",
      "revenue": "₹68 Lakhs",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showActionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: accentTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter active members based on search query
    final filteredMembers = _allMembers.where((m) {
      final nameMatches = m["name"].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final catMatches = m["category"].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final tierMatches = m["tier"].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatches || catMatches || tierMatches;
    }).toList();

    Widget contentBody = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          const Text(
            "Memberships & Plans",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textDark,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Configure ecosystem access tiers and monitor active vendor distributions.",
            style: TextStyle(
              fontSize: 14,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // Pricing Toggle
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x0a000000),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isAnnual = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isAnnual ? accentTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        "ANNUAL",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isAnnual ? Colors.white : textMuted,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isAnnual = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isAnnual ? accentTeal : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        "MONTHLY",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !_isAnnual ? Colors.white : textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tier Cards Stack
          _buildTierCards(),

          const SizedBox(height: 32),

          // Active Member Directory Table Card
          _buildActiveMemberDirectory(filteredMembers),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return Container(
        color: bgLight,
        child: contentBody,
      );
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Memberships & Plans",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontFamily: 'Manrope', fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: contentBody,
    );
  }

  Widget _buildTierCards() {
    return Column(
      children: [
        // 1. Bronze Card
        _buildTierCard(
          label: "BASE ENTRY",
          title: "Bronze",
          price: _isAnnual ? "₹0" : "₹0",
          period: _isAnnual ? "/yr" : "/mo",
          borderColor: Colors.grey.shade400,
          features: [
            "Standard Marketplace Access",
            "Limited Listing Capacity (5)",
            "Community Forum Access",
          ],
          buttonText: "Manage Access",
          buttonOnPressed: () => _showActionDialog("Bronze Plan Access", "You have Bronze level basic access active by default."),
        ),
        const SizedBox(height: 16),

        // 2. Silver Card
        _buildTierCard(
          label: "GROWTH FOCUSED",
          title: "Silver",
          price: _isAnnual ? "₹1,00,000" : "₹9,000",
          period: _isAnnual ? "/yr" : "/mo",
          borderColor: const Color(0xff296767),
          features: [
            "Unlimited Listing Capacity",
            "Priority Search Placement",
            "Analytics Dashboard Basic",
            "Direct Messaging Support",
          ],
          buttonText: "Manage Access",
          buttonOnPressed: () => _showActionDialog("Upgrade to Silver", "A billing request to update your plan to Silver will be sent to finance."),
        ),
        const SizedBox(height: 16),

        // 3. Gold Card (Highlighted Active Choice)
        _buildTierCard(
          label: "HIGH PERFORMANCE",
          title: "Gold",
          price: _isAnnual ? "₹4,00,000" : "₹36,000",
          period: _isAnnual ? "/yr" : "/mo",
          borderColor: accentTeal,
          isGoldHighlight: true,
          features: [
            "All Silver Features Included",
            "Premium Brand Hub Customization",
            "Dedicated Relationship Manager",
            "Early Access to Tech Launches",
          ],
          buttonText: "Edit Tier Specs",
          buttonOnPressed: () => _showActionDialog("Gold Tier Specs", "Access configuration panel for Gold level properties."),
        ),
        const SizedBox(height: 16),

        // 4. Strategic Card (Dark Theme)
        _buildTierCard(
          label: "ELITE PARTNERSHIPS",
          title: "Strategic",
          price: "Custom",
          period: _isAnnual ? "/yr" : "/mo",
          borderColor: const Color(0xff76d6d5),
          isDarkTheme: true,
          features: [
            "Board-Level Governance Rights",
            "Joint Venture Opportunity Access",
            "White-Glove Technical Integration",
            "Exclusive Beta Testing Rights",
          ],
          buttonText: "Customize Offer",
          buttonOnPressed: () => _showActionDialog("Strategic Quote", "Please contact administrative partnership desk to customize Strategic SLA."),
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required String label,
    required String title,
    required String price,
    required String period,
    required Color borderColor,
    required List<String> features,
    required String buttonText,
    required VoidCallback buttonOnPressed,
    bool isGoldHighlight = false,
    bool isDarkTheme = false,
  }) {
    Color bg = surfaceWhite;
    Color labelColor = textMuted;
    Color titleColor = textDark;
    Color priceColor = textDark;
    Color bulletColor = accentTeal;
    Color descColor = textMuted;

    if (isGoldHighlight) {
      bg = containerTeal;
      labelColor = const Color(0xff064f4f);
    } else if (isDarkTheme) {
      bg = darkTeal;
      labelColor = const Color(0xff76d6d5);
      titleColor = Colors.white;
      priceColor = Colors.white;
      bulletColor = const Color(0xff76d6d5);
      descColor = Colors.white70;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: isGoldHighlight 
            ? Border.all(color: accentTeal, width: 2) 
            : Border.all(color: borderTeal.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Accent left bar (for non-highlight/non-dark cards)
          if (!isGoldHighlight && !isDarkTheme)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(color: borderColor),
            ),

          if (isDarkTheme)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(color: borderColor),
            ),

          // "Popular Choice" tag for Gold card
          if (isGoldHighlight)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: accentTeal,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                ),
                child: const Text(
                  "POPULAR CHOICE",
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: labelColor, letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: priceColor),
                    ),
                    Text(
                      period,
                      style: TextStyle(fontSize: 13, color: descColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Column(
                  children: features.map((f) {
                    final bool isFeatureHighlight = isGoldHighlight && f.startsWith("All Silver");
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isFeatureHighlight ? Icons.check_circle : Icons.check_circle_outline,
                            color: bulletColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 13,
                                color: descColor,
                                fontWeight: isFeatureHighlight ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: isGoldHighlight
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 0),
                            backgroundColor: accentTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: buttonOnPressed,
                          child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        )
                      : isDarkTheme
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 0),
                                backgroundColor: Colors.white,
                                foregroundColor: darkTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: buttonOnPressed,
                              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            )
                          : OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 0),
                                side: const BorderSide(color: accentTeal),
                                foregroundColor: accentTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: buttonOnPressed,
                              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActiveMemberDirectory(List<Map<String, dynamic>> members) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTeal.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header title block
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Active Member Directory",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Search members...",
                            hintStyle: const TextStyle(fontSize: 13, color: textMuted),
                            prefixIcon: const Icon(Icons.search, size: 18, color: textMuted),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            filled: true,
                            fillColor: bgLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderTeal.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderTeal.withOpacity(0.5)),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 0),
                          side: BorderSide(color: borderTeal.withOpacity(0.5)),
                          foregroundColor: textMuted,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: const Icon(Icons.filter_list, size: 16),
                        label: const Text("FILTER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _showActionDialog("Filter Members", "Additional category filter parameters can be configured here.");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Horizontal scrollable Table view to prevent overlaps
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: borderTeal.withOpacity(0.3),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(bgLight),
                headingTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted),
                dataTextStyle: const TextStyle(fontSize: 13, color: textDark),
                horizontalMargin: 16,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text("MEMBER DETAILS")),
                  DataColumn(label: Text("MEMBERSHIP TIER")),
                  DataColumn(label: Text("STATUS")),
                  DataColumn(label: Text("JOINED DATE")),
                  DataColumn(label: Text("REVENUE (YTD)")),
                  DataColumn(label: Text("ACTIONS")),
                ],
                rows: members.map((m) {
                  // Initials block background color logic
                  Color logoBg = borderTeal.withOpacity(0.3);
                  Color logoTxt = primaryTeal;
                  if (m["tier"] == "STRATEGIC") {
                    logoBg = const Color(0xffeaeaea);
                    logoTxt = darkTeal;
                  } else if (m["tier"] == "GOLD") {
                    logoBg = containerTeal;
                    logoTxt = accentTeal;
                  }

                  // Status dot indicator color logic
                  Color dotColor = Colors.green;
                  if (m["status"] == "Pending Review") {
                    dotColor = Colors.orange;
                  }

                  // Tier badge style logic
                  Color badgeBg = Colors.grey.shade100;
                  Color badgeText = textMuted;
                  if (m["tier"] == "STRATEGIC") {
                    badgeBg = darkTeal;
                    badgeText = const Color(0xff76d6d5);
                  } else if (m["tier"] == "GOLD") {
                    badgeBg = containerTeal;
                    badgeText = accentTeal;
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: logoBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                m["initials"],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: logoTxt),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(m["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(m["category"], style: const TextStyle(fontSize: 10, color: textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m["tier"],
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeText),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(m["status"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      DataCell(Text(m["date"])),
                      DataCell(Text(m["revenue"], style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 18, color: textMuted),
                          onPressed: () {
                            _showActionDialog("Member Options", "Management actions for ${m['name']} can be executed here.");
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Directory table footer block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: bgLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Showing ${members.length} of ${_allMembers.length} Members",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMuted),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
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
