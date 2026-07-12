import 'package:flutter/material.dart';

class MyResponsesScreen extends StatefulWidget {
  const MyResponsesScreen({super.key});

  @override
  State<MyResponsesScreen> createState() => _MyResponsesScreenState();
}

class _MyResponsesScreenState extends State<MyResponsesScreen> {
  String selectedFilter = 'All';
  bool isContactModalVisible = false;
  String? selectedAdminName;
  String? selectedOpportunityTitle;
  final TextEditingController messageController = TextEditingController();

  final List<ResponseCard> responses = [
    ResponseCard(
      id: '1',
      title: 'Strategic Marketing Expansion',
      status: 'Under Review',
      statusType: ResponseStatus.review,
      dateTime: 'Oct 12, 2023 • 10:24 AM',
      budgetRange: '\$45,000 - \$60,000',
      category: 'Digital Growth',
      response: '"Our proposed strategy focuses on a multi-channel approach leveraging automated segmentation and high-conversion landing pages. We anticipate a 25% increase in acquisition efficiency within the first quarter..."',
      attachment: 'Proposal_V2.pdf',
      adminName: 'Sarah Admin',
      isEditable: true,
    ),
    ResponseCard(
      id: '2',
      title: 'Logistics Optimization Protocol',
      status: 'Accepted',
      statusType: ResponseStatus.accepted,
      dateTime: 'Oct 08, 2023 • 03:15 PM',
      budgetRange: '\$120,000 - \$150,000',
      category: 'Supply Chain',
      response: 'Implementation of a real-time tracking dashboard and route optimization algorithm designed for 15% reduction in fuel costs.',
      attachment: null,
      adminName: 'Mike Logistics',
      isEditable: false,
    ),
    ResponseCard(
      id: '3',
      title: 'UX Audit for Retail App',
      status: 'Pending',
      statusType: ResponseStatus.pending,
      dateTime: 'Oct 14, 2023 • 09:00 AM',
      budgetRange: '\$12,000',
      category: 'User Experience',
      response: 'Comprehensive 4-week audit covering accessibility, navigation flow, and checkout optimization.',
      attachment: null,
      adminName: 'Devon UX',
      isEditable: true,
    ),
  ];

  List<ResponseCard> get filteredResponses {
    if (selectedFilter == 'All') return responses;
    return responses.where((response) {
      switch (selectedFilter) {
        case 'Pending':
          return response.statusType == ResponseStatus.pending;
        case 'Accepted':
          return response.statusType == ResponseStatus.accepted;
        case 'Under Review':
          return response.statusType == ResponseStatus.review;
        default:
          return true;
      }
    }).toList();
  }

  void openContactModal(String title, String adminName) {
    setState(() {
      selectedOpportunityTitle = title;
      selectedAdminName = adminName;
      isContactModalVisible = true;
      messageController.text =
      'Hi $adminName, I am following up on my response for \'$title\'. I\'m available to discuss any additional details you might need regarding the technical implementation phase.';
    });
  }

  void closeContactModal() {
    setState(() {
      isContactModalVisible = false;
    });
  }

