// // import 'package:flutter/material.dart';
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // Stub widgets – remove these if you already have them in your project
// // // ─────────────────────────────────────────────────────────────────────────────
// // class LuxeHeaderp extends StatelessWidget implements PreferredSizeWidget {
// //   const LuxeHeaderp({super.key});
// //   @override
// //   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// //   @override
// //   Widget build(BuildContext context) => AppBar(
// //     title: const Text('Luxe Marketplace',
// //         style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
// //     backgroundColor: Colors.white,
// //     foregroundColor: const Color(0xFF0F766E),
// //     elevation: 0,
// //     centerTitle: true,
// //   );
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // Main page
// // // ─────────────────────────────────────────────────────────────────────────────
// // class BtbProductDetailPage extends StatefulWidget {
// //   final Map<String, dynamic>? productData;
// //   const BtbProductDetailPage({super.key, this.productData});
// //
// //   @override
// //   State<BtbProductDetailPage> createState() => _BtbProductDetailPageState();
// // }
// //
// // class _BtbProductDetailPageState extends State<BtbProductDetailPage> {
// //   // ── constants ──────────────────────────────────────────────────────────────
// //   static const _teal = Color(0xFF0F766E);
// //   static const _tealLight = Color(0xFFEEFCFB);
// //   static const _border = Color(0xFFDCEBEA);
// //   static const _textMuted = Color(0xFF64748B);
// //   static const _textPrimary = Color(0xFF111827);
// //   static const _bgSurface = Color(0xFFF8FBFB);
// //
// //   // ── image gallery ──────────────────────────────────────────────────────────
// //   final List<String> _images = [
// //     'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=1200',
// //     'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200',
// //     'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=1200',
// //   ];
// //   int _currentImageIdx = 0;
// //
// //   // ── price slabs ────────────────────────────────────────────────────────────
// //   final List<Map<String, dynamic>> _slabs = [
// //     {'label': '100 – 499 Units', 'min': 100, 'max': 499, 'price': 399, 'desc': 'Standard Bulk Order'},
// //     {'label': '500 – 999 Units', 'min': 500, 'max': 999, 'price': 349, 'desc': 'Distributor Pricing'},
// //     {'label': '1000+ Units', 'min': 1000, 'max': 9999999, 'price': 299, 'desc': 'Factory Pricing'},
// //   ];
// //   int _selectedSlabIdx = 0;
// //   int _quantity = 100;
// //   final TextEditingController _qtyCtrl = TextEditingController(text: '100');
// //
// //   // ── delivery ───────────────────────────────────────────────────────────────
// //   final TextEditingController _pincodeCtrl = TextEditingController();
// //   String _deliveryMsg = '';
// //
// //   // ── lifecycle ──────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     _qtyCtrl.addListener(() {
// //       final q = int.tryParse(_qtyCtrl.text) ?? 0;
// //       if (q != _quantity) setState(() { _quantity = q; _syncSlab(); });
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _qtyCtrl.dispose();
// //     _pincodeCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   // ── helpers ────────────────────────────────────────────────────────────────
// //   void _syncSlab() {
// //     for (int i = 0; i < _slabs.length; i++) {
// //       if (_quantity >= (_slabs[i]['min'] as int) &&
// //           _quantity <= (_slabs[i]['max'] as int)) {
// //         _selectedSlabIdx = i;
// //         break;
// //       }
// //     }
// //   }
// //
// //   void _increment() => setState(() {
// //     _quantity++;
// //     _qtyCtrl.text = _quantity.toString();
// //     _syncSlab();
// //   });
// //
// //   void _decrement() {
// //     if (_quantity > 100) {
// //       setState(() {
// //         _quantity--;
// //         _qtyCtrl.text = _quantity.toString();
// //         _syncSlab();
// //       });
// //     }
// //   }
// //
// //   void _selectSlab(int idx) => setState(() {
// //     _selectedSlabIdx = idx;
// //     _quantity = _slabs[idx]['min'] as int;
// //     _qtyCtrl.text = _quantity.toString();
// //   });
// //
// //   int get _unitPrice => _slabs[_selectedSlabIdx]['price'] as int;
// //   int get _totalPrice => _quantity * _unitPrice;
// //
// //   void _checkDelivery() {
// //     final code = _pincodeCtrl.text.trim();
// //     setState(() {
// //       _deliveryMsg = code.length < 5
// //           ? 'Please enter a valid postal code.'
// //           : '✓ Delivery available. Estimated lead time: 7 days.';
// //     });
// //   }
// //
// //   // ── build ──────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4FBFB),
// //       appBar: const LuxeHeaderp(),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.fromLTRB(14, 14, 14, 60),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             _GalleryCard(images: _images, currentIdx: _currentImageIdx,
// //                 onTap: (i) => setState(() => _currentImageIdx = i)),
// //             const SizedBox(height: 14),
// //             _buildPricingCard(),
// //             const SizedBox(height: 14),
// //             _buildPurchaseBox(),
// //             _buildSampleBox(),
// //             _buildDeliveryCard(),
// //             _buildDescriptionCard(),
// //             _buildSpecsCard(),
// //             _buildReviewsCard(),
// //             const SizedBox(height: 24),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Pricing card ───────────────────────────────────────────────────────────
// //   Widget _buildPricingCard() {
// //     return _Card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Badges
// //           Wrap(spacing: 6, runSpacing: 6, children: const [
// //             _Badge('OEM'), _Badge('PRIVATE LABEL'),
// //             _Badge('MOQ 100'), _Badge('SAMPLE AVAILABLE'),
// //           ]),
// //           const SizedBox(height: 14),
// //           // Title
// //           Text(
// //             widget.productData?['title'] ?? 'Premium Wireless Bluetooth Earbuds',
// //             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textPrimary, height: 1.3),
// //           ),
// //           const SizedBox(height: 6),
// //           const Text(
// //             'High quality wholesale product for distributors and ecommerce resellers.',
// //             style: TextStyle(fontSize: 12, color: _textMuted, height: 1.6),
// //           ),
// //           const SizedBox(height: 16),
// //           // Seller
// //           _SellerTile(),
// //           const SizedBox(height: 18),
// //           // Slabs heading
// //           const Text('Wholesale price slabs',
// //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
// //           const SizedBox(height: 10),
// //           // Slab rows
// //           ...List.generate(_slabs.length, (i) => _SlabRow(
// //             slab: _slabs[i],
// //             isSelected: _selectedSlabIdx == i,
// //             onTap: () => _selectSlab(i),
// //           )),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Purchase box ───────────────────────────────────────────────────────────
// //   Widget _buildPurchaseBox() {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 14),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: _tealLight,
// //         borderRadius: BorderRadius.circular(22),
// //         border: Border.all(color: const Color(0xFFBCE9E2)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text('Purchase quantity',
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
// //           const SizedBox(height: 4),
// //           const Text('Select quantity — slab pricing updates automatically',
// //               style: TextStyle(fontSize: 11, color: _textMuted)),
// //           const SizedBox(height: 14),
// //           // Quantity stepper
// //           Row(children: [
// //             _QtyCtrl(ctrl: _qtyCtrl, onDecrement: _decrement, onIncrement: _increment),
// //             const SizedBox(width: 10),
// //             const Text('units', style: TextStyle(fontSize: 12, color: _textMuted)),
// //           ]),
// //           const SizedBox(height: 14),
// //           // Summary row
// //           Row(children: [
// //             Expanded(child: _SummaryItem(label: 'Selected slab', value: _slabs[_selectedSlabIdx]['label'] as String)),
// //             const SizedBox(width: 10),
// //             Expanded(child: _SummaryItem(label: 'Price per unit', value: '₹$_unitPrice', valueColor: _teal)),
// //           ]),
// //           const SizedBox(height: 12),
// //           // Total
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF0FDFA),
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: const Color(0xFF99F6E4)),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('Order total',
// //                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _teal)),
// //                 Text('₹$_totalPrice',
// //                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _teal)),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           // Buttons
// //           Row(children: [
// //             Expanded(child: _OutlineBtn(label: 'Add to cart', onPressed: () {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(content: Text('Added to wholesale cart!'), backgroundColor: _teal));
// //             })),
// //             const SizedBox(width: 10),
// //             Expanded(child: _FillBtn(label: 'Buy now', onPressed: () {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                   const SnackBar(content: Text('Proceeding to bulk checkout…'), backgroundColor: _teal));
// //             })),
// //           ]),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Sample box ─────────────────────────────────────────────────────────────
// //   Widget _buildSampleBox() {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 14),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: _bgSurface,
// //         borderRadius: BorderRadius.circular(18),
// //         border: Border.all(color: _border),
// //       ),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// //                   decoration: BoxDecoration(
// //                       color: _teal, borderRadius: BorderRadius.circular(6)),
// //                   child: const Text('Sample available',
// //                       style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Text('Buy product sample',
// //                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
// //                 const SizedBox(height: 4),
// //                 const Text('Sample price ₹199 · Max qty 2',
// //                     style: TextStyle(fontSize: 11, color: _textMuted)),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(width: 16),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               const Text('₹199',
// //                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _teal)),
// //               const SizedBox(height: 8),
// //               ElevatedButton(
// //                 onPressed: () {},
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: _teal,
// //                   elevation: 0,
// //                   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                 ),
// //                 child: const Text('Buy sample',
// //                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Delivery card ──────────────────────────────────────────────────────────
// //   Widget _buildDeliveryCard() {
// //     return _Card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text('Check delivery location',
// //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
// //           const SizedBox(height: 10),
// //           Row(children: [
// //             Expanded(
// //               child: SizedBox(
// //                 height: 42,
// //                 child: TextField(
// //                   controller: _pincodeCtrl,
// //                   keyboardType: TextInputType.number,
// //                   style: const TextStyle(fontSize: 13),
// //                   decoration: InputDecoration(
// //                     hintText: 'Enter postal / zip code',
// //                     hintStyle: const TextStyle(fontSize: 12, color: _textMuted),
// //                     contentPadding: const EdgeInsets.symmetric(horizontal: 14),
// //                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(width: 10),
// //             SizedBox(
// //               height: 42,
// //               child: ElevatedButton(
// //                 onPressed: _checkDelivery,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: _teal, elevation: 0,
// //                   padding: const EdgeInsets.symmetric(horizontal: 18),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //                 ),
// //                 child: const Text('Check',
// //                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
// //               ),
// //             ),
// //           ]),
// //           if (_deliveryMsg.isNotEmpty) ...[
// //             const SizedBox(height: 10),
// //             Text(_deliveryMsg,
// //                 style: TextStyle(
// //                   fontSize: 12, fontWeight: FontWeight.w700,
// //                   color: _deliveryMsg.startsWith('✓') ? _teal : Colors.red,
// //                 )),
// //           ],
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Description card ───────────────────────────────────────────────────────
// //   Widget _buildDescriptionCard() {
// //     return _Card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: const [
// //           Text('Product description',
// //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
// //           SizedBox(height: 10),
// //           Text(
// //             'Premium OEM wireless Bluetooth earbuds suitable for wholesale buyers, ecommerce sellers, '
// //                 'retailers and distributors. Supports private labeling, custom branding, packaging '
// //                 'customization and logo printing for B2B marketplace requirements.',
// //             style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.8),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Specs card ─────────────────────────────────────────────────────────────
// //   Widget _buildSpecsCard() {
// //     final specs = [
// //       ['Bluetooth', 'Bluetooth 5.3'],
// //       ['Battery backup', '36 Hours'],
// //       ['OEM', 'Supported'],
// //       ['Water resistance', 'IPX5'],
// //       ['Sample', 'Available'],
// //       ['Lead time', '7 Days'],
// //     ];
// //     return _Card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text('Product specifications',
// //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
// //           const SizedBox(height: 12),
// //           GridView.builder(
// //             shrinkWrap: true,
// //             physics: const NeverScrollableScrollPhysics(),
// //             itemCount: specs.length,
// //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.4),
// //             itemBuilder: (_, i) => Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //               decoration: BoxDecoration(
// //                 color: _bgSurface,
// //                 borderRadius: BorderRadius.circular(10),
// //                 border: Border.all(color: _border),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Text(specs[i][0].toUpperCase(),
// //                       style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8),
// //                           fontWeight: FontWeight.w700, letterSpacing: 0.5)),
// //                   const SizedBox(height: 3),
// //                   Text(specs[i][1],
// //                       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textPrimary)),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Reviews card ───────────────────────────────────────────────────────────
// //   Widget _buildReviewsCard() {
// //     return _Card(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text('Buyer reviews',
// //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
// //           const SizedBox(height: 12),
// //           Container(
// //             padding: const EdgeInsets.all(14),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFFCFEFE),
// //               borderRadius: BorderRadius.circular(14),
// //               border: Border.all(color: _border),
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(children: [
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(10),
// //                     child: Image.network(
// //                         'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
// //                         width: 40, height: 40, fit: BoxFit.cover),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   const Expanded(child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text('Global Retail Hub',
// //                           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary)),
// //                       SizedBox(height: 2),
// //                       Text('Bulk Buyer · Mumbai',
// //                           style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
// //                     ],
// //                   )),
// //                   const Text('★★★★★', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 15)),
// //                 ]),
// //                 const SizedBox(height: 10),
// //                 const Text('Excellent OEM quality and packaging customization support.',
// //                     style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.6)),
// //                 const SizedBox(height: 8),
// //                 Wrap(spacing: 6, children: const [
// //                   _ReviewTag('Verified buyer'), _ReviewTag('OEM order'),
// //                 ]),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // Reusable sub-widgets
// // // ─────────────────────────────────────────────────────────────────────────────
// //
// // class _Card extends StatelessWidget {
// //   final Widget child;
// //   const _Card({required this.child});
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(bottom: 14),
// //     padding: const EdgeInsets.all(16),
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(22),
// //       border: Border.all(color: const Color(0xFFDCEBEA)),
// //     ),
// //     child: child,
// //   );
// // }
// //
// // class _Badge extends StatelessWidget {
// //   final String label;
// //   const _Badge(this.label);
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
// //     decoration: BoxDecoration(
// //         color: const Color(0xFFEEFCFB), borderRadius: BorderRadius.circular(20)),
// //     child: Text(label,
// //         style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
// //   );
// // }
// //
// // class _SellerTile extends StatelessWidget {
// //   const _SellerTile();
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.all(12),
// //     decoration: BoxDecoration(
// //       color: const Color(0xFFF8FBFB),
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: const Color(0xFFDCEBEA)),
// //     ),
// //     child: Row(children: [
// //       ClipRRect(
// //         borderRadius: BorderRadius.circular(12),
// //         child: Image.network(
// //             'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
// //             width: 50, height: 50, fit: BoxFit.cover),
// //       ),
// //       const SizedBox(width: 12),
// //       const Expanded(child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text('TechNova Suppliers',
// //               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
// //           SizedBox(height: 3),
// //           Text('Verified OEM Electronics Manufacturer',
// //               style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
// //           SizedBox(height: 5),
// //           Text('★ 4.8 Seller Rating',
// //               style: TextStyle(fontSize: 11, color: Color(0xFF0F766E), fontWeight: FontWeight.w700)),
// //         ],
// //       )),
// //     ]),
// //   );
// // }
// //
// // class _SlabRow extends StatelessWidget {
// //   final Map<String, dynamic> slab;
// //   final bool isSelected;
// //   final VoidCallback onTap;
// //   const _SlabRow({required this.slab, required this.isSelected, required this.onTap});
// //
// //   static const _teal = Color(0xFF0F766E);
// //
// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //     onTap: onTap,
// //     child: Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
// //       decoration: BoxDecoration(
// //         color: isSelected ? const Color(0xFFEEFCFB) : const Color(0xFFF8FBFB),
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(
// //           color: isSelected ? _teal : const Color(0xFFDCEBEA),
// //           width: isSelected ? 2 : 1,
// //         ),
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Row(children: [
// //             Radio<bool>(
// //               value: true,
// //               groupValue: isSelected,
// //               onChanged: (_) => onTap(),
// //               activeColor: _teal,
// //               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //             ),
// //             const SizedBox(width: 6),
// //             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //               Text(slab['label'] as String,
// //                   style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
// //               const SizedBox(height: 2),
// //               Text(slab['desc'] as String,
// //                   style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
// //             ]),
// //           ]),
// //           RichText(text: TextSpan(
// //             children: [
// //               TextSpan(text: '₹${slab['price']}',
// //                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _teal)),
// //               const TextSpan(text: '/unit',
// //                   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF64748B))),
// //             ],
// //           )),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// //
// // class _QtyCtrl extends StatelessWidget {
// //   final TextEditingController ctrl;
// //   final VoidCallback onDecrement;
// //   final VoidCallback onIncrement;
// //   const _QtyCtrl({required this.ctrl, required this.onDecrement, required this.onIncrement});
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(12),
// //       border: Border.all(color: const Color(0xFFDCEBEA)),
// //     ),
// //     child: Row(mainAxisSize: MainAxisSize.min, children: [
// //       IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: onDecrement,
// //           color: const Color(0xFF0F766E), padding: const EdgeInsets.symmetric(horizontal: 12)),
// //       SizedBox(
// //         width: 56,
// //         height: 42,
// //         child: TextField(
// //           controller: ctrl,
// //           keyboardType: TextInputType.number,
// //           textAlign: TextAlign.center,
// //           decoration: const InputDecoration(border: InputBorder.none, isDense: true,
// //               contentPadding: EdgeInsets.symmetric(vertical: 12)),
// //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
// //         ),
// //       ),
// //       IconButton(icon: const Icon(Icons.add, size: 18), onPressed: onIncrement,
// //           color: const Color(0xFF0F766E), padding: const EdgeInsets.symmetric(horizontal: 12)),
// //     ]),
// //   );
// // }
// //
// // class _SummaryItem extends StatelessWidget {
// //   final String label;
// //   final String value;
// //   final Color valueColor;
// //   const _SummaryItem({required this.label, required this.value, this.valueColor = const Color(0xFF111827)});
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //     decoration: BoxDecoration(
// //       color: Colors.white, borderRadius: BorderRadius.circular(10),
// //       border: Border.all(color: const Color(0xFFDCEBEA)),
// //     ),
// //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //       Text(label.toUpperCase(),
// //           style: const TextStyle(fontSize: 10, color: Color(0xFF64748B),
// //               fontWeight: FontWeight.w700, letterSpacing: 0.4)),
// //       const SizedBox(height: 4),
// //       Text(value,
// //           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
// //     ]),
// //   );
// // }
// //
// // class _OutlineBtn extends StatelessWidget {
// //   final String label;
// //   final VoidCallback onPressed;
// //   const _OutlineBtn({required this.label, required this.onPressed});
// //
// //   @override
// //   Widget build(BuildContext context) => SizedBox(
// //     height: 44,
// //     child: OutlinedButton(
// //       onPressed: onPressed,
// //       style: OutlinedButton.styleFrom(
// //         side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //       ),
// //       child: Text(label,
// //           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
// //     ),
// //   );
// // }
// //
// // class _FillBtn extends StatelessWidget {
// //   final String label;
// //   final VoidCallback onPressed;
// //   const _FillBtn({required this.label, required this.onPressed});
// //
// //   @override
// //   Widget build(BuildContext context) => SizedBox(
// //     height: 44,
// //     child: DecoratedBox(
// //       decoration: BoxDecoration(
// //         gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: ElevatedButton(
// //         onPressed: onPressed,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         ),
// //         child: Text(label,
// //             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _ReviewTag extends StatelessWidget {
// //   final String label;
// //   const _ReviewTag(this.label);
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //     decoration: BoxDecoration(
// //         color: const Color(0xFFEEFCFB), borderRadius: BorderRadius.circular(8)),
// //     child: Text(label,
// //         style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
// //   );
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // Gallery card (extracted to keep state clean)
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _GalleryCard extends StatelessWidget {
// //   final List<String> images;
// //   final int currentIdx;
// //   final void Function(int) onTap;
// //   const _GalleryCard({required this.images, required this.currentIdx, required this.onTap});
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(22),
// //       border: Border.all(color: const Color(0xFFDCEBEA)),
// //     ),
// //     padding: const EdgeInsets.all(14),
// //     child: Column(children: [
// //       ClipRRect(
// //         borderRadius: BorderRadius.circular(16),
// //         child: Image.network(images[currentIdx], height: 260, width: double.infinity, fit: BoxFit.cover),
// //       ),
// //       const SizedBox(height: 10),
// //       SizedBox(
// //         height: 62,
// //         child: ListView.builder(
// //           scrollDirection: Axis.horizontal,
// //           itemCount: images.length,
// //           itemBuilder: (_, i) {
// //             final sel = currentIdx == i;
// //             return GestureDetector(
// //               onTap: () => onTap(i),
// //               child: Container(
// //                 margin: const EdgeInsets.only(right: 8),
// //                 width: 62,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(10),
// //                   border: Border.all(
// //                     color: sel ? const Color(0xFF0F766E) : Colors.transparent,
// //                     width: 2,
// //                   ),
// //                   image: DecorationImage(image: NetworkImage(images[i]), fit: BoxFit.cover),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     ]),
// //   );
// // }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import 'app_constants.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // ⚠️ CONFIG — point this at your PHP endpoint file (the one you pasted).
// // e.g. "https://yourdomain.com/api/marketplace_product.php"
// // ─────────────────────────────────────────────────────────────────────────────
// class ApiConfig {
//   static const String baseurl =
//       "${baseUrl}new_apis/product_detail_API.php";}
//
// // ─────────────────────────────────────────────────────────────────────────────
// // API Service — one method per `action` in the PHP file
// // ─────────────────────────────────────────────────────────────────────────────
//
// class BtbApiService {
//   static Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
//     final res = await http.post(
//       Uri.parse(ApiConfig.baseurl),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(body),
//     );
//     final decoded = jsonDecode(res.body);
//     if (decoded is Map<String, dynamic>) return decoded;
//     return {'success': false, 'message': 'Unexpected response', 'data': null};
//   }
//
//   /// action = get_marketplace_item_details
//   static Future<Map<String, dynamic>> getItemDetails({
//     required int marketplaceId,
//     required int itemId,
//     required int varId,
//   }) {
//     return _post({
//       'action': 'get_marketplace_item_details',
//       'marketplace_id': marketplaceId,
//       'item_id': itemId,
//       'var_id': varId,
//     });
//   }
//
//   /// action = get_product_images
//   static Future<Map<String, dynamic>> getProductImages({
//     required int marketplaceId,
//     required int itemId,
//     int varId = 0,
//   }) {
//     return _post({
//       'action': 'get_product_images',
//       'marketplace_id': marketplaceId,
//       'item_id': itemId,
//       'var_id': varId,
//     });
//   }
//
//   /// action = get_product_purchase_details
//   static Future<Map<String, dynamic>> getPurchaseDetails({
//     required int marketplaceId,
//     required int itemId,
//     required int varId,
//     double discount = 0,
//     required Map<String, dynamic> result,
//   }) {
//     return _post({
//       'action': 'get_product_purchase_details',
//       'marketplace_id': marketplaceId,
//       'item_id': itemId,
//       'var_id': varId,
//       'discount': discount,
//       'result': result,
//     });
//   }
//
//   /// action = get_product_sample_data (description / specs / tabs / sample slabs)
//   static Future<Map<String, dynamic>> getSampleData({
//     required int marketplaceId,
//     required int itemId,
//     required int varId,
//     double discount = 0,
//     required Map<String, dynamic> result,
//     Map<String, dynamic> siteDetails = const {},
//   }) {
//     return _post({
//       'action': 'get_product_sample_data',
//       'marketplace_id': marketplaceId,
//       'item_id': itemId,
//       'var_id': varId,
//       'discount': discount,
//       'result': result,
//       'site_details': siteDetails,
//     });
//   }
//
//   /// action = get_review_rating
//   static Future<Map<String, dynamic>> getReviewRating({
//     required int marketplaceId,
//     required int productId,
//     required int variantId,
//     required int productVendorId,
//   }) {
//     return _post({
//       'action': 'get_review_rating',
//       'marketplace_id': marketplaceId,
//       'product_id': productId,
//       'variant_id': variantId,
//       'product_vendor_id': productVendorId,
//     });
//   }
//
//   /// action = add_to_cart
//   static Future<Map<String, dynamic>> addToCart({
//     required int itemId,
//     required int variantId,
//     int orgSiteId = 0,
//     int selectedItemsVendorId = 0,
//     String itemType = 'NULL',
//     required int marketplaceId,
//     int qty = 1,
//   }) {
//     return _post({
//       'action': 'add_to_cart',
//       'item_id': itemId,
//       'variant_id': variantId,
//       'org_site_id': orgSiteId,
//       'selected_items_vendor_id': selectedItemsVendorId,
//       'item_type': itemType,
//       'marketplace_id': marketplaceId,
//       'qty': qty,
//     });
//   }
//
//   /// action = add_to_wishlist
//   static Future<Map<String, dynamic>> addToWishlist({
//     required int itemId,
//     required int variantId,
//     int orgSiteId = 0,
//     int selectedItemsVendorId = 0,
//     String itemType = 'NULL',
//     required int marketplaceId,
//   }) {
//     return _post({
//       'action': 'add_to_wishlist',
//       'item_id': itemId,
//       'variant_id': variantId,
//       'org_site_id': orgSiteId,
//       'selected_items_vendor_id': selectedItemsVendorId,
//       'item_type': itemType,
//       'marketplace_id': marketplaceId,
//     });
//   }
//
//   /// action = set_pincode (delivery check)
//   static Future<Map<String, dynamic>> setPincode(String pincode) {
//     return _post({'action': 'set_pincode', 'pincode': pincode});
//   }
//
//   /// action = is_delivery_services
//   static Future<Map<String, dynamic>> isDeliveryAvailable({
//     required int logisticId,
//     required int pincode,
//   }) {
//     return _post({
//       'action': 'is_delivery_services',
//       'logistic_id': logisticId,
//       'pincode': pincode,
//     });
//   }
//
//   /// action = add_review_rating
//   static Future<Map<String, dynamic>> addReview({
//     required int marketplaceId,
//     required int productId,
//     required int variantId,
//     int productVendorId = 0,
//     required int rating,
//     required String review,
//   }) {
//     return _post({
//       'action': 'add_review_rating',
//       'marketplace_id': marketplaceId,
//       'product_id': productId,
//       'variant_id': variantId,
//       'product_vendor_id': productVendorId,
//       'rating': rating,
//       'review': review,
//     });
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Header
// // ─────────────────────────────────────────────────────────────────────────────
// class LuxeHeaderp extends StatelessWidget implements PreferredSizeWidget {
//   const LuxeHeaderp({super.key});
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
//   @override
//   Widget build(BuildContext context) => AppBar(
//     title: const Text('Luxe Marketplace',
//         style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
//     backgroundColor: Colors.white,
//     foregroundColor: const Color(0xFF0F766E),
//     elevation: 0,
//     centerTitle: true,
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Main page — now driven entirely by the API
// // ─────────────────────────────────────────────────────────────────────────────
// class BtbProductDetailPage extends StatefulWidget {
//   /// Required identifiers to fetch data from the backend.
//   final int marketplaceId; // e.g. 6 = BTB products, 51 = packaging, 53 = branding...
//   final int itemId;
//   final int varId; // variant id (or vendor_id for marketplace_id 6/51, per PHP logic)
//
//   const BtbProductDetailPage({
//     super.key,
//     required this.marketplaceId,
//     required this.itemId,
//     required this.varId,
//   });
//
//   @override
//   State<BtbProductDetailPage> createState() => _BtbProductDetailPageState();
// }
//
// class _BtbProductDetailPageState extends State<BtbProductDetailPage> {
//   static const _teal = Color(0xFF0F766E);
//   static const _tealLight = Color(0xFFEEFCFB);
//   static const _border = Color(0xFFDCEBEA);
//   static const _textMuted = Color(0xFF64748B);
//   static const _textPrimary = Color(0xFF111827);
//   static const _bgSurface = Color(0xFFF8FBFB);
//
//   bool _loading = true;
//   String? _error;
//
//   // raw API payloads
//   Map<String, dynamic> _details = {};
//   List<String> _images = [];
//   Map<String, dynamic> _purchase = {};
//   Map<String, dynamic> _sampleData = {};
//   Map<String, dynamic> _reviewData = {};
//
//   // local UI state
//   int _currentImageIdx = 0;
//   List<Map<String, dynamic>> _slabs = [];
//   int _selectedSlabIdx = 0;
//   int _quantity = 1;
//   final TextEditingController _qtyCtrl = TextEditingController(text: '1');
//
//   final TextEditingController _pincodeCtrl = TextEditingController();
//   String _deliveryMsg = '';
//   bool _checkingDelivery = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _qtyCtrl.addListener(() {
//       final q = int.tryParse(_qtyCtrl.text) ?? 0;
//       if (q != _quantity) setState(() => _quantity = q);
//     });
//     _loadAll();
//   }
//
//   @override
//   void dispose() {
//     _qtyCtrl.dispose();
//     _pincodeCtrl.dispose();
//     super.dispose();
//   }
//
//   // ── data loading ────────────────────────────────────────────────────────
//   Future<void> _loadAll() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//
//     try {
//       // 1. Item details
//       final detailsRes = await BtbApiService.getItemDetails(
//         marketplaceId: widget.marketplaceId,
//         itemId: widget.itemId,
//         varId: widget.varId,
//       );
//
//       if (detailsRes['success'] != true) {
//         setState(() {
//           _loading = false;
//           _error = detailsRes['message']?.toString() ?? 'Failed to load product';
//         });
//         return;
//       }
//
//       _details = Map<String, dynamic>.from(detailsRes['data'] ?? {});
//       final discount = double.tryParse('${_details['total_discount_percent'] ?? 0}') ?? 0;
//
//       // 2. Images
//       final imagesRes = await BtbApiService.getProductImages(
//         marketplaceId: widget.marketplaceId,
//         itemId: widget.itemId,
//         varId: widget.varId,
//       );
//       if (imagesRes['success'] == true) {
//         final imgList = (imagesRes['data']?['images'] as List?) ?? [];
//         _images = imgList
//             .map((e) => (e as Map)['image_url']?.toString() ?? '')
//             .where((s) => s.isNotEmpty)
//             .toList();
//       }
//       if (_images.isEmpty) {
//         _images = ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=1200'];
//       }
//
//       // 3. Purchase details (price slabs / add-to-cart payload)
//       final purchaseRes = await BtbApiService.getPurchaseDetails(
//         marketplaceId: widget.marketplaceId,
//         itemId: widget.itemId,
//         varId: widget.varId,
//         discount: discount,
//         result: _details,
//       );
//       if (purchaseRes['success'] == true) {
//         _purchase = Map<String, dynamic>.from(purchaseRes['data'] ?? {});
//         final slabsRaw = (_purchase['price_slabs'] as List?) ?? [];
//         _slabs = slabsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
//         if (_slabs.isNotEmpty) {
//           final checkedIdx = _slabs.indexWhere((s) => s['is_checked'] == true);
//           _selectedSlabIdx = checkedIdx >= 0 ? checkedIdx : 0;
//           final minQty = _slabs[_selectedSlabIdx]['min_qty'];
//           _quantity = int.tryParse('$minQty') ?? 1;
//         } else {
//           final box = _purchase['purchase_box'];
//           final minQ = box is Map ? box['min_quantity'] : 1;
//           _quantity = int.tryParse('$minQ') ?? 1;
//         }
//         _qtyCtrl.text = _quantity.toString();
//       }
//
//       // 4. Description / specs / tabs / sample slabs
//       final sampleRes = await BtbApiService.getSampleData(
//         marketplaceId: widget.marketplaceId,
//         itemId: widget.itemId,
//         varId: widget.varId,
//         discount: discount,
//         result: _details,
//       );
//       if (sampleRes['success'] == true) {
//         _sampleData = Map<String, dynamic>.from(sampleRes['data'] ?? {});
//       }
//
//       // 5. Reviews (best-effort, ignore failures)
//       final reviewRes = await BtbApiService.getReviewRating(
//         marketplaceId: widget.marketplaceId,
//         productId: widget.itemId,
//         variantId: widget.varId,
//         productVendorId: int.tryParse('${_details['vendor_id'] ?? 0}') ?? 0,
//       );
//       if (reviewRes.containsKey('reviews')) {
//         _reviewData = reviewRes;
//       }
//
//       setState(() => _loading = false);
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _error = 'Network error: $e';
//       });
//     }
//   }
//
//   // ── helpers ────────────────────────────────────────────────────────────
//   void _increment() => setState(() => _qtyCtrl.text = (++_quantity).toString());
//
//   void _decrement() {
//     final minQty = _slabs.isNotEmpty
//         ? int.tryParse('${_slabs[_selectedSlabIdx]['min_qty']}') ?? 1
//         : 1;
//     if (_quantity > minQty) {
//       setState(() => _qtyCtrl.text = (--_quantity).toString());
//     }
//   }
//
//   void _selectSlab(int idx) => setState(() {
//     _selectedSlabIdx = idx;
//     _quantity = int.tryParse('${_slabs[idx]['min_qty']}') ?? 1;
//     _qtyCtrl.text = _quantity.toString();
//   });
//
//   double get _unitPrice => _slabs.isNotEmpty
//       ? double.tryParse('${_slabs[_selectedSlabIdx]['final_price']}') ?? 0
//       : double.tryParse('${_details['price'] ?? 0}') ?? 0;
//
//   double get _totalPrice => _quantity * _unitPrice;
//
//   Map<String, dynamic> get _cartPayload {
//     if (_slabs.isNotEmpty) {
//       return Map<String, dynamic>.from(_purchase['sample_order']?['add_to_cart'] ??
//           {
//             'item_id': widget.itemId,
//             'variant_id': _slabs[_selectedSlabIdx]['btbprice_id'],
//             'org_site_id': _details['selected_org_site_id'] ?? 0,
//             'selected_items_vendor_id': _details['selected_items_vendor_id'] ?? 0,
//             'item_type': 'NULL',
//             'marketplace_id': widget.marketplaceId,
//           });
//     }
//     final box = _purchase['purchase_box'];
//     if (box is Map && box['add_to_cart'] is Map) {
//       return Map<String, dynamic>.from(box['add_to_cart']);
//     }
//     return {
//       'item_id': widget.itemId,
//       'variant_id': widget.varId,
//       'org_site_id': 0,
//       'selected_items_vendor_id': 0,
//       'item_type': 'NULL',
//       'marketplace_id': widget.marketplaceId,
//     };
//   }
//
//   Future<void> _addToCart() async {
//     final payload = _cartPayload;
//     final res = await BtbApiService.addToCart(
//       itemId: int.tryParse('${payload['item_id']}') ?? widget.itemId,
//       variantId: int.tryParse('${payload['variant_id']}') ?? widget.varId,
//       orgSiteId: int.tryParse('${payload['org_site_id']}') ?? 0,
//       selectedItemsVendorId: int.tryParse('${payload['selected_items_vendor_id']}') ?? 0,
//       itemType: '${payload['item_type'] ?? 'NULL'}',
//       marketplaceId: int.tryParse('${payload['marketplace_id']}') ?? widget.marketplaceId,
//       qty: _quantity,
//     );
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(res['message']?.toString() ?? (res['success'] == true ? 'Added to cart' : 'Failed')),
//       backgroundColor: res['success'] == true ? _teal : Colors.red,
//     ));
//   }
//
//   Future<void> _addToWishlist() async {
//     final payload = _cartPayload;
//     final res = await BtbApiService.addToWishlist(
//       itemId: int.tryParse('${payload['item_id']}') ?? widget.itemId,
//       variantId: int.tryParse('${payload['variant_id']}') ?? widget.varId,
//       orgSiteId: int.tryParse('${payload['org_site_id']}') ?? 0,
//       selectedItemsVendorId: int.tryParse('${payload['selected_items_vendor_id']}') ?? 0,
//       itemType: '${payload['item_type'] ?? 'NULL'}',
//       marketplaceId: int.tryParse('${payload['marketplace_id']}') ?? widget.marketplaceId,
//     );
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(res['message']?.toString() ?? (res['success'] == true ? 'Added to wishlist' : 'Failed')),
//       backgroundColor: res['success'] == true ? _teal : Colors.red,
//     ));
//   }
//
//   Future<void> _checkDelivery() async {
//     final code = _pincodeCtrl.text.trim();
//     if (code.length < 5) {
//       setState(() => _deliveryMsg = 'Please enter a valid postal code.');
//       return;
//     }
//     setState(() => _checkingDelivery = true);
//     final res = await BtbApiService.setPincode(code);
//     if (!mounted) return;
//     setState(() {
//       _checkingDelivery = false;
//       _deliveryMsg = res['success'] == true
//           ? '✓ Delivery available for ${res['data']?['city'] ?? code}.'
//           : (res['message']?.toString() ?? 'Delivery not available for this pincode.');
//     });
//   }
//
//   // ── build ──────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4FBFB),
//       appBar: const LuxeHeaderp(),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator(color: _teal))
//           : _error != null
//           ? _buildErrorState()
//           : RefreshIndicator(
//         onRefresh: _loadAll,
//         color: _teal,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(14, 14, 14, 60),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _GalleryCard(images: _images, currentIdx: _currentImageIdx,
//                   onTap: (i) => setState(() => _currentImageIdx = i)),
//               const SizedBox(height: 14),
//               _buildPricingCard(),
//               const SizedBox(height: 14),
//               _buildPurchaseBox(),
//               if ((_sampleData['sample_order'] as Map?)?['price_slabs'] != null)
//                 _buildSampleBox(),
//               _buildDeliveryCard(),
//               _buildDescriptionCard(),
//               _buildSpecsCard(),
//               _buildReviewsCard(),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorState() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
//           const SizedBox(height: 12),
//           Text(_error ?? 'Something went wrong',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 13, color: _textMuted)),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _loadAll,
//             style: ElevatedButton.styleFrom(backgroundColor: _teal),
//             child: const Text('Retry', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     ),
//   );
//
//   // ── Pricing card ───────────────────────────────────────────────────────
//   Widget _buildPricingCard() {
//     final title = _details['product_title'] ??
//         _details['service_name'] ??
//         _details['title'] ??
//         _details['property_title'] ??
//         _details['project_title'] ??
//         'Product';
//     final desc = (_sampleData['description']?['content'] ?? _details['short_description'] ?? '')
//         .toString();
//
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(spacing: 6, runSpacing: 6, children: [
//             if (_details['verified'] == 1) const _Badge('VERIFIED'),
//             const _Badge('OEM'),
//             if (_slabs.isNotEmpty) _Badge('MOQ ${_slabs.first['min_qty'] ?? ''}'),
//             if ((_sampleData['sample_order'] as Map?)?['price_slabs'] != null)
//               const _Badge('SAMPLE AVAILABLE'),
//           ]),
//           const SizedBox(height: 14),
//           Text(title.toString(),
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textPrimary, height: 1.3)),
//           if (desc.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             Text(_stripHtml(desc),
//                 maxLines: 2, overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontSize: 12, color: _textMuted, height: 1.6)),
//           ],
//           const SizedBox(height: 16),
//           _SellerTile(
//             name: _details['vendor_name']?.toString() ?? 'Seller',
//             subtitle: _details['cat_id']?.toString() ?? _details['industry']?.toString() ?? '',
//           ),
//           if (_slabs.isNotEmpty) ...[
//             const SizedBox(height: 18),
//             const Text('Wholesale price slabs',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
//             const SizedBox(height: 10),
//             ...List.generate(_slabs.length, (i) => _SlabRow(
//               slab: _slabs[i],
//               isSelected: _selectedSlabIdx == i,
//               onTap: () => _selectSlab(i),
//             )),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ── Purchase box ──────────────────────────────────────────────────────
//   Widget _buildPurchaseBox() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _tealLight,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: const Color(0xFFBCE9E2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Purchase quantity',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
//           const SizedBox(height: 4),
//           const Text('Select quantity — slab pricing updates automatically',
//               style: TextStyle(fontSize: 11, color: _textMuted)),
//           const SizedBox(height: 14),
//           Row(children: [
//             _QtyCtrl(ctrl: _qtyCtrl, onDecrement: _decrement, onIncrement: _increment),
//             const SizedBox(width: 10),
//             const Text('units', style: TextStyle(fontSize: 12, color: _textMuted)),
//           ]),
//           const SizedBox(height: 14),
//           Row(children: [
//             Expanded(child: _SummaryItem(
//               label: 'Selected slab',
//               value: _slabs.isNotEmpty
//                   ? '${_slabs[_selectedSlabIdx]['min_qty']} - ${_slabs[_selectedSlabIdx]['max_qty']} ${_slabs[_selectedSlabIdx]['unit'] ?? ''}'
//                   : 'Standard',
//             )),
//             const SizedBox(width: 10),
//             Expanded(child: _SummaryItem(
//                 label: 'Price per unit', value: '₹${_unitPrice.toStringAsFixed(2)}', valueColor: _teal)),
//           ]),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF0FDFA),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFF99F6E4)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Order total',
//                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _teal)),
//                 Text('₹${_totalPrice.toStringAsFixed(2)}',
//                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _teal)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//           Row(children: [
//             Expanded(child: _OutlineBtn(label: 'Add to cart', onPressed: _addToCart)),
//             const SizedBox(width: 10),
//             Expanded(child: _FillBtn(label: 'Wishlist', onPressed: _addToWishlist)),
//           ]),
//         ],
//       ),
//     );
//   }
//
//   // ── Sample box ────────────────────────────────────────────────────────
//   Widget _buildSampleBox() {
//     final sampleOrder = Map<String, dynamic>.from(_sampleData['sample_order'] ?? {});
//     final slabs = (sampleOrder['price_slabs'] as List?) ?? [];
//     if (slabs.isEmpty) return const SizedBox.shrink();
//     final first = Map<String, dynamic>.from(slabs.first as Map);
//     final price = double.tryParse('${first['final_price'] ?? first['price'] ?? 0}') ?? 0;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _bgSurface,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: _border),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(6)),
//                   child: const Text('Sample available',
//                       style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text('Buy product sample',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
//                 const SizedBox(height: 4),
//                 Text('Sample price ₹${price.toStringAsFixed(2)} · Max qty ${first['max_qty'] ?? 2}',
//                     style: const TextStyle(fontSize: 11, color: _textMuted)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text('₹${price.toStringAsFixed(2)}',
//                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _teal)),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () async {
//                   final cart = Map<String, dynamic>.from(sampleOrder['add_to_cart'] ?? {});
//                   final res = await BtbApiService.addToCart(
//                     itemId: int.tryParse('${cart['item_id']}') ?? widget.itemId,
//                     variantId: int.tryParse('${first['btbprice_id']}') ?? widget.varId,
//                     orgSiteId: int.tryParse('${cart['org_site_id']}') ?? 0,
//                     selectedItemsVendorId: int.tryParse('${cart['selected_items_vendor_id']}') ?? 0,
//                     itemType: 'sample',
//                     marketplaceId: widget.marketplaceId,
//                     qty: 1,
//                   );
//                   if (!mounted) return;
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(res['message']?.toString() ?? 'Sample requested'),
//                     backgroundColor: res['success'] == true ? _teal : Colors.red,
//                   ));
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _teal,
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: const Text('Buy sample',
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Delivery card ─────────────────────────────────────────────────────
//   Widget _buildDeliveryCard() {
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Check delivery location',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
//           const SizedBox(height: 10),
//           Row(children: [
//             Expanded(
//               child: SizedBox(
//                 height: 42,
//                 child: TextField(
//                   controller: _pincodeCtrl,
//                   keyboardType: TextInputType.number,
//                   style: const TextStyle(fontSize: 13),
//                   decoration: InputDecoration(
//                     hintText: 'Enter postal / zip code',
//                     hintStyle: const TextStyle(fontSize: 12, color: _textMuted),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 14),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             SizedBox(
//               height: 42,
//               child: ElevatedButton(
//                 onPressed: _checkingDelivery ? null : _checkDelivery,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _teal, elevation: 0,
//                   padding: const EdgeInsets.symmetric(horizontal: 18),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: _checkingDelivery
//                     ? const SizedBox(
//                     width: 16, height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                     : const Text('Check',
//                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
//               ),
//             ),
//           ]),
//           if (_deliveryMsg.isNotEmpty) ...[
//             const SizedBox(height: 10),
//             Text(_deliveryMsg,
//                 style: TextStyle(
//                   fontSize: 12, fontWeight: FontWeight.w700,
//                   color: _deliveryMsg.startsWith('✓') ? _teal : Colors.red,
//                 )),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ── Description card ─────────────────────────────────────────────────
//   Widget _buildDescriptionCard() {
//     final content = _stripHtml((_sampleData['description']?['content'] ?? '').toString());
//     if (content.isEmpty) return const SizedBox.shrink();
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Product description',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
//           const SizedBox(height: 10),
//           Text(content, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.8)),
//         ],
//       ),
//     );
//   }
//
//   // ── Specs card ────────────────────────────────────────────────────────
//   Widget _buildSpecsCard() {
//     final info = (_sampleData['additional_info'] as List?) ?? [];
//     if (info.isEmpty) return const SizedBox.shrink();
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Product specifications',
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
//           const SizedBox(height: 12),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: info.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.4),
//             itemBuilder: (_, i) {
//               final item = Map<String, dynamic>.from(info[i] as Map);
//               return Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: _bgSurface,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: _border),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('${item['title'] ?? ''}'.toUpperCase(),
//                         style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8),
//                             fontWeight: FontWeight.w700, letterSpacing: 0.5)),
//                     const SizedBox(height: 3),
//                     Text('${item['value'] ?? ''}',
//                         maxLines: 1, overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textPrimary)),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Reviews card ──────────────────────────────────────────────────────
//   Widget _buildReviewsCard() {
//     final reviews = (_reviewData['reviews'] as List?) ?? [];
//     final avg = _reviewData['avg_rating']?.toString() ?? '0';
//     final total = _reviewData['total_reviews']?.toString() ?? '0';
//
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Buyer reviews',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
//               Text('★ $avg ($total)',
//                   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (reviews.isEmpty)
//             const Text('No reviews yet.', style: TextStyle(fontSize: 12, color: _textMuted))
//           else
//             ...reviews.take(3).map((r) {
//               final rev = Map<String, dynamic>.from(r as Map);
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 10),
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFCFEFE),
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: _border),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           rev['profile_pic']?.toString() ??
//                               'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                           width: 40, height: 40, fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('${rev['name'] ?? 'Anonymous'}',
//                               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary)),
//                           const SizedBox(height: 2),
//                           Text('${rev['date'] ?? ''}',
//                               style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
//                         ],
//                       )),
//                       Text('★' * (int.tryParse('${rev['rating'] ?? 0}') ?? 0),
//                           style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 15)),
//                     ]),
//                     const SizedBox(height: 10),
//                     Text(_stripHtml('${rev['review'] ?? ''}'),
//                         style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.6)),
//                   ],
//                 ),
//               );
//             }),
//         ],
//       ),
//     );
//   }
//
//   String _stripHtml(String input) =>
//       input.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('&nbsp;', ' ').trim();
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Reusable sub-widgets
// // ─────────────────────────────────────────────────────────────────────────────
// class _Card extends StatelessWidget {
//   final Widget child;
//   const _Card({required this.child});
//   @override
//   Widget build(BuildContext context) => Container(
//     margin: const EdgeInsets.only(bottom: 14),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(22),
//       border: Border.all(color: const Color(0xFFDCEBEA)),
//     ),
//     child: child,
//   );
// }
//
// class _Badge extends StatelessWidget {
//   final String label;
//   const _Badge(this.label);
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//     decoration: BoxDecoration(
//         color: const Color(0xFFEEFCFB), borderRadius: BorderRadius.circular(20)),
//     child: Text(label,
//         style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
//   );
// }
//
// class _SellerTile extends StatelessWidget {
//   final String name;
//   final String subtitle;
//   const _SellerTile({required this.name, required this.subtitle});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: const Color(0xFFF8FBFB),
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: const Color(0xFFDCEBEA)),
//     ),
//     child: Row(children: [
//       ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.network(
//             'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//             width: 50, height: 50, fit: BoxFit.cover),
//       ),
//       const SizedBox(width: 12),
//       Expanded(child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(name,
//               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
//           const SizedBox(height: 3),
//           Text(subtitle.isEmpty ? 'Verified Manufacturer' : subtitle,
//               style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
//         ],
//       )),
//     ]),
//   );
// }
//
// class _SlabRow extends StatelessWidget {
//   final Map<String, dynamic> slab;
//   final bool isSelected;
//   final VoidCallback onTap;
//   const _SlabRow({required this.slab, required this.isSelected, required this.onTap});
//
//   static const _teal = Color(0xFF0F766E);
//
//   @override
//   Widget build(BuildContext context) {
//     final minQty = slab['min_qty'];
//     final maxQty = slab['max_qty'];
//     final unit = slab['unit'] ?? 'Units';
//     final price = double.tryParse('${slab['final_price'] ?? slab['price'] ?? 0}') ?? 0;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFEEFCFB) : const Color(0xFFF8FBFB),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isSelected ? _teal : const Color(0xFFDCEBEA),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(children: [
//               Radio<bool>(
//                 value: true,
//                 groupValue: isSelected,
//                 onChanged: (_) => onTap(),
//                 activeColor: _teal,
//                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               const SizedBox(width: 6),
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('$minQty – $maxQty $unit',
//                     style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
//               ]),
//             ]),
//             RichText(text: TextSpan(
//               children: [
//                 TextSpan(text: '₹${price.toStringAsFixed(2)}',
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _teal)),
//                 const TextSpan(text: '/unit',
//                     style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF64748B))),
//               ],
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _QtyCtrl extends StatelessWidget {
//   final TextEditingController ctrl;
//   final VoidCallback onDecrement;
//   final VoidCallback onIncrement;
//   const _QtyCtrl({required this.ctrl, required this.onDecrement, required this.onIncrement});
//
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: const Color(0xFFDCEBEA)),
//     ),
//     child: Row(mainAxisSize: MainAxisSize.min, children: [
//       IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: onDecrement,
//           color: const Color(0xFF0F766E), padding: const EdgeInsets.symmetric(horizontal: 12)),
//       SizedBox(
//         width: 56,
//         height: 42,
//         child: TextField(
//           controller: ctrl,
//           keyboardType: TextInputType.number,
//           textAlign: TextAlign.center,
//           decoration: const InputDecoration(border: InputBorder.none, isDense: true,
//               contentPadding: EdgeInsets.symmetric(vertical: 12)),
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
//         ),
//       ),
//       IconButton(icon: const Icon(Icons.add, size: 18), onPressed: onIncrement,
//           color: const Color(0xFF0F766E), padding: const EdgeInsets.symmetric(horizontal: 12)),
//     ]),
//   );
// }
//
// class _SummaryItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color valueColor;
//   const _SummaryItem({required this.label, required this.value, this.valueColor = const Color(0xFF111827)});
//
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     decoration: BoxDecoration(
//       color: Colors.white, borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: const Color(0xFFDCEBEA)),
//     ),
//     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(label.toUpperCase(),
//           style: const TextStyle(fontSize: 10, color: Color(0xFF64748B),
//               fontWeight: FontWeight.w700, letterSpacing: 0.4)),
//       const SizedBox(height: 4),
//       Text(value,
//           maxLines: 1, overflow: TextOverflow.ellipsis,
//           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
//     ]),
//   );
// }
//
// class _OutlineBtn extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;
//   const _OutlineBtn({required this.label, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) => SizedBox(
//     height: 44,
//     child: OutlinedButton(
//       onPressed: onPressed,
//       style: OutlinedButton.styleFrom(
//         side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       child: Text(label,
//           style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
//     ),
//   );
// }
//
// class _FillBtn extends StatelessWidget {
//   final String label;
//   final VoidCallback onPressed;
//   const _FillBtn({required this.label, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) => SizedBox(
//     height: 44,
//     child: DecoratedBox(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//         child: Text(label,
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
//       ),
//     ),
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Gallery card
// // ─────────────────────────────────────────────────────────────────────────────
// class _GalleryCard extends StatelessWidget {
//   final List<String> images;
//   final int currentIdx;
//   final void Function(int) onTap;
//   const _GalleryCard({required this.images, required this.currentIdx, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(22),
//       border: Border.all(color: const Color(0xFFDCEBEA)),
//     ),
//     padding: const EdgeInsets.all(14),
//     child: Column(children: [
//       ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Image.network(
//           images[currentIdx.clamp(0, images.length - 1)],
//           height: 260, width: double.infinity, fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => Container(height: 260, color: const Color(0xFFF1F5F9)),
//         ),
//       ),
//       const SizedBox(height: 10),
//       if (images.length > 1)
//         SizedBox(
//           height: 62,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: images.length,
//             itemBuilder: (_, i) {
//               final sel = currentIdx == i;
//               return GestureDetector(
//                 onTap: () => onTap(i),
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 8),
//                   width: 62,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: sel ? const Color(0xFF0F766E) : Colors.transparent,
//                       width: 2,
//                     ),
//                     image: DecorationImage(image: NetworkImage(images[i]), fit: BoxFit.cover),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//     ]),
//   );
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';


// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — points at the PHP endpoint file
// ─────────────────────────────────────────────────────────────────────────────
class ApiConfig {
  static const String baseurl = "${baseUrl}new_apis/product_detail_API.php";
}

// ─────────────────────────────────────────────────────────────────────────────
// API Service — one method per `action` in the PHP file
// ─────────────────────────────────────────────────────────────────────────────
class BtbApiService {
  static Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.baseurl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': false, 'message': 'Unexpected response', 'data': null};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  /// action = get_marketplace_item_details
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

  /// action = get_product_images
  static Future<Map<String, dynamic>> getProductImages({
    required int marketplaceId,
    required int itemId,
    int varId = 0,
  }) {
    return _post({
      'action': 'get_product_images',
      'marketplace_id': marketplaceId,
      'item_id': itemId,
      'var_id': varId,
    });
  }

  /// action = get_product_purchase_details
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

  /// action = get_product_sample_data (description / specs / tabs / sample slabs)
  static Future<Map<String, dynamic>> getSampleData({
    required int marketplaceId,
    required int itemId,
    required int varId,
    double discount = 0,
    required Map<String, dynamic> result,
    Map<String, dynamic> siteDetails = const {},
  }) {
    return _post({
      'action': 'get_product_sample_data',
      'marketplace_id': marketplaceId,
      'item_id': itemId,
      'var_id': varId,
      'discount': discount,
      'result': result,
      'site_details': siteDetails,
    });
  }

  /// action = get_review_rating
  /// NOTE: This action does NOT use respond(); it returns a bare JSON object
  /// (avg_rating, reviews, etc.) with no `success` key — handled specially.
  static Future<Map<String, dynamic>> getReviewRating({
    required int marketplaceId,
    required int productId,
    required int variantId,
    int productVendorId = 0,
  }) {
    return _post({
      'action': 'get_review_rating',
      'marketplace_id': marketplaceId,
      'product_id': productId,
      'variant_id': variantId,
      // PHP filters product_rating.product_vendor_id, which is whatever
      // value was supplied at review-creation time (defaults to 0), NOT the
      // product's own vendor_id. Default to 0 unless you track this value.
      'product_vendor_id': productVendorId,
    });
  }

  /// action = add_to_cart
  static Future<Map<String, dynamic>> addToCart({
    required int itemId,
    required int variantId,
    int orgSiteId = 0,
    int selectedItemsVendorId = 0,
    String itemType = 'NULL',
    required int marketplaceId,
    int qty = 1,
  }) {
    return _post({
      'action': 'add_to_cart',
      'item_id': itemId,
      'variant_id': variantId,
      'org_site_id': orgSiteId,
      'selected_items_vendor_id': selectedItemsVendorId,
      'item_type': itemType,
      'marketplace_id': marketplaceId,
      'qty': qty,
    });
  }

  /// action = add_to_wishlist
  static Future<Map<String, dynamic>> addToWishlist({
    required int itemId,
    required int variantId,
    int orgSiteId = 0,
    int selectedItemsVendorId = 0,
    String itemType = 'NULL',
    required int marketplaceId,
  }) {
    return _post({
      'action': 'add_to_wishlist',
      'item_id': itemId,
      'variant_id': variantId,
      'org_site_id': orgSiteId,
      'selected_items_vendor_id': selectedItemsVendorId,
      'item_type': itemType,
      'marketplace_id': marketplaceId,
    });
  }

  /// action = set_pincode (delivery check)
  static Future<Map<String, dynamic>> setPincode(String pincode) {
    return _post({'action': 'set_pincode', 'pincode': pincode});
  }

  /// action = is_delivery_services
  static Future<Map<String, dynamic>> isDeliveryAvailable({
    required int logisticId,
    required int pincode,
  }) {
    return _post({
      'action': 'is_delivery_services',
      'logistic_id': logisticId,
      'pincode': pincode,
    });
  }

  /// action = add_review_rating
  static Future<Map<String, dynamic>> addReview({
    required int marketplaceId,
    required int productId,
    required int variantId,
    int productVendorId = 0,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class LuxeHeaderp extends StatelessWidget implements PreferredSizeWidget {
  const LuxeHeaderp({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) => AppBar(
    title: const Text('Luxe Marketplace',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF0F766E),
    elevation: 0,
    centerTitle: true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main page — fully driven by the API, with corrected wiring
// ─────────────────────────────────────────────────────────────────────────────
class BtbProductDetailPage extends StatefulWidget {
  final int marketplaceId; // e.g. 6 = BTB products, 51 = packaging, 53 = branding...
  final int itemId;
  final int varId; // variant id (or vendor_id for marketplace_id 6/51, per PHP logic)

  /// Set true if the vendor is logged in (drives login prompts on cart/wishlist).
  final bool isLoggedIn;

  const BtbProductDetailPage({
    super.key,
    required this.marketplaceId,
    required this.itemId,
    required this.varId,
    this.isLoggedIn = true,
  });

  @override
  State<BtbProductDetailPage> createState() => _BtbProductDetailPageState();
}

class _BtbProductDetailPageState extends State<BtbProductDetailPage> {
  static const _teal = Color(0xFF0F766E);
  static const _tealLight = Color(0xFFEEFCFB);
  static const _border = Color(0xFFDCEBEA);
  static const _textMuted = Color(0xFF64748B);
  static const _textPrimary = Color(0xFF111827);
  static const _bgSurface = Color(0xFFF8FBFB);

  bool _loading = true;
  String? _error;

  // raw API payloads
  Map<String, dynamic> _details = {};
  List<String> _images = [];
  Map<String, dynamic> _purchase = {};
  Map<String, dynamic> _sampleData = {};
  Map<String, dynamic> _reviewData = {};

  // local UI state
  int _currentImageIdx = 0;
  List<Map<String, dynamic>> _slabs = [];
  int _selectedSlabIdx = 0;
  int _quantity = 1;
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');

  final TextEditingController _pincodeCtrl = TextEditingController();
  String _deliveryMsg = '';
  bool _checkingDelivery = false;
  bool _addingToCart = false;
  bool _addingToWishlist = false;

  @override
  void initState() {
    super.initState();
    _qtyCtrl.addListener(() {
      final q = int.tryParse(_qtyCtrl.text) ?? 0;
      if (q != _quantity) setState(() => _quantity = q);
    });
    _loadAll();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  // ── data loading ────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1. Item details
      final detailsRes = await BtbApiService.getItemDetails(
        marketplaceId: widget.marketplaceId,
        itemId: widget.itemId,
        varId: widget.varId,
      );

      if (detailsRes['success'] != true) {
        setState(() {
          _loading = false;
          _error = detailsRes['message']?.toString() ?? 'Failed to load product';
        });
        return;
      }

      _details = Map<String, dynamic>.from(detailsRes['data'] ?? {});
      final discount =
          double.tryParse('${_details['total_discount_percent'] ?? 0}') ?? 0;

      // 2. Images
      final imagesRes = await BtbApiService.getProductImages(
        marketplaceId: widget.marketplaceId,
        itemId: widget.itemId,
        varId: widget.varId,
      );
      if (imagesRes['success'] == true) {
        final imgList = (imagesRes['data']?['images'] as List?) ?? [];
        _images = imgList
            .map((e) => (e as Map)['image_url']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (_images.isEmpty) {
        _images = [
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=1200'
        ];
      }

      // 3. Purchase details (price slabs / purchase_box / contact_us)
      final purchaseRes = await BtbApiService.getPurchaseDetails(
        marketplaceId: widget.marketplaceId,
        itemId: widget.itemId,
        varId: widget.varId,
        discount: discount,
        result: _details,
      );
      if (purchaseRes['success'] == true) {
        _purchase = Map<String, dynamic>.from(purchaseRes['data'] ?? {});
        final slabsRaw = (_purchase['price_slabs'] as List?) ?? [];
        _slabs = slabsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (_slabs.isNotEmpty) {
          final checkedIdx = _slabs.indexWhere((s) => s['is_checked'] == true);
          _selectedSlabIdx = checkedIdx >= 0 ? checkedIdx : 0;
          final minQty = _slabs[_selectedSlabIdx]['min_qty'];
          _quantity = int.tryParse('$minQty') ?? 1;
        } else {
          final box = _purchase['purchase_box'];
          final minQ = box is Map ? box['min_quantity'] : 1;
          _quantity = int.tryParse('$minQ') ?? 1;
        }
        _qtyCtrl.text = _quantity.toString();
      }

      // 4. Description / specs / tabs / sample slabs
      final sampleRes = await BtbApiService.getSampleData(
        marketplaceId: widget.marketplaceId,
        itemId: widget.itemId,
        varId: widget.varId,
        discount: discount,
        result: _details,
      );
      if (sampleRes['success'] == true) {
        _sampleData = Map<String, dynamic>.from(sampleRes['data'] ?? {});
      }

      // 5. Reviews — bare JSON object, no `success` key, so check for
      // `reviews` directly instead of relying on _post's success contract.
      final reviewRes = await BtbApiService.getReviewRating(
        marketplaceId: widget.marketplaceId,
        productId: widget.itemId,
        variantId: widget.varId,
        // Defaulting to 0 — see note in BtbApiService.getReviewRating.
        productVendorId: 0,
      );
      if (reviewRes.containsKey('reviews')) {
        _reviewData = reviewRes;
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Network error: $e';
      });
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────
  void _increment() => setState(() => _qtyCtrl.text = (++_quantity).toString());

  void _decrement() {
    final minQty = _slabs.isNotEmpty
        ? int.tryParse('${_slabs[_selectedSlabIdx]['min_qty']}') ?? 1
        : 1;
    if (_quantity > minQty) {
      setState(() => _qtyCtrl.text = (--_quantity).toString());
    }
  }

  void _selectSlab(int idx) => setState(() {
    _selectedSlabIdx = idx;
    _quantity = int.tryParse('${_slabs[idx]['min_qty']}') ?? 1;
    _qtyCtrl.text = _quantity.toString();
  });

  /// True when the backend says "contact us" instead of showing a price
  /// (marketplace_id 16 with show_price set).
  bool get _isContactUsOnly => _purchase['contact_us'] == true;

  double get _unitPrice => _slabs.isNotEmpty
      ? double.tryParse('${_slabs[_selectedSlabIdx]['final_price']}') ?? 0
      : double.tryParse('${_details['price'] ?? 0}') ?? 0;

  double get _totalPrice => _quantity * _unitPrice;

  /// Builds the add-to-cart / wishlist payload.
  /// FIX: previously this incorrectly fell back to the *sample order*
  /// cart payload for slabbed items. Now it builds the correct payload
  /// directly from the selected slab / purchase_box.
  Map<String, dynamic> get _cartPayload {
    if (_slabs.isNotEmpty) {
      return {
        'item_id': widget.itemId,
        'variant_id': _slabs[_selectedSlabIdx]['btbprice_id'],
        'org_site_id': _details['selected_org_site_id'] ?? 0,
        'selected_items_vendor_id': _details['selected_items_vendor_id'] ?? 0,
        'item_type': 'NULL',
        'marketplace_id': widget.marketplaceId,
      };
    }
    final box = _purchase['purchase_box'];
    if (box is Map && box['add_to_cart'] is Map) {
      return Map<String, dynamic>.from(box['add_to_cart']);
    }
    return {
      'item_id': widget.itemId,
      'variant_id': widget.varId,
      'org_site_id': 0,
      'selected_items_vendor_id': 0,
      'item_type': 'NULL',
      'marketplace_id': widget.marketplaceId,
    };
  }

  void _promptLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in to continue.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _addToCart() async {
    if (!widget.isLoggedIn) {
      _promptLogin();
      return;
    }
    setState(() => _addingToCart = true);
    final payload = _cartPayload;
    final res = await BtbApiService.addToCart(
      itemId: int.tryParse('${payload['item_id']}') ?? widget.itemId,
      variantId: int.tryParse('${payload['variant_id']}') ?? widget.varId,
      orgSiteId: int.tryParse('${payload['org_site_id']}') ?? 0,
      selectedItemsVendorId:
      int.tryParse('${payload['selected_items_vendor_id']}') ?? 0,
      itemType: '${payload['item_type'] ?? 'NULL'}',
      marketplaceId:
      int.tryParse('${payload['marketplace_id']}') ?? widget.marketplaceId,
      qty: _quantity,
    );
    if (!mounted) return;
    setState(() => _addingToCart = false);

    if (res['success'] != true && res['message']?.toString().toLowerCase().contains('login') == true) {
      _promptLogin();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message']?.toString() ??
          (res['success'] == true ? 'Added to cart' : 'Failed to add to cart')),
      backgroundColor: res['success'] == true ? _teal : Colors.red,
    ));
  }

  Future<void> _addToWishlist() async {
    if (!widget.isLoggedIn) {
      _promptLogin();
      return;
    }
    setState(() => _addingToWishlist = true);
    final payload = _cartPayload;
    final res = await BtbApiService.addToWishlist(
      itemId: int.tryParse('${payload['item_id']}') ?? widget.itemId,
      variantId: int.tryParse('${payload['variant_id']}') ?? widget.varId,
      orgSiteId: int.tryParse('${payload['org_site_id']}') ?? 0,
      selectedItemsVendorId:
      int.tryParse('${payload['selected_items_vendor_id']}') ?? 0,
      itemType: '${payload['item_type'] ?? 'NULL'}',
      marketplaceId:
      int.tryParse('${payload['marketplace_id']}') ?? widget.marketplaceId,
    );
    if (!mounted) return;
    setState(() => _addingToWishlist = false);

    if (res['success'] != true && res['message']?.toString().toLowerCase().contains('login') == true) {
      _promptLogin();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message']?.toString() ??
          (res['success'] == true ? 'Added to wishlist' : 'Failed to add to wishlist')),
      backgroundColor: res['success'] == true ? _teal : Colors.red,
    ));
  }

  Future<void> _checkDelivery() async {
    final code = _pincodeCtrl.text.trim();
    if (code.length < 5) {
      setState(() => _deliveryMsg = 'Please enter a valid postal code.');
      return;
    }
    setState(() => _checkingDelivery = true);
    final res = await BtbApiService.setPincode(code);
    if (!mounted) return;

    String msg;
    if (res['success'] == true) {
      final data = res['data'];
      final city = (data is Map) ? data['city'] : null;
      msg = city != null
          ? '✓ Delivery available for $city.'
          : '✓ Delivery available for pincode $code.';
    } else {
      msg = res['message']?.toString() ?? 'Delivery not available for this pincode.';
    }

    setState(() {
      _checkingDelivery = false;
      _deliveryMsg = msg;
    });
  }

  // ── build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFB),
      appBar: const LuxeHeaderp(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
        onRefresh: _loadAll,
        color: _teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GalleryCard(
                  images: _images,
                  currentIdx: _currentImageIdx,
                  onTap: (i) => setState(() => _currentImageIdx = i)),
              const SizedBox(height: 14),
              _buildPricingCard(),
              const SizedBox(height: 14),
              _isContactUsOnly ? _buildContactUsBox() : _buildPurchaseBox(),
              if ((_sampleData['sample_order'] as Map?)?['price_slabs'] != null)
                _buildSampleBox(),
              _buildDeliveryCard(),
              _buildDescriptionCard(),
              _buildSpecsCard(),
              _buildReviewsCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
          const SizedBox(height: 12),
          Text(_error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _textMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAll,
            style: ElevatedButton.styleFrom(backgroundColor: _teal),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  // ── Pricing card ───────────────────────────────────────────────────────
  Widget _buildPricingCard() {
    final title = _details['product_title'] ??
        _details['service_name'] ??
        _details['title'] ??
        _details['property_title'] ??
        _details['project_title'] ??
        'Product';
    final desc =
    (_sampleData['description']?['content'] ?? _details['short_description'] ?? '')
        .toString();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 6, runSpacing: 6, children: [
            if (_details['verified'] == 1) const _Badge('VERIFIED'),
            const _Badge('OEM'),
            if (_slabs.isNotEmpty) _Badge('MOQ ${_slabs.first['min_qty'] ?? ''}'),
            if ((_sampleData['sample_order'] as Map?)?['price_slabs'] != null)
              const _Badge('SAMPLE AVAILABLE'),
            if (_isContactUsOnly) const _Badge('PRICE ON REQUEST'),
          ]),
          const SizedBox(height: 14),
          Text(title.toString(),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: _textPrimary, height: 1.3)),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_stripHtml(desc),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _textMuted, height: 1.6)),
          ],
          const SizedBox(height: 16),
          _SellerTile(
            name: _details['vendor_name']?.toString() ?? 'Seller',
            subtitle: _details['cat_id']?.toString() ?? _details['industry']?.toString() ?? '',
          ),
          if (_slabs.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('Wholesale price slabs',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
            const SizedBox(height: 10),
            ...List.generate(
                _slabs.length,
                    (i) => _SlabRow(
                  slab: _slabs[i],
                  isSelected: _selectedSlabIdx == i,
                  onTap: () => _selectSlab(i),
                )),
          ],
        ],
      ),
    );
  }

  // ── Contact-us box (marketplace_id 16 with show_price set) ─────────────
  Widget _buildContactUsBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tealLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBCE9E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pricing on request',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
          const SizedBox(height: 6),
          const Text(
            'This seller has chosen to share pricing only with interested buyers. Reach out to get a quote.',
            style: TextStyle(fontSize: 12, color: _textMuted, height: 1.6),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _FillBtn(
              label: 'Contact seller',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening contact form…'), backgroundColor: _teal),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Purchase box ──────────────────────────────────────────────────────
  Widget _buildPurchaseBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tealLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBCE9E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Purchase quantity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
          const SizedBox(height: 4),
          const Text('Select quantity — slab pricing updates automatically',
              style: TextStyle(fontSize: 11, color: _textMuted)),
          const SizedBox(height: 14),
          Row(children: [
            _QtyCtrl(ctrl: _qtyCtrl, onDecrement: _decrement, onIncrement: _increment),
            const SizedBox(width: 10),
            const Text('units', style: TextStyle(fontSize: 12, color: _textMuted)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _SummaryItem(
                  label: 'Selected slab',
                  value: _slabs.isNotEmpty
                      ? '${_slabs[_selectedSlabIdx]['min_qty']} - ${_slabs[_selectedSlabIdx]['max_qty']} ${_slabs[_selectedSlabIdx]['unit'] ?? ''}'
                      : 'Standard',
                )),
            const SizedBox(width: 10),
            Expanded(
                child: _SummaryItem(
                    label: 'Price per unit',
                    value: '₹${_unitPrice.toStringAsFixed(2)}',
                    valueColor: _teal)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order total',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _teal)),
                Text('₹${_totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _teal)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _OutlineBtn(
                  label: _addingToCart ? 'Adding…' : 'Add to cart',
                  onPressed: _addingToCart ? () {} : _addToCart,
                )),
            const SizedBox(width: 10),
            Expanded(
                child: _FillBtn(
                  label: _addingToWishlist ? 'Adding…' : 'Wishlist',
                  onPressed: _addingToWishlist ? () {} : _addToWishlist,
                )),
          ]),
        ],
      ),
    );
  }

  // ── Sample box ────────────────────────────────────────────────────────
  Widget _buildSampleBox() {
    final sampleOrder = Map<String, dynamic>.from(_sampleData['sample_order'] ?? {});
    final slabs = (sampleOrder['price_slabs'] as List?) ?? [];
    if (slabs.isEmpty) return const SizedBox.shrink();
    final first = Map<String, dynamic>.from(slabs.first as Map);
    final price = double.tryParse('${first['final_price'] ?? first['price'] ?? 0}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration:
                  BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(6)),
                  child: const Text('Sample available',
                      style:
                      TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                const Text('Buy product sample',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                const SizedBox(height: 4),
                Text('Sample price ₹${price.toStringAsFixed(2)} · Max qty ${first['max_qty'] ?? 2}',
                    style: const TextStyle(fontSize: 11, color: _textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _teal)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  if (!widget.isLoggedIn) {
                    _promptLogin();
                    return;
                  }
                  final cart = Map<String, dynamic>.from(sampleOrder['add_to_cart'] ?? {});
                  final res = await BtbApiService.addToCart(
                    itemId: int.tryParse('${cart['item_id']}') ?? widget.itemId,
                    variantId: int.tryParse('${first['btbprice_id']}') ?? widget.varId,
                    orgSiteId: int.tryParse('${cart['org_site_id']}') ?? 0,
                    selectedItemsVendorId:
                    int.tryParse('${cart['selected_items_vendor_id']}') ?? 0,
                    itemType: 'sample',
                    marketplaceId: widget.marketplaceId,
                    qty: 1,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(res['message']?.toString() ?? 'Sample requested'),
                    backgroundColor: res['success'] == true ? _teal : Colors.red,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Buy sample',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Delivery card ─────────────────────────────────────────────────────
  Widget _buildDeliveryCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Check delivery location',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _pincodeCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter postal / zip code',
                    hintStyle: const TextStyle(fontSize: 12, color: _textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: _checkingDelivery ? null : _checkDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _checkingDelivery
                    ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Check',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
          if (_deliveryMsg.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(_deliveryMsg,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _deliveryMsg.startsWith('✓') ? _teal : Colors.red,
                )),
          ],
        ],
      ),
    );
  }

  // ── Description card ─────────────────────────────────────────────────
  Widget _buildDescriptionCard() {
    final content = _stripHtml((_sampleData['description']?['content'] ?? '').toString());
    if (content.isEmpty) return const SizedBox.shrink();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product description',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.8)),
        ],
      ),
    );
  }

  // ── Specs card ────────────────────────────────────────────────────────
  Widget _buildSpecsCard() {
    final info = (_sampleData['additional_info'] as List?) ?? [];
    if (info.isEmpty) return const SizedBox.shrink();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product specifications',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: info.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.4),
            itemBuilder: (_, i) {
              final item = Map<String, dynamic>.from(info[i] as Map);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${item['title'] ?? ''}'.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 3),
                    Text('${item['value'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: _textPrimary)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Reviews card ──────────────────────────────────────────────────────
  Widget _buildReviewsCard() {
    final reviews = (_reviewData['reviews'] as List?) ?? [];
    final avg = _reviewData['avg_rating']?.toString() ?? '0';
    final total = _reviewData['total_reviews']?.toString() ?? '0';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Buyer reviews',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
              Text('★ $avg ($total)',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const Text('No reviews yet.', style: TextStyle(fontSize: 12, color: _textMuted))
          else
            ...reviews.take(3).map((r) {
              final rev = Map<String, dynamic>.from(r as Map);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFEFE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          rev['profile_pic']?.toString() ??
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${rev['name'] ?? 'Anonymous'}',
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary)),
                              const SizedBox(height: 2),
                              Text('${rev['date'] ?? ''}',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            ],
                          )),
                      Text('★' * (int.tryParse('${rev['rating'] ?? 0}') ?? 0),
                          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 15)),
                    ]),
                    const SizedBox(height: 10),
                    Text(_stripHtml('${rev['review'] ?? ''}'),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.6)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _stripHtml(String input) =>
      input.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('&nbsp;', ' ').trim();
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFDCEBEA)),
    ),
    child: child,
  );
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
        color: const Color(0xFFEEFCFB), borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
  );
}

