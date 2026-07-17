import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SupportDonationsScreen extends StatefulWidget {
  final bool isEmbedded;
  const SupportDonationsScreen({super.key, this.isEmbedded = false});

  @override
  State<SupportDonationsScreen> createState() => _SupportDonationsScreenState();
}

class _SupportDonationsScreenState extends State<SupportDonationsScreen> {
  final List<Map<String, dynamic>> activities = [
    {
      "title": "Education First Foundation",
      "type": "Donation",
      "date": "Oct 24, 2023",
      "amount": "₹15,000",
      "status": "Completed",
      "statusColor": Colors.teal,
      "icon": Icons.foundation,
    },
    {
      "title": "Green Earth Alliance",
      "type": "Volunteering",
      "date": "Nov 02, 2023",
      "amount": "8 hrs",
      "status": "Verified",
      "statusColor": Colors.teal,
      "icon": Icons.eco,
    },
    {
      "title": "Rural Library Project",
      "type": "Items",
      "date": "Nov 15, 2023",
      "amount": "45 units",
      "status": "Processing",
      "statusColor": Colors.grey,
      "icon": Icons.menu_book,
    }
  ];

  void _showReceiptDialog(String foundation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Donation Receipt", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Receipt for $foundation", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Transaction ID", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text("#TXN-882910", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Date", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text("Oct 24, 2023", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text("₹15,000", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Downloading PDF Receipt..."), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text("Download PDF"),
          ),
        ],
      ),
    );
  }

  void _showShareImpactDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Share Your Impact", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: msg),
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied to clipboard! Share on social media."), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text("Copy Text"),
          ),
        ],
      ),
    );
  }

  void _showThankYouNoteDialog(String recipient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Thank You Note", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\"Dear Alex, thank you so much for your dedicated 8 hours of volunteering. Your contribution has directly helped us plant 50 new saplings in the urban forest project. We are truly grateful for your support!\"",
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "— The Green Earth Team",
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Donation Status", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Received at Warehouse", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text("Nov 16, 2023", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.sync, color: AppTheme.primary, size: 20),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sorting & Cataloging", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text("In Progress", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("In Transit to Library", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("Pending", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Support & Donations", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Impact Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            // Stat row/slider
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatCard("Total Cash Donated", "₹50,000", "12% from last month", Icons.payments),
                  const SizedBox(width: 12),
                  _buildStatCard("Items Contributed", "120 units", "Verified contributions", Icons.inventory_2),
                  const SizedBox(width: 12),
                  _buildStatCard("Volunteer Hours", "45 hrs", "Across 5 projects", Icons.volunteer_activism),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Activity Feed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...activities.map((activity) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.secondaryContainer,
                            child: Icon(activity["icon"], color: AppTheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(activity["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                                      child: Text(activity["type"], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(activity["date"], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(activity["amount"], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 15)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  CircleAvatar(radius: 3, backgroundColor: activity["statusColor"]),
                                  const SizedBox(width: 4),
                                  Text(activity["status"], style: TextStyle(color: activity["statusColor"], fontSize: 11)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          if (activity["type"] == "Donation")
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showReceiptDialog(activity["title"]),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("View Receipt", style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          if (activity["type"] == "Volunteering")
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showThankYouNoteDialog(activity["title"]),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("Thank You Note", style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          if (activity["type"] == "Items")
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showStatusDialog(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("Check Status", style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _showShareImpactDialog("I just supported ${activity["title"]} with a contribution of ${activity["amount"]}!"),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Share Impact", style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String val, String desc, IconData icon) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              Text(desc, style: const TextStyle(fontSize: 9, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
