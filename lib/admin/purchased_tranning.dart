import 'package:flutter/material.dart';

class TrainingsHubScreen extends StatefulWidget {
  const TrainingsHubScreen({super.key});

  @override
  State<TrainingsHubScreen> createState() => _TrainingsHubScreenState();
}

class _TrainingsHubScreenState extends State<TrainingsHubScreen> {
  String selectedPaidFilter = 'All';

  // Core Theme Color Palette mapped from design script token declarations
  static const Color primaryColor = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color secondaryColor = Color(0xFF555F71);
  static const Color surfaceBackground = Color(0xFFF7FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textOnSurface = Color(0xFF181C1E);
  static const Color textOnSurfaceVariant = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color outlineColor = Color(0xFF6E7979);

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
      idNumber: '#VND-9921',
      location: 'Chicago Conference Center',
      date: 'Nov 15 - Nov 17, 2024',
      price: '\$1,250.00',
      isCompleted: false,
      isVirtual: false,
    ),
    PaidTraining(
      id: '2',
      title: 'Cybersecurity Compliance Masterclass',
      type: 'Online',
      idNumber: '#WEB-4410',
      location: 'Virtual Classroom',
      date: 'Oct 30, 2024 @ 10:00 AM CST',
      price: '\$450.00',
      isCompleted: false,
      isVirtual: true,
    ),
    PaidTraining(
      id: '3',
      title: 'Advanced Negotiation Tactics',
      type: 'Online',
      idNumber: '#WEB-2201',
      location: 'Completed Aug 12',
      date: '',
      price: '\$300.00',
      isCompleted: true,
      isVirtual: true,
    ),
  ];

  List<PaidTraining> get filteredPaidTrainings {
    if (selectedPaidFilter == 'All') return paidTrainings;
    return paidTrainings.where((t) => t.type == selectedPaidFilter).toList();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Native Material 3 Bottom Sheets replace layout-blocking custom markup modals
  void _showMaterialsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Course Materials', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Text('AVAILABLE RESOURCES', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: textOnSurfaceVariant.withOpacity(0.8))),
            const SizedBox(height: 12),
            _buildMaterialRowItem(Icons.picture_as_pdf, 'Executive Guide 2024', 'PDF Document • 4.2 MB'),
            _buildMaterialRowItem(Icons.table_view, 'Q4 Strategy Framework', 'Excel Spreadsheet • 1.1 MB'),
            _buildMaterialRowItem(Icons.description, 'Vendor Checklist', 'Word Document • 850 KB'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: primaryColor, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showToast('Preparing batch download...');
                  },
                  style: FilledButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Download All', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialRowItem(IconData icon, String title, String sizeInfo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: textOnSurface)),
                const SizedBox(height: 2),
                Text(sizeInfo, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: outlineColor)),
              ],
            ),
          ),
          const Icon(Icons.download, color: outlineColor, size: 20)
        ],
      ),
    );
  }

  void _showJoinLiveSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Color(0xFFF9F9F9), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.video_chat, color: primaryColor, size: 28),
            ),
            const SizedBox(height: 16),
            const Text('Cybersecurity Compliance', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Starting in 15 minutes. Please ensure your microphone is muted upon entry.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: textOnSurfaceVariant), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildCodeBlock('MEETING ID', '882-192-004')),
                const SizedBox(width: 12),
                Expanded(child: _buildCodeBlock('PASSCODE', 'SECURE-24')),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _showToast('Launching Virtual Classroom...');
              },
              style: FilledButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Launch Meeting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCodeBlock(String label, String code) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xEBECEFF0), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, fontWeight: FontWeight.bold, color: outlineColor)),
          const SizedBox(height: 2),
          Text(code, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: textOnSurface)),
        ],
      ),
    );
  }

  void _showReplaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Color(0xFFF9F9F9), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Video Replay', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&q=80&w=500'),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                child: const Center(child: Icon(Icons.play_circle_outline, size: 56, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Course Chapters', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildChapterRow('00:00 - Introduction & Foundations', true),
            _buildChapterRow('08:20 - Core Negotiation Framework', false, suffix: 'Playing'),
            _buildChapterRow('22:15 - Handling Resistance Tactics', false, suffix: '22:45'),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterRow(String title, bool done, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: done ? primaryColor : textOnSurface, fontWeight: done ? FontWeight.bold : FontWeight.normal))),
          if (done) const Icon(Icons.check_circle, size: 16, color: primaryColor) else if (suffix != null) Text(suffix, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: outlineColor)),
        ],
      ),
    );
  }

  void _showCertificateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Color(0xFFF9F9F9), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Digital Certificate', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: outlineVariant, width: 2)),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 44, color: primaryColor),
                  const SizedBox(height: 10),
                  const Text('CERTIFICATE OF COMPLETION', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 14),
                  const Text('This acknowledges that vendor user node instance profile', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textOnSurfaceVariant), textAlign: TextAlign.center),
                  const Text('VENDOR USER #9421', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: textOnSurface)),
                  const Text('has fully verified training operations execution for', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: textOnSurfaceVariant)),
                  const Text('Advanced Negotiation Tactics', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('ISSUED', style: TextStyle(fontSize: 10, color: outlineColor)), Text('Aug 12, 2024', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [Text('CREDENTIAL ID', style: TextStyle(fontSize: 10, color: outlineColor)), Text('CRT-NEG-X99', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showToast('Downloading Certificate PDF...');
              },
              style: FilledButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.download, color: Colors.white, size: 18),
              label: const Text('Download PDF Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  void _showTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Color(0xFFF9F9F9), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Entrance Ticket', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: outlineVariant.withOpacity(0.5))),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 100, color: textOnSurface),
                  const SizedBox(height: 12),
                  const Text('Q4 Regional Vendor Summit', style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Chicago Conference Center', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: textOnSurfaceVariant)),
                  const SizedBox(height: 4),
                  const Text('NOV 15, 2024 • 09:00 AM', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _showToast('Ticket added to secure structural wallet node.');
              },
              style: FilledButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save to Local Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 720;

        return Scaffold(
          backgroundColor: surfaceBackground,
          appBar: AppBar(
        title: const Text('Training', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
        centerTitle: false,
        backgroundColor: Colors.teal,

        ),
          body: Row(

            children: [
              Expanded(
                child: Column(
                  children: [

                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        children: [
                          _buildSummarySection(),
                          const SizedBox(height: 28),
                          _buildWhiteLabelSection(context, isDesktop),
                          const SizedBox(height: 32),
                          _buildPaidTrainingsSection(context),
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: cardBackground,
        border: Border(bottom: BorderSide(color: outlineVariant, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: outlineVariant),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAMJx_60-kjP24QxRGDcbkyG4piU6qGX9LDq72gD9u0HvbW9tkTAcN1xTMiqZ5IByj8zJ1HQxpPweDS3GmGSWoqbGAWDtLVLmPjjwVJgcf37xT-3IDoBBZTd1oxffxLIE2gQhWCJdoJqoAb-yFfeTixEEnS_Gfmfu47FSyCLRl0Q4yvNDix63TYPDa9bbb0wrZJ7OkvSYLxgDCRO4ksdm7aCnQJOhUnDPy6zyWSip2YzLqJcsk2F2Nt'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Trainings Hub',
                style: TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _showToast('Search currently unavailable'),
            icon: const Icon(Icons.search, color: primaryColor),
          ),
        ],
      ),
    );
  }



  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Trainings', style: TextStyle(fontFamily: 'Manrope', fontSize: 26, fontWeight: FontWeight.bold, color: textOnSurface)),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Row(
              children: [
                _buildMetricTile('White Label', '12 Units', Icons.branding_watermark_outlined, cardWidth),
                const SizedBox(width: 12),
                _buildMetricTile('Paid Trainings', '08 Enrollments', Icons.payments_outlined, cardWidth),
              ],
            );
          },
        )
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: textOnSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(icon, size: 32, color: outlineVariant),
        ],
      ),
    );
  }

  Widget _buildWhiteLabelSection(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('White Label Trainings', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: textOnSurface)),
            TextButton.icon(
              onPressed: () => _showToast('Redirecting to Full Course Catalog...'),
              icon: const Text('View Catalog', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold)),
              label: const Icon(Icons.arrow_forward, size: 14, color: primaryColor),
            )
          ],
        ),
        const SizedBox(height: 10),
        if (isDesktop)
          Row(
            children: whiteLabelTrainings.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: _buildWhiteLabelCard(context, t)))).toList(),
          )
        else
          Column(
            children: whiteLabelTrainings.map((t) => _buildWhiteLabelCard(context, t)).toList(),
          )
      ],
    );
  }

  Widget _buildWhiteLabelCard(BuildContext context, WhiteLabelTraining training) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFD6E0F6), borderRadius: BorderRadius.circular(4)),
                  child: Text(training.category, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF596376))),
                ),
                const SizedBox(height: 10),
                Text(training.title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.bold, color: textOnSurface)),
                const SizedBox(height: 6),
                Text(training.description, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: textOnSurfaceVariant, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
                _buildCardMetadataRow(Icons.calendar_today, 'Purchased: ${training.purchasedDate}'),
                const SizedBox(height: 4),
                _buildCardMetadataRow(Icons.person, 'Owner: ${training.owner}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: FilledButton.icon(
              onPressed: () => _showMaterialsSheet(context),
              style: FilledButton.styleFrom(backgroundColor: primaryContainer, minimumSize: const Size.fromHeight(40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.folder_open, size: 16, color: Colors.white),
              label: const Text('Access Materials', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardMetadataRow(IconData icon, String detail) {
    return Row(
      children: [
        Icon(icon, size: 13, color: outlineColor),
        const SizedBox(width: 6),
        Expanded(child: Text(detail, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, color: outlineColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildPaidTrainingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Paid Trainings', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: textOnSurface)),
            Row(
              children: ['All', 'Onsite', 'Online'].map((filter) {
                final isSelected = selectedPaidFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => selectedPaidFilter = filter);
                    },
                    labelStyle: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : textOnSurfaceVariant),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            )
          ],
        ),
        const SizedBox(height: 14),
        Column(
          children: filteredPaidTrainings.map((t) => _buildPaidTrainingCard(context, t)).toList(),
        )
      ],
    );
  }

  Widget _buildPaidTrainingCard(BuildContext context, PaidTraining training) {
    return Opacity(
      opacity: training.isCompleted ? 0.9 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: outlineVariant.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: training.isCompleted
                        ? const Color(0xFFD6E0F6)
                        : (training.isVirtual ? const Color(0xFFE3FFFE) : const Color(0xFFCFE8E3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    training.type.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: training.isCompleted
                          ? const Color(0xFF596376)
                          : (training.isVirtual ? primaryColor : const Color(0xFF354B48)),
                    ),
                  ),
                ),
                Text(training.idNumber, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: outlineColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(training.title, style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.bold, color: textOnSurface)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _buildInfoChip(training.isCompleted ? Icons.check_circle : (training.isVirtual ? Icons.devices : Icons.location_on), training.location),
                if (training.date.isNotEmpty) _buildInfoChip(Icons.event, training.date),
                _buildInfoChip(Icons.payments, '${training.price} (Paid)'),
              ],
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!training.isCompleted) ...[
                  OutlinedButton.icon(
                    onPressed: () => _showMaterialsSheet(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.description, size: 14, color: primaryColor),
                    label: const Text('Materials', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                  ),
                  const SizedBox(width: 8),
                  if (training.isVirtual)
                    FilledButton(
                      onPressed: () => _showJoinLiveSheet(context),
                      style: FilledButton.styleFrom(backgroundColor: primaryContainer, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Join Live', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _showTicketSheet(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.download, size: 14, color: primaryColor),
                      label: const Text('Ticket', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                    ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: () => _showReplaySheet(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.play_circle, size: 14, color: primaryColor),
                    label: const Text('Replay', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showCertificateSheet(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.workspace_premium, size: 14, color: primaryColor),
                    label: const Text('Certificate', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: primaryColor),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: textOnSurfaceVariant)),
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
  final String idNumber;
  final String location;
  final String date;
  final String price;
  final bool isCompleted;
  final bool isVirtual;

  PaidTraining({
    required this.id,
    required this.title,
    required this.type,
    required this.idNumber,
    required this.location,
    required this.date,
    required this.price,
    required this.isCompleted,
    required this.isVirtual,
  });
}