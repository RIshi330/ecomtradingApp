import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MyRewardsScreen extends StatefulWidget {
  final bool isEmbedded;
  const MyRewardsScreen({super.key, this.isEmbedded = false});

  @override
  State<MyRewardsScreen> createState() => _MyRewardsScreenState();
}

class _MyRewardsScreenState extends State<MyRewardsScreen> {
  String selectedTab = "Feed"; // Feed, Leaderboard, Catalog

  int creditPoints = 2450;
  int cashbackCoupons = 450;
  int pendingCredits = 1200;

  final List<Map<String, dynamic>> pendingDecisions = [
    {"title": "Claim Q4 Bonus", "actionText": "Claim", "claimed": false},
    {"title": "Accept Peer Kudos", "actionText": "Accept", "claimed": false},
  ];

  final List<Map<String, dynamic>> achievements = [
    {
      "title": "Top Performer",
      "subtitle": "Q3 2023",
      "icon": Icons.military_tech,
      "color": Color(0xFFD4E6E5),
    },
    {
      "title": "Team Hero",
      "subtitle": "15 Shout-outs",
      "icon": Icons.groups,
      "color": Color(0xFFCDE6F4),
    },
    {
      "title": "Fast Starter",
      "subtitle": "Onboarding",
      "icon": Icons.bolt,
      "color": Color(0xFFABEEF6),
    },
    {
      "title": "Certified",
      "subtitle": "Expert Level",
      "icon": Icons.verified,
      "color": Color(0xFFB8CAC9),
    },
  ];

  final List<Map<String, dynamic>> recognitionFeed = [
    {
      "sender": "Sarah Chen",
      "recipient": "Alex Rivers",
      "time": "2h ago",
      "message": "Kudos to Alex for the Q3 lead! Your dedication to the client presentation really showed through and helped us secure the renewal. Absolute stellar performance! 🚀",
      "likes": 12,
      "commentsCount": 3,
      "liked": false,
    },
    {
      "sender": "David Miller",
      "recipient": "Design Team",
      "time": "5h ago",
      "message": "The new procurement dashboard looks fantastic. Precision minimalism at its best! Thanks for prioritizing clarity and data legibility for our ops managers.",
      "likes": 24,
      "commentsCount": 8,
      "liked": true,
    }
  ];

  final List<Map<String, dynamic>> leaderboard = [
    {"rank": "01", "name": "Elena Rodriguez", "points": "5,200 pts", "avatarLetter": "E"},
    {"rank": "02", "name": "Marcus Thorne", "points": "4,850 pts", "avatarLetter": "M"},
    {"rank": "03", "name": "Alex Rivers (You)", "points": "2,450 pts", "avatarLetter": "A", "isCurrentUser": true},
  ];

  final List<Map<String, dynamic>> catalog = [
    {
      "title": "Wallet Credit",
      "desc": "Convert points to direct cash in your payroll.",
      "cost": 1000,
      "icon": Icons.account_balance_wallet_outlined,
      "color": Color(0xFFCDE6F4),
    },
    {
      "title": "Amazon Voucher",
      "desc": "₹4,000 Digital voucher for any purchase.",
      "cost": 2000,
      "icon": Icons.shopping_cart_outlined,
      "color": Color(0xFFD4E6E5),
    },
    {
      "title": "Event Tickets",
      "desc": "Choice of sports or concert tickets.",
      "cost": 4500,
      "icon": Icons.confirmation_number_outlined,
      "color": Color(0xFFABEEF6),
    },
    {
      "title": "Extra Leave Day",
      "desc": "One additional paid vacation day.",
      "cost": 3000,
      "icon": Icons.calendar_month_outlined,
      "color": Color(0xFFCDE6F4),
    },
  ];

