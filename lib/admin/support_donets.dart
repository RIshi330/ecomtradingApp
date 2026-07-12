import 'package:flutter/material.dart';

class SupportDonationScreen extends StatefulWidget {
  const SupportDonationScreen({super.key});

  @override
  State<SupportDonationScreen> createState() => _SupportDonationScreenState();
}

class _SupportDonationScreenState extends State<SupportDonationScreen> {
  String selectedTab = 'All Activities';

  // Types match tab selections perfectly to prevent filtering display bugs
  final List<Activity> activities = [
    Activity(
      id: '1',
      title: 'Education First Foundation',
      type: 'Donations',
      date: 'Oct 24, 2023',
      amount: '₹15,000',
      status: 'Completed',
      statusType: ActivityStatus.completed,
      icon: Icons.foundation,
      iconBg: const Color(0xFF008080),
    ),
    Activity(
      id: '2',
      title: 'Green Earth Alliance',
      type: 'Volunteering',
      date: 'Nov 02, 2023',
      amount: '8 hrs',
      status: 'Verified',
      statusType: ActivityStatus.verified,
      icon: Icons.eco,
      iconBg: const Color(0xFF555F71),
    ),
    Activity(
      id: '3',
      title: 'Rural Library Project',
      type: 'Items',
      date: 'Nov 15, 2023',
      amount: '45 units',
      status: 'Processing',
      statusType: ActivityStatus.processing,
      icon: Icons.menu_book,
      iconBg: const Color(0xFF3E4949),
    ),
  ];

  List<Activity> get filteredActivities {
    if (selectedTab == 'All Activities') return activities;
    return activities.where((a) => a.type == selectedTab).toList();
  }

