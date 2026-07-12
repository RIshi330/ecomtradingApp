import 'package:flutter/material.dart';

class TrainingsHubScreen extends StatefulWidget {
  const TrainingsHubScreen({super.key});

  @override
  State<TrainingsHubScreen> createState() => _TrainingsHubScreenState();
}

class _TrainingsHubScreenState extends State<TrainingsHubScreen> {
  String selectedPaidFilter = 'All';

  final List<WhiteLabelTraining> whiteLabelTrainings = [
    WhiteLabelTraining(
      id: '1',
      title: 'Executive Leadership 2024',
      category: 'STRATEGIC GROWTH',
      description: 'A comprehensive framework for modern enterprise leadership focusing on agility and data-driven decisions.',
      purchasedDate: 'Oct 12, 2023',
      owner: 'Global HR Solutions',
    ),
    WhiteLabelTraining(
      id: '2',
      title: 'Supply Chain Optimization',
      category: 'OPERATIONS',
      description: 'Mastering the complexities of global logistics with localized distribution strategies.',
      purchasedDate: 'Sep 28, 2023',
      owner: 'Nexus Logistics Group',
    ),
    WhiteLabelTraining(
      id: '3',
      title: 'Risk Management Advanced',
      category: 'FINANCE',
      description: 'Identifying systemic risks and implementing mitigation protocols for mid-to-large vendors.',
      purchasedDate: 'Aug 05, 2023',
      owner: 'SecureFlow Finance',
    ),
  ];

  final List<PaidTraining> paidTrainings = [
    PaidTraining(
      id: '1',
      title: 'Q4 Regional Vendor Summit',
      type: 'Onsite',
      typeColor: Colors.blue,
      idNumber: '#VND-9921',
      location: 'Chicago Conference Center',
      date: 'Nov 15 - Nov 17, 2024',
      price: '\$1,250.00',
      isCompleted: false,
      isVirtual: false,
      hasReplay: false,
      hasCertificate: false,
    ),
    PaidTraining(
      id: '2',
      title: 'Cybersecurity Compliance Masterclass',
      type: 'Online',
      typeColor: const Color(0xFF006565),
      idNumber: '#WEB-4410',
      location: 'Virtual Classroom',
      date: 'Oct 30, 2024 @ 10:00 AM CST',
      price: '\$450.00',
      isCompleted: false,
      isVirtual: true,
      hasReplay: false,
      hasCertificate: false,
    ),
    PaidTraining(
      id: '3',
      title: 'Advanced Negotiation Tactics',
      type: 'Online',
      typeColor: const Color(0xFF555F71),
      idNumber: '#WEB-2201',
      location: 'Completed Aug 12',
      date: '',
      price: '\$300.00',
      isCompleted: true,
      isVirtual: true,
      hasReplay: true,
      hasCertificate: true,
    ),
  ];

