import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EventTicketsScreen extends StatefulWidget {
  const EventTicketsScreen({super.key});

  @override
  State<EventTicketsScreen> createState() => _EventTicketsScreenState();
}

class _EventTicketsScreenState extends State<EventTicketsScreen> {
  String currentTab = 'upcoming';
  bool isTicketModalVisible = false;
  bool isToastVisible = false;
  String toastMessage = '';

  final List<UpcomingEvent> upcomingEvents = [
    UpcomingEvent(
      id: '1',
      title: 'Global Ecommerce Summit 2024',
      ticketType: 'EXECUTIVE VIP',
      date: 'Nov 15-17, 2024',
      time: '09:00 AM - 05:00 PM',
      location: 'Chicago Conference Center',
      isVirtual: false,
      hasQRCode: true,
      ticketData: 'GES2024-VIP-12345',
      holderName: 'Alex Chen',
      seat: '4G',
    ),
    UpcomingEvent(
      id: '2',
      title: 'Supply Chain Strategy Workshop',
      ticketType: 'STANDARD ACCESS',
      date: 'Dec 05, 2024',
      time: '02:00 PM - 04:30 PM',
      location: 'Virtual Suite',
      isVirtual: true,
      hasQRCode: false,
      ticketData: null,
      holderName: 'Alex Chen',
      seat: null,
    ),
  ];

  final List<PastEvent> pastEvents = [
    PastEvent(
      title: 'Global Logistics Forum 2023',
      date: 'Oct 12-14, 2023',
      ticketType: 'VIP PASS',
    ),
  ];

  void switchTab(String tab) {
    setState(() => currentTab = tab);
  }

  void showTicketModal() => setState(() => isTicketModalVisible = true);
  void hideTicketModal() => setState(() => isTicketModalVisible = false);

