import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../core/theme/app_theme.dart';
import 'order_details_screen.dart';

class SellerOrderScreen extends StatefulWidget {
  final bool isEmbedded;
  const SellerOrderScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen> {

  String currentStatus = "Pending";
  final notesController = TextEditingController();
  final searchController = TextEditingController();
  String searchQuery = "";
  String selectedFilter = "All";

  List<OrderModel> mockOrders = [
    OrderModel(
      id: "#ORD-99210",
      customerName: "Alex Rivera",
      date: "14 Aug 2026",
      amount: 1450.0,
      items: "Graphic Design Kit Pro",
      status: "Shipped",
      contact: "+1 555 982 1029",
      email: "arivera@example.com",
      community: "Design Hub",
      chapter: "NYC Chapter",
      deliveryAddress: "Brooklyn, NY",
    ),
    OrderModel(
      id: "#ORD-99208",
      customerName: "John Doe",
      date: "13 Aug 2026",
      amount: 452.10,
      items: "Developer Keyboard Mechanical",
      status: "Processing",
      contact: "+1 555 123 4567",
      email: "johndoe@example.com",
      community: "Tech & Product",
      chapter: "SF Chapter",
      deliveryAddress: "San Francisco, CA",
    ),
    OrderModel(
      id: "#ORD-99195",
      customerName: "Sarah Connor",
      date: "12 Aug 2026",
      amount: 89.00,
      items: "Leather Journal",
      status: "Pending",
      contact: "+1 555 987 6543",
      email: "sarahc@example.com",
      community: "Creative Arts",
      chapter: "LA Chapter",
      deliveryAddress: "Los Angeles, CA",
    ),
    OrderModel(
      id: "#ORD-99180",
      customerName: "Bruce Wayne",
      date: "10 Aug 2026",
      amount: 9200.0,
      items: "B2B Bulletproof Armor Plates",
      status: "Delivered",
      contact: "+1 555 000 0007",
      email: "bruce@waynecorp.com",
      community: "Defense Hub",
      chapter: "Gotham Chapter",
      deliveryAddress: "Gotham City, NJ",
    ),
  ];

  @override
  void dispose() {
    notesController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void showTrackingModal(
    OrderModel order,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tracking Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                buildTrackingRow(
                  "Courier",
                  "BlueDart Express",
                ),
                buildTrackingRow(
                  "Tracking ID",
                  "TRK-992821",
                ),
                buildTrackingRow(
                  "Estimated Delivery",
                  "16 Aug 2026",
                ),
                buildTrackingRow(
                  "Current Status",
                  "In Transit",
                ),
                const SizedBox(height: 24),
                const Text(
                  "Shipment History",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                buildTimelineItem(
                  "Order Placed",
                  "14 Aug 2026, 10:24 AM",
                  true,
                ),
                buildTimelineItem(
                  "Confirmed",
                  "14 Aug 2026, 11:15 AM",
                  true,
                ),
                buildTimelineItem(
                  "Packed",
                  "14 Aug 2026, 04:30 PM",
                  true,
                ),
                buildTimelineItem(
                  "In Transit",
                  "Mumbai Hub",
                  true,
                ),
                buildTimelineItem(
                  "Delivered",
                  "Pending",
                  false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTrackingRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimelineItem(
    String title,
    String subtitle,
    bool active,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? AppTheme.primary
                    : Colors.grey,
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showStatusModal(
    OrderModel order,
  ) {
    currentStatus = order.status;
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (
            context,
            modalSetState,
          ) {
            return AlertDialog(
              title: const Text(
                "Update Status",
              ),
              content: DropdownButtonFormField<String>(
                value: currentStatus,
                items: const [
                  DropdownMenuItem(
                    value: "Pending",
                    child: Text(
                      "Pending",
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Processing",
                    child: Text(
                      "Processing",
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Packed",
                    child: Text(
                      "Packed",
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Shipped",
                    child: Text(
                      "Shipped",
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Delivered",
                    child: Text(
                      "Delivered",
                    ),
                  ),
                ],
                onChanged: (value) {
                  modalSetState(() {
                    currentStatus = value!;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      final index = mockOrders.indexWhere((o) => o.id == order.id);
                      if (index != -1) {
                        mockOrders[index] = OrderModel(
                          id: order.id,
                          customerName: order.customerName,
                          date: order.date,
                          amount: order.amount,
                          items: order.items,
                          status: currentStatus,
                          contact: order.contact,
                          email: order.email,
                          community: order.community,
                          chapter: order.chapter,
                          deliveryAddress: order.deliveryAddress,
                        );
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Status changed to $currentStatus",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Update",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showOrderNotesModal(
    OrderModel order,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Order Notes",
          ),
          content: TextFormField(
            controller: notesController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Enter delivery instructions...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                notesController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Notes Saved",
                    ),
                  ),
                );
              },
              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  List<OrderModel> get filteredOrders {
    List<OrderModel> list = mockOrders;
    if (selectedFilter != "All") {
      list = list.where((o) => o.status.toLowerCase() == selectedFilter.toLowerCase()).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((o) =>
          o.id.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.items.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.red;
      case "processing":
        return Colors.orange;
      case "packed":
        return Colors.amber.shade700;
      case "shipped":
        return Colors.blue;
      case "delivered":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        _buildSearchBar(),
        _buildFilterTabs(),
        Expanded(
          child: filteredOrders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return Container(
        color: AppTheme.backgroundColor,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          "Order Management",
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        onChanged: (val) {
          setState(() {
            searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: "Search orders by ID, customer, items...",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    setState(() {
                      searchQuery = "";
                      searchController.clear();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ["All", "Pending", "Processing", "Packed", "Shipped", "Delivered"];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.secondaryContainer,
                onSelected: (val) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    order.date,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Customer: ${order.customerName}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Items: ${order.items}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${order.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          switch (value) {
                            case "details":
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsScreen(order: order),
                                ),
                              );
                              break;
                            case "status":
                              showStatusModal(order);
                              break;
                            case "tracking":
                              showTrackingModal(order);
                              break;
                            case "notes":
                              showOrderNotesModal(order);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: "details",
                            child: Text("View Details"),
                          ),
                          const PopupMenuItem(
                            value: "status",
                            child: Text("Update Status"),
                          ),
                          const PopupMenuItem(
                            value: "tracking",
                            child: Text("Tracking Details"),
                          ),
                          const PopupMenuItem(
                            value: "notes",
                            child: Text("Order Notes"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No orders found",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try adjusting your filters or search term.",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
