import 'package:flutter/material.dart';

class RewardsRecognitionScreen extends StatefulWidget {
  const RewardsRecognitionScreen({super.key});

  @override
  State<RewardsRecognitionScreen> createState() => _RewardsRecognitionScreenState();
}

class _RewardsRecognitionScreenState extends State<RewardsRecognitionScreen> {
  // Local state for dashboard details
  double _totalDistributed = 15400.0;
  double _availablePayout = 5200.0;
  int _activeContributors = 14;

  final List<Map<String, dynamic>> _pendingPayouts = [
    {
      'id': '1',
      'name': 'Sarah Jenkins',
      'role': 'Community Moderator',
      'amount': 1200.0,
      'date': 'Oct 14, 2025',
      'avatar': 'https://i.pravatar.cc/100?img=47',
    },
    {
      'id': '2',
      'name': 'Arjun Patel',
      'role': 'Developer Partner',
      'amount': 2500.0,
      'date': 'Oct 12, 2025',
      'avatar': 'https://i.pravatar.cc/100?img=33',
    },
    {
      'id': '3',
      'name': 'Riya Mehta',
      'role': 'Design Head',
      'amount': 1500.0,
      'date': 'Oct 15, 2025',
      'avatar': 'https://i.pravatar.cc/100?img=12',
    },
  ];

  final List<Map<String, dynamic>> _contributors = [
    {
      'rank': 1,
      'name': 'Sarah Jenkins',
      'points': 4800,
      'badge': 'Top Contributor',
      'badgeColor': Colors.amber,
      'avatar': 'https://i.pravatar.cc/100?img=47',
    },
    {
      'rank': 2,
      'name': 'Arjun Patel',
      'points': 3950,
      'badge': 'Code Ninja',
      'badgeColor': Colors.purple,
      'avatar': 'https://i.pravatar.cc/100?img=33',
    },
    {
      'rank': 3,
      'name': 'Riya Mehta',
      'points': 3200,
      'badge': 'Pixel Perfect',
      'badgeColor': Colors.teal,
      'avatar': 'https://i.pravatar.cc/100?img=12',
    },
    {
      'rank': 4,
      'name': 'Sneha Kapoor',
      'points': 2850,
      'badge': 'Rising Star',
      'badgeColor': Colors.orange,
      'avatar': 'https://i.pravatar.cc/100?img=32',
    },
  ];

  final List<Map<String, dynamic>> _activities = [
    {
      'member': 'Sarah Jenkins',
      'action': 'was awarded the "Top Contributor" badge by Admin',
      'time': '2 hours ago',
      'icon': Icons.stars_rounded,
      'color': Colors.amber,
    },
    {
      'member': 'Arjun Patel',
      'action': 'earned 450 points for completing "Stitch Integration UI"',
      'time': '1 day ago',
      'icon': Icons.military_tech_rounded,
      'color': Colors.indigo,
    },
    {
      'member': 'Riya Mehta',
      'action': 'requested a payout of ₹1,500',
      'time': '2 days ago',
      'icon': Icons.payment_rounded,
      'color': Colors.green,
    },
  ];

