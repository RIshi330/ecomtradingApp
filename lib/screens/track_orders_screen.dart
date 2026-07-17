import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import '../core/theme/app_theme.dart';

class TrackOrdersScreen extends StatefulWidget {
  final bool isEmbedded;
  const TrackOrdersScreen({super.key, this.isEmbedded = false});

  @override
  State<TrackOrdersScreen> createState() => _TrackOrdersScreenState();
}

class _TrackOrdersScreenState extends State<TrackOrdersScreen> {
  String selectedTab = "Active Orders";
  bool _isLoading = false;
  List<dynamic> _activeOrders = [];
  List<dynamic> _completedOrders = [];

  // Active Order details view state
  Map<String, dynamic>? _selectedOrder;
  List<dynamic> _selectedOrderItems = [];
  bool _isLoadingItems = false;

  // Track expanded state of completed orders to load and show their items
  final Map<int, List<dynamic>> _completedOrderItems = {};
  final Map<int, bool> _completedOrderLoading = {};
  final Map<int, bool> _completedOrderExpanded = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData(
        {'action': 'get_orders'},
        endpoint: 'new_apis/track_orders_api.php',
      );
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _activeOrders = data.where((order) {
            final status = int.tryParse(order['order_status']?.toString() ?? '') ?? 0;
            return status != 5 && status != 6;
          }).toList();
          _completedOrders = data.where((order) {
            final status = int.tryParse(order['order_status']?.toString() ?? '') ?? 0;
            return status == 5 || status == 6;
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to fetch orders'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOrderItems(Map<String, dynamic> order) async {
    setState(() {
      _selectedOrder = order;
      _isLoadingItems = true;
      _selectedOrderItems = [];
    });
    try {
      final response = await Database().getData(
        {
          'action': 'get_order_items',
          'order_id': order['order_id'],
        },
        endpoint: 'new_apis/track_orders_api.php',
      );
      if (response['success'] == true) {
        setState(() {
          _selectedOrderItems = response['data'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to fetch order items'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching order items: $e');
    } finally {
      setState(() {
        _isLoadingItems = false;
      });
    }
  }

  Future<void> _fetchCompletedOrderItems(int orderId) async {
    setState(() {
      _completedOrderLoading[orderId] = true;
    });
    try {
      final response = await Database().getData(
        {
          'action': 'get_order_items',
          'order_id': orderId,
        },
        endpoint: 'new_apis/track_orders_api.php',
      );
      if (response['success'] == true) {
        setState(() {
          _completedOrderItems[orderId] = response['data'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to fetch items'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching completed order items: $e');
    } finally {
      setState(() {
        _completedOrderLoading[orderId] = false;
      });
    }
  }

  Future<void> _submitReview(
    Map<String, dynamic> item,
    int orderId,
    int rating,
    String reviewText,
  ) async {
    try {
      final response = await Database().getData(
        {
          'action': 'add_review_rating',
          'order_id': orderId,
          'marketplace_id': item['marketplace_id'] ?? 0,
          'product_id': item['product_id'] ?? 0,
          'variant_id': item['variant_id'] ?? 0,
          'product_vendor_id': 0,
          'rating': rating,
          'review': reviewText,
        },
        endpoint: 'new_apis/track_orders_api.php',
      );
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to submit review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  void _showReviewDialog(Map<String, dynamic> item, int orderId) {
    int rating = 5;
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Submit Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Product ID: ${item['product_id']}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              const Text("Overall Rating", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= rating ? Icons.star : Icons.star_border,
                      color: starIndex <= rating ? Colors.amber : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () {
                      setDialogState(() => rating = starIndex);
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text("Your Feedback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Tell us about your experience...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _submitReview(item, orderId, rating, feedbackController.text);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnDialog(Map<String, dynamic> item) {
    String? selectedReason;
    final List<String> reasons = [
      "Product is defective",
      "Wrong item received",
      "Better price found elsewhere",
      "No longer needed"
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Return / Exchange Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Product ID: ${item['product_id']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text("Reason for Return", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedReason,
                hint: const Text("Select a reason"),
                items: reasons.map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  setDialogState(() => selectedReason = val);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  border: Border.all(color: AppTheme.error.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.error, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Returns are subject to a standard 3-5 business day evaluation period once received.",
                        style: TextStyle(color: AppTheme.error, fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Return request submitted successfully!"), backgroundColor: AppTheme.primary),
                      );
                    },
              child: const Text("Submit Request"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch tracking URL: $urlString")),
      );
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return "Order Placed";
      case 2:
        return "Processing";
      case 3:
        return "Shipped";
      case 4:
        return "Out for Delivery";
      case 5:
        return "Delivered";
      case 6:
        return "Completed";
      default:
        return "Pending";
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 5:
      case 6:
        return Colors.green;
      case 3:
      case 4:
        return Colors.blue;
      case 2:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Order Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchOrders,
                ),
              ],
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: Column(
                children: [
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = "Active Orders";
                                _selectedOrder = null;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: selectedTab == "Active Orders" ? AppTheme.primary : Colors.transparent, width: 2)),
                              ),
                              child: Text("Active Orders", style: TextStyle(fontWeight: selectedTab == "Active Orders" ? FontWeight.bold : FontWeight.normal, color: selectedTab == "Active Orders" ? AppTheme.primary : AppTheme.textSecondary)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = "Completed";
                                _selectedOrder = null;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: selectedTab == "Completed" ? AppTheme.primary : Colors.transparent, width: 2)),
                              ),
                              child: Text("Completed", style: TextStyle(fontWeight: selectedTab == "Completed" ? FontWeight.bold : FontWeight.normal, color: selectedTab == "Completed" ? AppTheme.primary : AppTheme.textSecondary)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body content
                  Expanded(
                    child: selectedTab == "Active Orders"
                        ? (_selectedOrder != null ? _buildOrderDetailsView() : _buildActiveOrdersListView())
                        : _buildCompletedOrdersListView(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActiveOrdersListView() {
    if (_activeOrders.isEmpty) {
      return const Center(child: Text("No active orders found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeOrders.length,
      itemBuilder: (context, index) {
        final order = _activeOrders[index];
        final orderId = order['order_id'];
        final statusInt = int.tryParse(order['order_status']?.toString() ?? '') ?? 1;
        final amountPaid = order['amount_paid'] ?? 0.0;
        final date = order['order_date'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #$orderId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(statusInt).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(statusInt).toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(statusInt)),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("Placed on $date", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text("${order['item_count']} Items • \$${amountPaid.toStringAsFixed(2)} total", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _fetchOrderItems(order),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetailsView() {
    final order = _selectedOrder!;
    final orderId = order['order_id'];
    final statusInt = int.tryParse(order['order_status']?.toString() ?? '') ?? 1;
    final date = order['order_date'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedOrder = null),
              ),
              const Text("Order Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          // Intelligence card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: const Text("ORDER INTELLIGENCE", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                    Text("ID #$orderId", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Text("Order Status: ${_getStatusText(statusInt)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text("Placed on $date • ${order['item_count']} Items", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Items in this order
          const Text("Items in this Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _isLoadingItems
              ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              : Column(
                  children: _selectedOrderItems.map((item) {
                    final trackingId = item['tracking_id'];
                    final trackingUrl = item['tracking_site_url'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppTheme.surfaceContainer,
                                child: Icon(Icons.shopping_bag_outlined, color: AppTheme.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Product ID: ${item['product_id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    if (item['variant_id'] != null && item['variant_id'].toString().isNotEmpty)
                                      Text("Variant: ${item['variant_id']}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                    const SizedBox(height: 4),
                                    Text("Est. Delivery: ${item['order_date']}", style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(4)),
                                    child: Text(_getStatusText(item['status'] ?? statusInt), style: const TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("${item['quantity']} × \$${item['price']}", style: const TextStyle(fontSize: 11)),
                                ],
                              )
                            ],
                          ),
                          if (trackingId != null && trackingId.toString().isNotEmpty) ...[
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tracking ID: $trackingId", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                if (trackingUrl != null && trackingUrl.toString().isNotEmpty)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                                    icon: const Icon(Icons.open_in_new, size: 12),
                                    label: const Text("Track Package", style: TextStyle(fontSize: 11)),
                                    onPressed: () => _launchUrl(trackingUrl.toString()),
                                  ),
                              ],
                            )
                          ]
                        ],
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 16),
          // Tracking Dossier Timeline
          const Text("Tracking Dossier", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                _buildTimelineStep("Order Confirmed", "Oct 28, 09:15 AM", statusInt >= 1, statusInt >= 2),
                _buildTimelineStep("Processing", "Under preparation", statusInt >= 2, statusInt >= 3),
                _buildTimelineStep("Shipped from Hub", "Handed over to carrier", statusInt >= 3, statusInt >= 4),
                _buildTimelineStep("Out for Delivery", "Expected soon", statusInt >= 4, statusInt >= 5),
                _buildTimelineStep("Delivered", "Finished", statusInt >= 5, false, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Billing details
          const Text("Billing & Payment Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("PAYMENT METHOD", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.credit_card, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(order['payment_status'] ?? 'Paid', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const Divider(height: 24),
                const Text("PRICE BREAKDOWN", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildPriceRow("Subtotal", "\$${(order['amount_paid'] ?? 0.0).toStringAsFixed(2)}"),
                const SizedBox(height: 4),
                _buildPriceRow("Shipping", "Free", isFree: true),
                const Divider(height: 16),
                _buildPriceRow("Total Paid", "\$${(order['amount_paid'] ?? 0.0).toStringAsFixed(2)}", isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompletedOrdersListView() {
    if (_completedOrders.isEmpty) {
      return const Center(child: Text("No completed orders found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedOrders.length,
      itemBuilder: (context, index) {
        final order = _completedOrders[index];
        final orderId = order['order_id'];
        final amountPaid = order['amount_paid'] ?? 0.0;
        final date = order['order_date'] ?? '';
        final isExpanded = _completedOrderExpanded[orderId] ?? false;
        final isLoading = _completedOrderLoading[orderId] ?? false;
        final items = _completedOrderItems[orderId] ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: const Icon(Icons.verified_outlined, color: Colors.green, size: 24),
                ),
                title: Text("Order #$orderId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Delivered on $date", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("${order['item_count']} Items • \$${amountPaid.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onTap: () {
                  setState(() {
                    _completedOrderExpanded[orderId] = !isExpanded;
                  });
                  if (!isExpanded && items.isEmpty) {
                    _fetchCompletedOrderItems(orderId);
                  }
                },
              ),
              if (isExpanded) ...[
                const Divider(height: 1),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No items details found."),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      final item = items[itemIndex];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Product ID: ${item['product_id']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  Text("Qty: ${item['quantity']} • Price: \$${item['price']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => _showReviewDialog(item, orderId),
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                  child: const Text("Write Review", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: () => _showReturnDialog(item),
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                  child: const Text("Return", style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isCompleted, bool showLine, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppTheme.primary : Colors.grey.shade200,
                border: Border.all(color: isCompleted ? AppTheme.primary : Colors.grey.shade300, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : const SizedBox(),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: showLine ? AppTheme.primary : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isCompleted ? Colors.black87 : Colors.grey)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: isCompleted ? AppTheme.primary : Colors.grey, fontSize: 11)),
              const SizedBox(height: 12),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isFree = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isFree ? AppTheme.primary : (isBold ? Colors.black87 : Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
