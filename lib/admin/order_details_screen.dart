import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../core/theme/app_theme.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? order;
  const OrderDetailsScreen({
    super.key,
    this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late String orderStatus;
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    orderStatus = widget.order?.status ?? "Shipped";
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                "https://picsum.photos/200",
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCustomerCard(),
            const SizedBox(height: 16),
            buildStatusCard(),
            const SizedBox(height: 16),
            buildOrderSummary(),
            const SizedBox(height: 16),
            buildTrackingCard(),
            const SizedBox(height: 16),
            buildShipmentTimeline(),
            const SizedBox(height: 16),
            buildNotesSection(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    );
  }

  Widget buildCustomerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outline.withOpacity(0.5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Customer Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Icon(
                Icons.person_pin,
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildInfoRow(
            "Name",
            widget.order?.customerName ?? "Alex Rivera",
          ),
          buildInfoRow(
            "Contact",
            widget.order?.contact ?? "+1 555 982 1029",
          ),
          buildInfoRow(
            "Email",
            widget.order?.email ?? "arivera@example.com",
          ),
          const Divider(),
          buildInfoRow(
            "Community",
            widget.order?.community ?? "Design Hub",
          ),
          buildInfoRow(
            "Chapter",
            widget.order?.chapter ?? "NYC Chapter",
          ),
          buildInfoRow(
            "Delivery",
            widget.order?.deliveryAddress ?? "Brooklyn, NY",
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
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

  Widget buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outline.withOpacity(0.5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: DropdownButtonFormField<String>(
        value: orderStatus,
        decoration: const InputDecoration(
          labelText: "Update Order Status",
        ),
        items: const [
          DropdownMenuItem(
            value: "Pending",
            child: Text("Pending"),
          ),
          DropdownMenuItem(
            value: "Processing",
            child: Text("Processing"),
          ),
          DropdownMenuItem(
            value: "Packed",
            child: Text("Packed"),
          ),
          DropdownMenuItem(
            value: "Shipped",
            child: Text("Shipped"),
          ),
          DropdownMenuItem(
            value: "Delivered",
            child: Text("Delivered"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            orderStatus = value!;
          });
        },
      ),
    );
  }

  Widget buildOrderSummary() {
    final double amount = widget.order?.amount ?? 1450.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outline.withOpacity(0.5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  "Order Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Icon(
                Icons.receipt_long,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(
                Icons.inventory,
              ),
            ),
            title: Text(
              widget.order?.items ?? "Graphic Design Kit Pro",
            ),
            subtitle: const Text(
              "Qty: 01 • SKU: GDK-2024",
            ),
            trailing: Text(
              "₹${amount.toStringAsFixed(0)}",
            ),
          ),
          const Divider(),
          buildPriceRow(
            "Packaging",
            "₹120",
          ),
          buildPriceRow(
            "Logistics",
            "₹240",
          ),
          buildPriceRow(
            "Coupon",
            "-₹100",
          ),
          const Divider(),
          buildPriceRow(
            "Total Amount",
            "₹${(amount + 120 + 240 - 100).toStringAsFixed(0)}",
            true,
          ),
        ],
      ),
    );
  }

  Widget buildPriceRow(
    String title,
    String value, [
    bool total = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: total ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: total ? AppTheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTrackingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Tracking Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildTrackingInfo(
            "Courier",
            "BlueDart Express",
          ),
          buildTrackingInfo(
            "Tracking ID",
            "TRK-992821",
          ),
          buildTrackingInfo(
            "Est. Delivery",
            "16 Aug 2026",
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.open_in_new,
              color: Colors.white,
            ),
            label: const Text(
              "Track Shipment",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTrackingInfo(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildShipmentTimeline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outline.withOpacity(0.5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shipment History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          buildShipmentStep(
            "Order Placed",
            "14 Aug 2026, 10:24 AM",
            true,
          ),
          buildShipmentStep(
            "Confirmed",
            "14 Aug 2026, 11:15 AM",
            true,
          ),
          buildShipmentStep(
            "Packed",
            "14 Aug 2026, 04:30 PM",
            true,
          ),
          buildShipmentStep(
            "In Transit",
            "Mumbai Distribution Center",
            true,
          ),
          buildShipmentStep(
            "Out For Delivery",
            "Pending",
            false,
          ),
        ],
      ),
    );
  }

  Widget buildShipmentStep(
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
                color: active ? AppTheme.primary : Colors.grey,
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
            padding: const EdgeInsets.only(bottom: 20),
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
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Notes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Enter special delivery instructions...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Notes Saved",
                        ),
                      ),
                    );
                  },
                  child: const Text("Save Note"),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  notesController.clear();
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
