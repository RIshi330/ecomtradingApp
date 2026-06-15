import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../model/module_model.dart';

class ModuleDetailsScreen extends StatelessWidget {
  const ModuleDetailsScreen({super.key});

  IconData _getFeatureIcon(String featureName) {
    final name = featureName.toLowerCase();
    if (name.contains('vendor') || name.contains('multi-vendor')) return Icons.groups;
    if (name.contains('sync') || name.contains('inventory') || name.contains('cards')) return Icons.sync_alt;
    if (name.contains('payment') || name.contains('wallet') || name.contains('upi') || name.contains('cards')) return Icons.payments;
    if (name.contains('admin') || name.contains('dashboard') || name.contains('panel')) return Icons.dashboard_customize;
    if (name.contains('seo')) return Icons.search;
    return Icons.star;
  }

  Future<void> _handleBuyNow(BuildContext context, ModuleModel module) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7C83FD)),
        ),
      ),
    );

    try {
      final db = Database();
      final res = await db.getData(
        {
          "purchaseCurrentModule": module.id,
          "ebanking": "0.0",
          "ewallet": "0.0",
        },
        endpoint: "new_apis/buy_module_api.php",
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading indicator
      }

      if (res['success'] == true || res['status'] == 200 || res.containsKey('razorpay_order_id') || res.containsKey('order_id')) {
        final String? orderId = res['razorpay_order_id']?.toString() ?? res['order_id']?.toString();
        
        if (orderId != null) {
          // Razorpay flow initiated
          if (context.mounted) {
            _showVerifyPurchaseDialog(context, orderId);
          }
        } else {
          // Purchase completed immediately (e.g. mock wallet success)
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Module purchased successfully!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } else {
        // API failed or error response
        final String errorMsg = res['error']?.toString() ?? "Failed to initiate purchase.";
        if (context.mounted) {
          _showErrorDialog(context, errorMsg);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        _showErrorDialog(context, "Network connection error: $e");
      }
    }
  }

  void _showVerifyPurchaseDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Simulate Razorpay Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Razorpay Order Created successfully on server."),
            const SizedBox(height: 8),
            Text("Order ID: $orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Would you like to simulate signature verification success on the backend?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff7C83FD)),
            onPressed: () {
              Navigator.pop(ctx);
              _verifyPurchaseOnBackend(context, orderId);
            },
            child: const Text("Verify Success", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPurchaseOnBackend(BuildContext context, String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final db = Database();
      final res = await db.getData(
        {
          "verifyModulePurchase": "true",
          "razorpay_payment_id": "pay_mock_${DateTime.now().millisecondsSinceEpoch}",
          "razorpay_order_id": orderId,
          "razorpay_signature": "mock_signature_verification_success_ccbul",
        },
        endpoint: "new_apis/buy_module_api.php",
      );

      if (context.mounted) {
        Navigator.pop(context); // Pop loader
      }

      if (res['success'] == true || res['status'] == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment verified & module purchased successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Pop details screen
        }
      } else {
        final errorMsg = res['error']?.toString() ?? "Verification failed on server.";
        if (context.mounted) {
          _showErrorDialog(context, errorMsg);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, "Failed to verify signature: $e");
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Purchase Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract ModuleModel from navigation arguments
    final ModuleModel module = ModalRoute.of(context)!.settings.arguments as ModuleModel;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff7C83FD),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/payment', arguments: module);
            },
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            label: const Text(
              "Buy Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Module Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 260,
              width: double.infinity,
              color: const Color(0xffF1F2FF),
              child: Center(
                child: Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    module.icon,
                    size: 90,
                    color: const Color(0xff7C83FD),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      module.category.isNotEmpty ? module.category : "Module",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    module.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Developer: "),
                      Text(
                        module.developer,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(module.rating),
                      Text(" (${module.installs.split(' ')[0]})"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (module.badge.isNotEmpty)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                module.badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Text(
                          module.discountPrice,
                          style: const TextStyle(
                            fontSize: 32,
                            color: Color(0xff7C83FD),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          module.originalPrice,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Color(0xff7C83FD),
                            ),
                            SizedBox(width: 8),
                            Text("Lifetime License"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Key Features",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (module.features.isEmpty)
                    const Text("No specific features highlighted.")
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: module.features.map((featureName) {
                        return FeatureCard(
                          icon: _getFeatureIcon(featureName),
                          title: featureName,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 30),
                  const Text(
                    "About This Module",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    module.description,
                    style: const TextStyle(
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xff7C83FD),
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