  List<PaidTraining> get filteredPaidTrainings {
    if (selectedPaidFilter == 'All') return paidTrainings;
    return paidTrainings.where((t) => t.type == selectedPaidFilter).toList();
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMaterialsSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Course Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            _buildMaterialItem(Icons.picture_as_pdf, 'Executive Guide 2024', 'PDF Document • 4.2 MB', colorScheme),
            _buildMaterialItem(Icons.table_view, 'Q4 Strategy Framework', 'Excel Spreadsheet • 1.1 MB', colorScheme),
            _buildMaterialItem(Icons.description, 'Vendor Checklist', 'Word Document • 850 KB', colorScheme),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showToast('Preparing batch download...');
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.download),
              label: const Text('Download All Bundle'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(IconData icon, String title, String subtitle, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
              ],
            ),
          ),
          IconButton(onPressed: () => showToast('Downloading individual item...'), icon: const Icon(Icons.arrow_downward, size: 20))
        ],
      ),
    );
  }

  void _showJoinLiveSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_call, size: 48, color: Colors.teal),
            const SizedBox(height: 12),
            const Text('Cybersecurity Compliance Masterclass', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Starting shortly. Ensure audio hardware configurations match platform protocols.', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildCodeTile('MEETING ID', '882-192-004', colorScheme)),
                const SizedBox(width: 12),
                Expanded(child: _buildCodeTile('PASSCODE', 'SECURE-24', colorScheme)),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                showToast('Launching Node Video Session...');
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.teal),
              child: const Text('Launch Streaming Frame'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCodeTile(String label, String code, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontFamily: 'JetBrains Mono', color: colorScheme.outline)),
          const SizedBox(height: 4),
          Text(code, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showReplaySheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Replay Hub Frame', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Negotiation Framework Chapter 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text('Duration evaluated: 45:00 minutes total infrastructure.', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showCertificateSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 54, color: Colors.amber),
            const SizedBox(height: 8),
            const Text('Credential Verification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            _buildInfoRow('Holder ID token', 'VENDOR USER #9421'),
            _buildInfoRow('Course Context', 'Advanced Negotiation Tactics'),
            _buildInfoRow('Issuance Date', 'August 12, 2024'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.badge),
              label: const Text('Download Verifiable PDF'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold,)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 720;

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLow ?? const Color(0xFFF9FAFB),
          bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(colorScheme),
          body: Row(
            children: [
              if (isDesktop) _buildDesktopSidebar(colorScheme),
              Expanded(
                child: Column(
                  children: [
                    _buildTopAppBar(colorScheme),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        children: [
                          _buildSummarySection(colorScheme),
                          const SizedBox(height: 24),
                          _buildWhiteLabelSection(context, colorScheme, isDesktop),
                          const SizedBox(height: 24),
                          _buildPaidTrainingsSection(context, colorScheme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: const Text('Trainings System', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(onPressed: () => showToast('Search framework initialized.'), icon: const Icon(Icons.search)),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDesktopSidebar(ColorScheme colorScheme) {
    return NavigationRail(
      selectedIndex: 0,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: Text('Hub')),
        NavigationRailDestination(icon: Icon(Icons.rss_feed), label: Text('Feed')),
        NavigationRailDestination(icon: Icon(Icons.leaderboard_outlined), label: Text('Stats')),
      ],
      onDestinationSelected: (idx) {},
    );
  }

  Widget _buildSummarySection(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(child: _buildMetricTile('White Label Assets', '12 Units', Icons.branding_watermark_outlined, colorScheme)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricTile('Paid Matrix Nodes', '08 Pipeline', Icons.payments_outlined, colorScheme)),
      ],
    );
  }

  Widget _buildMetricTile(String label, String val, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: colorScheme.outline, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(icon, size: 28, color: colorScheme.primary.withOpacity(0.6))
        ],
      ),
    );
  }

  Widget _buildWhiteLabelSection(BuildContext context, ColorScheme colorScheme, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('White Label Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => showToast('Routing catalog logs...'), child: const Text('View Catalog'))
          ],
        ),
        const SizedBox(height: 8),
        if (isDesktop)
          Row(
            children: whiteLabelTrainings.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildWhiteLabelCard(context, t, colorScheme)))).toList(),
          )
        else
          Column(
            children: whiteLabelTrainings.map((t) => _buildWhiteLabelCard(context, t, colorScheme)).toList(),
          )
      ],
    );
  }

  Widget _buildWhiteLabelCard(BuildContext context, WhiteLabelTraining training, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
            child: Text(training.category, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          ),
          const SizedBox(height: 8),
          Text(training.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(training.description, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
          const Divider(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showMaterialsSheet(context, colorScheme),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            icon: const Icon(Icons.folder_open_outlined, size: 16),
            label: const Text('Access Matrix Materials', style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildPaidTrainingsSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Paid Subscriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: ['All', 'Onsite', 'Online'].map((f) {
                final selected = selectedPaidFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (val) => setState(() => selectedPaidFilter = f),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            )
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: filteredPaidTrainings.map((t) => _buildPaidTrainingCard(context, t, colorScheme)).toList(),
        )
      ],
    );
  }

  Widget _buildPaidTrainingCard(BuildContext context, PaidTraining training, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: training.typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(training.type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: training.typeColor)),
              ),
              Text(training.idNumber, style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: colorScheme.outline)),
            ],
          ),
          const SizedBox(height: 8),
          Text(training.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(training.location, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
          if (training.date.isNotEmpty) Text(training.date, style: TextStyle(fontSize: 12, color: colorScheme.outline)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(training.price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              Row(
                children: [
                  if (!training.isCompleted) ...[
                    OutlinedButton(
                      onPressed: () => _showMaterialsSheet(context, colorScheme),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Materials', style: TextStyle(fontSize: 12)),
                    ),
                    if (training.isVirtual) ...[
                      const SizedBox(width: 6),
                      FilledButton(
                        onPressed: () => _showJoinLiveSheet(context, colorScheme),
                        style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: Colors.teal),
                        child: const Text('Join Live', style: TextStyle(fontSize: 12)),
                      ),
                    ]
                  ] else ...[
                    OutlinedButton(
                      onPressed: () => _showReplaySheet(context, colorScheme),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Replay', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () => _showCertificateSheet(context, colorScheme),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Certificate', style: TextStyle(fontSize: 12)),
                    ),
                  ]
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav(ColorScheme colorScheme) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Hub'),
        NavigationDestination(icon: Icon(Icons.rss_feed), label: 'Feed'),
        NavigationDestination(icon: Icon(Icons.leaderboard_outlined), label: 'Stats'),
      ],
    );
  }
}

class WhiteLabelTraining {
  final String id;
  final String title;
  final String category;
  final String description;
  final String purchasedDate;
  final String owner;

  WhiteLabelTraining({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.purchasedDate,
    required this.owner,
  });
}

class PaidTraining {
  final String id;
  final String title;
  final String type;
  final Color typeColor;
  final String idNumber;
  final String location;
  final String date;
  final String price;
  final bool isCompleted;
  final bool isVirtual;
  final bool hasReplay;
  final bool hasCertificate;

  PaidTraining({
    required this.id,
    required this.title,
    required this.type,
    required this.typeColor,
    required this.idNumber,
    required this.location,
    required this.date,
    required this.price,
    required this.isCompleted,
    required this.isVirtual,
    required this.hasReplay,
    required this.hasCertificate,
  });
}