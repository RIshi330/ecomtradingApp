import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/admin/purchased_tranning.dart';
import 'package:trading_ecommerce_admin/admin/support_donets.dart';
import 'package:trading_ecommerce_admin/admin/track_order.dart';
import 'package:trading_ecommerce_admin/admin/upcoming_event.dart';

import '../common/chat_screen.dart';
import '../common/notification_screen.dart';
import 'job_application.dart';
import 'my_opportunity_activity.dart';

class MyActivity extends StatefulWidget {
  final bool isEmbedded;

  const MyActivity({super.key,required this.isEmbedded});

  @override
  State<MyActivity> createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // List of activity items with different navigation targets
  final List<ActivityItem> _allItems = [
    ActivityItem(
      title: 'Job Applications',
      icon: Icons.work_outline,
      color: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1976D2),
      screen: const AppliedJobsScreen(), // Navigates to Job Applications
    ),
    ActivityItem(
      title: 'Enrolled Trainings',
      icon: Icons.school_outlined,
      color: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF388E3C),
      screen: const TrainingsHubScreen(), // Navigate to Trainings
    ),
    ActivityItem(
      title: 'Track Orders',
      icon: Icons.local_shipping_outlined,
      color: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFF57C00),
      screen: const OrderManagementScreen(), // Navigate to Track Orders
    ),
    ActivityItem(
      title: 'Track Digital product Orders',
      icon: Icons.cloud_download_outlined,
      color: const Color(0xFFF3E5F5),
      iconColor: const Color(0xFF7B1FA2),
      screen: const TrackDigitalOrdersScreen(), // Navigate to Digital Orders
    ),
    ActivityItem(
      title: 'Support & Donations',
      icon: Icons.favorite_border,
      color: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFC62828),
      screen: const SupportDonationScreen(), // Navigate to Support
    ),
    ActivityItem(
      title: 'Applied Opportunities',
      icon: Icons.assignment_outlined,
      color: const Color(0xFFE0F7FA),
      iconColor: const Color(0xFF00695C),
      screen: const MyResponsesScreen(), // Navigate to Opportunities
    ),
    ActivityItem(
      title: 'Upcoming Events',
      icon: Icons.event_outlined,
      color: const Color(0xFFFFF8E1),
      iconColor: const Color(0xFFF9A825),
      screen: const EventTicketsScreen(), // Navigate to Events
    ),
  ];

  List<ActivityItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _allItems;
    return _allItems
        .where((item) =>
        item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isEmbedded);
    return Scaffold(
      appBar: widget.isEmbedded
          ? null : AppBar(title: const Text(
          'My Activit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ), centerTitle: false, elevation: 0,backgroundColor: Colors.white, foregroundColor: Colors.black87, bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search activities...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey.shade600),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: _buildGrid(),
      ),
    );
  }

  Widget _buildGrid() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No activities found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCard(item);
      },
    );
  }

  Widget _buildCard(ActivityItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to the specific screen for this card
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 28,
                  color: item.iconColor,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model class to represent activity items
class ActivityItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Widget screen; // Add screen property

  const ActivityItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.screen, // Make it required
  });
}

// Placeholder screens - replace these with your actual screen widgets
class EnrolledTrainingsScreen extends StatelessWidget {
  const EnrolledTrainingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrolled Trainings')),
      body: const Center(child: Text('Enrolled Trainings Screen')),
    );
  }
}

class TrackOrdersScreen extends StatelessWidget {
  const TrackOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Orders')),
      body: const Center(child: Text('Track Orders Screen')),
    );
  }
}

class TrackDigitalOrdersScreen extends StatelessWidget {
  const TrackDigitalOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Digital Product Orders')),
      body: const Center(child: Text('Track Digital Product Orders Screen')),
    );
  }
}

class SupportDonationsScreen extends StatelessWidget {
  const SupportDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support & Donations')),
      body: const Center(child: Text('Support & Donations Screen')),
    );
  }
}

class AppliedOpportunitiesScreen extends StatelessWidget {
  const AppliedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applied Opportunities')),
      body: const Center(child: Text('Applied Opportunities Screen')),
    );
  }
}

class UpcomingEventsScreen extends StatelessWidget {
  const UpcomingEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: const Center(child: Text('Upcoming Events Screen')),
    );
  }
}