  void _showAddActivityModal(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddActivityBottomSheet(context, colorScheme),
    );
  }

  void _showShareModal(BuildContext context, String message, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShareBottomSheet(context, message, colorScheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCZvfCsFO-mwfFQlDxHkWB0OrUGvecj5xGU9aRuAHp6NsBrlex2q0TgRaUB1zX9thEMPFnw42UKKa2NfdmzfrKBt4GqEDpRQnp9CU_FjFAzGFUCKxG16f_KbmRKJ8-w8pj6pfeYNTtI5n7CPlH0WWk8Ko3yf1quf16lP6Y6XDqBPGylu44A5XOSohqZ3C1D8YMGtPiSZnbtL99dMKUCvkVfrczLmtbRREq-S7Uj6co67pGF2_3fzXuC',
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'My Activity',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings_outlined, color: colorScheme.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityModal(context, colorScheme),
        backgroundColor: const Color(0xFF008080),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildImpactSummaryHeader(),
            const SizedBox(height: 16),
            _buildImpactCardsCarousel(),
            const SizedBox(height: 32),
            _buildActivityTabs(colorScheme),
            const SizedBox(height: 20),
            ...filteredActivities.map((activity) => _buildActivityCard(context, activity, colorScheme)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactSummaryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Impact Summary',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF181C1E),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF555F71)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF555F71)),
              onPressed: () {},
            ),
          ],
        )
      ],
    );
  }

  Widget _buildImpactCardsCarousel() {
    return SizedBox(
      height: 145,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSummaryCard(
            icon: Icons.payments_outlined,
            label: 'Total Cash Donated',
            value: '₹50,000',
            trend: '12% from last month',
            trendIcon: Icons.trending_up,
          ),
          const SizedBox(width: 16),
          _buildSummaryCard(
            icon: Icons.inventory_2_outlined,
            label: 'Items Contributed',
            value: '120 units',
            trend: 'Verified contributions',
            trendIcon: Icons.check_circle,
          ),
          const SizedBox(width: 16),
          _buildSummaryCard(
            icon: Icons.volunteer_activism_outlined,
            label: 'Volunteer Hours',
            value: '45 hrs',
            trend: 'Across 5 projects',
            trendIcon: Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required String trend,
    required IconData trendIcon,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF006565), size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E4949),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006565),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(trendIcon, size: 12, color: const Color(0xFF006565)),
                  const SizedBox(width: 4),
                  Text(
                    trend,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: Color(0xFF006565),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTabs(ColorScheme colorScheme) {
    final tabs = ['All Activities', 'Donations', 'Items', 'Volunteering'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFBDC9C8), width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tabs.map((tab) {
            final isActive = selectedTab == tab;
            return GestureDetector(
              onTap: () => setState(() => selectedTab = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? const Color(0xFF008080) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFF006565) : const Color(0xFF3E4949),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: activity.iconBg.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(activity.icon, color: activity.iconBg, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181C1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            activity.type == 'Donations' ? 'Donation' : activity.type,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activity.date,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.amount,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006565),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activity.statusType == ActivityStatus.completed
                              ? const Color(0xFF006565)
                              : (activity.statusType == ActivityStatus.verified ? const Color(0xFF555F71) : const Color(0xFFBDC9C8)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activity.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: activity.statusType == ActivityStatus.completed
                              ? const Color(0xFF006565)
                              : (activity.statusType == ActivityStatus.verified ? const Color(0xFF555F71) : const Color(0xFF3E4949)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _handleAction(context, activity, colorScheme),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      side: BorderSide(color: activity.statusType == ActivityStatus.processing ? const Color(0xFF6E7979) : const Color(0xFF006565)),
                    ),
                    child: Text(
                      _getActionLabel(activity.type),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: activity.statusType == ActivityStatus.processing ? const Color(0xFF6E7979) : const Color(0xFF006565),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _showShareModal(
                      context,
                      'I just supported ${activity.title} with a ${activity.amount} contribution!',
                      colorScheme,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Share Impact', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActionLabel(String type) {
    switch (type) {
      case 'Donations':
        return 'View Receipt';
      case 'Volunteering':
        return 'Thank You Note';
      case 'Items':
        return 'Pending';
      default:
        return 'View';
    }
  }

  void _handleAction(BuildContext context, Activity activity, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        switch (activity.type) {
          case 'Donations':
            return _buildReceiptBottomSheet(context, colorScheme);
          case 'Volunteering':
            return _buildThankYouBottomSheet(context, colorScheme);
          case 'Items':
            return _buildStatusBottomSheet(context, colorScheme);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildAddActivityBottomSheet(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add New Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(label: 'Organization Name', hint: 'e.g. Red Cross'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField(label: 'Activity Type', hint: 'Donations')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(label: 'Date', hint: 'YYYY-MM-DD')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(label: 'Amount / Quantity', hint: 'e.g. ₹5,000 or 10 units'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity logged successfully!'), behavior: SnackBarBehavior.floating),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF006565),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949))),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF1F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildShareBottomSheet(BuildContext context, String message, ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Share Your Impact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F4F6), borderRadius: BorderRadius.circular(8)),
            child: Text(message, style: const TextStyle(fontSize: 14, height: 1.4)),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating));
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            child: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptBottomSheet(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Donation Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5))
            ),
            child: Column(
              children: [
                _buildRowValue('Transaction ID', '#TXN-882910'),
                const SizedBox(height: 8),
                _buildRowValue('Date', 'Oct 24, 2023'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFBDC9C8)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('₹15,000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading PDF...'), behavior: SnackBarBehavior.floating));
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildThankYouBottomSheet(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thank You Note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '"Dear Alex, thank you so much for your dedicated 8 hours of volunteering. Your contribution to the Green Earth Alliance has directly helped us plant 50 new saplings in the urban forest project. We are truly grateful for your support!"',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF3E4949)),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— The Green Earth Team',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusBottomSheet(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Donation Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusLine(Icons.check_circle, 'Received at Warehouse', 'Nov 16, 2023', true),
          _buildStatusLine(Icons.sync, 'Sorting & Cataloging', 'In Progress', true),
          _buildStatusLine(Icons.local_shipping, 'In Transit to Library', 'Pending', false),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusLine(IconData icon, String title, String subtitle, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: isDone ? const Color(0xFF006565) : Colors.grey.withOpacity(0.5)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: isDone ? FontWeight.w600 : FontWeight.normal, color: isDone ? Colors.black : Colors.grey)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRowValue(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

enum ActivityStatus { completed, verified, processing }

class Activity {
  final String id;
  final String title;
  final String type;
  final String date;
  final String amount;
  final String status;
  final ActivityStatus statusType;
  final IconData icon;
  final Color iconBg;

  Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusType,
    required this.icon,
    required this.iconBg,
  });
}