  void sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent successfully!')),
    );
    closeContactModal();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTopAppBar(colorScheme),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilters(colorScheme),
                            const SizedBox(height: 24),
                            ...filteredResponses.map((response) =>
                                _buildResponseCard(response, colorScheme)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Mobile Bottom Navigation
          _buildMobileBottomNav(colorScheme),
          // Contact Modal
          if (isContactModalVisible) _buildContactModal(colorScheme),
        ],
      ),
    );
  }


  Widget _buildSidebarItem(IconData icon, String label, bool isActive,
      ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border(
          left: BorderSide(color: colorScheme.primary, width: 4),
        )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.menu,
                  color: colorScheme.onSurfaceVariant,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                ),
              ),
              Text(
                'My Responses',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search responses...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDHLKReih9aDxLIFwh6dipaGPu1unqh5trMbQXli2UcRyfpJHDqHU4D8xAFmWQDM-yu3qPUr_9TxBJpw_nWgDn8BW1vnSDQh98QgFPjNJsP2L_wtLWUdGvBcZvQabZBwoO5GfRHGanWWozPHigWrvZUKmUjZ2J1KGkUcIPO8WfvPPZt5DtCN68LN07UBTwUV-QKv-7qPTcDxekc6vKIPxkAg8KCykZFTTGTNBEZ6PHou0q4WTTpplxZ',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    final filters = ['All', 'Pending', 'Accepted', 'Under Review'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.05,
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Text(
                  'Sort by:',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.05,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                DropdownButton<String>(
                  value: 'Latest Submission',
                  underline: const SizedBox(),
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.05,
                    color: colorScheme.primary,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Latest Submission',
                      child: Text('Latest Submission'),
                    ),
                    DropdownMenuItem(
                      value: 'Budget High-Low',
                      child: Text('Budget High-Low'),
                    ),
                    DropdownMenuItem(
                      value: 'Status Priority',
                      child: Text('Status Priority'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponseCard(ResponseCard response, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            response.title,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(response.statusType,
                                colorScheme),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            response.status,
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.05,
                              color: _getStatusTextColor(response.statusType,
                                  colorScheme),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          response.dateTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BUDGET RANGE',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.05,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              response.budgetRange,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.05,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              response.category,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildExpandableResponse(response, colorScheme),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  color: colorScheme.outlineVariant.withOpacity(0.3),
                ),
                const SizedBox(width: 16),
              ],
              SizedBox(
                width: isDesktop ? 256 : double.infinity,
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => openContactModal(
                          response.title, response.adminName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Contact Admin'),
                    ),
                    const SizedBox(height: 8),
                    if (response.isEditable)
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: colorScheme.primary),
                          foregroundColor: colorScheme.primary,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Response'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: colorScheme.outlineVariant),
                          foregroundColor: colorScheme.outlineVariant,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.lock, size: 18),
                        label: const Text('Edit Locked'),
                      ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        textStyle: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.05,
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('View Original Opportunity'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpandableResponse(ResponseCard response, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.description,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'View My Response',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.expand_more,
          color: colorScheme.primary,
        ),
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  response.response,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (response.attachment != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          response.attachment!,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.05,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav(ColorScheme colorScheme) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMobileNavItem(Icons.storefront, 'Vendors', false, colorScheme),
          _buildMobileNavItem(Icons.inventory_2, 'Products', false, colorScheme),
          _buildMobileNavItem(
            Icons.account_balance_wallet,
            'Finance',
            true,
            colorScheme,
            isActive: true,
          ),
          _buildMobileNavItem(Icons.group_add, 'Recruit', false, colorScheme),
          _buildMobileNavItem(Icons.track_changes, 'Tracker', false, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem(IconData icon, String label, bool isPrimary,
      ColorScheme colorScheme,
      {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.05,
              color: isActive
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactModal(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: closeContactModal,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(16),
              width: 480,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Follow-up Message',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: closeContactModal,
                          icon: Icon(
                            Icons.close,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Direct message to administrator regarding your submission.',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECIPIENT',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.05,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                selectedAdminName ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR MESSAGE',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.05,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: messageController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: closeContactModal,
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            textStyle: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.05,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: sendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 4,
                            textStyle: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.05,
                            ),
                          ),
                          child: const Text('Send Message'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ResponseStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ResponseStatus.accepted:
        return colorScheme.primary;
      case ResponseStatus.review:
        return const Color(0xFFFFB300);
      case ResponseStatus.pending:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusTextColor(ResponseStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ResponseStatus.accepted:
        return Colors.white;
      case ResponseStatus.review:
        return colorScheme.onSurface;
      case ResponseStatus.pending:
        return Colors.white;
    }
  }
}

enum ResponseStatus {
  pending,
  accepted,
  review,
}

class ResponseCard {
  final String id;
  final String title;
  final String status;
  final ResponseStatus statusType;
  final String dateTime;
  final String budgetRange;
  final String category;
  final String response;
  final String? attachment;
  final String adminName;
  final bool isEditable;

  ResponseCard({
    required this.id,
    required this.title,
    required this.status,
    required this.statusType,
    required this.dateTime,
    required this.budgetRange,
    required this.category,
    required this.response,
    this.attachment,
    required this.adminName,
    required this.isEditable,
  });
}