  void showToast(String message) {
    setState(() {
      toastMessage = message;
      isToastVisible = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => isToastVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isLargeScreen = screenSize.width >= 720;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow ?? const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Tickets', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Manrope')),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildTabNavigation(colorScheme),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: 16,
                    ),
                    children: [
                      if (currentTab == 'upcoming') ...[
                        _buildHeroSection(colorScheme, isLargeScreen),
                        const SizedBox(height: 24),
                        _buildUpcomingEvents(colorScheme, isLargeScreen),
                      ] else ...[
                        _buildPastEvents(colorScheme, isLargeScreen),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isTicketModalVisible) _buildTicketModal(colorScheme, isSmallScreen),
          if (isToastVisible) _buildToastNotification(colorScheme),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(ColorScheme colorScheme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh ?? Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Upcoming Active',
              isActive: currentTab == 'upcoming',
              onTap: () => switchTab('upcoming'),
              colorScheme: colorScheme,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'Past Events',
              isActive: currentTab == 'past',
              onTap: () => switchTab('past'),
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(ColorScheme colorScheme, bool isLargeScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready for adventure?',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You hold 2 Active passes',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMicroStat('\$1,850', 'Asset Value'),
                    const SizedBox(width: 24),
                    _buildMicroStat('12,400', 'XP Points'),
                  ],
                )
              ],
            ),
          ),
          if (isLargeScreen)
            const Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.white24)
        ],
      ),
    );
  }

  Widget _buildMicroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildUpcomingEvents(ColorScheme colorScheme, bool isLargeScreen) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = upcomingEvents[index];
        return ClipPath(
          clipper: TicketClipper(punchRadius: 10, punchPosition: 0.68),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
            ),
            child: isLargeScreen
                ? Row(children: [Expanded(child: _buildTicketBody(event, colorScheme)), _buildTicketSideStub(event, colorScheme)])
                : Column(children: [_buildTicketBody(event, colorScheme), _buildTicketStubDivider(colorScheme), _buildTicketFooterAction(event, colorScheme)]),
          ),
        );
      },
    );
  }

  Widget _buildTicketBody(UpcomingEvent event, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (event.isVirtual ? Colors.teal : colorScheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  event.ticketType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: event.isVirtual ? Colors.teal : colorScheme.primary,
                  ),
                ),
              ),
              if (event.seat != null)
                Text('SEAT ${event.seat}', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetaInfo(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  subtitle: event.date,
                  colorScheme: colorScheme,
                ),
              ),
              Expanded(
                child: _buildMetaInfo(
                  icon: event.isVirtual ? Icons.videocam_outlined : Icons.location_on_outlined,
                  title: event.isVirtual ? 'Platform' : 'Location',
                  subtitle: event.location,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetaInfo({required IconData icon, required String title, required String subtitle, required ColorScheme colorScheme}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: colorScheme.surfaceContainerHigh,
          child: Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant.withOpacity(0.6))),
              Text(subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTicketStubDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          30,
              (index) => Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.transparent : colorScheme.outlineVariant.withOpacity(0.6),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketFooterAction(UpcomingEvent event, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: event.hasQRCode ? showTicketModal : () => showToast('Opening virtual stream...'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: event.isVirtual ? Colors.teal : colorScheme.primary,
              ),
              icon: Icon(event.hasQRCode ? Icons.qr_code_2 : Icons.launch, size: 18),
              label: Text(event.hasQRCode ? 'Show Ticket Pass' : 'Join Livestream'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: () => showToast('Saved to Google Calendar'),
            style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.calendar_month),
          )
        ],
      ),
    );
  }

  Widget _buildTicketSideStub(UpcomingEvent event, ColorScheme colorScheme) {
    return Container(
      width: 140,
      height: 170,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (event.hasQRCode) ...[
            const Icon(Icons.qr_code_2, size: 64),
            const SizedBox(height: 8),
            Text('TAP TO OPEN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          ] else ...[
            CircleAvatar(radius: 24, backgroundColor: Colors.teal.withOpacity(0.1), child: const Icon(Icons.link, color: Colors.teal)),
            const SizedBox(height: 8),
            const Text('WEB ACCESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
          ]
        ],
      ),
    );
  }

  Widget _buildPastEvents(ColorScheme colorScheme, bool isLargeScreen) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pastEvents.length,
      itemBuilder: (context, index) {
        final event = pastEvents[index];
        return Opacity(
          opacity: 0.7,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4))),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.history_toggle_off_rounded),
              ),
              title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(event.date, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorScheme.outlineVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(6)),
                child: const Text('ARCHIVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketModal(ColorScheme colorScheme, bool isSmallScreen) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Digital Entry Pass'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [IconButton(onPressed: hideTicketModal, icon: const Icon(Icons.close))],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: colorScheme.outlineVariant)),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=GES2024-VIP-12345',
                        width: 180,
                        height: 180,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Global Ecommerce Summit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text('Holder: Alex Chen', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        hideTicketModal();
                        showToast('Ticket Saved to Downloads');
                      },
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Save Offline PDF'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToastNotification(ColorScheme colorScheme) {
    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            toastMessage,
            style: TextStyle(color: colorScheme.onInverseSurface),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final double punchRadius;
  final double punchPosition;

  TicketClipper({required this.punchRadius, required this.punchPosition});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * punchPosition - punchRadius);
    path.arcToPoint(
      Offset(0, size.height * punchPosition + punchRadius),
      radius: Radius.circular(punchRadius),
      clockwise: true,
    );
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * punchPosition + punchRadius);
    path.arcToPoint(
      Offset(size.width, size.height * punchPosition - punchRadius),
      radius: Radius.circular(punchRadius),
      clockwise: true,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class UpcomingEvent {
  final String id;
  final String title;
  final String ticketType;
  final String date;
  final String time;
  final String location;
  final bool isVirtual;
  final bool hasQRCode;
  final String? ticketData;
  final String holderName;
  final String? seat;

  UpcomingEvent({
    required this.id,
    required this.title,
    required this.ticketType,
    required this.date,
    required this.time,
    required this.location,
    required this.isVirtual,
    required this.hasQRCode,
    this.ticketData,
    required this.holderName,
    this.seat,
  });
}

class PastEvent {
  final String title;
  final String date;
  final String ticketType;

  PastEvent({required this.title, required this.date, required this.ticketType});
}