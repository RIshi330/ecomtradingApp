import 'package:flutter/material.dart';

class LogisticsPartner {
  final String companyName;
  final String serviceType;
  final String route;
  final String deliveryTime;
  final String price;
  final double rating;
  final IconData icon;
  final Color badgeColor;
  final String category;
  final String transport;
  final double priceVal;
  final int speedDays;

  LogisticsPartner({
    required this.companyName,
    required this.serviceType,
    required this.route,
    required this.deliveryTime,
    required this.price,
    required this.rating,
    required this.icon,
    required this.badgeColor,
    required this.category,
    required this.transport,
    required this.priceVal,
    required this.speedDays,
  });
}

class LogisticsScreen extends StatefulWidget {
  final bool isEmbedded;
  const LogisticsScreen({super.key, this.isEmbedded = false});

  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen> {
  int selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  double selectedPrice = 8000;
  String selectedCategory = "Express Cargo";
  String selectedTransport = "Road";

  bool nextDay = false;
  bool express23 = true;
  bool standard57 = false;

  final List<LogisticsPartner> partners = [
    LogisticsPartner(
      companyName: "SwiftTrans",
      serviceType: "Express",
      route: "Delhi → Mumbai",
      deliveryTime: "2-3 Days Delivery",
      price: "₹20/km",
      rating: 4.8,
      icon: Icons.local_shipping,
      badgeColor: Colors.teal,
      category: "Express Cargo",
      transport: "Road",
      priceVal: 1200,
      speedDays: 2,
    ),
    LogisticsPartner(
      companyName: "AirLift Co",
      serviceType: "Air Cargo",
      route: "Bangalore → Chennai",
      deliveryTime: "24 Hours Delivery",
      price: "₹500/base",
      rating: 4.9,
      icon: Icons.flight,
      badgeColor: Colors.orange,
      category: "Standard Shipping",
      transport: "Air",
      priceVal: 3500,
      speedDays: 1,
    ),
    LogisticsPartner(
      companyName: "Ocean Freight",
      serviceType: "Sea Cargo",
      route: "Mumbai → Dubai",
      deliveryTime: "5-7 Days",
      price: "₹35/km",
      rating: 4.7,
      icon: Icons.directions_boat,
      badgeColor: Colors.blue,
      category: "Standard Shipping",
      transport: "Sea",
      priceVal: 6500,
      speedDays: 6,
    ),
    LogisticsPartner(
      companyName: "SafeStore Logistics",
      serviceType: "Warehousing",
      route: "Pune Hub (HQ)",
      deliveryTime: "Flexible Term Storage",
      price: "₹150/pallet",
      rating: 4.6,
      icon: Icons.warehouse,
      badgeColor: Colors.purple,
      category: "Warehousing",
      transport: "Road",
      priceVal: 2500,
      speedDays: 6,
    ),
    LogisticsPartner(
      companyName: "Pack & Box Solutions",
      serviceType: "Packaging Services",
      route: "PAN-India Dispatch",
      deliveryTime: "2-3 Days Delivery",
      price: "₹10/unit",
      rating: 4.7,
      icon: Icons.inventory_2,
      badgeColor: Colors.green,
      category: "Packaging Services",
      transport: "Road",
      priceVal: 900,
      speedDays: 2,
    ),
  ];

  List<LogisticsPartner> get filteredPartners {
    final search = searchController.text.toLowerCase();
    return partners.where((partner) {
      if (search.isNotEmpty &&
          !partner.companyName.toLowerCase().contains(search) &&
          !partner.route.toLowerCase().contains(search)) {
        return false;
      }
      if (partner.category != selectedCategory) {
        return false;
      }
      if (partner.transport != selectedTransport) {
        return false;
      }
      if (partner.priceVal > selectedPrice) {
        return false;
      }
      if (nextDay && partner.speedDays != 1) return false;
      if (express23 && partner.speedDays != 2) return false;
      if (standard57 && partner.speedDays != 6) return false;
      return true;
    }).toList();
  }

  void openMessage(LogisticsPartner partner) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Chat window opened with ${partner.companyName}"),
        backgroundColor: const Color(0xff006565),
      ),
    );
  }

  void openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "Service Filters",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006565),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        const Text(
                          "Service Categories",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 10),
                        ...[
                          "Standard Shipping",
                          "Express Cargo",
                          "Warehousing",
                          "Packaging Services",
                        ].map(
                          (e) {
                            final isSelected = selectedCategory == e;
                            return ListTile(
                              leading: Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? const Color(0xFF006565) : Colors.grey,
                              ),
                              title: Text(e, style: const TextStyle(fontSize: 14)),
                              onTap: () {
                                setModalState(() {
                                  selectedCategory = e;
                                });
                                setState(() {
                                  selectedCategory = e;
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Transport Mode",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: [
                            transportChip("Road", Icons.local_shipping, setModalState),
                            transportChip("Air", Icons.flight, setModalState),
                            transportChip("Sea", Icons.directions_boat, setModalState),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Price Range Up to ₹${selectedPrice.toInt()}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        Slider(
                          min: 500,
                          max: 10000,
                          divisions: 19,
                          value: selectedPrice,
                          activeColor: const Color(0xFF006565),
                          onChanged: (value) {
                            setModalState(() {
                              selectedPrice = value;
                            });
                            setState(() {
                              selectedPrice = value;
                            });
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₹500"),
                              Text("₹10,000+"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "Delivery Speed",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        CheckboxListTile(
                          value: nextDay,
                          title: const Text("Next Day Delivery", style: TextStyle(fontSize: 14)),
                          activeColor: const Color(0xFF006565),
                          onChanged: (value) {
                            setModalState(() {
                              nextDay = value!;
                            });
                            setState(() {
                              nextDay = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          value: express23,
                          title: const Text("2-3 Days Express", style: TextStyle(fontSize: 14)),
                          activeColor: const Color(0xFF006565),
                          onChanged: (value) {
                            setModalState(() {
                              express23 = value!;
                            });
                            setState(() {
                              express23 = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          value: standard57,
                          title: const Text("5-7 Days Standard", style: TextStyle(fontSize: 14)),
                          activeColor: const Color(0xFF006565),
                          onChanged: (value) {
                            setModalState(() {
                              standard57 = value!;
                            });
                            setState(() {
                              standard57 = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF006565)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(0, 44),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedPrice = 8000;
                              selectedCategory = "Express Cargo";
                              selectedTransport = "Road";
                              nextDay = false;
                              express23 = true;
                              standard57 = false;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Reset", style: TextStyle(color: Color(0xFF006565))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(0, 44),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Filters Applied Successfully"),
                                backgroundColor: Color(0xFF006565),
                              ),
                            );
                          },
                          child: const Text("Apply Filters"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget transportChip(String title, IconData icon, StateSetter modalSetState) {
    final selected = selectedTransport == title;
    return ChoiceChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.white : Colors.black87),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
      selectedColor: const Color(0xFF006565),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: selected ? Colors.transparent : Colors.grey.shade200),
      onSelected: (_) {
        modalSetState(() {
          selectedTransport = title;
        });
        setState(() {
          selectedTransport = title;
        });
      },
    );
  }

  void openBookingForm(LogisticsPartner partner) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Booking Request", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF006565))),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Pickup Pincode",
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Delivery Pincode",
                      prefixIcon: Icon(Icons.flag_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Volume (cu ft)",
                      prefixIcon: Icon(Icons.square_foot, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: "Weight (kg)",
                      prefixIcon: Icon(Icons.scale, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: "Road",
                    items: const [
                      DropdownMenuItem(value: "Road", child: Text("Road")),
                      DropdownMenuItem(value: "Air", child: Text("Air")),
                      DropdownMenuItem(value: "Sea", child: Text("Sea")),
                      DropdownMenuItem(value: "Rail", child: Text("Rail")),
                    ],
                    onChanged: (_) {},
                    decoration: const InputDecoration(
                      labelText: "Transport Mode",
                      prefixIcon: Icon(Icons.local_shipping_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Special Instructions",
                      prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Request sent successfully to ${partner.companyName}"),
                            backgroundColor: const Color(0xff006565),
                          ),
                        );
                      },
                      child: const Text("Send Request", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePartners = filteredPartners;

    Widget content = Column(
      children: [
        // Search Bar Row
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search partners or routes...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF006565)),
                    filled: true,
                    fillColor: const Color(0xffF0EDED),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF006565).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFF006565),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: openFilterDrawer,
                icon: const Icon(Icons.tune),
              )
            ],
          ),
        ),
        Expanded(
          child: activePartners.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 70, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        "No Logistics Partners Found",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Try relaxing filter sliders or keywords.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Hero Banner Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006565),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.local_shipping,
                              size: 120,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  "CORPORATE OFFER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Fastest PAN-India Logistics",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Book Express Cargo starting at just ₹20/km with verified logistics partners.",
                                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Partner Lists
                    ...activePartners.map(
                      (partner) => LogisticsPartnerCard(
                        partner: partner,
                        onBook: () => openBookingForm(partner),
                        onMessage: () => openMessage(partner),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xffFCF9F8),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
        ),
        title: const Text(
          "Logistics Marketplace",
          style: TextStyle(
            color: Color(0xFF006565),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: openFilterDrawer,
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF006565),
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}

class LogisticsPartnerCard extends StatelessWidget {
  final LogisticsPartner partner;
  final VoidCallback onBook;
  final VoidCallback onMessage;

  const LogisticsPartnerCard({
    super.key,
    required this.partner,
    required this.onBook,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xffF6F3F2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006565).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    partner.icon,
                    color: const Color(0xFF006565),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.companyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            partner.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: partner.badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    partner.serviceType,
                    style: TextStyle(
                      color: partner.badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.trip_origin, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      partner.route,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      partner.deliveryTime,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      partner.price,
                      style: const TextStyle(
                        color: Color(0xFF006565),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: onMessage,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF006565)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        minimumSize: const Size(75, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text("Message", style: TextStyle(color: Color(0xFF006565), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: onBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        minimumSize: const Size(80, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text("Book Now", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
