import 'package:flutter/material.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String currentTab = 'active';
  int selectedStars = 0;

  final Order activeOrder = Order(
    id: 'ORD-8821',
    title: 'Enterprise SaaS Suite',
    date: 'Oct 28, 2023',
    itemCount: 4,
    shippingAddress: 'Global Tech HQ\n1200 Innovation Way, Suite 400\nSan Francisco, CA 94105\nUnited States',
    paymentMethod: 'Corporate Visa •••• 8821',
    subtotal: 2100.00,
    shipping: 0.00,
    taxes: 178.50,
    total: 2278.50,
    items: [
      OrderItem(
        name: 'Core Infrastructure Module',
        sku: 'INF-992-A',
        status: 'In Transit',
        statusType: OrderStatus.inTransit,
        estimatedDelivery: 'Nov 02',
        quantity: 1,
        price: 1200.00,
        icon: Icons.cloud_done,
      ),
      OrderItem(
        name: 'Advanced Security Shield',
        sku: 'SEC-441-B',
        status: 'Processing',
        statusType: OrderStatus.processing,
        estimatedDelivery: 'Nov 05',
        quantity: 2,
        price: 450.00,
        icon: Icons.security,
      ),
    ],
    trackingSteps: [
      TrackingStep(
        title: 'Order Confirmed',
        date: 'Oct 28, 09:15 AM',
        isCompleted: true,
        icon: Icons.check,
      ),
      TrackingStep(
        title: 'Shipped from Hub',
        date: 'Oct 29, 02:30 PM',
        isCompleted: true,
        icon: Icons.check,
      ),
      TrackingStep(
        title: 'Out for Delivery',
        date: 'Oct 31, 08:45 AM',
        isCompleted: false,
        icon: Icons.local_shipping,
        isActive: true,
        extraInfo: 'Courier is 2 miles away',
      ),
      TrackingStep(
        title: 'Delivered',
        date: 'Expected Today',
        isCompleted: false,
        icon: Icons.home,
      ),
    ],
  );

  final List<CompletedOrder> completedOrders = [
    CompletedOrder(
      title: 'Strategic Growth Package',
      deliveredDate: 'Oct 24, 2023',
      icon: Icons.verified,
    ),
    CompletedOrder(
      title: 'Marketing Automation Kit',
      deliveredDate: 'Oct 12, 2023',
      icon: Icons.auto_awesome,
    ),
  ];

  void _showReviewSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Submit Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              Text('OVERALL RATING', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.outline)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  final isFilled = index < selectedStars;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => selectedStars = index + 1);
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.star, color: isFilled ? colorScheme.primary : colorScheme.outlineVariant, size: 32),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text('YOUR FEEDBACK', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.outline)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us about your experience...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow ?? Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your feedback!'), behavior: SnackBarBehavior.floating),
                  );
                },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Submit Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReturnSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Return / Exchange', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Text('REASON FOR RETURN', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.outline)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainerLow ?? Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'defective', child: Text('Product is defective')),
                DropdownMenuItem(value: 'wrong_item', child: Text('Wrong item received')),
                DropdownMenuItem(value: 'no_longer_needed', child: Text('No longer needed')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Returns are subject to a standard 3-5 business day evaluation period once received.',
                      style: TextStyle(fontSize: 12, color: colorScheme.onErrorContainer, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Return request submitted!'), behavior: SnackBarBehavior.floating),
                );
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Submit Request', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow ?? const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Order Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Manrope')),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.support_agent_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildTabNavigation(colorScheme),
            const SizedBox(height: 20),
            currentTab == 'active'
                ? _buildActiveOrdersSection(colorScheme)
                : _buildCompletedOrdersSection(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation(ColorScheme colorScheme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh ?? Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Active Tracking', currentTab == 'active', () => setState(() => currentTab = 'active'), colorScheme),
          ),
          Expanded(
            child: _buildTabButton('Complete Order', currentTab == 'completed', () => setState(() => currentTab = 'completed'), colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildActiveOrdersSection(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(activeOrder, colorScheme),
            const SizedBox(height: 20),
            _buildItemsList(activeOrder.items, colorScheme),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            _buildDossierAndSummaryLayout(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierAndSummaryLayout(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildAddressAndBillingSection(activeOrder, colorScheme)),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: _buildTrackingDossier(activeOrder.trackingSteps, colorScheme)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildAddressAndBillingSection(activeOrder, colorScheme),
              const SizedBox(height: 24),
              _buildTrackingDossier(activeOrder.trackingSteps, colorScheme),
            ],
          );
        }
      },
    );
  }

  Widget _buildOrderHeader(Order order, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('SAAS METRICS', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 0.5)),
                  ),
                  const SizedBox(width: 8),
                  Text('#${order.id}', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: colorScheme.outline)),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${order.date} • ${order.itemCount} Active Nodes', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
          icon: const Icon(Icons.analytics_outlined, size: 16),
          label: const Text('Track Live', style: TextStyle(fontSize: 13)),
        )
      ],
    );
  }

  Widget _buildItemsList(List<OrderItem> items, ColorScheme colorScheme) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow ?? Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.statusType == OrderStatus.inTransit ? Colors.teal.withOpacity(0.1) : colorScheme.outlineVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.statusType == OrderStatus.inTransit ? Colors.teal : colorScheme.onSurfaceVariant)),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('SKU: ${item.sku}', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: colorScheme.outline)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Est: ${item.estimatedDelivery}', style: TextStyle(fontSize: 13, color: colorScheme.primary, fontWeight: FontWeight.w500)),
                        Text('${item.quantity} × \$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressAndBillingSection(Order order, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SHIPPING TARGET', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.outline)),
        const SizedBox(height: 8),
        Text(order.shippingAddress, style: TextStyle(fontSize: 14, color: colorScheme.onSurface, height: 1.5)),
        const SizedBox(height: 20),
        Text('PAYMENT SCHEME', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.outline)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.credit_card, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(order.paymentMethod, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 24),
        Text('SUMMARY LEDGER', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.outline)),
        const SizedBox(height: 10),
        _buildPriceLedgerRow('Subtotal Units', '\$${order.subtotal.toStringAsFixed(2)}', colorScheme),
        _buildPriceLedgerRow('Fulfillment Logistics', 'Free Logistics', colorScheme, isPromo: true),
        _buildPriceLedgerRow('Estimated Taxes', '\$${order.taxes.toStringAsFixed(2)}', colorScheme),
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
        _buildPriceLedgerRow('Aggregated Total', '\$${order.total.toStringAsFixed(2)}', colorScheme, isTotal: true),
      ],
    );
  }

  Widget _buildPriceLedgerRow(String label, String val, ColorScheme colorScheme, {bool isPromo = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, color: isPromo ? Colors.teal : colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildTrackingDossier(List<TrackingStep> steps, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TRACKING TIMELINE', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.outline)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isDone = step.isCompleted || step.isActive;
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
                          color: isDone ? colorScheme.primary : Colors.transparent,
                          border: Border.all(color: isDone ? colorScheme.primary : colorScheme.outlineVariant, width: 2),
                        ),
                        child: Icon(step.icon, size: 12, color: isDone ? Colors.white : colorScheme.outline),
                      ),
                      if (index != steps.length - 1)
                        Container(width: 2, height: 40, color: step.isCompleted ? colorScheme.primary : colorScheme.outlineVariant),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.title, style: TextStyle(fontSize: 13, fontWeight: step.isActive ? FontWeight.bold : FontWeight.w600, color: step.isActive ? colorScheme.primary : colorScheme.onSurface)),
                        Text(step.date, style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                        if (step.extraInfo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(step.extraInfo!, style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  )
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildCompletedOrdersSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: completedOrders.map((order) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                child: Icon(order.icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('Delivered on ${order.deliveredDate}', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _showReviewSheet(context, colorScheme),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () => _showReturnSheet(context, colorScheme),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Return', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }

}

class Order {
  final String id;
  final String title;
  final String date;
  final int itemCount;
  final String shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double shipping;
  final double taxes;
  final double total;
  final List<OrderItem> items;
  final List<TrackingStep> trackingSteps;

  Order({
    required this.id,
    required this.title,
    required this.date,
    required this.itemCount,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shipping,
    required this.taxes,
    required this.total,
    required this.items,
    required this.trackingSteps,
  });
}

class OrderItem {
  final String name;
  final String sku;
  final String status;
  final OrderStatus statusType;
  final String estimatedDelivery;
  final int quantity;
  final double price;
  final IconData icon;

  OrderItem({
    required this.name,
    required this.sku,
    required this.status,
    required this.statusType,
    required this.estimatedDelivery,
    required this.quantity,
    required this.price,
    required this.icon,
  });
}

enum OrderStatus { inTransit, processing }

class TrackingStep {
  final String title;
  final String date;
  final bool isCompleted;
  final IconData icon;
  final bool isActive;
  final String? extraInfo;

  TrackingStep({
    required this.title,
    required this.date,
    required this.isCompleted,
    required this.icon,
    this.isActive = false,
    this.extraInfo,
  });
}

class CompletedOrder {
  final String title;
  final String deliveredDate;
  final IconData icon;

  CompletedOrder({required this.title, required this.deliveredDate, required this.icon});
}