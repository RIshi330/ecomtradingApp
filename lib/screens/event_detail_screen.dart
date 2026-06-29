import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/index.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isFavorited = false;
  int _ticketQty = 1;
  
  final List<String> _galleryImages = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC6Yu7C9SoUIGrKimAcDvJY56b-U5amQZD2YG99yxK1IKfWVYGxENex1gr3a0AafTgIj3OvSCxcigGT8WWD7NNYbzXJGSvtxfxJ8MWlM3ZkrM1nqVyoz33QsPlnBDoGrk2BkfaVkNys-aKkZAIICPX-a7tCQ7MITnZUgT_MXdVerpwxnUQ5ku9DmXLzsleAT3es-OoS_E6OBwx_EOU9uCbV20C5LdgYr8ChtktuCk1qjxwxLtF4TU5nXeK5Np7l5N_d4A69tUmllAY',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCn3R2N8RDMa46vJjpp6kujfN1wgTTDMw9D5C5FWoAwiTxi4CMDQFQklTf4LbHWvwrX3O3X4vCZ5mSXB3VzBY5KncdylcA-grWmo7YkvOXnc1r2OWYJkUFPZIOSfiVEiCLIT4Of03eUX0UdEpTyMCQaTi4g4Gqzcci89TMZvVtSJ1Z6REm2GCS5LruIT6BpQm8jBCaFhyXDr6MPbfXL8wsZxLum0-ZsBn5dHQ0qJDe7rWwufMKDfRuDdbNFYUl8rbH_EaRKQniH8OA',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCcuXC25etDeY1Wef3QpukAEgHX7y3LrpklFX3AOHUIfIVDeIYJ6QDVXpROAkT_UWiYyai79uUv-WL7kPx6ziUW97PBrYUMGRUjooF_Sb-KPUVvFhUB8UoRxXQviyr5NbDdVLIc0BEp_bS3U5J0n_6Wy-_7onyMT0SgWGX5yG05D9kljzt7-t4tluqmPVCaHn2_IBed4tTkdUokzuj-PQI2rdSJzGlMpBLOu4q7sCOPR5M4Lno0BF7m4aBWYnaZxqXb1OZKVbjt3pc',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBAXmT7Hlkp8bHMkJKAFB5oRrxYf4m-Lx5mjQRRso2CocMxC6udYr5-RJPvTs1zKo28A5BOM63_2v8OGr5aDnB5RcMU9XMhTM1O-WtHe5a6U-9KfUnRwy69Du-_OSZm6kfiQv0BuVmFsjMm-AhquUMZLlRxNo0AxreLQsn3E4uQRxRcTN9YRfKcHaRZY9CjKjVXb5yiP57QVhpkL6JWBUDgNcCuAk3i1cF9CxSsGs60Nhm0p903Vslc6hY5ouPsmFOvCsjurzvKxgs'
  ];

  final List<Map<String, dynamic>> _similarEvents = [
    {
      'title': 'Future of Design 2024',
      'category': 'DESIGN',
      'price': '₹199.00',
      'date': 'Nov 12',
      'location': 'San Francisco, CA',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBvWSqjdBv4GtYU6hL74Sf0UqdKO8QUlzhZWEsPtTqgr6Sm_XJJlUzzMOk8L_4JE84NScRp-v1Bj8SQgE3FUKtaJo9HAnIh7COV_-wut9LJOqGjPlA4-Gw5uNv4R-JgcorJvSkAsdA1gBXVh8Gj02bpEkzVfYid5-xWo2KMeSAzXxxj8nd5tZCFmcai6EWHnLarV3CiSWT6fd_D1oNP8NCn-524uRDO6_gTpI_cXLjCRsLROyTDtnlbMJZHCt76inRDtVUsAq7-3Jo',
    },
    {
      'title': 'Data Science Workshop',
      'category': 'SCIENCE',
      'price': '₹89.00',
      'date': 'Nov 18',
      'location': 'Online',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBsaKkkyuutP5N79ueU5NjQ2e-redxsMRmEj7XiuetFBV4lbqZ7iBOLyoQrenUIMXBGFjun1Fc5Y2L6NR4ByztifvqGXRvGN40HiHiLKUCLuinw8Vkz05qb7a1hwQR2HhzI1pgH2E1acmNIN06mbkWH1Xb3jYn7ZCYCG0-f7ATobA4QWQF5fcIGk7Z9a1q0rtXvn4HdJoZmaLjMkOB6x7IIOh357ebaE5IQxWkh67Qq4jfCvA08P-PnobgtgQSm5VqggQsWNQ3prj4',
    },
  ];

  void _showCheckoutSheet() {
    final price = widget.event['price'] as double? ?? 0.00;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalPrice = price * _ticketQty;
            final isFree = price == 0;

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Tickets",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "General Admission",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isFree ? "FREE" : "₹${price.toStringAsFixed(2)}",
                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primary, size: 28),
                              onPressed: () {
                                if (_ticketQty > 1) {
                                  setModalState(() => _ticketQty--);
                                }
                              },
                            ),
                            Text(
                              "$_ticketQty",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 28),
                              onPressed: () {
                                setModalState(() => _ticketQty++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPaymentGateway(totalPrice);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isFree ? "Confirm Reservation" : "Checkout (₹${totalPrice.toStringAsFixed(2)})",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentGateway(double totalPrice) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedMethod = 'Digital Wallet';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Confirm Payment", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        const Text("Total Amount:", style: TextStyle(color: AppTheme.textSecondary)),
                        Text("₹${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Payment Method", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
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
                    _showSuccessDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.secondaryContainer,
                child: Icon(Icons.check_circle, size: 48, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                "Tickets Confirmed!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your registration is complete. We've sent details to your registered email.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContactModal() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Contact Organizer",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Your Name",
                    fillColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Your Email",
                    fillColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(text: "Inquiry: ${widget.event['title']}"),
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    fillColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Your Message",
                    alignLabelWithHint: true,
                    fillColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Message sent successfully!"),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Send Message", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ev = widget.event;
    final isFree = ev['price'] == 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Event Details",
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Link to ${ev['title']} copied!"),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner section
            Stack(
              children: [
                Image.network(
                  ev['imageUrl'] as String,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ev['category'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      setState(() {
                        _isFavorited = !_isFavorited;
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.redAccent,
                    child: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and reviews
                  Text(
                    ev['title'] as String,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Icon(Icons.star_half, color: Colors.amber, size: 18),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${ev['rating'] ?? 4.8} (${ev['reviewsCount'] ?? 120} reviews)",
                        style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Organizer block
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(ev['organizerImageUrl'] as String),
                          child: ev['organizerImageUrl'] == null
                              ? Text(ev['organizerInitials'] as String)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Organizer", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              const SizedBox(height: 2),
                              Text(ev['organizer'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primary),
                          onPressed: _showContactModal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bento Info Box Layout
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.calendar_today_outlined, "Date", ev['dateFull'] as String),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(Icons.schedule_outlined, "Time", ev['time'] as String),
                        const Divider(height: 24, thickness: 0.5),
                        _buildInfoRow(Icons.location_on_outlined, "Location", ev['locationFull'] as String),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  const Text("About the Event", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    ev['about'] as String,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (ev['tags'] as List<String>? ?? []).map((tag) {
                      return Chip(
                        label: Text("#$tag"),
                        backgroundColor: AppTheme.surfaceContainer.withOpacity(0.5),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Gallery
                  const Text("Gallery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _galleryImages.length,
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _galleryImages[idx],
                              width: 180,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sponsors / Partners
                  const Text("Sponsors & Partners", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 2.8,
                    children: ['LOGO_ONE', 'LOGO_TWO', 'LOGO_THREE', 'LOGO_FOUR'].map((logo) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.outline.withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text(
                            logo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Map Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      TextButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 16, color: AppTheme.primary),
                        label: const Text("Google Maps", style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBtT6i3X2Ghf4ZnXvjM4JbsXtRXi72J-eGTe0bKU6BLZyZjBb57ulC_PG_c_fqn5qYx0H2tVtAcv6ZKB68iAh0MwauO8nl1h4zUGwYg2-VEMC0xQg3wEs5mTsZRPv3hTMYaGA4Yny_tK-pZ5LJeYAscYfdtSb256oe2VF93eSdmY8PIvNJsf2x0hD3pGMklbDe4Uc1HFu5o3QgCDjHPKryQOs7WxKZnxChQMjw1PMVanDEfP0SHmINqe6_LxBsICz3md9qL2BEMBF8',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Similar Events
                  const Text("Similar Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _similarEvents.length,
                      itemBuilder: (context, idx) {
                        final se = _similarEvents[idx];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(se['imageUrl'] as String, height: 100, width: double.infinity, fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(4)),
                                          child: Text(se['category'] as String, style: const TextStyle(fontSize: 8, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                        ),
                                        Text(se['date'] as String, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(se['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(se['price'] as String, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text("Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Event added to your calendar!"),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.confirmation_number, size: 16),
                label: Text(isFree ? "Reserve Spot" : "Buy Tickets", style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _showCheckoutSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
