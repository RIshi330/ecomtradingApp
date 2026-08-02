// import 'package:flutter/material.dart';
//
// class OffersScreen extends StatefulWidget {
//   const OffersScreen({super.key});
//
//   @override
//   State<OffersScreen> createState() => _OffersScreenState();
// }
//
// class _OffersScreenState extends State<OffersScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentNavIndex = 2; // Offers tab selected
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFCF9F8).withOpacity(0.8),
//         elevation: 0.5,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
//           onPressed: () {
//             Navigator.maybePop(context);
//           },
//         ),
//         title: const Text(
//           'Offers',
//           style: TextStyle(
//             color: Color(0xFF006565),
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: Color(0xFF006565)),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Sticky Tabs Header
//           Container(
//             color: const Color(0xFFFCF9F8),
//             child: TabBar(
//               controller: _tabController,
//               indicatorColor: const Color(0xFF006565),
//               indicatorWeight: 3,
//               indicatorSize: TabBarIndicatorSize.tab,
//               labelColor: const Color(0xFF006565),
//               unselectedLabelColor: const Color(0xFF3E4949),
//               labelStyle: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.2,
//                 fontFamily: 'Inter',
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 letterSpacing: 1.2,
//                 fontFamily: 'Inter',
//               ),
//               tabs: const [
//                 Tab(text: 'AVAILABLE'),
//                 Tab(text: 'USED/EXPIRED'),
//               ],
//             ),
//           ),
//           const Divider(height: 1, color: Color(0xFFE5E2E1)),
//
//           // Tab Body Content
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: const [
//                 AvailableCouponsTab(),
//                 ExpiredCouponsTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//
//       // Bottom Navigation Bar
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// // TAB 1: AVAILABLE COUPONS
// // -----------------------------------------------------------------------------
//
// class AvailableCouponsTab extends StatelessWidget {
//   const AvailableCouponsTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: const [
//           // Featured Promo Banner
//           FeaturedPromoBanner(),
//           SizedBox(height: 24),
//
//           // Coupon Cards List
//           ActiveCouponCard(
//             discount: '20%',
//             unit: 'OFF',
//             title: 'New Member Special',
//             subtitle: 'Valid on all items above \$50',
//             code: 'WELCOME20',
//             expiry: 'Expires: 24 Oct 2024',
//           ),
//           SizedBox(height: 16),
//           ActiveCouponCard(
//             discount: '\$15',
//             unit: 'CASHBACK',
//             title: 'Tech Category Bonus',
//             subtitle: 'On select electronics & accessories',
//             code: 'TECHSAVE',
//             expiry: 'Expires: 30 Oct 2024',
//           ),
//           SizedBox(height: 16),
//           ActiveCouponCard(
//             discount: 'FREE',
//             unit: 'SHIPPING',
//             title: 'No Delivery Fees',
//             subtitle: 'Available for standard shipping',
//             code: 'FREESHIP',
//             expiry: 'Expires: 15 Nov 2024',
//           ),
//           SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// // TAB 2: EXPIRED / USED COUPONS
// // -----------------------------------------------------------------------------
//
// class ExpiredCouponsTab extends StatelessWidget {
//   const ExpiredCouponsTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Opacity(
//         opacity: 0.65,
//         child: Column(
//           children: const [
//             ExpiredCouponCard(
//               discount: '10%',
//               unit: 'OFF',
//               title: 'Summer Flash Sale',
//               subtitle: 'Expired on 31 Aug 2024',
//               code: 'SUMMER10',
//               statusTag: 'EXPIRED',
//               statusColor: Color(0xFFBA1A1A),
//             ),
//             SizedBox(height: 16),
//             ExpiredCouponCard(
//               discount: '\$5',
//               unit: 'CREDIT',
//               title: 'Referral Bonus',
//               subtitle: 'Used on 12 Sep 2024',
//               code: 'REF5-XXXX',
//               statusTag: 'USED',
//               statusColor: Color(0xFF006565),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// // FEATURED PROMO BANNER
// // -----------------------------------------------------------------------------
//
// class FeaturedPromoBanner extends StatelessWidget {
//   const FeaturedPromoBanner({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 192,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         image: const DecorationImage(
//           image: NetworkImage(
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuDGx5YyLfJ52ZU7if2jbeiGyPhk-NnftSOLeEJM1ZRau77aOHPeVll17AQE0nxo99ACpIKPMUbHl5_2lVEpaSOPkGmK47OmyveUYTpGw4DP48UnogDBDBahnUqZiO89_LrLmn_no5LI0GINm5bxz2YQ3ngcnS6pNhDQ0d_K6aHXT6xoIHsxMBMAvkd8XeocSXoAc_3HwKxUNhVOOlfAkFJp2-RmMc9WC1KVU8SxDIKP0hBWfZm3zKykhH_KEQRTkvCZ9MboWttfUXs',
//           ),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             colors: [
//               const Color(0xFF008080).withOpacity(0.9),
//               const Color(0xFF006565).withOpacity(0.4),
//             ],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//         ),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFD4E6E5),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: const Text(
//                 'LIMITED TIME',
//                 style: TextStyle(
//                   color: Color(0xFF0E1E1E),
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Seasonal Sale',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               'Up to 40% OFF on premium essentials.',
//               style: TextStyle(
//                 color: Color(0xFFE3FFFE),
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// // ACTIVE COUPON CARD (CUSTOM TICKET CUTOUT CLIPPER)
// // -----------------------------------------------------------------------------
//
// class ActiveCouponCard extends StatefulWidget {
//   final String discount;
//   final String unit;
//   final String title;
//   final String subtitle;
//   final String code;
//   final String expiry;
//
//   const ActiveCouponCard({
//     super.key,
//     required this.discount,
//     required this.unit,
//     required this.title,
//     required this.subtitle,
//     required this.code,
//     required this.expiry,
//   });
//
//   @override
//   State<ActiveCouponCard> createState() => _ActiveCouponCardState();
// }
//
// class _ActiveCouponCardState extends State<ActiveCouponCard> {
//   bool _isApplied = false;
//
//   void _toggleApply() {
//     setState(() {
//       _isApplied = !_isApplied;
//     });
//
//     if (_isApplied) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Coupon ${widget.code} applied!'),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           setState(() {
//             _isApplied = false;
//           });
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: CouponTicketClipper(),
//       child: Container(
//         height: 140,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFEAE7E7)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             )
//           ],
//         ),
//         child: Row(
//           children: [
//             // Left Banner (1/3)
//             Container(
//               width: 105,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFD4E6E5).withOpacity(0.3),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     widget.discount,
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF006565),
//                     ),
//                   ),
//                   Text(
//                     widget.unit,
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF006565),
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Dashed Divider Line
//             CustomPaint(
//               size: const Size(1, double.infinity),
//               painter: DashedLinePainter(),
//             ),
//
//             // Right Details (2/3)
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.title,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1C1B1B),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           widget.subtitle,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Color(0xFF3E4949),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF6F3F2),
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: const Color(0xFFBDC9C8),
//                               style: BorderStyle.solid,
//                             ),
//                           ),
//                           child: Text(
//                             widget.code,
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF516161),
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                         ),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _isApplied
//                                 ? const Color(0xFF008080)
//                                 : const Color(0xFF006565),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             elevation: 0,
//                           ),
//                           onPressed: _toggleApply,
//                           child: Text(
//                             _isApplied ? 'Applied!' : 'Apply',
//                             style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Icon(Icons.schedule,
//                             size: 12, color: Color(0xFF6E7979)),
//                         const SizedBox(width: 4),
//                         Text(
//                           widget.expiry,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             color: Color(0xFF6E7979),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// // EXPIRED COUPON CARD
// // -----------------------------------------------------------------------------
//
// class ExpiredCouponCard extends StatelessWidget {
//   final String discount;
//   final String unit;
//   final String title;
//   final String subtitle;
//   final String code;
//   final String statusTag;
//   final Color statusColor;
//
//   const ExpiredCouponCard({
//     super.key,
//     required this.discount,
//     required this.unit,
//     required this.title,
//     required this.subtitle,
//     required this.code,
//     required this.statusTag,
//     required this.statusColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: CouponTicketClipper(),
//       child: Container(
//         height: 130,
//         decoration: BoxDecoration(
//           color: const Color(0xFFF6F3F2),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFE5E2E1)),
//         ),
//         child: Row(
//           children: [
//             // Left Banner (1/3)
//             Container(
//               width: 105,
//               color: const Color(0xFFE5E2E1),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     discount,
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF595A5B),
//                     ),
//                   ),
//                   Text(
//                     unit,
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF595A5B),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Dashed Divider Line
//             CustomPaint(
//               size: const Size(1, double.infinity),
//               painter: DashedLinePainter(),
//             ),
//
//             // Right Details
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF595A5B),
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           subtitle,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Color(0xFF3E4949),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFE5E2E1),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             code,
//                             style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF595A5B),
//                             ),
//                           ),
//                         ),
//                         Text(
//                           statusTag,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                             color: statusColor,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // -----------------------------------------------------------------------------
// // TICKET SIDE NOTCHES CLIPPER
// // -----------------------------------------------------------------------------
//
// class CouponTicketClipper {
//   @override
//   Path getClip(Size size) {
//     const double radius = 12.0;
//     final path = Path();
//
//     path.lineTo(0, size.height / 2 - radius);
//     path.arcToPoint(
//       Offset(0, size.height / 2 + radius),
//       radius: const Radius.circular(radius),
//       clockwise: true,
//     );
//     path.lineTo(0, size.height);
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, size.height / 2 + radius);
//     path.arcToPoint(
//       Offset(size.width, size.height / 2 - radius),
//       radius: const Radius.circular(radius),
//       clockwise: true,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(oldClipper) => false;
// }
//
// // -----------------------------------------------------------------------------
// // DASHED VERTICAL LINE PAINTER
// // -----------------------------------------------------------------------------
//
// class DashedLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     double dashHeight = 4, dashSpace = 4, startY = 0;
//     final paint = Paint();
//     var color = const Color(0xFFBDC9C8);
//     var strokeWidth = 1;
//
//     while (startY < size.height) {
//       canvas.drawLine(
//         Offset(0, startY),
//         Offset(0, startY + dashHeight),
//         paint,
//       );
//       startY += dashHeight + dashSpace;
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }