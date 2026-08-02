import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — points at the PHP endpoint file
// ─────────────────────────────────────────────────────────────────────────────
class BrandingApiConfig {
  static const String baseurl = "${baseUrl}new_apis/brand_details_api.php";
}

// ─────────────────────────────────────────────────────────────────────────────
// API Service — one method per `action` in brand_details_api.php.
// ─────────────────────────────────────────────────────────────────────────────
class BrandingApiService {
  static Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse(BrandingApiConfig.baseurl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint(
          '[BrandingApiService] action=${body['action']} status=${res.statusCode} body=${res.body}');

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': false, 'message': 'Unexpected response', 'data': null};
    } catch (e) {
      debugPrint('[BrandingApiService] action=${body['action']} error=$e');
      return {'success': false, 'message': 'Network error: $e', 'data': null};
    }
  }

  /// action = get_branding_details
  static Future<Map<String, dynamic>> getBrandingDetails({
    required int brandingId,
  }) {
    return _post({
      'action': 'get_branding_details',
      'branding_id': brandingId,
    });
  }

  /// action = get_same_vendor_brands
  static Future<Map<String, dynamic>> getSameVendorBrands({
    required int brandingId,
  }) {
    return _post({
      'action': 'get_same_vendor_brands',
      'branding_id': brandingId,
    });
  }

  /// action = get_similar_brands
  static Future<Map<String, dynamic>> getSimilarBrands({
    required int brandingId,
  }) {
    return _post({
      'action': 'get_similar_brands',
      'branding_id': brandingId,
    });
  }

  /// action = add_brand_to_cart
  static Future<Map<String, dynamic>> addBrandToCart({
    required int brandId,
    int qty = 1,
  }) {
    return _post({
      'action': 'add_brand_to_cart',
      'brand_id': brandId,
      'qty': qty,
    });
  }

  /// action = add_brand_to_wishlist
  static Future<Map<String, dynamic>> addBrandToWishlist({
    required int brandId,
  }) {
    return _post({
      'action': 'add_brand_to_wishlist',
      'brand_id': brandId,
    });
  }

  /// action = add_branding_package_to_cart
  static Future<Map<String, dynamic>> addBrandingPackageToCart({
    required int brandId,
    required int packageId,
    int qty = 1,
  }) {
    return _post({
      'action': 'add_branding_package_to_cart',
      'brand_id': brandId,
      'package_id': packageId,
      'qty': qty,
    });
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

  /// action = set_pincode
  static Future<Map<String, dynamic>> setPincode(String pincode) {
    return _post({'action': 'set_pincode', 'pincode': pincode});
  }

  /// action = ask_branding_quotation
  static Future<Map<String, dynamic>> askBrandingQuotation({
    required String brandId,
    required int quantityRequired,
    required String targetPrice,
    required String timeline,
    required String packagingCustomization,
    required String logoCustomization,
    required String preferredColors,
    required String brandLabelType,
    required String additionalRequirements,
  }) {
    return _post({
      'action': 'ask_branding_quotation',
      'brand_id': brandId,
      'quantity_required': quantityRequired,
      'target_price': targetPrice,
      'timeline': timeline,
      'packaging_customization': packagingCustomization,
      'logo_customization': logoCustomization,
      'preferred_colors': preferredColors,
      'brand_label_type': brandLabelType,
      'additional_requirements': additionalRequirements,
    });
  }

  /// action = get_branding_cart
  static Future<Map<String, dynamic>> getBrandingCart() {
    return _post({'action': 'get_branding_cart'});
  }

  /// action = chat_with_brand_seller
  static Future<Map<String, dynamic>> chatWithBrandSeller({
    required int brandId,
  }) {
    return _post({'action': 'chat_with_brand_seller', 'brand_id': brandId});
  }

  /// action = send_brand_message
  static Future<Map<String, dynamic>> sendBrandMessage({
    required int brandId,
    required String message,
  }) {
    return _post({
      'action': 'send_brand_message',
      'brand_id': brandId,
      'message': message,
    });
  }

  /// action = get_brand_chat
  static Future<Map<String, dynamic>> getBrandChat({required int brandId}) {
    return _post({'action': 'get_brand_chat', 'brand_id': brandId});
  }

  /// action = brand_chat_list
  static Future<Map<String, dynamic>> brandChatList() {
    return _post({'action': 'brand_chat_list'});
  }

  /// action = delete_brand_chat
  static Future<Map<String, dynamic>> deleteBrandChat({required int brandId}) {
    return _post({'action': 'delete_brand_chat', 'brand_id': brandId});
  }
}

