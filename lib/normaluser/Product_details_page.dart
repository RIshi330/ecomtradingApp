// import 'package:flutter/material.dart';
// import 'package:luxe_marketplace/common_widgets.dart';
// import 'package:luxe_marketplace/services/login_guard.dart';
// import 'package:luxe_marketplace/marketplace-btc.dart';
//
// import 'checkout.dart';
//
// class ProductDetailPage extends StatefulWidget {
//   final ProductModel product;
//   const ProductDetailPage({super.key, required this.product});
//
//   @override
//   State<ProductDetailPage> createState() => _ProductDetailPageState();
// }
//
// class _ProductDetailPageState extends State<ProductDetailPage> {
//   // Theme Colors matching Tailwind config
//   static const Color colorPrimary = Color(0xFF006565);
//   static const Color colorBackground = Color(0xFFFCF9F8);
//   static const Color colorSurfaceContainer = Color(0xFFF0EDED);
//   static const Color colorSurfaceContainerLow = Color(0xFFF6F3F2);
//   static const Color colorSecondaryContainer = Color(0xFFD4E6E5);
//   static const Color colorOnSecondaryContainer = Color(0xFF576867);
//   static const Color colorPrimaryContainer = Color(0xFF008080);
//   static const Color colorOnPrimaryContainer = Color(0xFFE3FFFE);
//   static const Color colorTertiary = Color(0xFF595A5B);
//   static const Color colorOutlineVariant = Color(0xFFBDC9C8);
//   static const Color colorError = Color(0xFFBA1A1A);
//
//   // States
//   int _cartCount = 0;
//   int _quantity = 1;
//   bool _isWishlisted = false;
//   bool _isShippingOpen = false;
//   bool _isSustainabilityOpen = false;
//   int _selectedSizeIndex = 1; // Default 'S' selected
//   int _selectedColorIndex = 0;
//
//   void _showToast(String message) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.check_circle, color: Color(0xFF76D6D5)),
//             const SizedBox(width: 8),
//             Text(
//               message,
//               style: const TextStyle(color: Colors.white, fontSize: 14),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF313030),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
//         margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final bool isDesktop = screenWidth >= 768;
//
//     return Scaffold(
//       backgroundColor: colorBackground,
//       appBar: const LuxeHeader(),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(
//           horizontal: isDesktop ? 48.0 : 16.0,
//           vertical: 24.0,
//         ),
//         child: Center(
//           child: Column(
//             children: [
//               Container(
//                 constraints: const BoxConstraints(maxWidth: 1280),
//                 child: isDesktop
//                     ? Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(flex: 7, child: _buildProductImagery()),
//                     const SizedBox(width: 48),
//                     Expanded(
//                         flex: 5, child: _buildProductDetailsColumn()),
//                   ],
//                 )
//                     : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildProductImagery(),
//                     const SizedBox(height: 24),
//                     _buildProductDetailsColumn(),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 48),
//               // const LuxeFooter(),
//             ],
//           ),
//         ),
//       ),
//       // bottomNavigationBar: isDesktop ? null : _buildMobileBottomNavBar(),
//     );
//   }
//
//   // MARK: - Component Layouts
//
//   Widget _buildProductImagery() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AspectRatio(
//           aspectRatio: 4 / 5,
//           child: Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   color: colorSurfaceContainerLow,
//                   width: double.infinity,
//                   height: double.infinity,
//                   child: Image.network(
//                     widget.product.image,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) =>
//                     const Center(child: Icon(Icons.image, size: 50)),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 16,
//                 right: 16,
//                 child: Column(
//                   children: [
//                     _buildFloatingActionButton(
//                       icon: _isWishlisted
//                           ? Icons.favorite
//                           : Icons.favorite_border,
//                       iconColor: _isWishlisted ? colorError : colorPrimary,
//                       onPressed: () async {
//                         final hasAccess = await LoginGuard.checkAndPrompt(
//                           context,
//                           message:
//                           'Please sign in to add items to your wishlist.',
//                         );
//                         if (!hasAccess) return;
//                         setState(() {
//                           _isWishlisted = !_isWishlisted;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     _buildFloatingActionButton(icon: Icons.share),
//                     const SizedBox(height: 12),
//                     _buildFloatingActionButton(icon: Icons.compare_arrows),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 80,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: 4,
//             separatorBuilder: (_, __) => const SizedBox(width: 8),
//             itemBuilder: (context, index) {
//               final bool isSelected = index == 0;
//               return Opacity(
//                 opacity: isSelected ? 1.0 : 0.6,
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     border: isSelected
//                         ? Border.all(color: colorPrimary, width: 2)
//                         : null,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(6),
//                     child: Image.network(
//                       widget.product.image,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         )
//       ],
//     );
//   }
//
//   Widget _buildFloatingActionButton(
//       {required IconData icon,
//         Color iconColor = colorPrimary,
//         VoidCallback? onPressed}) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.8),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: IconButton(
//         padding: EdgeInsets.zero,
//         icon: Icon(icon, color: iconColor, size: 20),
//         onPressed: onPressed ?? () {},
//       ),
//     );
//   }
//
//   Widget _buildProductDetailsColumn() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Seller Row
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: colorSurfaceContainer,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: colorOutlineVariant),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 16,
//                 backgroundColor: colorPrimaryContainer,
//                 child: const Text('LB',
//                     style: TextStyle(
//                         color: colorOnPrimaryContainer,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700)),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(widget.product.store,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.w600, fontSize: 13)),
//                     Row(
//                       children: const [
//                         Icon(Icons.star, color: colorPrimary, size: 12),
//                         SizedBox(width: 2),
//                         Text('4.9 (2.4k sales)',
//                             style:
//                             TextStyle(color: colorTertiary, fontSize: 11)),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               OutlinedButton(
//                 onPressed: () {},
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: colorPrimary,
//                   side: const BorderSide(color: colorPrimary),
//                   shape: const StadiumBorder(),
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: const Text('FOLLOW',
//                     style:
//                     TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//
//         // Badges & Title
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: colorSecondaryContainer,
//                 borderRadius: BorderRadius.circular(100),
//               ),
//               child: const Text('New Arrival',
//                   style: TextStyle(
//                       color: colorOnSecondaryContainer,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600)),
//             ),
//             const SizedBox(width: 8),
//             // Explicitly typed generic List<Widget> to avoid assignability errors
//             ...<Widget>[
//               ...List.generate(
//                   4,
//                       (index) =>
//                   const Icon(Icons.star, color: colorPrimary, size: 14)),
//               const Icon(Icons.star_half, color: colorPrimary, size: 14),
//               const SizedBox(width: 4),
//               const Text('(128)',
//                   style: TextStyle(color: colorTertiary, fontSize: 11)),
//             ],
//           ],
//         ),
//         const SizedBox(height: 6),
//         Text(
//           widget.product.title,
//           style: const TextStyle(
//               fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4),
//         ),
//         const SizedBox(height: 6),
//
//         // Pricing Info
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.baseline,
//           textBaseline: TextBaseline.alphabetic,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text('₿${widget.product.btcPrice.toStringAsFixed(4)}',
//                 style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: colorPrimary)),
//             const SizedBox(width: 8),
//             Text('₿${widget.product.btcOldPrice.toStringAsFixed(4)}',
//                 style: const TextStyle(
//                     fontSize: 14,
//                     color: colorTertiary,
//                     decoration: TextDecoration.lineThrough)),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: colorPrimaryContainer.withOpacity(0.1),
//             border: Border.all(color: colorPrimaryContainer.withOpacity(0.2)),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(Icons.workspace_premium, color: colorPrimary, size: 12),
//               SizedBox(width: 4),
//               Text('Extra ₹25 off with Luxe Membership',
//                   style: TextStyle(
//                       color: colorPrimary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500)),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Divider(color: Color(0xFFF1F5F9)),
//         const SizedBox(height: 24),
//
//         // Delivery Check Section
//         const Text('DELIVERY & SERVICES',
//             style: TextStyle(
//                 fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
//         const SizedBox(height: 6),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 40,
//                 child: TextField(
//                   style: const TextStyle(fontSize: 13),
//                   decoration: InputDecoration(
//                     hintText: 'Enter Pincode',
//                     prefixIcon:
//                     const Icon(Icons.location_on, color: colorTertiary, size: 16),
//                     filled: true,
//                     fillColor: colorSurfaceContainerLow,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: const BorderSide(color: colorOutlineVariant),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: const BorderSide(color: colorPrimary),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             SizedBox(
//               height: 40,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colorPrimaryContainer,
//                   foregroundColor: colorOnPrimaryContainer,
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6)),
//                   elevation: 0,
//                 ),
//                 child: const Text('Check',
//                     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         const Text('Check availability and estimated delivery date',
//             style: TextStyle(fontSize: 11, color: colorTertiary)),
//         const SizedBox(height: 16),
//
//         // Color Selection
//         const Text('COLOR: DEEP TEAL',
//             style: TextStyle(
//                 fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
//         const SizedBox(height: 6),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             _buildColorOption(0, const Color(0xFF006565)),
//             const SizedBox(width: 8),
//             _buildColorOption(1, const Color(0xFF1C1B1B)),
//             const SizedBox(width: 8),
//             _buildColorOption(2, const Color(0xFF595A5B)),
//           ],
//         ),
//         const SizedBox(height: 16),
//
//         // Size Selection
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text('SELECT SIZE',
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 1.2)),
//             TextButton(
//               onPressed: () {},
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.zero,
//                 minimumSize: Size.zero,
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               child: const Text('Size Guide',
//                   style: TextStyle(
//                       color: colorPrimary,
//                       fontSize: 12,
//                       decoration: TextDecoration.underline)),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         _buildSizeGrid(),
//         const SizedBox(height: 16),
//
//         // Quantity & Actions Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: colorOutlineVariant),
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.white,
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//                     icon: const Icon(Icons.remove, size: 14),
//                     onPressed: () {
//                       if (_quantity > 1) setState(() => _quantity--);
//                     },
//                   ),
//                   Text('$_quantity',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.w700, fontSize: 14)),
//                   IconButton(
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//                     icon: const Icon(Icons.add, size: 14),
//                     onPressed: () => setState(() => _quantity++),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   final hasAccess = await LoginGuard.checkAndPrompt(
//                     context,
//                     message: 'Please sign in to add items to your cart.',
//                   );
//                   if (!hasAccess) return;
//
//                   _showToast("Adding to cart...");
//
//                   final res = await MarketplaceApiService.addItemToCart(
//                     encryptedProductId: widget.product.id,
//                     encryptedVariantId: widget.product.encryptedVariantId ?? '',
//                     quantity: _quantity,
//                   );
//
//                   if (res['success'] == true) {
//                     setState(() {
//                       _cartCount += _quantity;
//                     });
//                     _showToast('Item added to cart');
//                   } else {
//                     _showToast('Failed to add to cart: ${res['message']}');
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colorPrimary,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   elevation: 2,
//                   shadowColor: colorPrimary.withOpacity(0.2),
//                 ),
//                 child: const Text('Add to Cart',
//                     style:
//                     TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const CheckoutScreen()),
//               );
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: colorPrimary,
//               side: const BorderSide(color: colorPrimary),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Buy Now',
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // Description Section
//         const Text('Product Details',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//         const SizedBox(height: 8),
//         Text(
//           widget.product.subtitle,
//           style:
//           const TextStyle(fontSize: 14, color: colorTertiary, height: 1.5),
//         ),
//         const SizedBox(height: 12),
//         _buildBulletPoint('Premium Italian Technical Nylon'),
//         const SizedBox(height: 6),
//         _buildBulletPoint('Ethically sourced thermal lining'),
//         const SizedBox(height: 16),
//
//         // About Seller Stats Box
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: colorSurfaceContainerLow,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: colorOutlineVariant),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('About Seller',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
//               const SizedBox(height: 6),
//               const Text(
//                 'Luxe Boutique specializes in high-end architectural fashion. We focus on sustainable materials and timeless silhouettes for the modern urban dweller.',
//                 style: TextStyle(fontSize: 13, color: colorTertiary),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(child: _buildSellerStat('98%', 'Positive Feedback')),
//                   _buildDividerWidget(),
//                   Expanded(child: _buildSellerStat('2.4k', 'Total Sales')),
//                   _buildDividerWidget(),
//                   Expanded(child: _buildSellerStat('5yrs', 'On Marketplace')),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // Accordion Widgets
//         _buildAccordion(
//           title: 'Shipping & Returns',
//           isOpen: _isShippingOpen,
//           content:
//           'Free standard shipping on orders over ₹200. Express shipping available. Returns accepted within 30 days of purchase in original condition.',
//           onToggle: () => setState(() => _isShippingOpen = !_isShippingOpen),
//         ),
//         const Divider(color: Color(0xFFF1F5F9)),
//         _buildAccordion(
//           title: 'Sustainability Impact',
//           isOpen: _isSustainabilityOpen,
//           content:
//           'Made with 40% recycled nylon. Our thermal lining is Oeko-Tex certified. We offset 100% of carbon emissions from shipping this product.',
//           onToggle: () =>
//               setState(() => _isSustainabilityOpen = !_isSustainabilityOpen),
//         ),
//         const SizedBox(height: 24),
//
//         // Reviews Section
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text('Reviews',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//             ElevatedButton(
//               onPressed: () => _openReviewModal(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colorPrimary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 minimumSize: Size.zero,
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6)),
//               ),
//               child: const Text('Write a Review', style: TextStyle(fontSize: 12)),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//         _buildReviewSectionSummary(),
//       ],
//     );
//   }
//
//   Widget _buildColorOption(int index, Color color) {
//     final bool isSelected = _selectedColorIndex == index;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedColorIndex = index),
//       child: Container(
//         width: 30,
//         height: 30,
//         padding: const EdgeInsets.all(2),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(
//               color: isSelected ? colorPrimary : Colors.grey.shade300,
//               width: isSelected ? 1.5 : 1),
//           color: Colors.white,
//         ),
//         child: Container(
//           decoration: BoxDecoration(shape: BoxShape.circle, color: color),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBulletPoint(String text) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(Icons.check_circle, color: colorPrimary, size: 20),
//         const SizedBox(width: 12),
//         Expanded(
//             child: Text(text,
//                 style: const TextStyle(fontSize: 14, color: colorTertiary))),
//       ],
//     );
//   }
//
//   Widget _buildSellerStat(String value, String label) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(value,
//             style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: colorPrimary)),
//         Text(label,
//             style: const TextStyle(fontSize: 10, color: colorTertiary),
//             textAlign: TextAlign.center),
//       ],
//     );
//   }
//
//   Widget _buildDividerWidget() {
//     return Container(width: 1, height: 32, color: colorOutlineVariant);
//   }
//
//   Widget _buildAccordion(
//       {required String title,
//         required bool isOpen,
//         required String content,
//         required VoidCallback onToggle}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           title: Text(title,
//               style:
//               const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
//           trailing: AnimatedRotation(
//             duration: const Duration(milliseconds: 200),
//             turns: isOpen ? 0.5 : 0.0,
//             child: const Icon(Icons.expand_more),
//           ),
//           onTap: onToggle,
//         ),
//         AnimatedCrossFade(
//           firstChild: const SizedBox.shrink(),
//           secondChild: Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: Text(content,
//                 style: const TextStyle(
//                     fontSize: 14, color: colorTertiary, height: 1.5)),
//           ),
//           crossFadeState:
//           isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//           duration: const Duration(milliseconds: 200),
//         )
//       ],
//     );
//   }
//
//   Widget _buildReviewSectionSummary() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 4,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('4.8',
//                   style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.w700,
//                       color: colorPrimary)),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                     5,
//                         (index) =>
//                     const Icon(Icons.star, color: colorPrimary, size: 14)),
//               ),
//               const SizedBox(height: 4),
//               const Text('Based on 128 reviews',
//                   style: TextStyle(fontSize: 12, color: colorTertiary),
//                   textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//         const SizedBox(width: 24),
//         Expanded(
//           flex: 8,
//           child: Column(
//             children: [
//               _buildRatingBar(5, 0.85, '85%'),
//               _buildRatingBar(4, 0.10, '10%'),
//               _buildRatingBar(3, 0.03, '3%'),
//               _buildRatingBar(2, 0.01, '1%'),
//               _buildRatingBar(1, 0.01, '1%'),
//             ],
//           ),
//         )
//       ],
//     );
//   }
//
//   Widget _buildRatingBar(int index, double percent, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text('$index', style: const TextStyle(fontSize: 14)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(100),
//               child: LinearProgressIndicator(
//                 value: percent,
//                 backgroundColor: Colors.grey.shade100,
//                 color: colorPrimary,
//                 minHeight: 8,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//               width: 32,
//               child: Text(label,
//                   style: const TextStyle(fontSize: 14, color: colorTertiary))),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSizeGrid() {
//     final sizes = ['XS', 'S', 'M', 'L'];
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 4,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         mainAxisSpacing: 6,
//         crossAxisSpacing: 6,
//         childAspectRatio: 2.2,
//       ),
//       itemBuilder: (context, index) {
//         final isSelected = _selectedSizeIndex == index;
//         return InkWell(
//           onTap: () => setState(() => _selectedSizeIndex = index),
//           child: Container(
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? colorPrimaryContainer.withOpacity(0.1)
//                   : Colors.transparent,
//               border: Border.all(
//                   color: isSelected ? colorPrimary : Colors.grey.shade200,
//                   width: isSelected ? 1.5 : 1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               sizes[index],
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
//                 color: isSelected ? colorPrimary : Colors.black,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _openReviewModal(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('Write a Review',
//                   style: TextStyle(fontWeight: FontWeight.w700)),
//               const Spacer(),
//               IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.of(context).pop()),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Overall Rating',
//                   style: TextStyle(
//                       color: colorTertiary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700)),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                     5,
//                         (index) => const Icon(Icons.star_border,
//                         size: 36, color: Colors.grey)),
//               ),
//               const SizedBox(height: 16),
//               const Text('Your Review',
//                   style: TextStyle(
//                       color: colorTertiary,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700)),
//               const SizedBox(height: 8),
//               const TextField(
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   hintText:
//                   'What did you think of the fit, material, and quality?',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               OutlinedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.add_a_photo),
//                 label: const Text('Upload Photos'),
//                 style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 48)),
//               ),
//             ],
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _showToast('Review submitted successfully!');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colorPrimary,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 48),
//               ),
//               child: const Text('Submit Review'),
//             )
//           ],
//         );
//       },
//     );
//   }
//
//   // Widget _buildMobileBottomNavBar() {
//   //   return Container(
//   //     decoration: BoxDecoration(
//   //       color: Colors.white.withOpacity(0.95),
//   //       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//   //       boxShadow: [
//   //         BoxShadow(
//   //             color: Colors.black.withOpacity(0.05),
//   //             blurRadius: 20,
//   //             offset: const Offset(0, -4))
//   //       ],
//   //     ),
//   //     child: BottomNavigationBar(
//   //       currentIndex: 1,
//   //       type: BottomNavigationBarType.fixed,
//   //       backgroundColor: Colors.transparent,
//   //       elevation: 0,
//   //       selectedItemColor: colorPrimary,
//   //       unselectedItemColor: Colors.grey.shade400,
//   //       selectedLabelStyle:
//   //       const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
//   //       unselectedLabelStyle:
//   //       const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
//   //       items: const [
//   //         BottomNavigationBarItem(
//   //             icon: Icon(Icons.home_outlined), label: 'HOME'),
//   //         BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'SHOP'),
//   //         BottomNavigationBarItem(
//   //             icon: Icon(Icons.favorite_border), label: 'WISHLIST'),
//   //         BottomNavigationBarItem(
//   //             icon: Icon(Icons.person_outline), label: 'PROFILE'),
//   //       ],
//   //     ),
//   //   );
//   // }
// }
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:luxe_marketplace/common_widgets.dart';
// // import 'package:luxe_marketplace/services/login_guard.dart';
// // import 'package:luxe_marketplace/marketplace-btc.dart';
// // import 'package:luxe_marketplace/checkout.dart';
// //
// // import 'app_constants.dart';
// //
// // /// =======================================================
// // ///  API SERVICE (built into this file, no separate file)
// // /// =======================================================
// // class MarketplaceApiService {
// //   // TODO: change this to your real backend URL
// //   static const String Url =
// //       "${baseUrl}new_apis/product_detail.php";
// //
// //   static String _enc(String id) => Uri.encodeComponent(base64Encode(utf8.encode(id)));
// //
// //   static Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
// //     try {
// //       final res = await http.post(
// //         Uri.parse(Url),
// //         headers: {"Content-Type": "application/json"},
// //         body: jsonEncode(body),
// //       );
// //       final decoded = jsonDecode(res.body);
// //       if (decoded is Map<String, dynamic>) return decoded;
// //       return {"success": false, "message": "Invalid response", "data": {}};
// //     } catch (e) {
// //       return {"success": false, "message": e.toString(), "data": {}};
// //     }
// //   }
// //
// //   static Future<Map<String, dynamic>> getProductFullDetails(
// //       {required String pid, required String var_}) {
// //     return _post({"action": "get_product_full_details", "pid": pid, "var": var_});
// //   }
// //
// //   static Future<Map<String, dynamic>> getProductSocialLinks(
// //       {required String pid, required String var_}) {
// //     return _post({"action": "get_product_social_links", "pid": pid, "var": var_});
// //   }
// //
// //   static Future<Map<String, dynamic>> getProductSpecifications({required String pid}) {
// //     return _post({"action": "get_product_specifications", "pid": pid, "var": "x"});
// //   }
// //
// //   static Future<Map<String, dynamic>> getProductRatings({required String pid}) {
// //     return _post({"action": "get_product_ratings", "pid": pid, "var": "x"});
// //   }
// //
// //   static Future<Map<String, dynamic>> getProductReviews({required String pid}) {
// //     return _post({"action": "get_product_reviews", "pid": pid, "var": "x"});
// //   }
// //
// //   static Future<Map<String, dynamic>> getProductVendorInfo({required String pid}) {
// //     return _post({"action": "get_product_vendor_info", "pid": pid, "var": "x"});
// //   }
// //
// //   static Future<Map<String, dynamic>> checkDelivery(
// //       {required String pid, required String var_, required int logisticId, required int pincode}) {
// //     return _post({
// //       "action": "check_delivery",
// //       "pid": pid,
// //       "var": var_,
// //       "logistic_id": logisticId,
// //       "pincode": pincode,
// //     });
// //   }
// //
// //   static Future<Map<String, dynamic>> getAffiliateMarginAndCommission(
// //       {required String pid, required String var_}) {
// //     // backend base64-decodes pid/var for this action specifically
// //     return _post({"action": "get_affiliate_margin_and_commission", "pid": _enc(pid), "var": _enc(var_)});
// //   }
// //
// //   /// NOTE: Adding to cart / wishlist / submitting reviews is NOT implemented
// //   /// in the provided PHP file (it only has read/fetch actions). You need to
// //   /// add corresponding write actions (e.g. 'add_to_cart', 'toggle_wishlist',
// //   /// 'submit_review') on the backend before these will work. Stubs below
// //   /// point at a separate endpoint you'll need to create.
// //   static const String cartUrl = "https://yourdomain.com/api/cart/cart.php";
// //   static const String reviewUrl = "https://yourdomain.com/api/product/review.php";
// //
// //   static Future<Map<String, dynamic>> addItemToCart({
// //     required String encryptedProductId,
// //     required String encryptedVariantId,
// //     required int quantity,
// //   }) async {
// //     try {
// //       final res = await http.post(
// //         Uri.parse(cartUrl),
// //         headers: {"Content-Type": "application/json"},
// //         body: jsonEncode({
// //           "action": "add_to_cart",
// //           "pid": encryptedProductId,
// //           "var": encryptedVariantId,
// //           "qty": quantity,
// //         }),
// //       );
// //       final decoded = jsonDecode(res.body);
// //       return decoded is Map<String, dynamic> ? decoded : {"success": false, "message": "Invalid response"};
// //     } catch (e) {
// //       return {"success": false, "message": e.toString()};
// //     }
// //   }
// //
// //   static Future<Map<String, dynamic>> toggleWishlist({
// //     required String pid,
// //     required String var_,
// //   }) async {
// //     try {
// //       final res = await http.post(
// //         Uri.parse(cartUrl),
// //         headers: {"Content-Type": "application/json"},
// //         body: jsonEncode({"action": "toggle_wishlist", "pid": pid, "var": var_}),
// //       );
// //       final decoded = jsonDecode(res.body);
// //       return decoded is Map<String, dynamic> ? decoded : {"success": false, "message": "Invalid response"};
// //     } catch (e) {
// //       return {"success": false, "message": e.toString()};
// //     }
// //   }
// //
// //   static Future<Map<String, dynamic>> submitReview({
// //     required String pid,
// //     required int rating,
// //     required String comment,
// //   }) async {
// //     try {
// //       final res = await http.post(
// //         Uri.parse(reviewUrl),
// //         headers: {"Content-Type": "application/json"},
// //         body: jsonEncode({"action": "submit_review", "pid": pid, "rating": rating, "comment": comment}),
// //       );
// //       final decoded = jsonDecode(res.body);
// //       return decoded is Map<String, dynamic> ? decoded : {"success": false, "message": "Invalid response"};
// //     } catch (e) {
// //       return {"success": false, "message": e.toString()};
// //     }
// //   }
// // }
// //
// // /// =======================================================
// // ///  UI
// // /// =======================================================
// // class ProductDetailPage extends StatefulWidget {
// //   final ProductModel product;
// //   const ProductDetailPage({super.key, required this.product});
// //
// //   @override
// //   State<ProductDetailPage> createState() => _ProductDetailPageState();
// // }
// //
// // class _ProductDetailPageState extends State<ProductDetailPage> {
// //   static const Color colorPrimary = Color(0xFF006565);
// //   static const Color colorBackground = Color(0xFFFCF9F8);
// //   static const Color colorSurfaceContainer = Color(0xFFF0EDED);
// //   static const Color colorSurfaceContainerLow = Color(0xFFF6F3F2);
// //   static const Color colorSecondaryContainer = Color(0xFFD4E6E5);
// //   static const Color colorOnSecondaryContainer = Color(0xFF576867);
// //   static const Color colorPrimaryContainer = Color(0xFF008080);
// //   static const Color colorOnPrimaryContainer = Color(0xFFE3FFFE);
// //   static const Color colorTertiary = Color(0xFF595A5B);
// //   static const Color colorOutlineVariant = Color(0xFFBDC9C8);
// //   static const Color colorError = Color(0xFFBA1A1A);
// //
// //   bool _loading = true;
// //   String? _loadError;
// //
// //   Map<String, dynamic>? _productDetails;
// //   Map<String, dynamic>? _vendorInfo;
// //   Map<String, dynamic>? _ratingsData;
// //   Map<String, dynamic>? _reviewsData;
// //   Map<String, dynamic>? _socialData;
// //
// //   int _cartCount = 0;
// //   int _quantity = 1;
// //   bool _isWishlisted = false;
// //   bool _isShippingOpen = false;
// //   bool _isSustainabilityOpen = false;
// //   int _selectedSizeIndex = 1;
// //   int _selectedColorIndex = 0;
// //   final TextEditingController _pincodeController = TextEditingController();
// //   String? _deliveryStatus;
// //
// //   String get _pid => widget.product.id;
// //   String get _vid => widget.product.encryptedVariantId ?? '';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadAllData();
// //   }
// //
// //   Future<void> _loadAllData() async {
// //     setState(() => _loading = true);
// //     try {
// //       final results = await Future.wait([
// //         MarketplaceApiService.getProductFullDetails(pid: _pid, var_: _vid),
// //         MarketplaceApiService.getProductVendorInfo(pid: _pid),
// //         MarketplaceApiService.getProductRatings(pid: _pid),
// //         MarketplaceApiService.getProductReviews(pid: _pid),
// //         MarketplaceApiService.getProductSocialLinks(pid: _pid, var_: _vid),
// //       ]);
// //
// //       final fullDetails = results[0];
// //       final vendorInfo = results[1];
// //       final ratings = results[2];
// //       final reviews = results[3];
// //       final social = results[4];
// //
// //       setState(() {
// //         _productDetails = fullDetails['success'] == true ? fullDetails['data'] : null;
// //         _vendorInfo = vendorInfo['success'] == true
// //             ? (vendorInfo['data']?['vendor_info'])
// //             : null;
// //         _ratingsData = ratings['success'] == true ? ratings['data'] : null;
// //         _reviewsData = reviews['success'] == true ? reviews['data'] : null;
// //         _socialData = social['success'] == true ? social['data'] : null;
// //         _isWishlisted = _socialData?['wishlist']?['added'] == true;
// //         _loading = false;
// //         if (fullDetails['success'] != true) {
// //           _loadError = fullDetails['message'] ?? "Failed to load product";
// //         }
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _loading = false;
// //         _loadError = e.toString();
// //       });
// //     }
// //   }
// //
// //   void _showToast(String message) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).clearSnackBars();
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(Icons.check_circle, color: Color(0xFF76D6D5)),
// //             const SizedBox(width: 8),
// //             Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
// //           ],
// //         ),
// //         backgroundColor: const Color(0xFF313030),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
// //         margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
// //         duration: const Duration(seconds: 2),
// //       ),
// //     );
// //   }
// //
// //   Future<void> _onToggleWishlist() async {
// //     final hasAccess = await LoginGuard.checkAndPrompt(
// //       context,
// //       message: 'Please sign in to add items to your wishlist.',
// //     );
// //     if (!hasAccess) return;
// //
// //     final prev = _isWishlisted;
// //     setState(() => _isWishlisted = !_isWishlisted);
// //
// //     final res = await MarketplaceApiService.toggleWishlist(pid: _pid, var_: _vid);
// //     if (res['success'] != true) {
// //       setState(() => _isWishlisted = prev);
// //       _showToast('Failed to update wishlist: ${res['message'] ?? ''}');
// //     }
// //   }
// //
// //   Future<void> _onAddToCart() async {
// //     final hasAccess = await LoginGuard.checkAndPrompt(
// //       context,
// //       message: 'Please sign in to add items to your cart.',
// //     );
// //     if (!hasAccess) return;
// //
// //     _showToast("Adding to cart...");
// //     final res = await MarketplaceApiService.addItemToCart(
// //       encryptedProductId: _pid,
// //       encryptedVariantId: _vid,
// //       quantity: _quantity,
// //     );
// //
// //     if (res['success'] == true) {
// //       setState(() => _cartCount += _quantity);
// //       _showToast('Item added to cart');
// //     } else {
// //       _showToast('Failed to add to cart: ${res['message'] ?? ''}');
// //     }
// //   }
// //
// //   Future<void> _onCheckDelivery() async {
// //     final pin = int.tryParse(_pincodeController.text.trim());
// //     if (pin == null) {
// //       _showToast('Enter a valid pincode');
// //       return;
// //     }
// //     // logisticId would normally come from the seller/shipping config of the product
// //     final res = await MarketplaceApiService.checkDelivery(
// //       pid: _pid,
// //       var_: _vid,
// //       logisticId: 1,
// //       pincode: pin,
// //     );
// //     if (res['success'] == true) {
// //       final available = res['data']?['available'] == true;
// //       setState(() {
// //         _deliveryStatus = available ? 'Delivery available to $pin' : 'Delivery not available to $pin';
// //       });
// //     } else {
// //       setState(() => _deliveryStatus = 'Could not check delivery: ${res['message'] ?? ''}');
// //     }
// //   }
// //
// //   Future<void> _submitReview(int rating, String comment) async {
// //     final res = await MarketplaceApiService.submitReview(pid: _pid, rating: rating, comment: comment);
// //     if (res['success'] == true) {
// //       _showToast('Review submitted successfully!');
// //       _loadAllData(); // refresh ratings/reviews
// //     } else {
// //       _showToast('Failed to submit review: ${res['message'] ?? ''}');
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     final bool isDesktop = screenWidth >= 768;
// //
// //     if (_loading) {
// //       return Scaffold(
// //         backgroundColor: colorBackground,
// //         appBar: const LuxeHeader(),
// //         body: const Center(child: CircularProgressIndicator(color: colorPrimary)),
// //       );
// //     }
// //
// //     if (_loadError != null && _productDetails == null) {
// //       return Scaffold(
// //         backgroundColor: colorBackground,
// //         appBar: const LuxeHeader(),
// //         body: Center(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text('Failed to load product: $_loadError'),
// //               const SizedBox(height: 12),
// //               ElevatedButton(onPressed: _loadAllData, child: const Text('Retry')),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     return Scaffold(
// //       backgroundColor: colorBackground,
// //       appBar: const LuxeHeader(),
// //       body: RefreshIndicator(
// //         onRefresh: _loadAllData,
// //         child: SingleChildScrollView(
// //           physics: const AlwaysScrollableScrollPhysics(),
// //           padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48.0 : 16.0, vertical: 24.0),
// //           child: Center(
// //             child: Column(
// //               children: [
// //                 Container(
// //                   constraints: const BoxConstraints(maxWidth: 1280),
// //                   child: isDesktop
// //                       ? Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Expanded(flex: 7, child: _buildProductImagery()),
// //                       const SizedBox(width: 48),
// //                       Expanded(flex: 5, child: _buildProductDetailsColumn()),
// //                     ],
// //                   )
// //                       : Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       _buildProductImagery(),
// //                       const SizedBox(height: 24),
// //                       _buildProductDetailsColumn(),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 48),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // MARK: - Component Layouts
// //
// //   Widget _buildProductImagery() {
// //     final images = (_productDetails?['images'] as List?) ?? [];
// //     final mainImage = _productDetails?['main_image'] ?? widget.product.image;
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         AspectRatio(
// //           aspectRatio: 4 / 5,
// //           child: Stack(
// //             children: [
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(12),
// //                 child: Container(
// //                   color: colorSurfaceContainerLow,
// //                   width: double.infinity,
// //                   height: double.infinity,
// //                   child: Image.network(
// //                     mainImage,
// //                     fit: BoxFit.cover,
// //                     errorBuilder: (context, error, stackTrace) =>
// //                     const Center(child: Icon(Icons.image, size: 50)),
// //                   ),
// //                 ),
// //               ),
// //               Positioned(
// //                 top: 16,
// //                 right: 16,
// //                 child: Column(
// //                   children: [
// //                     _buildFloatingActionButton(
// //                       icon: _isWishlisted ? Icons.favorite : Icons.favorite_border,
// //                       iconColor: _isWishlisted ? colorError : colorPrimary,
// //                       onPressed: _onToggleWishlist,
// //                     ),
// //                     const SizedBox(height: 12),
// //                     _buildFloatingActionButton(icon: Icons.share),
// //                     const SizedBox(height: 12),
// //                     _buildFloatingActionButton(icon: Icons.compare_arrows),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         SizedBox(
// //           height: 80,
// //           child: ListView.separated(
// //             scrollDirection: Axis.horizontal,
// //             itemCount: images.isEmpty ? 1 : images.length,
// //             separatorBuilder: (_, __) => const SizedBox(width: 8),
// //             itemBuilder: (context, index) {
// //               final bool isSelected = index == 0;
// //               final imgUrl = images.isEmpty
// //                   ? mainImage
// //                   : (images[index]?['image_url'] ?? mainImage);
// //               return Opacity(
// //                 opacity: isSelected ? 1.0 : 0.6,
// //                 child: Container(
// //                   width: 80,
// //                   height: 80,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: isSelected ? Border.all(color: colorPrimary, width: 2) : null,
// //                   ),
// //                   child: ClipRRect(
// //                     borderRadius: BorderRadius.circular(6),
// //                     child: Image.network(imgUrl, fit: BoxFit.cover),
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         )
// //       ],
// //     );
// //   }
// //
// //   Widget _buildFloatingActionButton(
// //       {required IconData icon, Color iconColor = colorPrimary, VoidCallback? onPressed}) {
// //     return Container(
// //       width: 40,
// //       height: 40,
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.8),
// //         shape: BoxShape.circle,
// //         boxShadow: [
// //           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
// //         ],
// //       ),
// //       child: IconButton(
// //         padding: EdgeInsets.zero,
// //         icon: Icon(icon, color: iconColor, size: 20),
// //         onPressed: onPressed ?? () {},
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProductDetailsColumn() {
// //     final pd = _productDetails?['product_details'] ?? {};
// //     final title = pd['product_title'] ?? widget.product.title;
// //     final price = (_productDetails?['final_price'] ?? widget.product.btcPrice).toString();
// //     final oldPrice = (pd['price'] ?? widget.product.btcOldPrice).toString();
// //     final vendorName = _vendorInfo?['store_name'] ?? widget.product.store;
// //     final avgRating = (_ratingsData?['average_rating'] ?? 4.8).toDouble();
// //     final totalReviews = _ratingsData?['total_reviews'] ?? 128;
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Seller Row
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //           decoration: BoxDecoration(
// //             color: colorSurfaceContainer,
// //             borderRadius: BorderRadius.circular(8),
// //             border: Border.all(color: colorOutlineVariant),
// //           ),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               CircleAvatar(
// //                 radius: 16,
// //                 backgroundColor: colorPrimaryContainer,
// //                 child: const Text('LB',
// //                     style: TextStyle(color: colorOnPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w700)),
// //               ),
// //               const SizedBox(width: 8),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(vendorName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
// //                     Row(
// //                       children: [
// //                         const Icon(Icons.star, color: colorPrimary, size: 12),
// //                         const SizedBox(width: 2),
// //                         Text('$avgRating ($totalReviews reviews)',
// //                             style: const TextStyle(color: colorTertiary, fontSize: 11)),
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               ),
// //               OutlinedButton(
// //                 onPressed: () {},
// //                 style: OutlinedButton.styleFrom(
// //                   foregroundColor: colorPrimary,
// //                   side: const BorderSide(color: colorPrimary),
// //                   shape: const StadiumBorder(),
// //                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //                   minimumSize: Size.zero,
// //                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //                 ),
// //                 child: const Text('FOLLOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.start,
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //               decoration: BoxDecoration(color: colorSecondaryContainer, borderRadius: BorderRadius.circular(100)),
// //               child: const Text('New Arrival',
// //                   style: TextStyle(color: colorOnSecondaryContainer, fontSize: 10, fontWeight: FontWeight.w600)),
// //             ),
// //             const SizedBox(width: 8),
// //             ...List.generate(avgRating.floor().clamp(0, 5),
// //                     (index) => const Icon(Icons.star, color: colorPrimary, size: 14)),
// //             if (avgRating - avgRating.floor() >= 0.5)
// //               const Icon(Icons.star_half, color: colorPrimary, size: 14),
// //             const SizedBox(width: 4),
// //             Text('($totalReviews)', style: const TextStyle(color: colorTertiary, fontSize: 11)),
// //           ],
// //         ),
// //         const SizedBox(height: 6),
// //         Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
// //         const SizedBox(height: 6),
// //
// //         Row(
// //           crossAxisAlignment: CrossAxisAlignment.baseline,
// //           textBaseline: TextBaseline.alphabetic,
// //           mainAxisAlignment: MainAxisAlignment.start,
// //           children: [
// //             Text('₹$price',
// //                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colorPrimary)),
// //             const SizedBox(width: 8),
// //             Text('₹$oldPrice',
// //                 style: const TextStyle(fontSize: 14, color: colorTertiary, decoration: TextDecoration.lineThrough)),
// //           ],
// //         ),
// //         const SizedBox(height: 16),
// //         const Divider(color: Color(0xFFF1F5F9)),
// //         const SizedBox(height: 24),
// //
// //         // Delivery Check Section
// //         const Text('DELIVERY & SERVICES',
// //             style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
// //         const SizedBox(height: 6),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Expanded(
// //               child: SizedBox(
// //                 height: 40,
// //                 child: TextField(
// //                   controller: _pincodeController,
// //                   keyboardType: TextInputType.number,
// //                   style: const TextStyle(fontSize: 13),
// //                   decoration: InputDecoration(
// //                     hintText: 'Enter Pincode',
// //                     prefixIcon: const Icon(Icons.location_on, color: colorTertiary, size: 16),
// //                     filled: true,
// //                     fillColor: colorSurfaceContainerLow,
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(6),
// //                       borderSide: const BorderSide(color: colorOutlineVariant),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(6),
// //                       borderSide: const BorderSide(color: colorPrimary),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //             SizedBox(
// //               height: 40,
// //               child: ElevatedButton(
// //                 onPressed: _onCheckDelivery,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: colorPrimaryContainer,
// //                   foregroundColor: colorOnPrimaryContainer,
// //                   padding: const EdgeInsets.symmetric(horizontal: 16),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
// //                   elevation: 0,
// //                 ),
// //                 child: const Text('Check', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 4),
// //         Text(
// //           _deliveryStatus ?? 'Check availability and estimated delivery date',
// //           style: TextStyle(fontSize: 11, color: _deliveryStatus != null ? colorPrimary : colorTertiary),
// //         ),
// //         const SizedBox(height: 16),
// //
// //         // Color Selection
// //         const Text('COLOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
// //         const SizedBox(height: 6),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.start,
// //           children: [
// //             _buildColorOption(0, const Color(0xFF006565)),
// //             const SizedBox(width: 8),
// //             _buildColorOption(1, const Color(0xFF1C1B1B)),
// //             const SizedBox(width: 8),
// //             _buildColorOption(2, const Color(0xFF595A5B)),
// //           ],
// //         ),
// //         const SizedBox(height: 16),
// //
// //         // Size Selection
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             const Text('SELECT SIZE',
// //                 style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
// //             TextButton(
// //               onPressed: () {},
// //               style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
// //               child: const Text('Size Guide',
// //                   style: TextStyle(color: colorPrimary, fontSize: 12, decoration: TextDecoration.underline)),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 6),
// //         _buildSizeGrid(),
// //         const SizedBox(height: 16),
// //
// //         // Quantity & Actions Row
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               decoration: BoxDecoration(
// //                 border: Border.all(color: colorOutlineVariant),
// //                 borderRadius: BorderRadius.circular(8),
// //                 color: Colors.white,
// //               ),
// //               child: Row(
// //                 children: [
// //                   IconButton(
// //                     padding: EdgeInsets.zero,
// //                     constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
// //                     icon: const Icon(Icons.remove, size: 14),
// //                     onPressed: () {
// //                       if (_quantity > 1) setState(() => _quantity--);
// //                     },
// //                   ),
// //                   Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
// //                   IconButton(
// //                     padding: EdgeInsets.zero,
// //                     constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
// //                     icon: const Icon(Icons.add, size: 14),
// //                     onPressed: () => setState(() => _quantity++),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: ElevatedButton(
// //                 onPressed: _onAddToCart,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: colorPrimary,
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(vertical: 12),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                   elevation: 2,
// //                   shadowColor: colorPrimary.withOpacity(0.2),
// //                 ),
// //                 child: const Text('Add to Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 8),
// //         SizedBox(
// //           width: double.infinity,
// //           child: OutlinedButton(
// //             onPressed: () {
// //               Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
// //             },
// //             style: OutlinedButton.styleFrom(
// //               foregroundColor: colorPrimary,
// //               side: const BorderSide(color: colorPrimary),
// //               padding: const EdgeInsets.symmetric(vertical: 12),
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //             ),
// //             child: const Text('Buy Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //
// //         const Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
// //         const SizedBox(height: 8),
// //         Text(
// //           pd['description'] ?? widget.product.subtitle,
// //           style: const TextStyle(fontSize: 14, color: colorTertiary, height: 1.5),
// //         ),
// //         const SizedBox(height: 16),
// //
// //         // About Seller
// //         Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: colorSurfaceContainerLow,
// //             borderRadius: BorderRadius.circular(8),
// //             border: Border.all(color: colorOutlineVariant),
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text('About Seller', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
// //               const SizedBox(height: 6),
// //               Text(
// //                 _vendorInfo?['bio'] ?? '',
// //                 style: const TextStyle(fontSize: 13, color: colorTertiary),
// //               ),
// //               const SizedBox(height: 12),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Expanded(child: _buildSellerStat('${_vendorInfo?['ratings_percentage'] ?? 98}%', 'Positive Feedback')),
// //                   _buildDividerWidget(),
// //                   Expanded(child: _buildSellerStat('${_vendorInfo?['reviews_count'] ?? 32}', 'Total Sales')),
// //                   _buildDividerWidget(),
// //                   Expanded(child: _buildSellerStat('5yrs', 'On Marketplace')),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //
// //         _buildAccordion(
// //           title: 'Shipping & Returns',
// //           isOpen: _isShippingOpen,
// //           content:
// //           'Free standard shipping on orders over ₹200. Express shipping available. Returns accepted within 30 days of purchase in original condition.',
// //           onToggle: () => setState(() => _isShippingOpen = !_isShippingOpen),
// //         ),
// //         const Divider(color: Color(0xFFF1F5F9)),
// //         _buildAccordion(
// //           title: 'Sustainability Impact',
// //           isOpen: _isSustainabilityOpen,
// //           content:
// //           'Made with 40% recycled nylon. Our thermal lining is Oeko-Tex certified. We offset 100% of carbon emissions from shipping this product.',
// //           onToggle: () => setState(() => _isSustainabilityOpen = !_isSustainabilityOpen),
// //         ),
// //         const SizedBox(height: 24),
// //
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             const Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
// //             ElevatedButton(
// //               onPressed: () => _openReviewModal(context),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: colorPrimary,
// //                 foregroundColor: Colors.white,
// //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                 minimumSize: Size.zero,
// //                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
// //               ),
// //               child: const Text('Write a Review', style: TextStyle(fontSize: 12)),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 24),
// //         _buildReviewSectionSummary(),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildColorOption(int index, Color color) {
// //     final bool isSelected = _selectedColorIndex == index;
// //     return GestureDetector(
// //       onTap: () => setState(() => _selectedColorIndex = index),
// //       child: Container(
// //         width: 30,
// //         height: 30,
// //         padding: const EdgeInsets.all(2),
// //         decoration: BoxDecoration(
// //           shape: BoxShape.circle,
// //           border: Border.all(color: isSelected ? colorPrimary : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
// //           color: Colors.white,
// //         ),
// //         child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSellerStat(String value, String label) {
// //     return Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorPrimary)),
// //         Text(label, style: const TextStyle(fontSize: 10, color: colorTertiary), textAlign: TextAlign.center),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildDividerWidget() => Container(width: 1, height: 32, color: colorOutlineVariant);
// //
// //   Widget _buildAccordion(
// //       {required String title, required bool isOpen, required String content, required VoidCallback onToggle}) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         ListTile(
// //           contentPadding: EdgeInsets.zero,
// //           title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
// //           trailing: AnimatedRotation(
// //             duration: const Duration(milliseconds: 200),
// //             turns: isOpen ? 0.5 : 0.0,
// //             child: const Icon(Icons.expand_more),
// //           ),
// //           onTap: onToggle,
// //         ),
// //         AnimatedCrossFade(
// //           firstChild: const SizedBox.shrink(),
// //           secondChild: Padding(
// //             padding: const EdgeInsets.only(bottom: 16),
// //             child: Text(content, style: const TextStyle(fontSize: 14, color: colorTertiary, height: 1.5)),
// //           ),
// //           crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
// //           duration: const Duration(milliseconds: 200),
// //         )
// //       ],
// //     );
// //   }
// //
// //   Widget _buildReviewSectionSummary() {
// //     final avg = (_ratingsData?['average_rating'] ?? 4.8).toDouble();
// //     final total = _ratingsData?['total_reviews'] ?? 128;
// //     final breakdown = _ratingsData?['ratings_breakdown'] as Map?;
// //
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Expanded(
// //           flex: 4,
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(avg.toStringAsFixed(1),
// //                   style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: colorPrimary)),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: List.generate(5, (index) => const Icon(Icons.star, color: colorPrimary, size: 14)),
// //               ),
// //               const SizedBox(height: 4),
// //               Text('Based on $total reviews',
// //                   style: const TextStyle(fontSize: 12, color: colorTertiary), textAlign: TextAlign.center),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(width: 24),
// //         Expanded(
// //           flex: 8,
// //           child: Column(
// //             children: [
// //               for (int i = 5; i >= 1; i--)
// //                 _buildRatingBar(
// //                   i,
// //                   total > 0 ? ((breakdown?[i]?['count'] ?? 0) / total) : 0.0,
// //                   '${((breakdown?[i]?['percent'] ?? 0)).round()}%',
// //                 ),
// //             ],
// //           ),
// //         )
// //       ],
// //     );
// //   }
// //
// //   Widget _buildRatingBar(int index, double percent, String label) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 2.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Text('$index', style: const TextStyle(fontSize: 14)),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: ClipRRect(
// //               borderRadius: BorderRadius.circular(100),
// //               child: LinearProgressIndicator(
// //                 value: percent.clamp(0.0, 1.0),
// //                 backgroundColor: Colors.grey.shade100,
// //                 color: colorPrimary,
// //                 minHeight: 8,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           SizedBox(width: 32, child: Text(label, style: const TextStyle(fontSize: 14, color: colorTertiary))),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSizeGrid() {
// //     final sizes = ['XS', 'S', 'M', 'L'];
// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       itemCount: 4,
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 4,
// //         mainAxisSpacing: 6,
// //         crossAxisSpacing: 6,
// //         childAspectRatio: 2.2,
// //       ),
// //       itemBuilder: (context, index) {
// //         final isSelected = _selectedSizeIndex == index;
// //         return InkWell(
// //           onTap: () => setState(() => _selectedSizeIndex = index),
// //           child: Container(
// //             alignment: Alignment.center,
// //             decoration: BoxDecoration(
// //               color: isSelected ? colorPrimaryContainer.withOpacity(0.1) : Colors.transparent,
// //               border: Border.all(color: isSelected ? colorPrimary : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
// //               borderRadius: BorderRadius.circular(6),
// //             ),
// //             child: Text(
// //               sizes[index],
// //               style: TextStyle(
// //                 fontSize: 13,
// //                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
// //                 color: isSelected ? colorPrimary : Colors.black,
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   void _openReviewModal(BuildContext context) {
// //     int selectedRating = 0;
// //     final commentController = TextEditingController();
// //
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return StatefulBuilder(
// //           builder: (context, setModalState) {
// //             return AlertDialog(
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //               title: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.w700)),
// //                   const Spacer(),
// //                   IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
// //                 ],
// //               ),
// //               content: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text('Overall Rating',
// //                       style: TextStyle(color: colorTertiary, fontSize: 12, fontWeight: FontWeight.w700)),
// //                   const SizedBox(height: 8),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: List.generate(5, (index) {
// //                       final filled = index < selectedRating;
// //                       return IconButton(
// //                         icon: Icon(filled ? Icons.star : Icons.star_border,
// //                             size: 36, color: filled ? colorPrimary : Colors.grey),
// //                         onPressed: () => setModalState(() => selectedRating = index + 1),
// //                       );
// //                     }),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   const Text('Your Review',
// //                       style: TextStyle(color: colorTertiary, fontSize: 12, fontWeight: FontWeight.w700)),
// //                   const SizedBox(height: 8),
// //                   TextField(
// //                     controller: commentController,
// //                     maxLines: 4,
// //                     decoration: const InputDecoration(
// //                       hintText: 'What did you think of the fit, material, and quality?',
// //                       border: OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   OutlinedButton.icon(
// //                     onPressed: () {},
// //                     icon: const Icon(Icons.add_a_photo),
// //                     label: const Text('Upload Photos'),
// //                     style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
// //                   ),
// //                 ],
// //               ),
// //               actions: [
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     Navigator.of(context).pop();
// //                     _submitReview(selectedRating == 0 ? 5 : selectedRating, commentController.text);
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: colorPrimary,
// //                     foregroundColor: Colors.white,
// //                     minimumSize: const Size(double.infinity, 48),
// //                   ),
// //                   child: const Text('Submit Review'),
// //                 )
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
// // =====================================================================
// // product_detail_connected.dart
// //
// // Drop-in replacement for your ProductDetailPage that is FULLY wired
// // to the shared PHP API actions:
// //   - get_marketplace_item_details
// //   - get_product_images
// //   - get_product_purchase_details
// //   - add_to_cart
// //   - add_to_wishlist
// //   - get_review_rating
// //   - add_review_rating
// //   - is_delivery_services / get_pincode / set_pincode
// //
// // Replace BASE_URL below with your real API endpoint, and replace the
// // ProductModel fields (id, variantId, marketplaceId) with whatever you
// // already use to navigate into this page.
// // =====================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';


// ---------------------------------------------------------------------
// 1. CONFIG
// ---------------------------------------------------------------------

class DetailApiConfig {
  static const String baseurl = "${baseUrl}new_apis/product_detail_API.php";
}

// ---------------------------------------------------------------------
// 2. API SERVICE
// ---------------------------------------------------------------------

class ProductDetailApiService {
  static Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
        Uri.parse(DetailApiConfig.baseurl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 20));

      if (res.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': false, 'message': 'Unexpected response format'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getItemDetails({
    required int marketplaceId,
    required int itemId,
    required int varId,
  }) {
    return _post({
      'action': 'get_marketplace_item_details',
      'marketplace_id': marketplaceId,
      'item_id': itemId,
      'var_id': varId,
    });
  }

  static Future<Map<String, dynamic>> getProductImages({
    required int marketplaceId,
    required int itemId,
    int? varId,
  }) {
    return _post({
      'action': 'get_product_images',
      'marketplace_id': marketplaceId,
      'item_id': itemId,
      if (varId != null) 'var_id': varId,
    });
  }

  static Future<Map<String, dynamic>> getPurchaseDetails({
    required int marketplaceId,
    required int itemId,
    required int varId,
    double discount = 0,
    required Map<String, dynamic> result,
  }) {
    return _post({
      'action': 'get_product_purchase_details',
      'marketplace_id': marketplaceId,
      'item_id': itemId,
      'var_id': varId,
      'discount': discount,
      'result': result,
    });
  }

  static Future<Map<String, dynamic>> addItemToCart({
    required int itemId,
    required int variantId,
    required int marketplaceId,
    int orgSiteId = 0,
    int selectedItemsVendorId = 0,
    String itemType = 'NULL',
    int quantity = 1,
  }) {
    return _post({
      'action': 'add_to_cart',
      'item_id': itemId,
      'variant_id': variantId,
      'marketplace_id': marketplaceId,
      'org_site_id': orgSiteId,
      'selected_items_vendor_id': selectedItemsVendorId,
      'item_type': itemType,
      'qty': quantity,
    });
  }

  static Future<Map<String, dynamic>> addItemToWishlist({
    required int itemId,
    required int variantId,
    required int marketplaceId,
    int orgSiteId = 0,
    int selectedItemsVendorId = 0,
    String itemType = 'NULL',
  }) {
    return _post({
      'action': 'add_to_wishlist',
      'item_id': itemId,
      'variant_id': variantId,
      'marketplace_id': marketplaceId,
      'org_site_id': orgSiteId,
      'selected_items_vendor_id': selectedItemsVendorId,
      'item_type': itemType,
    });
  }

  static Future<Map<String, dynamic>> getReviewRating({
    required int marketplaceId,
    required int productId,
    required int variantId,
    required int productVendorId,
  }) {
    return _post({
      'action': 'get_review_rating',
      'marketplace_id': marketplaceId,
      'product_id': productId,
      'variant_id': variantId,
      'product_vendor_id': productVendorId,
    });
  }

  static Future<Map<String, dynamic>> addReviewRating({
    required int marketplaceId,
    required int productId,
    required int variantId,
    required int productVendorId,
    required int rating,
    required String review,
  }) {
    return _post({
      'action': 'add_review_rating',
      'marketplace_id': marketplaceId,
      'product_id': productId,
      'variant_id': variantId,
      'product_vendor_id': productVendorId,
      'rating': rating,
      'review': review,
    });
  }

  static Future<Map<String, dynamic>> checkDelivery({
    required int logisticId,
    required int pincode,
  }) {
    return _post({
      'action': 'is_delivery_services',
      'logistic_id': logisticId,
      'pincode': pincode,
    });
  }

  static Future<Map<String, dynamic>> setPincode(String pincode) {
    return _post({'action': 'set_pincode', 'pincode': pincode});
  }
}
//
// // ---------------------------------------------------------------------
// // 3. SCREEN — Luxe UI, fully wired to the API service above
// // ---------------------------------------------------------------------
// class ProductModel {
//   final String id;
//   final String title;
//   final String subtitle;
//   final String image;
//   final String store;
//   final double btcPrice;
//   final double btcOldPrice;
//   final String? encryptedVariantId;
//
//   ProductModel({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.image,
//     required this.store,
//     required this.btcPrice,
//     required this.btcOldPrice,
//     this.encryptedVariantId,
//   });
// }
class ProductDetailPage extends StatefulWidget {
  final  product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Theme Colors matching Tailwind config
  static const Color colorPrimary = Color(0xFF006565);
  static const Color colorBackground = Color(0xFFFCF9F8);
  static const Color colorSurfaceContainer = Color(0xFFF0EDED);
  static const Color colorSurfaceContainerLow = Color(0xFFF6F3F2);
  static const Color colorSecondaryContainer = Color(0xFFD4E6E5);
  static const Color colorOnSecondaryContainer = Color(0xFF576867);
  static const Color colorPrimaryContainer = Color(0xFF008080);
  static const Color colorOnPrimaryContainer = Color(0xFFE3FFFE);
  static const Color colorTertiary = Color(0xFF595A5B);
  static const Color colorOutlineVariant = Color(0xFFBDC9C8);
  static const Color colorError = Color(0xFFBA1A1A);
  //biswajit
  // ---- Derived numeric IDs from the shared ProductModel ----
  int get _itemId => int.tryParse(widget.product.id) ?? 0;
  int get _variantId =>
      int.tryParse(widget.product.encryptedVariantId ?? '') ?? 0;
  int get _marketplaceId => 5; // TODO: wire up if you track real marketplace id

  // ---- API data ----
  Map<String, dynamic>? _itemDetails;
  List<dynamic> _images = [];
  Map<String, dynamic>? _purchaseDetails;
  Map<String, dynamic>? _reviewData;

  bool _loadingDetails = true;
  bool _loadingReviews = true;
  String? _loadError;

  // ---- UI states ----
  int _cartCount = 0;
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _addingToCart = false;
  bool _addingToWishlist = false;
  bool _checkingDelivery = false;
  bool _submittingReview = false;
  bool _isShippingOpen = false;
  bool _isSustainabilityOpen = false;
  int _selectedSizeIndex = 1;
  int _selectedColorIndex = 0;

  final TextEditingController _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------
  // DATA LOADING
  // -----------------------------------------------------------------

  Future<void> _loadAll() async {
    setState(() {
      _loadingDetails = true;
      _loadError = null;
    });

    final detailsRes = await ProductDetailApiService.getItemDetails(
      marketplaceId: _marketplaceId,
      itemId: _itemId,
      varId: _variantId,
    );

    if (detailsRes['success'] != true) {
      setState(() {
        _loadingDetails = false;
        _loadError =
            detailsRes['message']?.toString() ?? 'Failed to load product details';
      });
      return;
    }

    final result = Map<String, dynamic>.from(detailsRes['data'] ?? {});

    final imagesRes = await ProductDetailApiService.getProductImages(
      marketplaceId: _marketplaceId,
      itemId: _itemId,
      varId: _variantId,
    );

    final purchaseRes = await ProductDetailApiService.getPurchaseDetails(
      marketplaceId: _marketplaceId,
      itemId: _itemId,
      varId: _variantId,
      discount:
      double.tryParse(result['total_discount_percent']?.toString() ?? '0') ??
          0,
      result: result,
    );

    setState(() {
      _itemDetails = result;
      _images = (imagesRes['data']?['images'] as List?) ?? [];
      _purchaseDetails =
      purchaseRes['success'] == true ? purchaseRes['data'] : null;
      _loadingDetails = false;
    });

    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);

    final res = await ProductDetailApiService.getReviewRating(
      marketplaceId: _marketplaceId,
      productId: _itemId,
      variantId: _variantId,
      productVendorId:
      int.tryParse(_itemDetails?['vendor_id']?.toString() ?? '0') ?? 0,
    );

    setState(() {
      _reviewData = res;
      _loadingReviews = false;
    });
  }

  // -----------------------------------------------------------------
  // ACTIONS
  // -----------------------------------------------------------------

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.redAccent : const Color(0xFF76D6D5),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(message,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF313030),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addToCart() async {
    if (_addingToCart) return;

    setState(() => _addingToCart = true);

    final addToCartParams =
        _purchaseDetails?['purchase_box']?['add_to_cart'] ?? {};

    final res = await ProductDetailApiService.addItemToCart(
      itemId: _itemId,
      variantId: _variantId,
      marketplaceId: _marketplaceId,
      orgSiteId:
      int.tryParse(addToCartParams['org_site_id']?.toString() ?? '0') ?? 0,
      selectedItemsVendorId: int.tryParse(
          addToCartParams['selected_items_vendor_id']?.toString() ?? '0') ??
          0,
      quantity: _quantity,
    );

    setState(() => _addingToCart = false);

    if (res['success'] == true) {
      final link = res['data']?['final_link']?.toString() ?? '';
      if (link.isNotEmpty) {
        _showToast('Redirecting to seller site...');
        // TODO: launch `link` with url_launcher if redirection_allowed.
      } else {
        setState(() => _cartCount += _quantity);
        _showToast(res['message']?.toString() ?? 'Item added to cart');
      }
    } else {
      _showToast(res['message']?.toString() ?? 'Failed to add to cart',
          isError: true);
    }
  }

  Future<void> _toggleWishlist() async {
    if (_addingToWishlist) return;

    setState(() => _addingToWishlist = true);

    final wishlistParams = _purchaseDetails?['purchase_box']?['wishlist'] ?? {};

    final res = await ProductDetailApiService.addItemToWishlist(
      itemId: _itemId,
      variantId: _variantId,
      marketplaceId: _marketplaceId,
      orgSiteId:
      int.tryParse(wishlistParams['org_site_id']?.toString() ?? '0') ?? 0,
      selectedItemsVendorId: int.tryParse(
          wishlistParams['selected_items_vendor_id']?.toString() ?? '0') ??
          0,
    );

    setState(() => _addingToWishlist = false);

    if (res['success'] == true) {
      setState(() => _isWishlisted = !_isWishlisted);
      _showToast(res['message']?.toString() ?? 'Wishlist updated');
    } else {
      _showToast(res['message']?.toString() ?? 'Failed to update wishlist',
          isError: true);
    }
  }

  Future<void> _submitReview(int rating, String text) async {
    if (rating <= 0 || text.trim().isEmpty) {
      _showToast('Please add a rating and a review', isError: true);
      return;
    }

    setState(() => _submittingReview = true);

    final res = await ProductDetailApiService.addReviewRating(
      marketplaceId: _marketplaceId,
      productId: _itemId,
      variantId: _variantId,
      productVendorId:
      int.tryParse(_itemDetails?['vendor_id']?.toString() ?? '0') ?? 0,
      rating: rating,
      review: text,
    );

    setState(() => _submittingReview = false);

    if (res['status'] == 'success' || res['success'] == true) {
      _showToast('Review submitted successfully!');
      _loadReviews();
    } else {
      _showToast('Failed to submit review', isError: true);
    }
  }

  Future<void> _checkDeliveryAt(String pincode) async {
    final pc = int.tryParse(pincode);
    if (pc == null || pincode.length != 6) {
      _showToast('Enter a valid 6-digit pincode', isError: true);
      return;
    }

    setState(() => _checkingDelivery = true);

    final logisticId =
        int.tryParse(_itemDetails?['logistic_id']?.toString() ?? '0') ?? 0;

    final res = await ProductDetailApiService.checkDelivery(
      logisticId: logisticId,
      pincode: pc,
    );

    final available = res['data']?['available'] == true;

    await ProductDetailApiService.setPincode(pincode);

    setState(() => _checkingDelivery = false);

    _showToast(available
        ? 'Delivery available for $pincode'
        : 'Delivery not available for $pincode');
  }

  // -----------------------------------------------------------------
  // DERIVED DISPLAY VALUES
  // -----------------------------------------------------------------

  String get _title =>
      (_itemDetails?['product_title'] ??
          _itemDetails?['service_name'] ??
          _itemDetails?['title'] ??
          widget.product.title)
          .toString();

  double get _price =>
      double.tryParse(_itemDetails?['price']?.toString() ?? '0') ?? 0;

  double get _discountPercent =>
      double.tryParse(
          _itemDetails?['total_discount_percent']?.toString() ?? '0') ??
          0;

  double get _finalPrice => _price - (_price * _discountPercent / 100);

  String get _mainImage => _images.isNotEmpty
      ? (_images.first['image_url']?.toString() ?? widget.product.image)
      : widget.product.image;

  String get _vendorName =>
      _itemDetails?['vendor_name']?.toString() ?? widget.product.store;

  double get _avgRating =>
      double.tryParse(_reviewData?['avg_rating']?.toString() ?? '0') ?? 0;

  int get _totalReviews =>
      int.tryParse(_reviewData?['total_reviews']?.toString() ?? '0') ?? 0;

  List<dynamic> get _reviews => (_reviewData?['reviews'] as List?) ?? [];

  int _ratingCount(int star) =>
      int.tryParse(_reviewData?['c$star']?.toString() ?? '0') ?? 0;

  // -----------------------------------------------------------------
  // BUILD
  // -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    print(widget.product.id.trim());
    print(widget.product.encryptedVariantId);
    if (widget.product.id.trim().isEmpty &&
        (widget.product.encryptedVariantId?.isEmpty ?? true)) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Product Not Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    if (_loadingDetails) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: colorPrimary)),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 768;

    return Scaffold(
      backgroundColor: colorBackground,
      // appBar: const LuxeHeader(),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.0 : 16.0,
            vertical: 24.0,
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: isDesktop
                      ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _buildProductImagery()),
                      const SizedBox(width: 48),
                      Expanded(
                          flex: 5, child: _buildProductDetailsColumn()),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImagery(),
                      const SizedBox(height: 24),
                      _buildProductDetailsColumn(),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Component Layouts

  Widget _buildProductImagery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: colorSurfaceContainerLow,
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    _mainImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.image, size: 50)),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    _addingToWishlist
                        ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : _buildFloatingActionButton(
                      icon: _isWishlisted
                          ? Icons.favorite
                          : Icons.favorite_border,
                      iconColor: _isWishlisted ? colorError : colorPrimary,
                      onPressed: _toggleWishlist,
                    ),
                    const SizedBox(height: 12),
                    _buildFloatingActionButton(icon: Icons.share),
                    const SizedBox(height: 12),
                    _buildFloatingActionButton(icon: Icons.compare_arrows),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final url = _images[index]['image_url']?.toString() ?? '';
                final bool isSelected = index == 0;
                return Opacity(
                  opacity: isSelected ? 1.0 : 0.6,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: colorPrimary, width: 2)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton(
      {required IconData icon,
        Color iconColor = colorPrimary,
        VoidCallback? onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildProductDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seller Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorSurfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorOutlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorPrimaryContainer,
                child: Text(
                  _vendorName.isNotEmpty
                      ? _vendorName.substring(0, _vendorName.length >= 2 ? 2 : 1).toUpperCase()
                      : 'LB',
                  style: const TextStyle(
                      color: colorOnPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_vendorName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: colorPrimary, size: 12),
                        const SizedBox(width: 2),
                        Text('${_avgRating.toStringAsFixed(1)} ($_totalReviews reviews)',
                            style:
                            const TextStyle(color: colorTertiary, fontSize: 11)),
                      ],
                    )
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorPrimary,
                  side: const BorderSide(color: colorPrimary),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('FOLLOW',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          _title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4),
        ),
        const SizedBox(height: 6),

        // Pricing Info
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('₹${_finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: colorPrimary)),
            if (_discountPercent > 0) ...[
              const SizedBox(width: 8),
              Text('₹${_price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14,
                      color: colorTertiary,
                      decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 8),
              Text('${_discountPercent.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(color: colorError, fontSize: 13)),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFF1F5F9)),
        const SizedBox(height: 24),

        // Delivery Check Section
        const Text('DELIVERY & SERVICES',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter Pincode',
                    prefixIcon:
                    const Icon(Icons.location_on, color: colorTertiary, size: 16),
                    filled: true,
                    fillColor: colorSurfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: colorOutlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: colorPrimary),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _checkingDelivery
                    ? null
                    : () => _checkDeliveryAt(_pincodeController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimaryContainer,
                  foregroundColor: colorOnPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: _checkingDelivery
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Check',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Check availability and estimated delivery date',
            style: TextStyle(fontSize: 11, color: colorTertiary)),
        const SizedBox(height: 16),

        // Color Selection (kept as static variant UI; wire to real variant data if available)
        const Text('COLOR',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildColorOption(0, const Color(0xFF006565)),
            const SizedBox(width: 8),
            _buildColorOption(1, const Color(0xFF1C1B1B)),
            const SizedBox(width: 8),
            _buildColorOption(2, const Color(0xFF595A5B)),
          ],
        ),
        const SizedBox(height: 16),

        // Size Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SELECT SIZE',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Size Guide',
                  style: TextStyle(
                      color: colorPrimary,
                      fontSize: 12,
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildSizeGrid(),
        const SizedBox(height: 16),

        // Quantity & Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorOutlineVariant),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.remove, size: 14),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text('$_quantity',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.add, size: 14),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _addingToCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                  shadowColor: colorPrimary.withOpacity(0.2),
                ),
                child: _addingToCart
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text('Add to Cart',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // SizedBox(
        //   width: double.infinity,
        //   child: OutlinedButton(
        //     onPressed: () async {
        //       final hasAccess = await LoginGuard.checkAndPrompt(
        //         context,
        //         message: 'Please sign in to continue to checkout.',
        //       );
        //       if (!hasAccess) return;
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => const CheckoutScreen()),
        //       );
        //     },
        //     style: OutlinedButton.styleFrom(
        //       foregroundColor: colorPrimary,
        //       side: const BorderSide(color: colorPrimary),
        //       padding: const EdgeInsets.symmetric(vertical: 12),
        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        //     ),
        //     child: const Text('Buy Now',
        //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        //   ),
        // ),
        const SizedBox(height: 16),

        // Description Section
        const Text('Product Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          (_itemDetails?['description']?.toString().isNotEmpty == true)
              ? _itemDetails!['description'].toString()
              : widget.product.subtitle,
          style: const TextStyle(fontSize: 14, color: colorTertiary, height: 1.5),
        ),
        const SizedBox(height: 16),

        // Accordion Widgets
        _buildAccordion(
          title: 'Shipping & Returns',
          isOpen: _isShippingOpen,
          content:
          'Free standard shipping on orders over ₹200. Express shipping available. Returns accepted within 30 days of purchase in original condition.',
          onToggle: () => setState(() => _isShippingOpen = !_isShippingOpen),
        ),
        const Divider(color: Color(0xFFF1F5F9)),
        _buildAccordion(
          title: 'Sustainability Impact',
          isOpen: _isSustainabilityOpen,
          content:
          'Made with recycled materials where possible. We aim to offset carbon emissions from shipping this product.',
          onToggle: () =>
              setState(() => _isSustainabilityOpen = !_isSustainabilityOpen),
        ),
        const SizedBox(height: 24),

        // Reviews Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ElevatedButton(
              onPressed: () => _openReviewModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Write a Review', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildReviewSectionSummary(),
        const SizedBox(height: 12),
        _buildReviewList(),
      ],
    );
  }

  Widget _buildColorOption(int index, Color color) {
    final bool isSelected = _selectedColorIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        width: 30,
        height: 30,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isSelected ? colorPrimary : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1),
          color: Colors.white,
        ),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }

  Widget _buildAccordion(
      {required String title,
        required bool isOpen,
        required String content,
        required VoidCallback onToggle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: isOpen ? 0.5 : 0.0,
            child: const Icon(Icons.expand_more),
          ),
          onTap: onToggle,
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(content,
                style: const TextStyle(fontSize: 14, color: colorTertiary, height: 1.5)),
          ),
          crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        )
      ],
    );
  }

  Widget _buildReviewSectionSummary() {
    if (_loadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    final int c5 = _ratingCount(5);
    final int c4 = _ratingCount(4);
    final int c3 = _ratingCount(3);
    final int c2 = _ratingCount(2);
    final int c1 = _ratingCount(1);
    final int total = _totalReviews > 0 ? _totalReviews : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w700, color: colorPrimary)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5, (index) => const Icon(Icons.star, color: colorPrimary, size: 14)),
              ),
              const SizedBox(height: 4),
              Text('Based on $_totalReviews reviews',
                  style: const TextStyle(fontSize: 12, color: colorTertiary),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 8,
          child: Column(
            children: [
              _buildRatingBar(5, c5 / total, c5),
              _buildRatingBar(4, c4 / total, c4),
              _buildRatingBar(3, c3 / total, c3),
              _buildRatingBar(2, c2 / total, c2),
              _buildRatingBar(1, c1 / total, c1),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRatingBar(int index, double percent, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$index', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: percent.clamp(0, 1),
                backgroundColor: Colors.grey.shade100,
                color: colorPrimary,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
              width: 32,
              child: Text('$count',
                  style: const TextStyle(fontSize: 14, color: colorTertiary))),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    if (_loadingReviews) return const SizedBox.shrink();
    if (_reviews.isEmpty) {
      return const Text('No reviews yet.', style: TextStyle(color: colorTertiary));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _reviews.take(5).map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorSecondaryContainer,
                backgroundImage: (r['profile_pic'] != null && r['profile_pic'].toString().isNotEmpty)
                    ? NetworkImage(r['profile_pic'].toString())
                    : null,
                child: (r['profile_pic'] == null || r['profile_pic'].toString().isEmpty)
                    ? const Icon(Icons.person, size: 16, color: colorOnSecondaryContainer)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r['name']?.toString() ?? 'Anonymous',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 6),
                        Row(
                          children: List.generate(
                            5,
                                (i) => Icon(
                              i < (int.tryParse(r['rating']?.toString() ?? '0') ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: colorPrimary,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(r['review']?.toString() ?? '',
                        style: const TextStyle(color: colorTertiary, fontSize: 13)),
                    if (r['date'] != null)
                      Text(r['date'].toString(),
                          style: const TextStyle(color: colorTertiary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeGrid() {
    final sizes = ['XS', 'S', 'M', 'L'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final isSelected = _selectedSizeIndex == index;
        return InkWell(
          onTap: () => setState(() => _selectedSizeIndex = index),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? colorPrimaryContainer.withOpacity(0.1) : Colors.transparent,
              border: Border.all(
                  color: isSelected ? colorPrimary : Colors.grey.shade200,
                  width: isSelected ? 1.5 : 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              sizes[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? colorPrimary : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  void _openReviewModal(BuildContext context) {
    int rating = 0;
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Rating',
                    style: TextStyle(color: colorTertiary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 36,
                        color: i < rating ? colorPrimary : Colors.grey,
                      ),
                      onPressed: () => setDialogState(() => rating = i + 1),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Your Review',
                    style: TextStyle(color: colorTertiary, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'What did you think of the fit, material, and quality?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: _submittingReview
                    ? null
                    : () {
                  Navigator.of(context).pop();
                  _submitReview(rating, textController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Submit Review'),
              )
            ],
          );
        });
      },
    );
  }
}