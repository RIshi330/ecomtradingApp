import 'package:flutter/material.dart';

class Coupon {
  final String code;
  final String description;
  final String status;
  final String uses;
  final String type;

  Coupon({
    required this.code,
    required this.description,
    required this.status,
    required this.uses,
    required this.type,
  });
}

class PromotionsScreen extends StatefulWidget {
  final bool isEmbedded;
  const PromotionsScreen({super.key, this.isEmbedded = false});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final searchController = TextEditingController();
  List<Coupon> coupons = [
    Coupon(
      code: "WELCOME50",
      description: "50% Off First Purchase",
      status: "Active",
      uses: "142 / 500",
      type: "Percent",
    ),
    Coupon(
      code: "FESTIVE200",
      description: "₹200 Off (Min spend ₹1500)",
      status: "Active",
      uses: "89 / unlimited",
      type: "Flat",
    ),
    Coupon(
      code: "FREESHIP",
      description: "Free Shipping on B2B orders",
      status: "Paused",
      uses: "340 / unlimited",
      type: "Shipping",
    ),
    Coupon(
      code: "CORPMEMBER",
      description: "15% Off for Elite Members",
      status: "Active",
      uses: "25 / 100",
      type: "Percent",
    ),
  ];

  List<Coupon> get filteredCoupons {
    if (searchController.text.isEmpty) {
      return coupons;
    }
    return coupons.where((e) {
      return e.code.toLowerCase().contains(searchController.text.toLowerCase()) ||
          e.description.toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();
  }

  Color getStatusColor(String status) {
    return status == "Active" ? Colors.green : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search coupon codes or descriptions...",
              prefixIcon: const Icon(Icons.search, color: Color(0xff006565)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: summaryCard(
                  Colors.green.shade50,
                  Colors.green.shade800,
                  Icons.local_offer,
                  "Active Coupons",
                  "3 Coupons",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: summaryCard(
                  Colors.teal.shade50,
                  const Color(0xff006565),
                  Icons.trending_up,
                  "Campaign ROI",
                  "4.8x ROI",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Active Discount Campaigns",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Campaign builder workspace initialized"),
                      backgroundColor: Color(0xff006565),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Color(0xff006565)),
                label: const Text("Create Coupon", style: TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          filteredCoupons.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text("No coupons found", style: TextStyle(color: Colors.grey)),
                  ),
                )
              : Column(
                  children: filteredCoupons.map((coupon) {
                    final statusColor = getStatusColor(coupon.status);
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 14),
                      color: Colors.white,
                      shadowColor: Colors.black.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.qr_code, color: Color(0xff006565)),
                                    const SizedBox(width: 8),
                                    Text(
                                      coupon.code,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    coupon.status,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              coupon.description,
                              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Type: ${coupon.type}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                Text(
                                  "Redemptions: ${coupon.uses}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: statusColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Campaign status changed for ${coupon.code}"),
                                        backgroundColor: const Color(0xff006565),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    coupon.status == "Active" ? "Pause Campaign" : "Resume Campaign",
                                    style: TextStyle(color: statusColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff006565),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Detailed report exported for ${coupon.code}"),
                                        backgroundColor: const Color(0xff006565),
                                      ),
                                    );
                                  },
                                  child: const Text("Analytics", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xffFCF9F8),
        body: content,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Promotions & Discounts", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: content,
    );
  }

  Widget summaryCard(Color bgColor, Color textColor, IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