  void _showGiveRecognitionDialog() {
    final nameController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
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
                    "Give Recognition Shout-out",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Who do you want to recognize?",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Tell them what they did that was awesome...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final msg = messageController.text.trim();
                    if (name.isNotEmpty && msg.isNotEmpty) {
                      setState(() {
                        recognitionFeed.insert(0, {
                          "sender": "Alex Rivers",
                          "recipient": name,
                          "time": "Just now",
                          "message": msg,
                          "likes": 0,
                          "commentsCount": 0,
                          "liked": false,
                        });
                        creditPoints += 50; // Give 50 points for appreciating peers!
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Shout-out posted! Earned +50 Credit Points!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text("Post Shout-out"),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _redeemCatalogItem(String title, int cost) {
    if (creditPoints >= cost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Redeem $title?"),
          content: Text("This will use $cost points from your balance. Confirm redemption?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            FilledButton(
              onPressed: () {
                setState(() {
                  creditPoints -= cost;
                  if (title == "Wallet Credit") {
                    cashbackCoupons += 250;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Successfully redeemed $title!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text("Confirm"),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Insufficient Points"),
          content: Text("You need $cost points to redeem this item, but you only have $creditPoints points."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Rewards & Recognition", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      floatingActionButton: selectedTab != "Catalog"
          ? FloatingActionButton.extended(
              onPressed: _showGiveRecognitionDialog,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_reaction_outlined),
              label: const Text("Give Recognition"),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Redeemable Assets
            const Text("REDEEMABLE ASSETS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAssetCard("Credit Points", "$creditPoints", "Pts", "Redeem", () {
                    setState(() => selectedTab = "Catalog");
                  }),
                  const SizedBox(width: 12),
                  _buildAssetCard("Cashback Coupons", "₹$cashbackCoupons", "", "Redeem", () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cashback successfully credited to payroll!"), backgroundColor: Colors.green),
                    );
                    setState(() => cashbackCoupons = 0);
                  }),
                  const SizedBox(width: 12),
                  _buildAssetCard("Pending Credits", "₹$pendingCredits", "", "Claim", () {
                    setState(() {
                      cashbackCoupons += pendingCredits;
                      pendingCredits = 0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pending credits successfully claimed!"), backgroundColor: Colors.green),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pending Decisions
            const Text("PENDING DECISIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            ...pendingDecisions.map((decision) {
              final isClaimed = decision['claimed'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      decision['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isClaimed ? Colors.grey : AppTheme.textPrimary,
                        decoration: isClaimed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    TextButton(
                      onPressed: isClaimed
                          ? null
                          : () {
                              setState(() {
                                decision['claimed'] = true;
                                if (decision['title'].contains("Bonus")) {
                                  pendingCredits += 1200;
                                } else {
                                  creditPoints += 200;
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${decision['title']} accepted!"), backgroundColor: Colors.green),
                              );
                            },
                      child: Text(isClaimed ? "Claimed" : decision['actionText']),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),

            // Achievements Scroll
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("YOUR ACHIEVEMENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.5)),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All", style: TextStyle(fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: achievements.map((ach) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: ach['color'],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(ach['icon'], color: AppTheme.primary, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ach['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          ach['subtitle'],
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Tab bar switcher
            Row(
              children: [
                _buildTabButton("Feed", Icons.diversity_3_outlined),
                _buildTabButton("Leaderboard", Icons.leaderboard_outlined),
                _buildTabButton("Catalog", Icons.shopping_basket_outlined),
              ],
            ),
            const SizedBox(height: 16),

            // Tab contents
            if (selectedTab == "Feed") ...[
              // Elena Spotlight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.stars, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text("RECOGNITION SPOTLIGHT", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Star of the Month: Elena Rodriguez", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text("For exceptional leadership in the Q3 Digital Transformation project and mentoring 5 new team members.", style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sent congratulations to Elena!"), backgroundColor: Colors.green),
                        );
                      },
                      child: const Text("Congratulate Elena"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Announcements Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Color(0xFFD4E6E5), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.campaign, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Team-wide Announcement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text("The Engineering team has reached 100% test coverage on the core API! Pizza party on Friday! 🍕", style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.3)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton(onPressed: () {}, child: const Text("React")),
                              TextButton(onPressed: () {}, child: const Text("Share")),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shout-outs list
              ...recognitionFeed.map((feed) {
                final bool liked = feed['liked'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${feed['sender']} recognized ${feed['recipient']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
                          ),
                          Text(feed['time'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        feed['message'],
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : Colors.grey, size: 20),
                            onPressed: () {
                              setState(() {
                                feed['liked'] = !liked;
                                feed['likes'] = liked ? feed['likes'] - 1 : feed['likes'] + 1;
                              });
                            },
                          ),
                          Text("${feed['likes']}", style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment_outlined, color: Colors.grey, size: 20),
                          const SizedBox(width: 6),
                          Text("${feed['commentsCount']}", style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else if (selectedTab == "Leaderboard") ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                ),
                child: Column(
                  children: leaderboard.map((leader) {
                    final bool isCurrent = leader['isCurrentUser'] == true;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: isCurrent ? AppTheme.primary.withOpacity(0.06) : null,
                      child: Row(
                        children: [
                          Text(
                            leader['rank'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isCurrent ? AppTheme.primary : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          CircleAvatar(
                            backgroundColor: isCurrent ? AppTheme.primary : Colors.grey.shade200,
                            radius: 16,
                            child: Text(
                              leader['avatarLetter'],
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              leader['name'],
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          Text(
                            leader['points'],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ] else if (selectedTab == "Catalog") ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: catalog.length,
                itemBuilder: (context, index) {
                  final catItem = catalog[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: catItem['color'], borderRadius: BorderRadius.circular(8)),
                          child: Icon(catItem['icon'], color: AppTheme.primary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          catItem['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            catItem['desc'],
                            style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.3),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${catItem['cost']} Pts",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward, color: AppTheme.primary, size: 18),
                              onPressed: () => _redeemCatalogItem(catItem['title'], catItem['cost']),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              )
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(String title, String value, String unit, String actionLabel, VoidCallback onTap) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabName, IconData icon) {
    final bool isSelected = selectedTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tabName),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? AppTheme.primary : Colors.transparent, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppTheme.primary : Colors.grey),
              const SizedBox(width: 6),
              Text(
                tabName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primary : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
