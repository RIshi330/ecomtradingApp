import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class UpcomingEventsScreen extends StatefulWidget {
  final bool isEmbedded;
  const UpcomingEventsScreen({super.key, this.isEmbedded = false});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  String selectedTab = "Upcoming";

  final List<Map<String, dynamic>> upcomingEvents = [
    {
      "title": "Global Ecommerce Summit 2024",
      "date": "Nov 15-17, 2026",
      "location": "Chicago Conference Center",
      "type": "EXECUTIVE VIP",
      "image": "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=GES2024-VIP-12345",
      "seat": "Seat 4G",
    },
    {
      "title": "Supply Chain Strategy Workshop",
      "date": "Dec 05, 2026",
      "location": "Virtual Suite",
      "type": "STANDARD ACCESS",
      "image": "",
      "seat": "",
    }
  ];

  final List<Map<String, dynamic>> pastEvents = [
    {
      "title": "Global Logistics Forum 2025",
      "date": "Oct 12-14, 2025",
      "location": "New York Convention Center",
      "type": "COMPLETED",
    }
  ];

  void _showTicketDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Digital Pass", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: event["image"].toString().isNotEmpty
                  ? Image.network(event["image"], width: 140, height: 140)
                  : const Icon(Icons.qr_code_2, size: 140, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(event["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text("Seat: ${event["seat"]}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Downloading PDF Ticket..."), backgroundColor: Colors.green),
              );
            },
            child: const Text("Download PDF"),
          ),
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
              title: const Text("My Event Tickets", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      body: Column(
        children: [
          // Registration hero card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Active Registrations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 2),
                      Text("You have 2 upcoming events scheduled", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.outline.withOpacity(0.4))),
                  child: const Row(
                    children: [
                      Column(
                        children: [
                          Text("TOTAL VALUE", style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text("\$1,850", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14)),
                        ],
                      ),
                      VerticalDivider(width: 24),
                      Column(
                        children: [
                          Text("REWARDS", style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text("12k", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = "Upcoming"),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: selectedTab == "Upcoming" ? AppTheme.primary : Colors.transparent, width: 2)),
                      ),
                      child: Text("Upcoming", style: TextStyle(fontWeight: selectedTab == "Upcoming" ? FontWeight.bold : FontWeight.normal, color: selectedTab == "Upcoming" ? AppTheme.primary : AppTheme.textSecondary)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = "Past Events"),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: selectedTab == "Past Events" ? AppTheme.primary : Colors.transparent, width: 2)),
                      ),
                      child: Text("Past Events", style: TextStyle(fontWeight: selectedTab == "Past Events" ? FontWeight.bold : FontWeight.normal, color: selectedTab == "Past Events" ? AppTheme.primary : AppTheme.textSecondary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: selectedTab == "Upcoming"
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: upcomingEvents.length,
                    itemBuilder: (context, index) {
                      final event = upcomingEvents[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                                  child: Text(event["type"], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                ),
                                const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(event["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(event["date"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(event["location"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => _showTicketDialog(event),
                                    icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                                    label: const Text("View Ticket"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Opening directions in Maps..."), backgroundColor: AppTheme.primary),
                                      );
                                    },
                                    icon: const Icon(Icons.near_me_outlined, size: 16),
                                    label: const Text("Directions"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pastEvents.length,
                    itemBuilder: (context, index) {
                      final event = pastEvents[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                              child: Text(event["type"], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                            const SizedBox(height: 12),
                            Text(event["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(event["date"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(event["location"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
