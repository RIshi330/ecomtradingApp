import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/admin/schedule_campaign_screen.dart';

class PromotionalPackageOrdersScreen extends StatefulWidget {
  final bool isEmbedded;
  const PromotionalPackageOrdersScreen({super.key, this.isEmbedded = false});

  @override
  State<PromotionalPackageOrdersScreen> createState() => _PromotionalPackageOrdersScreenState();
}

class _PromoOrder {
  final int id;
  final String packageName;
  final String buyerName;
  final double amount;
  final String orderStatus;
  final String paymentMode;
  final String orderDate;
  final String vendorName;

  _PromoOrder({
    required this.id,
    required this.packageName,
    required this.buyerName,
    required this.amount,
    required this.orderStatus,
    required this.paymentMode,
    required this.orderDate,
    required this.vendorName,
  });

  factory _PromoOrder.fromJson(Map<String, dynamic> json) {
    return _PromoOrder(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      packageName: json['package_name']?.toString() ?? 'N/A',
      buyerName: json['buyer_name']?.toString() ?? 'Unknown',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      orderStatus: json['order_status']?.toString() ?? 'pending',
      paymentMode: json['payment_mode']?.toString() ?? 'N/A',
      orderDate: json['order_date']?.toString() ?? '',
      vendorName: json['vendor']?['name']?.toString() ?? '',
    );
  }
}

class _PromotionalPackageOrdersScreenState extends State<PromotionalPackageOrdersScreen> {
  List<_PromoOrder> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedStatus = 'All';

  int _totalOrders = 0;
  int _activeOrders = 0;
  int _pendingOrders = 0;
  double _revenue = 0.0;

