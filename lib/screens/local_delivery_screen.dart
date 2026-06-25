import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../Database/Database.dart';

class DeliveryPartner {
  final int vendorId;
  final String name;
  final String role;
  final double rating;
  final int reviews;
  final String vehicle;
  final String distance;
  final String price;
  final bool available;
  final String image;
  final double latitude;
  final double longitude;

  DeliveryPartner({
    required this.vendorId,
    required this.name,
    required this.role,
    required this.rating,
    required this.reviews,
    required this.vehicle,
    required this.distance,
    required this.price,
    required this.available,
    required this.image,
    required this.latitude,
    required this.longitude,
  });
}

class LocalDeliveryScreen extends StatefulWidget {
  final bool isEmbedded;
  const LocalDeliveryScreen({super.key, this.isEmbedded = false});

  @override
  State<LocalDeliveryScreen> createState() => _LocalDeliveryScreenState();
}

class _LocalDeliveryScreenState extends State<LocalDeliveryScreen> {
  bool isMapView = false;
  String searchText = "";
  bool isLoading = false;

  List<DeliveryPartner> partners = [];

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  Future<void> _fetchPartners() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'fetch_partners',
      }, endpoint: 'new_apis/check_delivery_boy.php');

      if (response['status'] == true && response['partners'] != null) {
        final List<dynamic> partnerList = response['partners'];
        final List<DeliveryPartner> fetched = [];
        for (var item in partnerList) {
          final String rawImg = item['image']?.toString() ?? '';
          final String imageUrl = rawImg.isNotEmpty
              ? (rawImg.startsWith('http') ? rawImg : 'http://10.0.2.2/SetupBackendCCBUL/$rawImg')
              : "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200";

          fetched.add(
            DeliveryPartner(
              vendorId: int.tryParse(item['vendor_id']?.toString() ?? '0') ?? 0,
              name: item['name']?.toString() ?? '',
              role: item['role']?.toString() ?? 'Delivery Partner',
              rating: double.tryParse(item['rating']?.toString() ?? '4.5') ?? 4.5,
              reviews: int.tryParse(item['reviews']?.toString() ?? '10') ?? 10,
              vehicle: item['vehicle']?.toString() ?? 'Standard Vehicle',
              distance: item['distance']?.toString() ?? '2.5 km',
              price: item['price']?.toString() ?? '₹12/km',
              available: item['available'] == true || item['available'] == 1 || item['available'] == '1',
              image: imageUrl,
              latitude: double.tryParse(item['latitude']?.toString() ?? '12.9716') ?? 12.9716,
              longitude: double.tryParse(item['longitude']?.toString() ?? '77.5946') ?? 77.5946,
            ),
          );
        }
        setState(() {
          partners = fetched;
        });
      }
    } catch (e) {
      debugPrint("Error fetching delivery partners: $e");
    } finally {
      // Fallback if no partners are found from DB
      if (partners.isEmpty) {
        setState(() {
          partners = [
            DeliveryPartner(
              vendorId: 2,
              name: "Rahul Sharma",
              role: "Express Courier",
              rating: 4.8,
              reviews: 124,
              vehicle: "Honda Activa",
              distance: "2.5 km",
              price: "₹12/km",
              available: true,
              image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200",
              latitude: 12.9716,
              longitude: 77.5946,
            ),
            DeliveryPartner(
              vendorId: 3,
              name: "Vikram Singh",
              role: "Heavy Load Specialist",
              rating: 4.9,
              reviews: 210,
              vehicle: "Tata Ace",
              distance: "4.2 km",
              price: "₹28/km",
              available: true,
              image: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200",
              latitude: 12.9760,
              longitude: 77.6030,
            ),
            DeliveryPartner(
              vendorId: 4,
              name: "Ananya Das",
              role: "Standard Delivery",
              rating: 4.7,
              reviews: 86,
              vehicle: "Ather 450X",
              distance: "1.8 km",
              price: "₹10/km",
              available: true,
              image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200",
              latitude: 12.9650,
              longitude: 77.5890,
            ),
          ];
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshPartners() async {
    await _fetchPartners();
  }

  void openMessageModal(DeliveryPartner partner) {
    final controller = TextEditingController(
      text: "Hello ${partner.name}, I am interested in collaborating for my recent delivery requirements. Could you please provide more details about your current availability?",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Message ${partner.name}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff006565)),
        ),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff006565), width: 1.5),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006565),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              Navigator.pop(context);

              try {
                final response = await Database().getData({
                  'receiver_id': partner.vendorId,
                  'msg_type': 'Business_proposal',
                  'message': text,
                }, endpoint: 'new_apis/invite_as_partner_API.php');

                if (response['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']?.toString() ?? "Message sent to ${partner.name}"),
                      backgroundColor: const Color(0xff006565),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']?.toString() ?? "Failed to send message"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                debugPrint("Error sending business proposal message: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error sending message. Please try again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void openInviteModal(DeliveryPartner partner) {
    final controller = TextEditingController(
      text: "Dear ${partner.name}, We are impressed with your profile and would like to invite you to join our official delivery network as a partner.",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Invite Partner",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff006565)),
        ),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff006565), width: 1.5),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text("Decline", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006565),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              Navigator.pop(context);

              try {
                final response = await Database().getData({
                  'receiver_id': partner.vendorId,
                  'msg_type': 'Invite_as_partner',
                  'message': text,
                }, endpoint: 'new_apis/invite_as_partner_API.php');

                if (response['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']?.toString() ?? "Invitation sent to ${partner.name}"),
                      backgroundColor: const Color(0xff006565),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response['message']?.toString() ?? "Failed to send invitation"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                debugPrint("Error sending invite message: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error sending invitation. Please try again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Send Invitation"),
          ),
        ],
      ),
    );
  }

  void openProfileModal(DeliveryPartner partner) {
    String checkPincode = "";
    bool isCheckingAvailability = false;
    String? availabilityResult; // "available", "unavailable", "error"
    String? availabilityMessage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xff006565), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(partner.image),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.verified,
                              color: Color(0xff008080),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      partner.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      partner.role,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff006565),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${partner.rating}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          " (${partner.reviews} reviews)",
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Vehicle Type", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              Text(partner.vehicle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Price / Rate", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              Text(partner.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff006565))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Distance Near You", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              Text(partner.distance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "About Partner",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Professional delivery partner specializing in secure and timely transit. Verified clean safety record, active delivery credentials, and highly rated for logistics efficiency inside the local region.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const Divider(height: 30),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Check Delivery Availability",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Enter Pincode",
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            onChanged: (value) {
                              checkPincode = value.trim();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006565),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(80, 40),
                          ),
                          onPressed: isCheckingAvailability
                              ? null
                              : () async {
                                  if (checkPincode.isEmpty) return;
                                  setModalState(() {
                                    isCheckingAvailability = true;
                                    availabilityResult = null;
                                  });
                                  try {
                                    final response = await Database().getData({
                                      'vendor_id': partner.vendorId,
                                      'pincode': checkPincode,
                                    }, endpoint: 'new_apis/check_delivery_boy.php');
                                    
                                    setModalState(() {
                                      if (response['status'] == true) {
                                        availabilityResult = response['can_deliver'] == true ? "available" : "unavailable";
                                        availabilityMessage = response['message']?.toString() ?? "Check complete.";
                                      } else {
                                        availabilityResult = "error";
                                        availabilityMessage = response['message']?.toString() ?? "Check failed.";
                                      }
                                    });
                                  } catch (e) {
                                    setModalState(() {
                                      availabilityResult = "error";
                                      availabilityMessage = "Error connecting to server.";
                                    });
                                  } finally {
                                    setModalState(() {
                                      isCheckingAvailability = false;
                                    });
                                  }
                                },
                          child: isCheckingAvailability
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text("Check"),
                        ),
                      ],
                    ),
                    if (availabilityResult != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: availabilityResult == "available"
                              ? Colors.green.shade50
                              : availabilityResult == "unavailable"
                                  ? Colors.red.shade50
                                  : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: availabilityResult == "available"
                                ? Colors.green.shade200
                                : availabilityResult == "unavailable"
                                    ? Colors.red.shade200
                                    : Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              availabilityResult == "available"
                                  ? Icons.check_circle
                                  : availabilityResult == "unavailable"
                                      ? Icons.cancel
                                      : Icons.warning,
                              color: availabilityResult == "available"
                                  ? Colors.green
                                  : availabilityResult == "unavailable"
                                      ? Colors.red
                                      : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                availabilityMessage ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: availabilityResult == "available"
                                      ? Colors.green.shade900
                                      : availabilityResult == "unavailable"
                                          ? Colors.red.shade900
                                          : Colors.orange.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xff006565)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              openMessageModal(partner);
                            },
                            child: const Text("Message", style: TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff006565),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(0, 44),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              openInviteModal(partner);
                            },
                            child: const Text("Invite", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPartners = partners.where((partner) {
      return partner.name.toLowerCase().contains(searchText.toLowerCase()) ||
          partner.role.toLowerCase().contains(searchText.toLowerCase()) ||
          partner.vehicle.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    Widget content = RefreshIndicator(
      onRefresh: refreshPartners,
      color: const Color(0xff006565),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(),
            const SizedBox(height: 20),
            buildStatsHeader(filteredPartners.length),
            const SizedBox(height: 20),
            if (isLoading)
              const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xff006565)),
                ),
              )
            else if (isMapView)
              DeliveryMapView(
                partners: filteredPartners,
                onInvite: openInviteModal,
                onMessage: openMessageModal,
              )
            else if (filteredPartners.isEmpty)
              buildEmptyState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredPartners.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 1200
                      ? 3
                      : MediaQuery.of(context).size.width > 700
                          ? 2
                          : 1,
                  childAspectRatio: MediaQuery.of(context).size.width > 1200
                      ? 1.5
                      : MediaQuery.of(context).size.width > 700
                          ? 1.42
                          : 1.34,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return PartnerCard(
                    partner: filteredPartners[index],
                    onInvite: () => openInviteModal(filteredPartners[index]),
                    onMessage: () => openMessageModal(filteredPartners[index]),
                    onViewProfile: () => openProfileModal(filteredPartners[index]),
                  );
                },
              ),
          ],
        ),
      ),
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
        title: const Text(
          "Find Delivery Partners",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff006565)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: content,
    );
  }

  Widget buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search by name, role or vehicle...",
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
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff006565),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(0, 48),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Advanced search filter configuration simulated"),
                backgroundColor: Color(0xff006565),
              ),
            );
          },
          icon: const Icon(Icons.filter_list),
          label: const Text("Filter"),
        ),
      ],
    );
  }

  Widget buildStatsHeader(int count) {
    return Row(
      children: [
        Text(
          "$count Partners found near you",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              ChoiceChip(
                selected: !isMapView,
                label: const Text("List"),
                selectedColor: const Color(0xff006565),
                labelStyle: TextStyle(
                  color: !isMapView ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (_) {
                  setState(() {
                    isMapView = false;
                  });
                },
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                selected: isMapView,
                label: const Text("Map"),
                selectedColor: const Color(0xff006565),
                labelStyle: TextStyle(
                  color: isMapView ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (_) {
                  setState(() {
                    isMapView = true;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              "No Delivery Partners Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Try matching search parameters with name or role.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class PartnerCard extends StatelessWidget {
  final DeliveryPartner partner;
  final VoidCallback onInvite;
  final VoidCallback onMessage;
  final VoidCallback onViewProfile;

  const PartnerCard({
    super.key,
    required this.partner,
    required this.onInvite,
    required this.onMessage,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 1),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(partner.image),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(1.5),
                        child: const Icon(
                          Icons.verified,
                          color: Color(0xff008080), // Teal verification badge
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              partner.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onViewProfile,
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Color(0xff006565),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        partner.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff006565),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            "${partner.rating}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                          ),
                          Text(
                            " (${partner.reviews})",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (partner.available)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff006565).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "AVAILABLE NOW",
                      style: TextStyle(
                        color: Color(0xff006565),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: statBox("PRICE", partner.price),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: statBox("DISTANCE", partner.distance),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.motorcycle, size: 16, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  partner.vehicle,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: onMessage,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xff006565), size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onInvite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff006565),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text(
                      "Invite",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xff006565),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryMapView extends StatefulWidget {
  final List<DeliveryPartner> partners;
  final Function(DeliveryPartner) onInvite;
  final Function(DeliveryPartner) onMessage;

  const DeliveryMapView({
    super.key,
    required this.partners,
    required this.onInvite,
    required this.onMessage,
  });

  @override
  State<DeliveryMapView> createState() => _DeliveryMapViewState();
}

class _DeliveryMapViewState extends State<DeliveryMapView> {
  DeliveryPartner? selectedPartner;
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    if (widget.partners.isNotEmpty) {
      selectedPartner = widget.partners.first;
    }
    _zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      enablePinching: true,
      zoomLevel: 13,
      focalLatLng: const MapLatLng(12.9716, 77.5946),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            SfMaps(
              layers: [
                MapTileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  zoomPanBehavior: _zoomPanBehavior,
                  initialMarkersCount: widget.partners.length,
                  markerBuilder: (BuildContext context, int index) {
                    final partner = widget.partners[index];
                    final isSelected = selectedPartner == partner;
                    return MapMarker(
                      latitude: partner.latitude,
                      longitude: partner.longitude,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPartner = partner;
                            _zoomPanBehavior.focalLatLng = MapLatLng(partner.latitude, partner.longitude);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isSelected ? 52 : 44,
                          height: isSelected ? 52 : 44,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xff006565) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : const Color(0xff006565),
                              width: 2.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                partner.image,
                                width: isSelected ? 46 : 38,
                                height: isSelected ? 46 : 38,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  color: isSelected ? Colors.white : const Color(0xff006565),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Positioned(
              right: 16,
              top: 16,
              child: FloatingActionButton.small(
                heroTag: "loc_reset",
                onPressed: () {
                  setState(() {
                    _zoomPanBehavior.focalLatLng = const MapLatLng(12.9716, 77.5946);
                    _zoomPanBehavior.zoomLevel = 13;
                  });
                },
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff006565),
                child: const Icon(Icons.my_location),
              ),
            ),
            if (selectedPartner != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Card(
                  elevation: 6,
                  color: Colors.white,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(selectedPartner!.image),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedPartner!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    selectedPartner!.role,
                                    style: const TextStyle(
                                      color: Color(0xff006565),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 12),
                                      const SizedBox(width: 2),
                                      Text(
                                        "${selectedPartner!.rating}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          " (${selectedPartner!.reviews}) • ${selectedPartner!.distance}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  selectedPartner = null;
                                });
                              },
                            )
                          ],
                        ),
                        const Divider(height: 12, thickness: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Vehicle: ${selectedPartner!.vehicle} • Rate: ${selectedPartner!.price}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () => widget.onMessage(selectedPartner!),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(36, 36),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xff006565), size: 16),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => widget.onInvite(selectedPartner!),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff006565),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(80, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  child: const Text(
                                    "Invite",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
