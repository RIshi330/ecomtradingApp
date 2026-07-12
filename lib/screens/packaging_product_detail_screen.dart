import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../core/theme/app_theme.dart';
import 'packaging_cart_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import '../app_constants.dart';

class PackagingProductDetailPage extends StatefulWidget {
  final String productId;
  final String? variantId;

  const PackagingProductDetailPage({
    super.key,
    required this.productId,
    this.variantId,
  });

  @override
  State<PackagingProductDetailPage> createState() =>
      _PackagingProductDetailPageState();
}

class _PackagingProductDetailPageState
    extends State<PackagingProductDetailPage> {
  bool _isLoading = true;
  bool _isLoadingDetail = false;
  bool _isSubmitting = false;
  bool _isQuotationSubmitting = false;
  String _error = '';

  Map<String, dynamic>? _product;
  Map<String, dynamic>? _currentVariant;
  List<Map<String, dynamic>> _variants = [];
  List<Map<String, dynamic>> _pricing = [];
  bool _alreadyPurchased = false;

  // Unified list of all variants (selected variant + other variants)
  final List<Map<String, dynamic>> _allVariants = [];

  // Selections
  String _selectedVariantId = '';
  String _selectedSize = '';
  String _selectedMaterial = '';

  List<String> _images = [];
  int _currentImage = 0;
  int _quantity = 500;

  // Pincode validation state
  final TextEditingController _pincodeController = TextEditingController();
  String _pincodeMessage = '';
  bool _isPincodeValid = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final String initialVarId = (widget.variantId == null || widget.variantId!.isEmpty) ? '0' : widget.variantId!;
      await _fetchProductDetail(initialVarId);
    } catch (e) {
      setState(() {
        _error = "Failed to load product: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProductDetail(String varId) async {
    setState(() {
      _isLoadingDetail = true;
    });

    try {
      final response = await Database().getJsonData(
        {
          'action': 'get_product_detail',
          'package_product_id': widget.productId,
          'package_product_var_id': varId,
        },
        endpoint: 'new_apis/package_product_detail_API.php',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          _product = Map<String, dynamic>.from(data['product'] ?? {});
          _variants = List<Map<String, dynamic>>.from(data['variants'] ?? []);
          _pricing = List<Map<String, dynamic>>.from(data['pricing'] ?? []);
          _alreadyPurchased = data['already_purchased'] ?? false;
          _currentVariant = data['current_variant'] != null 
              ? Map<String, dynamic>.from(data['current_variant']) 
              : null;
          _selectedVariantId = _currentVariant != null 
              ? (_currentVariant!['id']?.toString() ?? varId)
              : varId;

          // Rebuild unified variants list
          _allVariants.clear();
          if (_currentVariant != null) {
            _allVariants.add(_currentVariant!);
          }
          _allVariants.addAll(_variants);

          // Update active selections
          if (_currentVariant != null) {
            _selectedSize = _currentVariant!['size']?.toString() ?? 'NA';
            _selectedMaterial = _currentVariant!['material_color']?.toString() ?? 'NA';
            
            // Set initial quantity to min_qty of the first pricing tier if available
            if (_pricing.isNotEmpty) {
              _quantity = int.tryParse(_pricing.first['min_qty']?.toString() ?? '500') ?? 500;
            }
          }

          // Gather images
          final List<dynamic> imageList = _product?['images'] ?? [];
          _images = imageList
              .map((img) => img['image_url']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .toList();

          if (_images.isEmpty) {
            _images = [
              'https://res.cloudinary.com/deadpool/image/upload/v1596902174/vful0bm6qb9gre2lad4o.jpg'
            ];
          }
          _currentImage = 0;
          _error = '';
        });
      } else {
        setState(() {
          _error = response['message']?.toString() ?? "Failed to fetch details";
        });
      }
    } catch (e) {
      setState(() {
        _error = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoadingDetail = false;
        _isLoading = false;
      });
    }
  }

  // Find a variant that satisfies selected size and material
  void _onSizeSelected(String size) {
    final matchingVar = _allVariants.firstWhere(
      (v) => (v['size']?.toString() ?? 'NA') == size && (v['material_color']?.toString() ?? 'NA') == _selectedMaterial,
      orElse: () => _allVariants.firstWhere(
        (v) => (v['size']?.toString() ?? 'NA') == size,
        orElse: () => {},
      ),
    );

    if (matchingVar.isNotEmpty) {
      final newVarId = matchingVar['id']?.toString() ?? matchingVar['variant_id']?.toString() ?? '';
      if (newVarId.isNotEmpty) {
        _fetchProductDetail(newVarId);
      }
    }
  }

  void _onMaterialSelected(String material) {
    final matchingVar = _allVariants.firstWhere(
      (v) => (v['material_color']?.toString() ?? 'NA') == material && (v['size']?.toString() ?? 'NA') == _selectedSize,
      orElse: () => _allVariants.firstWhere(
        (v) => (v['material_color']?.toString() ?? 'NA') == material,
        orElse: () => {},
      ),
    );

    if (matchingVar.isNotEmpty) {
      final newVarId = matchingVar['id']?.toString() ?? matchingVar['variant_id']?.toString() ?? '';
      if (newVarId.isNotEmpty) {
        _fetchProductDetail(newVarId);
      }
    }
  }

  double _getActiveUnitPrice() {
    for (var tier in _pricing) {
      int min = int.tryParse(tier['min_qty']?.toString() ?? '0') ?? 0;
      int max = int.tryParse(tier['max_qty']?.toString() ?? '99999999') ?? 99999999;
      if (_quantity >= min && _quantity <= max) {
        return double.tryParse(tier['price']?.toString() ?? '0') ?? 0.0;
      }
    }
    if (_pricing.isNotEmpty) {
      return double.tryParse(_pricing.first['price']?.toString() ?? '0') ?? 0.0;
    }
    return double.tryParse(_currentVariant?['mrp']?.toString() ?? '0') ?? 0.0;
  }

  int _getActiveBtbPriceId() {
    for (var tier in _pricing) {
      int min = int.tryParse(tier['min_qty']?.toString() ?? '0') ?? 0;
      int max = int.tryParse(tier['max_qty']?.toString() ?? '99999999') ?? 99999999;
      if (_quantity >= min && _quantity <= max) {
        return int.tryParse(tier['id']?.toString() ?? '0') ?? 0;
      }
    }
    if (_pricing.isNotEmpty) {
      return int.tryParse(_pricing.first['id']?.toString() ?? '0') ?? 0;
    }
    return 0;
  }

  Future<void> _addToCart({required bool isSample}) async {
    setState(() => _isSubmitting = true);
    try {
      final btbpriceId = _getActiveBtbPriceId();
      final action = isSample ? 'add_to_cart_sample' : 'add_to_cart';

      final response = await Database().getJsonData(
        {
          'action': action,
          'package_product_id': widget.productId,
          'product_variant_id': _selectedVariantId,
          'btbprice_id': btbpriceId,
          'item_type': isSample ? 'sample' : 'main',
        },
        endpoint: 'new_apis/package_product_detail_API.php',
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isSample ? "Sample added to cart successfully!" : "Product added to cart successfully!",
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: AppTheme.primary,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: "Go to Cart",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PackagingCartScreen()),
                  );
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message']?.toString() ?? "Failed to add to cart",
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e", style: const TextStyle(fontSize: 12)),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _checkPincode() {
    final code = _pincodeController.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() {
        _pincodeMessage = 'Please enter a valid 6-digit pincode';
        _isPincodeValid = false;
      });
      return;
    }
    setState(() {
      _pincodeMessage = 'Delivery available to $code. Estimated delivery: 3-5 days.';
      _isPincodeValid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text("Product Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20, color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text("Error", style: TextStyle(fontSize: 14, color: AppTheme.error)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20, color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                const SizedBox(height: 12),
                Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  onPressed: _loadInitialData,
                  child: const Text("Retry", style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
        ),
      );
    }

    final sizes = _allVariants.map((v) => v['size']?.toString() ?? 'NA').toSet().toList();
    final materials = _allVariants.map((v) => v['material_color']?.toString() ?? 'NA').toSet().toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "PackMarket B2B",
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primary, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: AppTheme.primary, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PackagingCartScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGallery(),

                const SizedBox(height: 16),

                Row(
                  children: const [
                    Icon(Icons.star, color: AppTheme.primary, size: 14),
                    Icon(Icons.star, color: AppTheme.primary, size: 14),
                    Icon(Icons.star, color: AppTheme.primary, size: 14),
                    Icon(Icons.star, color: AppTheme.primary, size: 14),
                    Icon(Icons.star_half, color: AppTheme.primary, size: 14),
                    SizedBox(width: 6),
                    Text("4.8 (120 reviews)", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  _product?['title']?.toString() ?? "Eco-Friendly Corrugated Box",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Brand: ${_product?['brand_name'] ?? 'Generic'} • Manufacturer: ${_product?['manufacturer'] ?? 'Standard'}",
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 14),

                _deliveryCard(),

                const SizedBox(height: 16),

                if (sizes.isNotEmpty && sizes.first != 'NA') _sizeSelector(sizes),

                const SizedBox(height: 14),

                if (materials.isNotEmpty && materials.first != 'NA') _materialSelector(materials),

                const SizedBox(height: 16),

                _pricingSection(),

                const SizedBox(height: 16),

                _specificationGrid(),

                const SizedBox(height: 16),

                _sellerCard(),

                const SizedBox(height: 16),

                _buildQuotationSection(),

                const SizedBox(height: 16),

                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: const Text(
                      "Shipping & Delivery",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Text(
                          "Estimated delivery within 3-5 business days for Metro cities. PAN India shipping available.",
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      )
                    ],
                  ),
                ),

                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: const Text(
                      "Samples Policy",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: Text(
                          "Paid samples available for quality assessment. Samples charge can be adjusted in the bulk order.",
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingDetail)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _buildGallery() {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _images[_currentImage],
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 240,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Best Seller",
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if ((_product?['sustainability'] as List?)?.isNotEmpty ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _product!['sustainability'].first.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              final isSelected = _currentImage == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImage = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      _images[index],
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 20),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _deliveryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DELIVERY DETAILS",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: "Enter 6-digit Pincode",
                      prefixIcon: const Icon(Icons.location_on, size: 16, color: AppTheme.primary),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: _checkPincode,
                child: const Text("Check", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_pincodeMessage.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _pincodeMessage,
              style: TextStyle(
                fontSize: 10,
                color: _isPincodeValid ? AppTheme.primary : AppTheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sizeSelector(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT SIZE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: sizes.map((size) {
            bool selected = size == _selectedSize;

            return ChoiceChip(
              label: Text(size, style: TextStyle(fontSize: 11, color: selected ? AppTheme.primary : AppTheme.textSecondary)),
              selected: selected,
              selectedColor: AppTheme.primary.withOpacity(.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: selected ? AppTheme.primary : Colors.grey.shade300),
              ),
              showCheckmark: false,
              onSelected: (_) => _onSizeSelected(size),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _materialSelector(List<String> materials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "MATERIAL / COLOR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: materials.map((material) {
            bool selected = material == _selectedMaterial;

            return ChoiceChip(
              label: Text(material, style: TextStyle(fontSize: 11, color: selected ? AppTheme.primary : AppTheme.textSecondary)),
              selected: selected,
              selectedColor: AppTheme.primary.withOpacity(.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: selected ? AppTheme.primary : Colors.grey.shade300),
              ),
              showCheckmark: false,
              onSelected: (_) => _onMaterialSelected(material),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _pricingSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "WHOLESALE PRICING",
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          if (_pricing.isEmpty)
            const Text("No wholesale pricing available for this variant.", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _pricing.map((tier) {
                final int min = int.tryParse(tier['min_qty']?.toString() ?? '0') ?? 0;
                final int max = int.tryParse(tier['max_qty']?.toString() ?? '99999999') ?? 99999999;
                final double price = double.tryParse(tier['price']?.toString() ?? '0') ?? 0.0;
                final bool highlight = _quantity >= min && _quantity <= max;

                return Column(
                  children: [
                    Text(
                      "$min+",
                      style: TextStyle(
                        fontSize: 10,
                        color: highlight ? AppTheme.primary : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: highlight ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "GST EXTRA (GST rate is ${_product?['gst'] ?? 18}%). Custom printing assistance is available.",
                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specificationGrid() {
    final specs = [
      ["Material Type", _currentVariant?['material_color'] ?? "Recycled Kraft"],
      ["SUK / SKU", _product?['SUK'] ?? "PK-001"],
      ["GST Applicable", "${_product?['gst'] ?? 18}% extra"],
      ["Dimensions", _currentVariant?['size'] ?? "Standard Size"],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: specs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                specs[index][0],
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
              ),
              const SizedBox(height: 2),
              Text(
                specs[index][1],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sellerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary,
                radius: 16,
                child: Text(
                  (_product?['vendor_name']?.toString() ?? "GS").substring(0, 2).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product?['vendor_name']?.toString() ?? "Global Pack Solutions",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
                    ),
                    const Text(
                      "A Grade Manufacturer • Verification Passed",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  minimumSize: const Size(60, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: () {},
                child: const Text("Profile", style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.chat, size: 14, color: AppTheme.primary),
                    label: const Text("Chat", style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.call, size: 14),
                    label: const Text("Call Vendor", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final double unitPrice = _getActiveUnitPrice();
    final double totalPrice = unitPrice * _quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_quantity > 100) _quantity -= 100;
                    });
                  },
                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primary, size: 20),
                ),
                Text(
                  _quantity.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _quantity += 100;
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 20),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    Text(
                      "(₹${unitPrice.toStringAsFixed(2)} / unit)",
                      style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isSubmitting ? null : () => _addToCart(isSample: true),
                      icon: const Icon(Icons.request_quote, size: 16, color: AppTheme.primary),
                      label: const Text("Sample", style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isSubmitting ? null : () => _addToCart(isSample: false),
                      icon: _isSubmitting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : const Icon(Icons.shopping_cart, size: 16),
                      label: const Text("Add Cart", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotationSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.edit_note, color: AppTheme.primary, size: 18),
              SizedBox(width: 6),
              Text(
                "Custom Branding & Quotation",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Request custom sizes, custom logo prints, or bulk volume discounts directly from this vendor.",
            style: TextStyle(fontSize: 9.5, color: AppTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              onPressed: _openQuotationBottomSheet,
              icon: const Icon(Icons.description, size: 12),
              label: const Text("Submit Custom Quote Form", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _openQuotationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        bool logoCustom = false;
        bool packageCustom = false;
        String packagingNeeded = "Outer Packaging";
        String materialPref = "Cardboard";
        String timeline = "Within 15 Days";
        
        final qtyController = TextEditingController(text: _quantity.toString());
        final addressController = TextEditingController();
        final reqNotesController = TextEditingController();
        final packNotesController = TextEditingController();
        
        List<File> selectedImages = [];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Title Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Request Custom Quotation",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customizations
                          const Text("Customization Needed", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text("Logo Printing", style: TextStyle(fontSize: 11)),
                                  value: logoCustom,
                                  onChanged: (val) => setModalState(() => logoCustom = val ?? false),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  title: const Text("Custom Packing", style: TextStyle(fontSize: 11)),
                                  value: packageCustom,
                                  onChanged: (val) => setModalState(() => packageCustom = val ?? false),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Packaging Type Dropdown
                          const Text("Packaging Needed", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: packagingNeeded,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            items: ["Outer Packaging", "Inner Box", "Complete Bundle", "None"].map((v) {
                              return DropdownMenuItem(value: v, child: Text(v));
                            }).toList(),
                            onChanged: (val) => setModalState(() => packagingNeeded = val ?? "Outer Packaging"),
                          ),
                          const SizedBox(height: 12),

                          // Material Preference Choices
                          const Text("Material Preference", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: ["Kraft Paper", "Cardboard", "Corrugated", "Plastic", "Biodegradable"].map((mat) {
                              final isSelected = materialPref == mat;
                              return ChoiceChip(
                                label: Text(mat, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppTheme.textSecondary)),
                                selected: isSelected,
                                selectedColor: AppTheme.primary,
                                backgroundColor: Colors.grey.shade100,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                onSelected: (selected) {
                                  if (selected) {
                                    setModalState(() => materialPref = mat);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          // Quantity and Timeline Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Quantity Required", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: qtyController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 11),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Expected Timeline", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: timeline,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      items: ["Within 7 Days", "Within 15 Days", "Within 30 Days", "Flexible"].map((v) {
                                        return DropdownMenuItem(value: v, child: Text(v));
                                      }).toList(),
                                      onChanged: (val) => setModalState(() => timeline = val ?? "Within 15 Days"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Requirement Notes
                          const Text("Requirement Details", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: reqNotesController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 11),
                            decoration: InputDecoration(
                              hintText: "Enter custom sizes, shape specifications, print requirements...",
                              hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Packaging Notes
                          const Text("Packaging & Shipping Notes", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: packNotesController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 11),
                            decoration: InputDecoration(
                              hintText: "Enter custom packing or shipping preferences...",
                              hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Delivery Address
                          const Text("Delivery Address", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: addressController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 11),
                            decoration: InputDecoration(
                              hintText: "Enter complete shipping address...",
                              hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Design Images Picker
                          const Text("Reference Designs / Logos (Max 6)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...selectedImages.map((file) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(file, width: 55, height: 55, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            selectedImages.remove(file);
                                          });
                                        },
                                        child: const CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close, size: 8, color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                              if (selectedImages.length < 6)
                                GestureDetector(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final List<XFile>? images = await picker.pickMultiImage();
                                    if (images != null) {
                                      setModalState(() {
                                        for (var img in images) {
                                          if (selectedImages.length < 6) {
                                            selectedImages.add(File(img.path));
                                          }
                                        }
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: const Icon(Icons.add_a_photo, size: 16, color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _isQuotationSubmitting
                                  ? null
                                  : () => _submitQuotation(
                                        logoCustom: logoCustom,
                                        packageCustom: packageCustom,
                                        packagingNeeded: packagingNeeded,
                                        materialPref: materialPref,
                                        qty: qtyController.text,
                                        timeline: timeline,
                                        address: addressController.text,
                                        reqNotes: reqNotesController.text,
                                        packNotes: packNotesController.text,
                                        images: selectedImages,
                                        setModalState: setModalState,
                                      ),
                              child: _isQuotationSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                  : const Text("Submit Quotation Request", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitQuotation({
    required bool logoCustom,
    required bool packageCustom,
    required String packagingNeeded,
    required String materialPref,
    required String qty,
    required String timeline,
    required String address,
    required String reqNotes,
    required String packNotes,
    required List<File> images,
    required StateSetter setModalState,
  }) async {
    if (qty.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantity is required", style: TextStyle(fontSize: 11)), backgroundColor: AppTheme.error),
      );
      return;
    }

    setModalState(() => _isQuotationSubmitting = true);

    try {
      final sessionId = await Database().getSessionId();
      final url = Uri.parse("$baseUrl" "new_apis/submit_quotation_API.php");//biswajit

      final request = http.MultipartRequest("POST", url);
      request.headers.addAll({
        'SESSION-ID': sessionId ?? '',
        'APP_ID': appId.toString(),
      });

      request.fields['product_id'] = _selectedVariantId;
      request.fields['packaging_needed'] = packagingNeeded;
      request.fields['material_preference'] = materialPref;
      request.fields['quantityRequired'] = qty;
      request.fields['timeline'] = timeline;
      request.fields['deliveryAddress'] = address;
      request.fields['requirementNotes'] = reqNotes;
      request.fields['packagingNotes'] = packNotes;
      if (logoCustom) request.fields['logoCustomization'] = '1';
      if (packageCustom) request.fields['packageCustomization'] = '1';

      // Add files
      for (int i = 0; i < images.length; i++) {
        final stream = http.ByteStream(images[i].openRead());
        final length = await images[i].length();
        final multipartFile = http.MultipartFile(
          'designImg[]',
          stream,
          length,
          filename: images[i].path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseBody = jsonDecode(response.body);

      if (streamedResponse.statusCode == 200 && responseBody['success'] == true) {
        if (mounted) {
          Navigator.pop(context); // Close modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Quotation request submitted successfully!", style: TextStyle(fontSize: 11)),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      } else {
        final errorMsg = responseBody['message']?.toString() ?? "Failed to submit quotation";
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg, style: const TextStyle(fontSize: 11)), backgroundColor: AppTheme.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission error: $e", style: const TextStyle(fontSize: 11)), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      setModalState(() => _isQuotationSubmitting = false);
    }
  }
}