class _SellerTile extends StatelessWidget {
  final String name;
  final String subtitle;
  const _SellerTile({required this.name, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FBFB),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFDCEBEA)),
    ),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
            width: 50, height: 50, fit: BoxFit.cover),
      ),
      const SizedBox(width: 12),
      Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 3),
              Text(subtitle.isEmpty ? 'Verified Manufacturer' : subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          )),
    ]),
  );
}

class _SlabRow extends StatelessWidget {
  final Map<String, dynamic> slab;
  final bool isSelected;
  final VoidCallback onTap;
  const _SlabRow({required this.slab, required this.isSelected, required this.onTap});

  static const _teal = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    final minQty = slab['min_qty'];
    final maxQty = slab['max_qty'];
    final unit = slab['unit'] ?? 'Units';
    final price = double.tryParse('${slab['final_price'] ?? slab['price'] ?? 0}') ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEFCFB) : const Color(0xFFF8FBFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _teal : const Color(0xFFDCEBEA),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: _teal,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 6),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$minQty – $maxQty $unit',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              ]),
            ]),
            RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _teal)),
                    const TextSpan(
                        text: '/unit',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF64748B))),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _QtyCtrl extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _QtyCtrl({required this.ctrl, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDCEBEA)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: onDecrement,
          color: const Color(0xFF0F766E),
          padding: const EdgeInsets.symmetric(horizontal: 12)),
      SizedBox(
        width: 56,
        height: 42,
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12)),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
      ),
      IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: onIncrement,
          color: const Color(0xFF0F766E),
          padding: const EdgeInsets.symmetric(horizontal: 12)),
    ]),
  );
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _SummaryItem({required this.label, required this.value, this.valueColor = const Color(0xFF111827)});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFDCEBEA)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700, letterSpacing: 0.4)),
      const SizedBox(height: 4),
      Text(value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
    ]),
  );
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _OutlineBtn({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
    ),
  );
}

class _FillBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _FillBtn({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Gallery card
// ─────────────────────────────────────────────────────────────────────────────
class _GalleryCard extends StatelessWidget {
  final List<String> images;
  final int currentIdx;
  final void Function(int) onTap;
  const _GalleryCard({required this.images, required this.currentIdx, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFDCEBEA)),
    ),
    padding: const EdgeInsets.all(14),
    child: Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          images[currentIdx.clamp(0, images.length - 1)],
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(height: 260, color: const Color(0xFFF1F5F9)),
        ),
      ),
      const SizedBox(height: 10),
      if (images.length > 1)
        SizedBox(
          height: 62,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (_, i) {
              final sel = currentIdx == i;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? const Color(0xFF0F766E) : Colors.transparent,
                      width: 2,
                    ),
                    image: DecorationImage(image: NetworkImage(images[i]), fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
    ]),
  );
}