class BrandingDetailPage extends StatefulWidget {
  final String productId;
  const BrandingDetailPage({super.key, required this.productId});

  @override
  State<BrandingDetailPage> createState() => _BrandingDetailPageState();
}

class _BrandingDetailPageState extends State<BrandingDetailPage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _brandRawDetails = {};

  List<String> _images = [];
  List<Map<String, dynamic>> _slabs = [];
  List<dynamic> _services = [];
  List<dynamic> _compliance = [];

  int _currentImageIdx = 0;

  bool _customLogo = false;
  bool _customBox = false;
  bool _compliancePack = false;

  int _selectedSlabIdx = 0;
  int _quantity = 500;

  String _brandName = '';
  String _brandDescription = '';
  String _vendorName = '';
  String _vendorInitials = 'NV';

  final _qtyCtrl = TextEditingController(text: '500');
  final _locationCtrl = TextEditingController();
  final _timelineCtrl = TextEditingController(text: '30 Days');
  final _packagingCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  bool _formLogoCustom = true;

  @override
  void initState() {
    super.initState();
    _fetchPageDetailsPipeline();

    _qtyCtrl.addListener(() {
      final q = int.tryParse(_qtyCtrl.text) ?? 0;
      if (q != _quantity) {
        setState(() {
          _quantity = q;
          _autoMatchSlabTier(q);
        });
      }
    });
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _locationCtrl.dispose();
    _timelineCtrl.dispose();
    _packagingCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPageDetailsPipeline() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Properly handle String / Base64 IDs passed from previous screen
      int parsedId = int.tryParse(widget.productId) ?? 0;
      if (parsedId == 0 && widget.productId.isNotEmpty) {
        try {
          // Handle Base64 encoded IDs if passed (e.g., "vw==" -> "1")
          final decodedString = utf8.decode(base64.decode(widget.productId));
          parsedId = int.tryParse(decodedString) ?? 0;
        } catch (_) {
          // Fallback if not valid Base64
        }
      }

      debugPrint(
          '[BrandingDetailPage] widget.productId="${widget.productId}" -> resolved branding_id=$parsedId');

      final response = await BrandingApiService.getBrandingDetails(
        brandingId: parsedId,
      );

      if (response['success'] != true) {
        throw Exception(response['message']?.toString() ??
            'Failed to load branding details.');
      }

      final data = Map<String, dynamic>.from(response['data'] ?? {});

      _brandRawDetails = data;

      // 2. Map Name/Title (Handles 'offer_title', 'brand_name', or 'title')
      _brandName = data['offer_title'] ??
          data['brand_name'] ??
          data['title'] ??
          'Custom Branding Service';

      // Map Description
      _brandDescription =
          data['description'] ?? 'No text description parameters registered.';

      // Map Vendor
      _vendorName = data['vendor_name']?.toString() ??
          (data['vendor'] is Map
              ? (data['vendor'] as Map)['name']?.toString()
              : null) ??
          'Authorized Manufacturer';

      if (_vendorName.isNotEmpty) {
        _vendorInitials = _vendorName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();
      }

      // 3. Map Images array safely
      final imageList = data['images'] as List? ?? [];
      _images = imageList
          .map((img) =>
      img['image_path']?.toString() ??
          img['image']?.toString() ??
          img['image_url']?.toString() ??
          'https://placehold.co/600x400/png')
          .toList();

      if (_images.isEmpty) {
        _images.add('https://placehold.co/600x400/png');
      }

      // 4. Map Services (Handles 'data_title' or 'title')
      final rawServices = data['services'] as List? ?? [];
      _services = rawServices.map((srv) {
        return {
          ...Map<String, dynamic>.from(srv is Map ? srv : {}),
          'title': srv['data_title'] ?? srv['title'] ?? 'Service Option',
        };
      }).toList();

      // Map Compliance
      _compliance = data['compliance'] as List? ?? [];

      // 5. Map Packages / Wholesale Slabs (Handles 'data_title' & 'moq')
      final dynamicPackages = data['packages'] as List? ?? [];
      if (dynamicPackages.isNotEmpty) {
        _slabs = dynamicPackages.map((pkg) {
          final double priceVal =
              double.tryParse(pkg['price']?.toString() ?? '0.0') ?? 0.0;

          // Backend sends 'moq', fallback to 'min_qty'
          final int minQtyVal = int.tryParse(
              pkg['moq']?.toString() ?? pkg['min_qty']?.toString() ?? '500') ??
              500;

          // Backend sends 'data_title', fallback to 'title'
          final String titleVal = pkg['data_title']?.toString() ??
              pkg['title']?.toString() ??
              '${minQtyVal}+ units';

          return {
            'id': pkg['id'],
            'label': titleVal,
            'min': minQtyVal,
            'price': priceVal,
            'lead': pkg['delivery_days'] != null
                ? 'Est. ${pkg['delivery_days']} days'
                : 'Est. 15-30 days',
          };
        }).toList();

        // Sort slabs ascending by minimum quantity bounds
        _slabs.sort((a, b) => (a['min'] as int).compareTo(b['min'] as int));
      } else {
        // Fallback default tier if packages list is empty
        final int baseMoq =
            int.tryParse(data['moq']?.toString() ?? '500') ?? 500;
        _slabs = [
          {
            'id': 0,
            'label': 'Standard Bulk',
            'min': baseMoq,
            'price': 0.00,
            'lead': 'Est. 30 days'
          }
        ];
      }

      // Initialize state selections
      _selectedSlabIdx = 0;
      _quantity = _slabs[0]['min'];
      _qtyCtrl.text = _quantity.toString();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _submitQuotationFormPipeline() async {
    if (_locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Please specify a delivery tracking location endpoint.'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    Navigator.pop(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await BrandingApiService.askBrandingQuotation(
        brandId: widget.productId,
        quantityRequired: _quantity,
        targetPrice: _unitPrice.toStringAsFixed(2),
        timeline: _timelineCtrl.text,
        packagingCustomization: _packagingCtrl.text.trim().isNotEmpty
            ? _packagingCtrl.text.trim()
            : 'Standard packaging configuration context line.',
        logoCustomization: _formLogoCustom ? 'Yes — custom logo' : 'No',
        preferredColors: 'See client design instruction documents block index.',
        brandLabelType: 'Silk Screen Overlay Custom Labeling Layer Process',
        additionalRequirements: _otherCtrl.text.trim(),
      );

      if (response['success'] != true) {
        throw Exception(response['message']?.toString() ??
            'Failed to submit branding quotation request.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ??
                'Inquiry data packet trace uploaded successfully.'),
            backgroundColor: const Color(0xFF006565),
          ),
        );
      }

      _locationCtrl.clear();
      _packagingCtrl.clear();
      _otherCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload Exception Trace: ${e.toString()}'),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _autoMatchSlabTier(int currentQuantity) {
    if (_slabs.isEmpty) return;
    int matchedIdx = 0;
    for (int i = 0; i < _slabs.length; i++) {
      if (currentQuantity >= _slabs[i]['min']) {
        matchedIdx = i;
      }
    }
    setState(() {
      _selectedSlabIdx = matchedIdx;
    });
  }

  double get _unitPrice {
    if (_slabs.isEmpty || _selectedSlabIdx >= _slabs.length) return 0.0;
    return _slabs[_selectedSlabIdx]['price'];
  }

  double get _customizationCost {
    double cost = 0.0;
    if (_customLogo) cost += 0.15;
    if (_customBox) cost += 0.45;
    return cost;
  }

  double get _subtotal {
    return _quantity * (_unitPrice + _customizationCost);
  }

  void _selectSlab(int idx) {
    setState(() {
      _selectedSlabIdx = idx;
      _quantity = _slabs[idx]['min'];
      _qtyCtrl.text = _quantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _brandRawDetails.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFFCF9F8),
        body:
        Center(child: CircularProgressIndicator(color: Color(0xFF006565))),
      );
    }

    if (_errorMessage != null && _brandRawDetails.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFCF9F8),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Data Connection dropped:\n$_errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchPageDetailsPipeline,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565)),
                  child: const Text('Retry Execution Pipeline',
                      style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBreadcrumbs(),
                _buildImageGallery(),
                _buildHorizontalThumbnails(),
                _buildProductHeader(),
                _buildWholesaleTiers(),
                _buildSellerCard(),
                _buildCustomizationServices(),
                if (_services.isNotEmpty) _buildExtraServicesWidgetsBlock(),
                _buildRequestSample(),
                _buildTechnicalSpecs(),
                _buildFooter(),
              ],
            ),
          ),
          _buildStickyBottomActionBar(),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.5),
              child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF006565))),
            )
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('Marketplace',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          Icon(Icons.chevron_right, size: 14, color: Colors.grey),
          Text('B2B Branding',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          Icon(Icons.chevron_right, size: 14, color: Colors.grey),
          Text('Details Vector',
              style: TextStyle(
                  color: Color(0xFF006565),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 320,
      color: const Color(0xFFF6F3F2),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: _images.length,
            onPageChanged: (idx) {
              setState(() {
                _currentImageIdx = idx;
              });
            },
            itemBuilder: (context, idx) {
              return Image.network(
                _images[idx],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey),
              );
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF006565),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('TOP SELLER',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)
                    ],
                  ),
                  child: const Text('VERIFIED FACILITY',
                      style: TextStyle(
                          color: Color(0xFF006565),
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (idx) {
                final isCurrent = _currentImageIdx == idx;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF006565)
                        : const Color(0xFFBDC9C8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalThumbnails() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _images.length,
        itemBuilder: (context, idx) {
          final isSelected = _currentImageIdx == idx;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentImageIdx = idx;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF006565)
                        : Colors.transparent,
                    width: 2),
                image: DecorationImage(
                    image: NetworkImage(_images[idx]), fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFD4E6E5),
                    borderRadius: BorderRadius.circular(4)),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 2),
                    Text('4.9',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006567))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('(Verified Source)',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              const Text('#1 Top Supplier',
                  style: TextStyle(
                      color: Color(0xFF006565),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_brandName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1B1B))),
          const SizedBox(height: 6),
          Text(_brandDescription,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF3E4949), height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildWholesaleTiers() {
    if (_slabs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Wholesale Tiers Matrix',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFE3FFFE),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('Base MOQ: ${_slabs.first['min']} units',
                    style: const TextStyle(
                        color: Color(0xFF006565),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_slabs.length, (idx) {
              final isSelected = _selectedSlabIdx == idx;
              final slab = _slabs[idx];
              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectSlab(idx),
                  child: Container(
                    margin: EdgeInsets.only(
                        left: idx == 0 ? 0 : 4,
                        right: idx == _slabs.length - 1 ? 0 : 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                      isSelected ? const Color(0xFFF0F7F7) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? const Color(0xFF006565)
                              : const Color(0xFFBDC9C8).withValues(alpha: 0.4),
                          width: isSelected ? 2 : 1),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                            color:
                            const Color(0xFF006565).withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                                child: Text(slab['label'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11))),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF006565), size: 12),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('₹${(slab['price'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006565),
                                fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(slab['lead'],
                            style: const TextStyle(
                                fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBDC9C8).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: const Color(0xFF008080),
                    borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(_vendorInitials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                            child: Text(_vendorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14))),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            color: Color(0xFF006565), size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('Global Verified Enterprise Supplier Group',
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RESPONSE',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(height: 2),
                      Text('99.1% / <2h',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006565))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ON-TIME PROD.',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                      SizedBox(height: 2),
                      Text('99.8%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006565))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF006565)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Contact Manufacturer',
                  style: TextStyle(
                      color: Color(0xFF006565),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customization Parameters',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _buildCustomServiceCheckbox(
            title: 'Logo Labeling Layer',
            desc: 'Industrial screen overlay options',
            priceText: '+₹0.15',
            value: _customLogo,
            onChanged: (val) {
              setState(() {
                _customLogo = val ?? false;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildCustomServiceCheckbox(
            title: 'Custom FSC Container Pack',
            desc: 'Premium structural casing design',
            priceText: '+₹0.45',
            value: _customBox,
            onChanged: (val) {
              setState(() {
                _customBox = val ?? false;
              });
            },
          ),
          _buildCustomServiceCheckbox(
            title: 'Regulatory Audit Package',
            desc: 'CoA and safety verification sheets',
            priceText: 'FREE',
            value: _compliancePack,
            onChanged: (val) {
              setState(() {
                _compliancePack = val ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomServiceCheckbox({
    required String title,
    required String desc,
    required String priceText,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withValues(alpha: 0.3)),
      ),
      child: CheckboxListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(desc,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
        secondary: Text(priceText,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
                fontSize: 13)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF006565),
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildExtraServicesWidgetsBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Included Services Matrix',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _services.map((srv) {
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFFD4E6E5).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                    srv['title']?.toString() ?? 'Service Variant Option',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF006565),
                        fontWeight: FontWeight.w500)),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildRequestSample() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF006565).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF006565).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request Engineering Sample',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 2),
                Text(
                    'Attest build consistency parameters before production line setup.',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('₹15.00',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006565),
                      fontSize: 18)),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0,
                ),
                child: const Text('Order',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSpecs() {
    if (_compliance.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Specifications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          // Replaced GridView with LayoutBuilder + Wrap for precise intrinsic layout
          LayoutBuilder(
            builder: (context, constraints) {
              final double cellWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _compliance.map((metric) {
                  return SizedBox(
                    width: cellWidth,
                    height: cellWidth / 2.2, // Matches childAspectRatio: 2.2
                    child: _buildSpecCell(
                      metric['compliance_type'] ?? 'Verification',
                      metric['compliance_value'] ?? 'Passed Audit',
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildSpecCell(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFD4E6E5).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF006565))),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: const Column(
        children: [
          Text('© 2026 LuxeMarket B2B Solutions Pipeline.',
              style: TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStickyBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            border: const Border(
                top: BorderSide(color: Color(0xFFBDC9C8), width: 0.5))),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('EST. SUBTOTAL',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('₹${_subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006565))),
                Text(
                    '${_quantity.toString()} Units • ₹${(_unitPrice + _customizationCost).toStringAsFixed(2)}/unit',
                    style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => _showQuotationDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Start Inquiry',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuotationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20))),
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quotation Request Pipeline',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006565))),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Quantity Required',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          isDense: true),
                    ),
                    const SizedBox(height: 12),
                    const Text('Shipping Destination',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _locationCtrl,
                      decoration: InputDecoration(
                          hintText: 'City, Country',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          isDense: true),
                    ),
                    const SizedBox(height: 12),
                    const Text('Required Timeline',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _timelineCtrl.text.contains('Days')
                              ? _timelineCtrl.text
                              : '30 Days',
                          isExpanded: true,
                          onChanged: (val) {
                            final selectedVal = val ?? '30 Days';
                            setModalState(() {
                              _timelineCtrl.text = selectedVal;
                            });
                            setState(() {
                              _timelineCtrl.text = selectedVal;
                            });
                          },
                          items: ['7 Days', '15 Days', '30 Days', '45+ Days']
                              .map((e) {
                            return DropdownMenuItem(value: e, child: Text(e));
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Logo Customization Required',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      value: _formLogoCustom,
                      onChanged: (val) {
                        final selectedVal = val ?? false;
                        setModalState(() {
                          _formLogoCustom = selectedVal;
                        });
                        setState(() {
                          _formLogoCustom = selectedVal;
                        });
                      },
                      activeColor: const Color(0xFF006565),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    const Text('Packaging Details & Color Notes',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _packagingCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                          hintText:
                          'Preferred colors, styling parameters, box structural constraints...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 12),
                    const Text('Other Requirements & Notes',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _otherCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                          hintText:
                          'Certificate criteria, target benchmarks, extra line processing logs...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitQuotationFormPipeline,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0),
                        child: const Text('Submit Request Packet',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}