  void _approvePayout(String id, double amount, String name) {
    setState(() {
      _pendingPayouts.removeWhere((item) => item['id'] == id);
      _availablePayout -= amount;
      _totalDistributed += amount;
      _activities.insert(0, {
        'member': name,
        'action': 'received payout of ₹${amount.toStringAsFixed(0)} successfully',
        'time': 'Just now',
        'icon': Icons.verified_user_rounded,
        'color': Colors.green,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payout of ₹${amount.toStringAsFixed(0)} to $name approved!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendPayout(String name, double amount, String method) {
    setState(() {
      _availablePayout -= amount;
      _totalDistributed += amount;
      _activities.insert(0, {
        'member': name,
        'action': 'was sent ₹${amount.toStringAsFixed(0)} via $method',
        'time': 'Just now',
        'icon': Icons.send_rounded,
        'color': Colors.blue,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sent payout of ₹${amount.toStringAsFixed(0)} via $method!"),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _giveRecognition(String name, String badge, String note) {
    setState(() {
      _activities.insert(0, {
        'member': name,
        'action': 'was recognized with "$badge" badge: "$note"',
        'time': 'Just now',
        'icon': Icons.emoji_events_rounded,
        'color': Colors.deepOrange,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Awarded $badge to $name!"),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Rewards & Recognition",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildActionSection(),
            const SizedBox(height: 20),
            _buildPendingPayoutsSection(),
            const SizedBox(height: 20),
            _buildLeaderboardSection(),
            const SizedBox(height: 20),
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          "Total Distributed",
          "₹${_totalDistributed.toStringAsFixed(0)}",
          Icons.emoji_events,
          const [Colors.amber, Colors.orange],
        ),
        _buildStatCard(
          "Pending Payouts",
          "₹${_availablePayout.toStringAsFixed(0)}",
          Icons.payments,
          const [Colors.green, Colors.teal],
        ),
        _buildStatCard(
          "Active Contributors",
          "$_activeContributors Members",
          Icons.people_alt,
          const [Colors.indigo, Colors.blue],
        ),
        _buildStatCard(
          "Leaderboard Points",
          "14.8k Coins",
          Icons.stars,
          const [Colors.purple, Colors.pink],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 45),
              ),
              onPressed: () => _showGiveRecognitionDialog(),
              icon: const Icon(Icons.stars),
              label: const Text("Recognize", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 45),
              ),
              onPressed: () => _showSendPayoutDialog(),
              icon: const Icon(Icons.payment),
              label: const Text("Send Payout", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPayoutsSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pending Payout Requests",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_pendingPayouts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No pending requests.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pendingPayouts.length,
                separatorBuilder: (context, index) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final item = _pendingPayouts[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item['avatar']),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text("Requested ${item['date']}", style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₹${item['amount'].toStringAsFixed(0)}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade50,
                            foregroundColor: Colors.teal.shade800,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () => _showPayoutApprovalConfirmation(item),
                          child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Contributors Leaderboard",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Monthly Stats",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _contributors.length,
              itemBuilder: (context, index) {
                final member = _contributors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Text(
                          "#${member['rank']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: member['rank'] == 1 ? Colors.amber.shade700 : (member['rank'] == 2 ? Colors.grey : Colors.brown),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundImage: NetworkImage(member['avatar']),
                        radius: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (member['badgeColor'] as Color).withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                member['badge'],
                                style: TextStyle(color: member['badgeColor'], fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${member['points']} pts",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          InkWell(
                            onTap: () => _showQuickRecognizeDialog(member['name']),
                            child: const Text(
                              "Recognize",
                              style: TextStyle(color: Colors.indigo, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Recognition Feed",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activities.length,
              separatorBuilder: (context, index) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final act = _activities[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: (act['color'] as Color).withAlpha(30),
                        child: Icon(act['icon'], color: act['color'], size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black, fontSize: 12),
                                children: [
                                  TextSpan(text: "${act['member']} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: act['action'], style: TextStyle(color: Colors.grey.shade700)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(act['time'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _showPayoutApprovalConfirmation(Map<String, dynamic> payout) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Approve Payout Request"),
          content: Text("Are you sure you want to approve the payout of ₹${payout['amount'].toStringAsFixed(0)} to ${payout['name']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                Navigator.pop(context);
                _approvePayout(payout['id'], payout['amount'], payout['name']);
              },
              child: const Text("Approve", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSendPayoutDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String method = "GPay / UPI";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Send Direct Payout"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Recipient Name", hintText: "Enter contributor name"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Payout Amount (₹)", hintText: "e.g. 1500"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: method,
                    decoration: const InputDecoration(labelText: "Transfer Method"),
                    items: const [
                      DropdownMenuItem(value: "GPay / UPI", child: Text("GPay / UPI")),
                      DropdownMenuItem(value: "Bank Transfer", child: Text("Direct Bank Transfer")),
                      DropdownMenuItem(value: "E-Wallet", child: Text("E-Wallet")),
                    ],
                    onChanged: (v) {
                      setDialogState(() {
                        method = v!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (name.isEmpty || amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Name and valid positive amount are required")),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _sendPayout(name, amt, method);
                  },
                  child: const Text("Send Payout", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showGiveRecognitionDialog() {
    final nameController = TextEditingController();
    final noteController = TextEditingController();
    String badge = "Top Contributor";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Award Badge / Recognize"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Recipient Name"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: badge,
                    decoration: const InputDecoration(labelText: "Recognition Badge"),
                    items: const [
                      DropdownMenuItem(value: "Top Contributor", child: Text("🏆 Top Contributor")),
                      DropdownMenuItem(value: "Code Ninja", child: Text("💻 Code Ninja")),
                      DropdownMenuItem(value: "Pixel Perfect", child: Text("🎨 Pixel Perfect")),
                      DropdownMenuItem(value: "Team Player", child: Text("🤝 Team Player")),
                      DropdownMenuItem(value: "Rising Star", child: Text("⭐ Rising Star")),
                    ],
                    onChanged: (v) {
                      setDialogState(() {
                        badge = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: "Personalized Message", hintText: "Why are you recognizing them?"),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final note = noteController.text.trim();
                    if (name.isEmpty || note.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Name and message are required")),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _giveRecognition(name, badge, note);
                  },
                  child: const Text("Recognize", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showQuickRecognizeDialog(String name) {
    final noteController = TextEditingController();
    String badge = "Team Player";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Recognize $name"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: badge,
                    decoration: const InputDecoration(labelText: "Recognition Badge"),
                    items: const [
                      DropdownMenuItem(value: "Top Contributor", child: Text("🏆 Top Contributor")),
                      DropdownMenuItem(value: "Code Ninja", child: Text("💻 Code Ninja")),
                      DropdownMenuItem(value: "Pixel Perfect", child: Text("🎨 Pixel Perfect")),
                      DropdownMenuItem(value: "Team Player", child: Text("🤝 Team Player")),
                      DropdownMenuItem(value: "Rising Star", child: Text("⭐ Rising Star")),
                    ],
                    onChanged: (v) {
                      setDialogState(() {
                        badge = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: "Personalized Message", hintText: "Add notes..."),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
                  onPressed: () {
                    final note = noteController.text.trim();
                    if (note.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please write a message")),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _giveRecognition(name, badge, note);
                  },
                  child: const Text("Award Badge", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }
}
