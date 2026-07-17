import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'applied_jobs_screen.dart';
import 'enrolled_trainings_custom_screen.dart';
import 'track_orders_screen.dart';
import 'track_digital_orders_screen.dart';
import 'support_donations_screen.dart';
import 'applied_opportunities_screen.dart';
import 'upcoming_events_screen.dart';
import 'my_rewards_screen.dart';

class MyActivityScreen extends StatefulWidget {
  final bool isEmbedded;
  const MyActivityScreen({super.key, this.isEmbedded = false});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  final List<Map<String, dynamic>> gridItems = [
    {
      "title": "Job Applications",
      "icon": Icons.work_outline_rounded,
      "color": Color(0xFFE3F2FD),
      "iconColor": Color(0xFF1E88E5),
      "screen": const AppliedJobsScreen(),
    },
    {
      "title": "Enrolled Trainings",
      "icon": Icons.school_outlined,
      "color": Color(0xFFE8F5E9),
      "iconColor": Color(0xFF43A047),
      "screen": const EnrolledTrainingsCustomScreen(),
    },
    {
      "title": "Track Orders",
      "icon": Icons.local_shipping_outlined,
      "color": Color(0xFFFFF3E0),
      "iconColor": Color(0xFFFB8C00),
      "screen": const TrackOrdersScreen(),
    },
    {
      "title": "Track Digital product Orders",
      "icon": Icons.cloud_download_outlined,
      "color": Color(0xFFF3E5F5),
      "iconColor": Color(0xFF8E24AA),
      "screen": const TrackDigitalOrdersScreen(),
    },
    {
      "title": "Support & Donations",
      "icon": Icons.favorite_outline_rounded,
      "color": Color(0xFFFCE4EC),
      "iconColor": Color(0xFFD81B60),
      "screen": const SupportDonationsScreen(),
    },
    {
      "title": "Applied Opportunities",
      "icon": Icons.assignment_ind_outlined,
      "color": Color(0xFFE0F2F1),
      "iconColor": Color(0xFF00897B),
      "screen": const AppliedOpportunitiesScreen(),
    },
    {
      "title": "Upcoming Events",
      "icon": Icons.calendar_month_outlined,
      "color": Color(0xFFFFFDE7),
      "iconColor": Color(0xFFFBC02D),
      "screen": const UpcomingEventsScreen(),
    },
    {
      "title": "My Rewards",
      "icon": Icons.military_tech_outlined,
      "color": Color(0xFFE0F2F1),
      "iconColor": Color(0xFF004349),
      "screen": const MyRewardsScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("My Activity", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                final item = gridItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item["screen"]),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: item["color"],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item["icon"],
                            color: item["iconColor"],
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item["title"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
