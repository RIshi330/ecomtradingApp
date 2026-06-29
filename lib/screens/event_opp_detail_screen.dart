import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';

class EventOppDetailScreen extends StatefulWidget {
  final Map<String, dynamic> opportunity;
  const EventOppDetailScreen({super.key, required this.opportunity});

  @override
  State<EventOppDetailScreen> createState() => _EventOppDetailScreenState();
}

class _EventOppDetailScreenState extends State<EventOppDetailScreen> {
  int? _selectedStallRadio; // 1: Premium ($5000), 2: Standard ($3500), 3: Kiosk ($1500)
  
  // Track expanded state for the 3 tiers
  bool _goldExpanded = true;
  bool _silverExpanded = false;
  bool _launchExpanded = false;

  void _showPaymentModal(String tierName, double price) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedMethod = 'Digital Wallet';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Payment Gateway", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tierName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("₹${price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Payment Method", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  ...['Digital Wallet', 'Credit/Debit Card', 'UPI / QR Pay'].map((method) {
                    return RadioListTile<String>(
                      title: Text(method, style: const TextStyle(fontSize: 14)),
                      value: method,
                      groupValue: selectedMethod,
                      activeColor: AppTheme.primary,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedMethod = val);
                        }
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showToast("Payment Successful! Registration confirmed.");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Confirm Payment"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStallConfirmModal(String name, double basePrice) {
    final tax = basePrice * 0.15;
    final total = basePrice + tax;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.secondaryContainer,
                child: Icon(Icons.shopping_cart_checkout, size: 40, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              const Text("Confirm Booking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text(
                "Booking $name for ₹${basePrice.toStringAsFixed(0)} plus 15% service tax:",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                "₹${total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.outline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showToast("Stall booked successfully!");
                      },
                      child: const Text("Confirm"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApplyModal() {
    final companyController = TextEditingController();
    final personController = TextEditingController();
    final webController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Participation Application", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: "Company Name", fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: personController,
                  decoration: const InputDecoration(labelText: "Contact Person", fillColor: Colors.transparent),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: webController,
                  decoration: const InputDecoration(labelText: "Website", fillColor: Colors.transparent),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessApplicationDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Submit Application", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessApplicationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.secondaryContainer,
                child: Icon(Icons.check_circle, size: 44, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              const Text("Application Sent!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                "Thank you for your interest. The organizer will review your application and contact you shortly.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessageModal() {
    final textController = TextEditingController(
      text: "Hi Sarah, I'm interested in the Gold Sponsorship tier for ${widget.opportunity['title']}. Could we schedule a brief call to discuss the details?"
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Message Sarah J. Miller", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: TextField(
            controller: textController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.transparent,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showToast("Message sent successfully!");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Send Message"),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Opportunity Details",
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.textSecondary),
            onPressed: () => _showToast("Link copied to clipboard!"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section banner
            Stack(
              children: [
                Image.network(
                  opp['imageUrl'] as String,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${opp['category'].toString().toUpperCase()} OPPORTUNITY",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opp['title'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.groups, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(opp['reach'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            const SizedBox(width: 14),
                            const Icon(Icons.calendar_month, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(opp['date'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            const SizedBox(width: 14),
                            const Icon(Icons.location_on, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(opp['location'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strategic Overview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Strategic Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        const SizedBox(height: 10),
                        Text(
                          opp['description'] as String? ?? 'Unlock strategic access to top-tier industry executives and decision-makers.',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Target Audience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primary, letterSpacing: 0.5)),
                                  const SizedBox(height: 6),
                                  _buildOverviewBullet("Enterprise Decision Makers"),
                                  _buildOverviewBullet("Tech Venture Capitalists"),
                                  _buildOverviewBullet("Mid-market IT Executives"),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Visibility Benefits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primary, letterSpacing: 0.5)),
                                  const SizedBox(height: 6),
                                  _buildOverviewBullet("Main Stage Keynote Mention"),
                                  _buildOverviewBullet("Digital Media Wall Placement"),
                                  _buildOverviewBullet("Post-Event Insight Report"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bento Grid projected impact
                  const Text("Projected Impact & Analytics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBentoCard(Icons.person_search, "12.4k", "Targeted Professionals"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBentoCard(Icons.analytics, "1.2M", "Media Impressions"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildBentoCard(Icons.fingerprint, "4.5k", "Expected Footfall"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Participation Tiers Accordion
                  const Text("Participation Tiers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),

                  // Gold Sponsor
                  _buildTierCard(
                    title: "Gold Sponsor",
                    price: 25000,
                    isExpanded: _goldExpanded,
                    desc: "Maximum exposure tier including exclusive rights to the evening gala and main stage logo placement.",
                    bullets: [
                      "400sqft Premium Booth",
                      "Logo on All Digital Assets",
                      "10 VIP Delegate Passes",
                      "Featured Media Interview"
                    ],
                    onToggle: () => setState(() => _goldExpanded = !_goldExpanded),
                  ),
                  const SizedBox(height: 10),

                  // Silver Sponsor
                  _buildTierCard(
                    title: "Silver Sponsor",
                    price: 12500,
                    isExpanded: _silverExpanded,
                    desc: "Standard exposure tier with networking access and digital recognition.",
                    bullets: [
                      "200sqft Booth",
                      "Logo on Website",
                      "5 Delegate Passes"
                    ],
                    onToggle: () => setState(() => _silverExpanded = !_silverExpanded),
                  ),
                  const SizedBox(height: 10),

                  // Product Partner
                  _buildTierCard(
                    title: "Product Launch Partner",
                    price: 8000,
                    isExpanded: _launchExpanded,
                    desc: "Specialized tier for startups looking to launch new products to enterprise buyers.",
                    bullets: [
                      "Demo Stage Slot",
                      "Press Release Inclusion"
                    ],
                    onToggle: () => setState(() => _launchExpanded = !_launchExpanded),
                  ),
                  const SizedBox(height: 24),

                  // Exhibition Stalls Selection
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Exhibition Stalls", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        const SizedBox(height: 12),
                        _buildStallRadio(1, "Premium Corner", "4x4m • ₹5,000", 5000),
                        const SizedBox(height: 8),
                        _buildStallRadio(2, "Standard Booth", "3x3m • ₹3,500", 3500),
                        const SizedBox(height: 8),
                        _buildStallRadio(3, "Product Kiosk", "2x2m • ₹1,500", 1500),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.storefront, size: 16),
                          label: const Text("Book Selected Stall", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            if (_selectedStallRadio == 1) {
                              _showStallConfirmModal("Premium Corner", 5000);
                            } else if (_selectedStallRadio == 2) {
                              _showStallConfirmModal("Standard Booth", 3500);
                            } else if (_selectedStallRadio == 3) {
                              _showStallConfirmModal("Product Kiosk", 1500);
                            } else {
                              _showToast("Please select a stall type first");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Organized By
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Organized By", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBcbV9NsY3O1Pr1PsEK59z0wARpMm7yxWS6ufIVB7MZFeQKDiEss0prVajiZZOy0VySU7uxkpHEslFeknumdYbG7CKh1Ugg5vBC0m9wGkGNGT8Q77SEfd5BIQaRhQ69EwiTAruJ38PKdBPOam-ATVhTmgD8ZfBD8BFI1pH6fzbcHpdeiYcCwNWvm9EeHCVNj95I3PNEXJ7Cv8hiev9scVjengJ4gZmjiTjn-hpiOKCtjiSFU6d7fk14h62Wc7-SRhVLokTxAU9IqGI',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Sarah J. Miller", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 14),
                                      SizedBox(width: 4),
                                      Text("4.9", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(" (124 Events)", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.mail_outline, size: 16),
                          label: const Text("Message Organizer", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _showMessageModal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Venue Location", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppTheme.primary, size: 18),
                                  const SizedBox(width: 6),
                                  Text("Moscone Center, ${opp['location']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuC-e0DdgFOXy40XhasIn6vVu4N8e8fchxb_tATWIm2dPt-6umcgc7d2WfPHpxzURd6HuS2JSsZAWa0m7fhIZVZC2_FX1qoJ8Bbz6drmrIhIkZIA6KGJcursO4paEXy_uweTyxotPOn-TzOMTa-rR8zMn64SzL038ikjq2gqjOkA39p2ALtePc7a7l59iLxD3oOE7QTX-MYLYUg-euPmcJDoB8QLNPKPkFQC-Qx7PorR_1uzlw9XjdVbVlUHZ42M1Z1SmM1AJrIfPsk',
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: TextButton.icon(
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text("Get Directions", style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timeline & Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Application Status", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                            Row(
                              children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary)),
                                const SizedBox(width: 6),
                                const Text("Accepting Proposals", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTimelineRow("Early Bird Deadline", "August 30, 2024", true),
                        _buildTimelineRow("Final Deadline", "October 15, 2024", false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text("Prospectus", style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  _showToast("Downloading prospectus...");
                  Future.delayed(const Duration(seconds: 2), () {
                    _showToast("Download Complete");
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment_turned_in, size: 16),
                label: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _showApplyModal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildBentoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required String title,
    required double price,
    required bool isExpanded,
    required String desc,
    required List<String> bullets,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
            subtitle: Text("₹${price.toStringAsFixed(0)}", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.textSecondary),
            onTap: onToggle,
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                  const SizedBox(height: 12),
                  ...bullets.map((bullet) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(bullet, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payments, size: 16),
                    label: const Text("Pay & Register", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => _showPaymentModal(title, price),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStallRadio(int val, String title, String subtitle, double price) {
    final isSelected = _selectedStallRadio == val;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStallRadio = val;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.outline.withOpacity(0.5), width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primary.withOpacity(0.03) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            Radio<int>(
              value: val,
              groupValue: _selectedStallRadio,
              activeColor: AppTheme.primary,
              onChanged: (int? value) {
                setState(() {
                  _selectedStallRadio = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(String title, String date, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? AppTheme.primary : AppTheme.outline,
                ),
              ),
              Container(width: 1, height: 24, color: AppTheme.outline),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
