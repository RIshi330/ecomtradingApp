import 'package:flutter/material.dart';


import '../Database/Database.dart';
import '../app_constants.dart';
import '../core/theme/app_theme.dart';
import '../normaluser/cart.dart';
import '../services/auth_User_and_Business_Session.dart';

// CHANGED: relative endpoint path only -- Database.getJsonData() builds the
// request itself as `$baseUrl?endpoint=$endpoint` (same pattern as
// Database.feedEndpoint / CartPage.cartApiEndpoint), so this must not be a
// full URL.
const String _cartApiEndpoint = "new_apis/cart_api.php";

class LuxeHeader extends StatefulWidget implements PreferredSizeWidget {
  final Widget? trailingWidget;
  const LuxeHeader({super.key, this.trailingWidget});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<LuxeHeader> createState() => _LuxeHeaderState();
}

class _LuxeHeaderState extends State<LuxeHeader> {
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    // _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    try {
      final db = Database();
      // CHANGED: db.postJsonData(...) did not exist on Database and
      // endpointUrl was not a valid parameter -- use getJsonData with the
      // relative endpoint path instead (matches the fix applied to
      // CartPage).
      final response = await db.getJsonData({
        'action': 'updateHeader',
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: _cartApiEndpoint);

      if (response['success'] == true && response['data'] != null) {
        final countVal = int.tryParse(response['data']['count']?.toString() ?? '0') ?? 0;
        if (mounted) {
          setState(() {
            _cartCount = countVal;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching cart count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0, // Reduce gap

      backgroundColor: Colors.white.withOpacity(0.9),
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Text(
          'LUXE',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 18,
          ),
        ),
      ),
      actions: [
        if (widget.trailingWidget != null) widget.trailingWidget!,
        if (widget.trailingWidget != null) const SizedBox(width: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: AppTheme.primary,
              ),
              onPressed: () async {

                if (context.mounted) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (_) => const CartPage()),
                  // ).then((_) => _fetchCartCount());
                }
              },
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_cartCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// class LuxeFooter extends StatelessWidget {
//   const LuxeFooter({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: const Color(0xFFF6F3F2), // surface-container-low
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       width: double.infinity,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: const Color(0xFFD4E6E5),
//                 ),
//                 child: const Icon(Icons.eco_outlined,
//                     color: Color(0xFF006565), size: 18),
//               ),
//               const SizedBox(width: 12),
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('SERENE PARTNER',
//                       style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF516161),
//                           letterSpacing: 1.2)),
//                   Text('Sustainable Goods',
//                       style: TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             '© 2024 Serene Commerce Inc. All Rights Reserved.',
//             style: TextStyle(fontSize: 10, color: Color(0xFF6E7979)),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 80), // Pad bottom for navigation bar
//         ],
//       ),
//     );
//   }
// }