  final TextEditingController _searchController = TextEditingController();
  final List<String> _statuses = ['All', 'Pending', 'Active', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await Database().getData({
        'action': 'get_package_orders',
        'search': _searchQuery,
        'status': _selectedStatus == 'All' ? '' : _selectedStatus.toUpperCase(),
      }, endpoint: 'new_apis/promotion_package_api.php');

      if (!mounted) return;

      if (response['success'] == true && response['data'] != null) {
        final List ordersData = response['data']['orders'] is List ? response['data']['orders'] : [];
        final statsData = response['data']['stats'] ?? {};
        setState(() {
          _orders = ordersData.map((item) => _PromoOrder.fromJson(Map<String, dynamic>.from(item))).toList();
          _totalOrders = int.tryParse(statsData['total_orders']?.toString() ?? '0') ?? 0;
          _activeOrders = int.tryParse(statsData['active_orders']?.toString() ?? '0') ?? 0;
          _pendingOrders = int.tryParse(statsData['pending_orders']?.toString() ?? '0') ?? 0;
          _revenue = double.tryParse(statsData['revenue']?.toString() ?? '0') ?? 0.0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message']?.toString() ?? 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAssetReviewSheet(_PromoOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: Database().getData({
            'action': 'get_campaign_content',
            'order_id': order.id.toString(),
          }, endpoint: 'new_apis/submit_content_api.php'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF006565)),
                ),
              );
            }

            final data = snapshot.data;
            final bool hasContent = data != null && data['success'] == true && data['data'] != null;
            final campaign = hasContent ? data['data'] : {};

            final description = campaign['description']?.toString() ?? "No description provided.";
            final comment = campaign['comment']?.toString() ?? "No comments.";
            
            // Attachments
            final List<String> attachments = [];
            for (int i = 1; i <= 5; i++) {
              final att = campaign['attachment$i']?.toString() ?? '';
              if (att.isNotEmpty) {
                attachments.add(att);
              }
            }

            final availability = campaign['availability']?.toString() ?? "N/A";
            final budget = campaign['budget']?.toString() ?? "0";

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.draw, color: Color(0xFF006565)),
                              SizedBox(width: 8),
                              Text(
                                "Campaign Asset Review",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        order.packageName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(color: Color(0xFF3E4949), height: 1.4),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        "CAMPAIGN ASSETS (${attachments.length})",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      attachments.isEmpty
                          ? const Text("No assets attached", style: TextStyle(color: Colors.grey, fontSize: 13))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              itemCount: attachments.length,
                              itemBuilder: (context, index) {
                                final url = attachments[index];
                                final isVideo = url.toLowerCase().endsWith(".mp4") || url.toLowerCase().endsWith(".mov");
                                if (isVideo) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEEEED),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFBDC9C8)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.play_circle, color: Color(0xFF006565), size: 32),
                                        const SizedBox(height: 4),
                                        Text(
                                          url.split('/').last,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return _buildAssetThumbnail(url);
                              },
                            ),
                      const SizedBox(height: 24),

                      // CTA / Campaign Details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3F3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "CAMPAIGN DETAILS",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Budget",
                              style: TextStyle(fontSize: 12, color: Color(0xFF3E4949)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹$budget",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Preferred Availability",
                              style: TextStyle(fontSize: 12, color: Color(0xFF3E4949)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              availability,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (comment.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                "Additional Comments",
                                style: TextStyle(fontSize: 12, color: Color(0xFF3E4949)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFFBDC9C8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Disapprove", style: TextStyle(color: Color(0xFF3E4949), fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close sheet
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScheduleCampaignScreen(
                                      isEmbedded: false,
                                      initialOrderId: order.id,
                                      initialPackageName: order.packageName,
                                      initialBuyerName: order.buyerName,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006565),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Approve & Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAssetThumbnail(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: const Color(0xFFF9F9F9),
              elevation: 0,
              title: const Text(
                "Package Orders",
                style: TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold),
              ),
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: const Color(0xFF006565),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Row
              Row(
                children: [
                  _buildStatBox("Total Orders", _totalOrders.toString()),
                  _buildStatBox("Revenue", "₹${_revenue.toStringAsFixed(0)}"),
                  _buildStatBox("Active", _activeOrders.toString()),
                  _buildStatBox("Pending", _pendingOrders.toString()),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar & Filter pills
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                        _fetchOrders();
                      },
                      decoration: InputDecoration(
                        hintText: "Search orders or buyers...",
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF3E4949)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF006565), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBDC9C8)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Color(0xFF3E4949)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter pills horizontal list
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statuses.length,
                  itemBuilder: (context, index) {
                    final status = _statuses[index];
                    final isSelected = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF3E4949),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                            _fetchOrders();
                          }
                        },
                        selectedColor: const Color(0xFF006565),
                        backgroundColor: const Color(0xFFEEEEED),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: Color(0xFF006565)),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                  ),
                )
              else if (_orders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No orders found.", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderCard(order);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBDC9C8)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 8, color: Color(0xFF3E4949), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(_PromoOrder order) {
    Color indicatorColor = const Color(0xFFBDC9C8);
    Color badgeColor = const Color(0xFFEEEEED);
    Color textColor = const Color(0xFF3E4949);

    if (order.orderStatus.toLowerCase() == 'pending') {
      indicatorColor = const Color(0xFFB45309);
      badgeColor = const Color(0xFFFFF7ED);
      textColor = const Color(0xFFB45309);
    } else if (order.orderStatus.toLowerCase() == 'active') {
      indicatorColor = const Color(0xFF008080);
      badgeColor = const Color(0xFFE3FFFE);
      textColor = const Color(0xFF008080);
    } else if (order.orderStatus.toLowerCase() == 'completed') {
      indicatorColor = const Color(0xFF006565);
      badgeColor = const Color(0xFFE0F2FE);
      textColor = const Color(0xFF006565);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAssetReviewSheet(order),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: indicatorColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "PACKAGE NAME",
                                  style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.packageName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "ORD-${order.id}-X",
                            style: const TextStyle(fontSize: 10, color: Color(0xFF006565), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "BUYER",
                                  style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4E6E5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "GF",
                                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        order.buyerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1A1C1C)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "DATE & TIME",
                                  style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        order.orderDate.split(' ').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949)),
                                      ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: indicatorColor.withOpacity(0.2)),
                            ),
                            child: Text(
                              order.orderStatus.toUpperCase(),
                              style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB0EEED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.rate_review,
                              size: 16,
                              color: Color(0xFF006565),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
