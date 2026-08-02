// import 'package:flutter/material.dart';
//
// import '../Database/Database.dart';
// import '../app_constants.dart';
//
// // CHANGED: this must be the relative endpoint path, not a full URL.
// // Database.getJsonData() builds the request as `$baseUrl?endpoint=$endpoint`
// // itself (same pattern as Database.feedEndpoint), so passing a full URL
// // here would have produced a malformed/duplicated URL.
// const String cartApiEndpoint = "new_apis/de_cart_api.php";
//
// // Image URL Formatting Helper
// String _getImageUrl(String? path) {
//   const String defaultPlaceholder =
//       'https://lh3.googleusercontent.com/aida-public/AB6AXuAE3HnwySz1vJK27tDHHqPdVE6PfB420yoIJoioOKnjaAjfeUVOOImbGG19N3mDTnUWlTZaprZuFGBl4qjo9IJlVraJysdOLUyNGWCvrWH_lhgatW-R8Axnit0Sm4U9Ou9lMsoJEA7tPr8skRZ8IUt4Z2ldVtIGYrGpwJQgZXWrlhvwliOE6fdW5LAQ1DiQ9xqCxPev1F2ka_XrUIERIVYYhlm6yD0pl1X5jh2k3nwNNwyXLig6A1Vih_6QDUpIb9RE5--lM0CTBEs';
//   if (path == null || path.isEmpty) {
//     return defaultPlaceholder;
//   }
//   if (!path.startsWith('http')) {
//     String base = baseUrl;
//     if (base.contains('/Android/')) {
//       base = base.replaceAll('/Android/', '/');
//     }
//     if (base.endsWith('/') && path.startsWith('/')) {
//       return base + path.substring(1);
//     } else if (!base.endsWith('/') && !path.startsWith('/')) {
//       return '$base/$path';
//     } else {
//       return base + path;
//     }
//   }
//   return path;
// }
//
// class SereneCommerceApp extends StatelessWidget {
//   const SereneCommerceApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const CartPage();
//   }
// }
//
// class CartPage extends StatefulWidget {
//   const CartPage({super.key});
//
//   @override
//   State<CartPage> createState() => _CartPageState();
// }
//
// class _CartPageState extends State<CartPage> {
//   bool isPersonalMode = true;
//
//   List<dynamic> _cartItems = [];
//   bool _isLoading = true;
//   bool _isMutating = false; // blocks double taps during qty/remove/coupon calls
//   final TextEditingController _couponController = TextEditingController();
//   String? _couponCode;
//   double _couponDiscount = 0.0;
//
//   Color get primaryColor => const Color(0xFF006565);
//   Color get onPrimaryColor => Colors.white;
//   Color get surface => const Color(0xFFFCF9F8);
//   Color get surfaceContainer => const Color(0xFFF0EDED);
//   Color get surfaceContainerLowest => const Color(0xFFFFFFFF);
//   Color get surfaceContainerHigh => const Color(0xFFEAE7E7);
//   Color get secondaryContainer => const Color(0xFFD4E6E5);
//   Color get onSecondaryContainer => const Color(0xFF576867);
//   Color get onSurface => const Color(0xFF1C1B1B);
//   Color get onSurfaceVariant => const Color(0xFF3E4949);
//   Color get outlineVariant => const Color(0xFFBDC9C8);
//   Color get errorColor => const Color(0xFFBA1A1A);
//   Color get onError => Colors.white;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchCart();
//   }
//
//   @override
//   void dispose() {
//     _couponController.dispose();
//     super.dispose();
//   }
//
//   void _showSnack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? errorColor : primaryColor,
//       ),
//     );
//   }
//
//   /// Handles session-expiry / unauthorized responses consistently
//   /// across every endpoint in de_cart_api.php (HTTP 401, "Unauthorized").
//   /// CHANGED: Database.getJsonData() already intercepts 401 / "Unauthorized"
//   /// responses itself -- it clears the session and redirects to the login
//   /// route, returning {'success': false, 'message': 'Session expired.
//   /// Please log in again.', 'status': 401, 'data': []}. The original code
//   /// only matched the literal string "Unauthorized", which getJsonData
//   /// never actually returns, so this branch could never fire. Widened the
//   /// check to also catch that message / status code.
//   bool _handleUnauthorized(Map response) {
//     final msg = (response['message'] ?? '').toString();
//     final status = response['status'];
//     if (msg == 'Unauthorized' ||
//         msg == 'Session expired. Please log in again.' ||
//         status == 401) {
//       _showSnack('Please login to continue.', isError: true);
//       return true;
//     }
//     return false;
//   }
//
//   Future<void> _fetchCart() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
//     try {
//       final db = Database();
//       // CHANGED: db.postJsonData(...) did not exist on Database and
//       // endpointUrl was not a valid parameter -- use getJsonData with the
//       // relative endpoint path instead.
//       final response = await db.getJsonData({
//         'action': 'get_cart',
//       }, endpoint: cartApiEndpoint);
//
//       if (_handleUnauthorized(response)) {
//         setState(() => _cartItems = []);
//         return;
//       }
//
//       if (response['status'] == 'success' && response['cart_items'] is List) {
//         setState(() => _cartItems = response['cart_items']);
//       } else {
//         setState(() => _cartItems = []);
//         final msg = response['message']?.toString();
//         if (msg != null && msg.isNotEmpty) _showSnack(msg, isError: true);
//       }
//     } catch (e) {
//       debugPrint("Error fetching cart: $e");
//       _showSnack("Couldn't load your cart. Pull down to retry.", isError: true);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _updateQuantity(dynamic item, String updateType) async {
//     if (_isMutating) return;
//     setState(() => _isMutating = true);
//     try {
//       final db = Database();
//       final response = await db.getJsonData({
//         'action': 'updateQuantity',
//         'updateQuantity': updateType,
//         'item': item['product_id'],
//         'type': item['marketplace_id'],
//         'curr': item['quantity'],
//         'variant': item['variant_id'] ?? '',
//         'org_site_id': item['org_site_id'] ?? '',
//         'selected_items_vendor_id': item['selected_items_vendor_id'] ?? '',
//         'item_type': item['item_type'] ?? '',
//       }, endpoint: cartApiEndpoint);
//
//       if (_handleUnauthorized(response)) return;
//
//       if (response['success'] == true) {
//         await _fetchCart();
//       } else {
//         _showSnack(response['message'] ?? "Failed to update quantity", isError: true);
//       }
//     } catch (e) {
//       debugPrint("Error updating quantity: $e");
//       _showSnack("Couldn't update quantity. Please try again.", isError: true);
//     } finally {
//       if (mounted) setState(() => _isMutating = false);
//     }
//   }
//
//   Future<void> _removeCartItem(dynamic item) async {
//     if (_isMutating) return;
//     setState(() => _isMutating = true);
//     try {
//       final db = Database();
//       final response = await db.getJsonData({
//         'action': 'removeCartItem',
//         'item_id': item['product_id'],
//         'variant_id': item['variant_id'] ?? '',
//         'org_site_id': item['org_site_id'] ?? '',
//         'selected_items_vendor_id': item['selected_items_vendor_id'] ?? '',
//         'item_type': item['item_type'] ?? '',
//         'marketplace_id': item['marketplace_id'],
//       }, endpoint: cartApiEndpoint);
//
//       if (_handleUnauthorized(response)) return;
//
//       if (response['success'] == true) {
//         _showSnack("Item removed from cart successfully.");
//         await _fetchCart();
//       } else {
//         _showSnack(response['message'] ?? "Failed to remove item from cart", isError: true);
//       }
//     } catch (e) {
//       debugPrint("Error removing item: $e");
//       _showSnack("Couldn't remove the item. Please try again.", isError: true);
//     } finally {
//       if (mounted) setState(() => _isMutating = false);
//     }
//   }
//
//   Future<void> _applyCoupon() async {
//     final code = _couponController.text.trim();
//     if (code.isEmpty) {
//       _showSnack("Enter a coupon code first.", isError: true);
//       return;
//     }
//     if (_isMutating) return;
//     setState(() => _isMutating = true);
//
//     final activeItems = _cartItems.where((item) {
//       final mId = int.tryParse(item['marketplace_id']?.toString() ?? '5') ?? 5;
//       final isB2B = const [6, 51, 53].contains(mId);
//       return isPersonalMode ? !isB2B : isB2B;
//     }).toList();
//
//     final double totalMRP = activeItems.fold(0.0, (sum, item) {
//       final priceVal = double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
//       final qtyVal = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
//       return sum + (priceVal * qtyVal);
//     });
//
//     try {
//       final db = Database();
//       final response = await db.getJsonData({
//         'action': 'applyCouponCode',
//         'code': code,
//         'total_price': totalMRP,
//       }, endpoint: cartApiEndpoint);
//
//       if (_handleUnauthorized(response)) return;
//
//       if (response['success'] == true) {
//         final discountVal =
//             double.tryParse(response['data']?['discount']?.toString() ?? '0.0') ?? 0.0;
//         setState(() {
//           _couponCode = code;
//           _couponDiscount = discountVal;
//         });
//         _showSnack(response['message'] ?? "Coupon applied successfully!");
//       } else {
//         setState(() {
//           _couponCode = null;
//           _couponDiscount = 0.0;
//         });
//         _showSnack(response['message'] ?? "Invalid coupon code", isError: true);
//       }
//     } catch (e) {
//       debugPrint("Error applying coupon: $e");
//       _showSnack("Couldn't apply the coupon. Please try again.", isError: true);
//     } finally {
//       if (mounted) setState(() => _isMutating = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final activeItems = _cartItems.where((item) {
//       final mId = int.tryParse(item['marketplace_id']?.toString() ?? '5') ?? 5;
//       final isB2B = const [6, 51, 53].contains(mId);
//       return isPersonalMode ? !isB2B : isB2B;
//     }).toList();
//
//     double totalMRP = activeItems.fold(0.0, (sum, item) {
//       final priceVal = double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
//       final qtyVal = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
//       return sum + (priceVal * qtyVal);
//     });
//
//     double totalDiscount = activeItems.fold(0.0, (sum, item) {
//       final discountVal = double.tryParse(item['discount_amount']?.toString() ?? '0.0') ?? 0.0;
//       final qtyVal = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
//       return sum + (discountVal * qtyVal);
//     });
//
//     double totalTax = activeItems.fold(0.0, (sum, item) {
//       final gstVal = double.tryParse(item['gst']?.toString() ?? '0.0') ?? 0.0;
//       final govtVal = double.tryParse(item['government_fees']?.toString() ?? '0.0') ?? 0.0;
//       final qtyVal = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
//       return sum + ((gstVal + govtVal) * qtyVal);
//     });
//
//     double totalPackaging = activeItems.fold(0.0, (sum, item) {
//       final packVal = double.tryParse(item['package_price']?.toString() ?? '0.0') ?? 0.0;
//       final qtyVal = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
//       return sum + (packVal * qtyVal);
//     });
//
//     double totalShipping = activeItems.fold(0.0, (sum, item) {
//       final logVal = double.tryParse(item['logistics_price']?.toString() ?? '0.0') ?? 0.0;
//       final qtyVal = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
//       return sum + (logVal * qtyVal);
//     });
//
//     double grandTotal =
//         totalMRP - totalDiscount + totalTax + totalPackaging + totalShipping - _couponDiscount;
//     if (grandTotal < 0.0) grandTotal = 0.0;
//
//     final String taxLabel = isPersonalMode ? 'GST (12%)' : 'Business Tax (Excl.)';
//     final String taxValue = '₹${totalTax.toStringAsFixed(2)}';
//     final String shippingLabel = isPersonalMode ? 'Express Delivery' : 'LTL Pallet Freight';
//     final String shippingValue = '₹${totalShipping.toStringAsFixed(2)}';
//     final String totalValue = '₹${grandTotal.toStringAsFixed(2)}';
//
//     return Scaffold(
//       backgroundColor: surface,
//       appBar: LuxeHeader(titleColor: onSurface),
//       body: SafeArea(
//         child: Center(
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 576),
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : RefreshIndicator(
//               onRefresh: _fetchCart,
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: ListView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                       children: [
//                         // --- B2B/B2C Switcher ---
//                         Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: surfaceContainer,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Stack(
//                             children: [
//                               AnimatedAlign(
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeInOut,
//                                 alignment: isPersonalMode
//                                     ? Alignment.centerLeft
//                                     : Alignment.centerRight,
//                                 child: FractionallySizedBox(
//                                   widthFactor: 0.5,
//                                   child: Container(
//                                     height: 44,
//                                     decoration: BoxDecoration(
//                                       color: surfaceContainerLowest,
//                                       borderRadius: BorderRadius.circular(8),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.05),
//                                           blurRadius: 4,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           isPersonalMode = true;
//                                           _couponCode = null;
//                                           _couponDiscount = 0.0;
//                                           _couponController.clear();
//                                         });
//                                       },
//                                       behavior: HitTestBehavior.opaque,
//                                       child: Container(
//                                         height: 44,
//                                         alignment: Alignment.center,
//                                         child: Text(
//                                           'Personal',
//                                           style: TextStyle(
//                                             color: isPersonalMode
//                                                 ? primaryColor
//                                                 : onSurfaceVariant,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           isPersonalMode = false;
//                                           _couponCode = null;
//                                           _couponDiscount = 0.0;
//                                           _couponController.clear();
//                                         });
//                                       },
//                                       behavior: HitTestBehavior.opaque,
//                                       child: Container(
//                                         height: 44,
//                                         alignment: Alignment.center,
//                                         child: Text(
//                                           'Business (B2B)',
//                                           style: TextStyle(
//                                             color: !isPersonalMode
//                                                 ? primaryColor
//                                                 : onSurfaceVariant,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//
//                         if (!isPersonalMode) ...[
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             decoration: BoxDecoration(
//                               color: secondaryContainer.withOpacity(0.3),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: primaryColor.withOpacity(0.1)),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.verified_user, color: primaryColor, size: 18),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     'LUXE BUSINESS ACCOUNT ACTIVE • GST INPUT ELIGIBLE',
//                                     style: TextStyle(
//                                       color: primaryColor,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       letterSpacing: 0.6,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                         ],
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Shopping Cart',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w600,
//                                 color: onSurface,
//                               ),
//                             ),
//                             Text(
//                               '${activeItems.length} Items',
//                               style: TextStyle(fontSize: 14, color: onSurfaceVariant),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//
//                         if (activeItems.isEmpty)
//                           Container(
//                             padding: const EdgeInsets.symmetric(vertical: 48),
//                             alignment: Alignment.center,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.shopping_cart_outlined,
//                                   size: 64,
//                                   color: onSurfaceVariant.withOpacity(0.3),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   isPersonalMode
//                                       ? 'Your personal cart is empty'
//                                       : 'Your business cart is empty',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                     color: onSurfaceVariant,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: primaryColor,
//                                     foregroundColor: onPrimaryColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 24, vertical: 12),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.of(context).popUntil((route) => route.isFirst);
//                                   },
//                                   child: const Text(
//                                     'Shop Now',
//                                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         else ...[
//                           Column(
//                             children: activeItems.asMap().entries.map((entry) {
//                               final item = entry.value;
//                               final isB2B = !isPersonalMode;
//                               return Padding(
//                                 padding: const EdgeInsets.only(bottom: 16),
//                                 child: _buildCartItem(item, isB2B),
//                               );
//                             }).toList(),
//                           ),
//                           const SizedBox(height: 24),
//
//                           // --- Coupon Section ---
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: surfaceContainerLowest,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'DISCOUNT CODE',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: onSurfaceVariant,
//                                     letterSpacing: 0.6,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Container(
//                                         height: 48,
//                                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                                         decoration: BoxDecoration(
//                                           color: surfaceContainer,
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: TextField(
//                                           controller: _couponController,
//                                           textInputAction: TextInputAction.done,
//                                           onSubmitted: (_) => _applyCoupon(),
//                                           decoration: InputDecoration(
//                                             hintText: 'Enter code',
//                                             hintStyle: TextStyle(
//                                               color: onSurfaceVariant.withOpacity(0.6),
//                                               fontSize: 16,
//                                             ),
//                                             border: InputBorder.none,
//                                             contentPadding:
//                                             const EdgeInsets.symmetric(vertical: 12),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     SizedBox(
//                                       height: 48,
//                                       child: ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: primaryColor,
//                                           foregroundColor: onPrimaryColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                           ),
//                                           padding: const EdgeInsets.symmetric(horizontal: 24),
//                                           elevation: 0,
//                                         ),
//                                         onPressed: _isMutating ? null : _applyCoupon,
//                                         child: _isMutating
//                                             ? const SizedBox(
//                                           width: 18,
//                                           height: 18,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             color: Colors.white,
//                                           ),
//                                         )
//                                             : const Text(
//                                           'Apply',
//                                           style: TextStyle(
//                                               fontSize: 16, fontWeight: FontWeight.w500),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//
//                           // --- Summary Section ---
//                           Container(
//                             padding: const EdgeInsets.all(24),
//                             decoration: BoxDecoration(
//                               color: surfaceContainer,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Order Summary',
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.w600,
//                                     color: onSurface,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 _buildSummaryRow('Subtotal', '₹${totalMRP.toStringAsFixed(2)}',
//                                     isBoldValue: true),
//                                 const SizedBox(height: 12),
//                                 if (totalDiscount > 0) ...[
//                                   _buildSummaryRow(
//                                     'Discount',
//                                     '-₹${totalDiscount.toStringAsFixed(2)}',
//                                     isBoldValue: true,
//                                   ),
//                                   const SizedBox(height: 12),
//                                 ],
//                                 _buildSummaryRow(taxLabel, taxValue, isBoldValue: true),
//                                 const SizedBox(height: 12),
//                                 _buildSummaryRow(
//                                   'Packaging (Eco-Luxe)',
//                                   '₹${totalPackaging.toStringAsFixed(2)}',
//                                   isBoldValue: true,
//                                 ),
//                                 const SizedBox(height: 12),
//                                 if (_couponDiscount > 0) ...[
//                                   _buildSummaryRow(
//                                     'Coupon Code ($_couponCode)',
//                                     '-₹${_couponDiscount.toStringAsFixed(2)}',
//                                     isBoldValue: true,
//                                   ),
//                                   const SizedBox(height: 12),
//                                 ],
//                                 Container(
//                                   padding: const EdgeInsets.only(bottom: 20),
//                                   decoration: BoxDecoration(
//                                     border: Border(
//                                       bottom: BorderSide(color: outlineVariant.withOpacity(0.3)),
//                                     ),
//                                   ),
//                                   child: _buildSummaryRow(shippingLabel, shippingValue,
//                                       isBoldValue: true),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Total Amount',
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: onSurface,
//                                       ),
//                                     ),
//                                     Text(
//                                       totalValue,
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: primaryColor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                         ],
//                       ],
//                     ),
//                   ),
//                   if (activeItems.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: 60,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: primaryColor,
//                             foregroundColor: onPrimaryColor,
//                             shadowColor: primaryColor.withOpacity(0.2),
//                             elevation: 8,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           ),
//                           onPressed: () {
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(builder: (_) => const CheckoutScreen()),
//                             // ).then((_) => _fetchCart());
//                           },
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text(
//                                 'Proceed to Payment',
//                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(width: 8),
//                               Icon(Icons.arrow_forward, color: onPrimaryColor),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCartItem(dynamic item, bool isB2B) {
//     final title = item['title'] ?? 'Product';
//     final priceVal = double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
//     final qtyVal = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
//     final imageUrl = _getImageUrl(item['image']);
//
//     String? b2bSubtitle;
//     String? moqText;
//     if (isB2B) {
//       if (item['marketplace_id'].toString() == '51') {
//         b2bSubtitle = "Packaging Item";
//       } else if (item['marketplace_id'].toString() == '53') {
//         b2bSubtitle = "Branding Item";
//       } else {
//         b2bSubtitle = "B2B Product";
//       }
//       if (item['vendor_name'] != null && item['vendor_name'].toString().isNotEmpty) {
//         b2bSubtitle += " | Vendor: ${item['vendor_name']}";
//       }
//       double unitPrice = priceVal / (qtyVal > 0 ? qtyVal : 1);
//       moqText = "MOQ: $qtyVal UNITS | ₹${unitPrice.toStringAsFixed(2)}/UNIT";
//     } else {
//       if (item['vendor_name'] != null && item['vendor_name'].toString().isNotEmpty) {
//         b2bSubtitle = "Vendor: ${item['vendor_name']}";
//       }
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: surfaceContainerLowest,
//         borderRadius: BorderRadius.circular(12),
//         border: isB2B
//             ? Border(left: BorderSide(color: primaryColor.withOpacity(0.2), width: 4))
//             : null,
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 96,
//             height: 96,
//             decoration: BoxDecoration(
//               color: surfaceContainerHigh,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: surfaceContainerHigh,
//                     alignment: Alignment.center,
//                     child: Text(
//                       title.isNotEmpty ? title[0] : 'P',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: onSurfaceVariant,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (isB2B)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: secondaryContainer,
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Text(
//                           'B2B BULK',
//                           style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w900),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "₹${priceVal.toStringAsFixed(2)}",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
//                 ),
//                 if (moqText != null) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     moqText,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: onSurfaceVariant.withOpacity(0.7),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//                 if (b2bSubtitle != null && moqText == null) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     b2bSubtitle,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: onSurfaceVariant.withOpacity(0.7),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: outlineVariant),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             visualDensity: VisualDensity.compact,
//                             padding: EdgeInsets.zero,
//                             icon: Icon(Icons.remove, size: 18, color: onSurfaceVariant),
//                             onPressed: _isMutating
//                                 ? null
//                                 : () {
//                               if (qtyVal > 1) {
//                                 _updateQuantity(item, 'decrease');
//                               }
//                             },
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Text(qtyVal.toString(), style: TextStyle(fontSize: 16, color: onSurface)),
//                           ),
//                           IconButton(
//                             visualDensity: VisualDensity.compact,
//                             padding: EdgeInsets.zero,
//                             icon: Icon(Icons.add, size: 18, color: onSurfaceVariant),
//                             onPressed: _isMutating ? null : () => _updateQuantity(item, 'increase'),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       visualDensity: VisualDensity.compact,
//                       icon: Icon(Icons.delete, color: errorColor),
//                       onPressed: _isMutating ? null : () => _removeCartItem(item),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, String value, {bool isBoldValue = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: TextStyle(fontSize: 16, color: onSurfaceVariant)),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             color: onSurface,
//             fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Enhanced LuxeHeader to match Serene Commerce design
// class LuxeHeader extends StatelessWidget implements PreferredSizeWidget {
//   final Color? backgroundColor;
//   final double elevation;
//   final String? title;
//   final Color? titleColor;
//
//   const LuxeHeader({
//     super.key,
//     this.backgroundColor,
//     this.elevation = 0,
//     this.title,
//     this.titleColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: backgroundColor ?? Colors.white,
//       elevation: elevation,
//       title: Row(
//         children: [
//           const SizedBox(width: 8),
//           Text(
//             title ?? 'Cart',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w500,
//               color: titleColor ?? const Color(0xFF1C1B1B),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(80);
// }