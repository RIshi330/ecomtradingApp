import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import '../screens/digital_product_payment_modal.dart';
import '../screens/digital_orders_installation_screen.dart';
import '../services/auth_service.dart';

class DigitalProductDetailsScreen extends StatefulWidget {
  final int productId;
  const DigitalProductDetailsScreen({super.key, required this.productId});

  @override
  State<DigitalProductDetailsScreen> createState() => _DigitalProductDetailsScreenState();
}

class _DigitalProductDetailsScreenState extends State<DigitalProductDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _productDetails;
  List<String> _galleryImages = [];
  List<dynamic> _vendorMoreProducts = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final db = Database();

      // 1. Fetch details
      final detailResponse = await db.getData({
        'action': 'fetch_product_detail',
        'item_id': widget.productId.toString(),
      }, endpoint: 'new_apis/digital_product_api.php');

      if (detailResponse['success'] == true && detailResponse['data'] != null) {
        _productDetails = detailResponse['data'];

        // 2. Fetch gallery
        final galleryResponse = await db.getData({
          'action': 'fetch_product_gallery',
          'item_id': widget.productId.toString(),
        }, endpoint: 'new_apis/digital_product_api.php');

        if (galleryResponse['success'] == true && galleryResponse['data'] != null) {
          final List<dynamic> galleryList = galleryResponse['data']['images'] ?? [];
          _galleryImages = galleryList.map((e) => e.toString()).toList();
        }

        // 3. Fetch vendor more products in category
        if (_productDetails != null) {
          final vendorId = _productDetails!['vendor_id']?.toString() ?? '0';
          final catId = _productDetails!['cat_id']?.toString() ?? '';

          if (vendorId != '0' && catId.isNotEmpty) {
            _isLoadingMore = true;
            final moreResponse = await db.getData({
              'action': 'fetch_vendor_more_products',
              'item_id': widget.productId.toString(),
              'vendor_id': vendorId,
              'cat_id': catId,
            }, endpoint: 'new_apis/digital_product_api.php');

            if (moreResponse['success'] == true && moreResponse['data'] != null) {
              _vendorMoreProducts = moreResponse['data']['products'] ?? [];
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAFC),
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF006565),
          elevation: 0.5,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF006565)),
        ),
      );
    }

    if (_productDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Not Found'),
        ),
        body: const Center(
          child: Text('Product details could not be loaded.'),
        ),
      );
    }

    final p = _productDetails!;
    final String title = p['title']?.toString() ?? 'Unnamed Product';
    final String banner = p['banner']?.toString() ?? '';
    final String cat = p['cat_id']?.toString() ?? 'Digital Asset';
    final double price = double.tryParse(p['price']?.toString() ?? '0') ?? 0.0;
    final double originalPrice = double.tryParse(p['original_price']?.toString() ?? '0') ?? 0.0;
    final double discount = double.tryParse(p['membership_discount']?.toString() ?? '0') ?? 0.0;
    final String description = p['description']?.toString() ?? 'No description provided.';
    
    final List<dynamic> features = p['features'] is List ? p['features'] : [];
    final List<dynamic> tags = p['tags'] is List ? p['tags'] : [];

    // Optional metadata fields from API
    final String version = p['version']?.toString() ?? '1.0.0';
    final String browsers = p['compatible_browsers']?.toString() ?? 'Not Specified';
    final String license = p['license_type']?.toString() ?? 'Regular License';
    final String accessType = p['access_type']?.toString() ?? 'Instant Download';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF006565),
        elevation: 0.5,
        toolbarHeight: 48,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product banner image and gallery
            _buildGallerySection(banner),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and badge tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF006666),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECE3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Save ₹${discount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF733512),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181C1E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF006565),
                                      ),
                                    ),
                                    if (originalPrice > price) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '₹${originalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBEBF0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Member Price',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF555F71),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 36,
                            width: 130,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006565),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _showPurchaseTypeModal();
                              },
                              child: const Text(
                                'Purchase Now',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specifications Table
                  const Text(
                    'SPECIFICATIONS',
                    style: TextStyle(
                      color: Color(0xFF3E4949),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow('Version', version),
                        _buildSpecRow('Compatible Browsers', browsers),
                        _buildSpecRow('License Type', license),
                        _buildSpecRow('Access Type', accessType, isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      color: Color(0xFF3E4949),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF3E4949),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features bullet points
                  if (features.isNotEmpty) ...[
                    const Text(
                      'KEY FEATURES',
                      style: TextStyle(
                        color: Color(0xFF3E4949),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: features.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4.0, right: 8.0),
                                child: Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF006565)),
                              ),
                              Expanded(
                                child: Text(
                                  f.toString(),
                                  style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tags Wrap
                  if (tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            t.toString(),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF555F71)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Vendor other products section
                  if (!_isLoadingMore && _vendorMoreProducts.isNotEmpty) ...[
                    const Text(
                      'MORE FROM THIS VENDOR',
                      style: TextStyle(
                        color: Color(0xFF3E4949),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _vendorMoreProducts.length,
                        itemBuilder: (context, index) {
                          final item = _vendorMoreProducts[index];
                          final int itemId = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
                          final String itemTitle = item['title']?.toString() ?? 'Asset';
                          final double itemPrice = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                          final String itemBanner = item['banner']?.toString() ?? '';

                          return InkWell(
                            onTap: () {
                              if (itemId > 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DigitalProductDetailsScreen(productId: itemId),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  itemBanner.isNotEmpty
                                      ? Image.network(
                                          itemBanner,
                                          height: 75,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 75,
                                            color: const Color(0xFFE6F2F2),
                                            child: const Icon(Icons.image_outlined, color: Color(0xFF006565)),
                                          ),
                                        )
                                      : Container(
                                          height: 75,
                                          color: const Color(0xFFE6F2F2),
                                          child: const Icon(Icons.image_outlined, color: Color(0xFF006565)),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itemTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${itemPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF006565), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF555F71), fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Color(0xFF181C1E), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGallerySection(String banner) {
    if (_galleryImages.isEmpty) {
      return banner.isNotEmpty
          ? Image.network(
              banner,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: const Color(0xFFE0E3E5),
                child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
              ),
            )
          : Container(
              height: 150,
              color: const Color(0xFFE6F2F2),
              child: const Center(
                child: Icon(Icons.shop_outlined, size: 40, color: Color(0xFF006565)),
              ),
            );
    }

    final List<String> allImages = [if (banner.isNotEmpty) banner] + _galleryImages;

    return SizedBox(
      height: 150,
      child: PageView.builder(
        itemCount: allImages.length,
        itemBuilder: (context, index) {
          return Image.network(
            allImages[index],
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFE0E3E5),
              child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  // Multi-step Checkout Modals

  void _showPurchaseTypeModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Purchase Type",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006565).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF006565)),
                ),
                title: const Text("Buying for Yourself", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Direct checkout for your own account"),
                onTap: () {
                  Navigator.pop(context);
                  _openPaymentModal();
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006565).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.group, color: Color(0xFF006565)),
                ),
                title: const Text("Buying for Client", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Select or add a client to manage their purchase"),
                onTap: () {
                  Navigator.pop(context);
                  _showClientSelectorModal();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPaymentModal({String? clientName, String? clientPhone, int? clientId, double serviceCharge = 0.0}) {
    if (_productDetails == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DigitalProductPaymentModal(
          product: _productDetails!,
          themeColor: const Color(0xFF006565),
          clientName: clientName,
          clientPhone: clientPhone,
          clientId: clientId,
          serviceCharge: serviceCharge,
        );
      },
    ).then((success) {
      if (success == true && mounted) {
        final mockOrderId = "${100000 + (DateTime.now().millisecond % 900000)}";
        final productPrice = double.tryParse(_productDetails!['price']?.toString() ?? '0.0') ?? 0.0;
        final productName = _productDetails!['title']?.toString() ?? 'Digital Product';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DigitalOrdersInstallationScreen(
              orderId: mockOrderId,
              amount: productPrice,
              productName: productName,
            ),
          ),
        );
      }
    });
  }

  void _showClientSelectorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<Map>(
              future: () async {
                final int? activeVendorId = await AuthService.getVendorId();
                return Database().getData({
                  'action': 'fetch_client_list',
                  'vendor_id': activeVendorId?.toString() ?? '',
                }, endpoint: 'new_apis/digital_product_api.php');
              }(),
              builder: (context, snapshot) {
                List<dynamic> clients = [];
                bool isFetching = snapshot.connectionState == ConnectionState.waiting;
                
                if (snapshot.hasData && snapshot.data!['success'] == true && snapshot.data!['data'] != null) {
                  clients = snapshot.data!['data']['clients'] ?? [];
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Select Client",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isFetching)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(color: Color(0xFF006565)),
                            ),
                          )
                        else if (clients.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text("No clients found. Click Add Client below to register one."),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: clients.length,
                              itemBuilder: (context, index) {
                                final client = clients[index];
                                final name = client['name']?.toString() ?? '';
                                final isVerified = client['verified'] == true;

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF006565).withOpacity(0.1),
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '',
                                        style: const TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (isVerified) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.verified, size: 16, color: Color(0xFF006565)),
                                        ],
                                      ],
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showClientActionChoiceModal(client);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF006565),
                              side: const BorderSide(color: Color(0xFF006565)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.person_add),
                            label: const Text("Add New Client", style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddNewClientModal();
                            },
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
      },
    );
  }

  void _showAddNewClientModal() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    final addressController = TextEditingController();
    
    // Vendor types matching Lawyers, CA, Web Developers, etc.
    final List<Map<String, String>> vendorTypes = [
      {'id': '13', 'title': 'Lawyer'},
      {'id': '14', 'title': 'CA'},
      {'id': '15', 'title': 'Marketing Professional'},
      {'id': '18', 'title': 'Web Developer'},
      {'id': '17', 'title': 'Graphic Designer'},
      {'id': '19', 'title': 'Trainer'},
      {'id': '21', 'title': 'Recruiter'},
      {'id': '45', 'title': 'Legal Consultant'},
    ];
    String selectedType = vendorTypes.first['id']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Add New Client",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: "Client Name", border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: "Contact Email", border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: "Contact Phone", border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(labelText: "Address", border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(labelText: "Industry/Type", border: OutlineInputBorder()),
                          items: vendorTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['id'],
                              child: Text(type['title']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedType = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006565),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => const Center(child: CircularProgressIndicator()),
                                );

                                try {
                                  final int? activeVendorId = await AuthService.getVendorId();
                                  final res = await Database().getJsonData({
                                    'action': 'addUser',
                                    'user_name': nameController.text,
                                    'user_email': emailController.text,
                                    'user_mobile': mobileController.text,
                                    'user_address': addressController.text,
                                    'user_type': selectedType,
                                    'vendor_id': activeVendorId,
                                  }, endpoint: 'new_apis/user_manager_API.php');

                                  Navigator.pop(context); // Close spinner

                                  if (res['success'] == true) {
                                    Navigator.pop(context); // Close sheet
                                    _showClientSelectorModal(); // Re-open selector
                                  } else {
                                    final String errorMsg = res['message']?.toString() ?? 'Failed to add client';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                                    );
                                  }
                                } catch (e) {
                                  Navigator.pop(context); // Close spinner
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            child: const Text("Save Client", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showClientActionChoiceModal(Map<dynamic, dynamic> client) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Action for: ${client['name']}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006565).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payments, color: Color(0xFF006565)),
                ),
                title: const Text("Pay on Behalf", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Complete the payment using your wallet balances"),
                onTap: () {
                  Navigator.pop(context);
                  _showPayBehalfConfirmation(client);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006565).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.link, color: Color(0xFF006565)),
                ),
                title: const Text("Send Payment Link", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Configure and share a checkout link directly to the client"),
                onTap: () {
                  Navigator.pop(context);
                  _showGenerateLinkModal(client);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPayBehalfConfirmation(Map<dynamic, dynamic> client) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Pay on Behalf",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF006565).withOpacity(0.1),
                        child: const Icon(Icons.person, color: Color(0xFF006565)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client['name']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Text("Verified Client", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final int targetId = client['id'] is int ? client['id'] : (int.tryParse(client['id']?.toString() ?? '') ?? 0);
                      final int? activeVendorId = await AuthService.getVendorId();
                      
                      final res = await Database().getJsonData({
                        'action': 'pay_on_behalf_of_client',
                        'target': targetId,
                        'service_charge': 0,
                        'vendor_id': activeVendorId,
                      }, endpoint: 'new_apis/digital_product_api.php');

                      Navigator.pop(context); // Close spinner

                      if (res['success'] == true) {
                        Navigator.pop(context); // Close sheet
                        _openPaymentModal(
                          clientName: client['name']?.toString(),
                          clientPhone: client['verified'] == true ? 'Verified' : '',
                          clientId: targetId,
                          serviceCharge: 0.0,
                        );
                      } else {
                        final String errorMsg = res['message']?.toString() ?? 'Failed to setup behalf payment';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                        );
                      }
                    } catch (e) {
                      Navigator.pop(context); // Close spinner
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text("Continue Payment", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGenerateLinkModal(Map<dynamic, dynamic> client) {
    final serviceChargeController = TextEditingController(text: "0");
    bool isGenerated = false;
    String generatedLink = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Generate Payment Link",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Client: ${client['name']}",
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (!isGenerated) ...[
                      TextFormField(
                        controller: serviceChargeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Service Charge (₹)",
                          border: OutlineInputBorder(),
                          prefixText: "₹ ",
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator()),
                            );

                            try {
                              final int targetId = client['id'] is int ? client['id'] : (int.tryParse(client['id']?.toString() ?? '') ?? 0);
                              final double charge = double.tryParse(serviceChargeController.text) ?? 0.0;
                              final int? activeVendorId = await AuthService.getVendorId();
                              
                              final res = await Database().getJsonData({
                                'action': 'generate_payment_link',
                                'target': targetId,
                                'service_charge': charge,
                                'vendor_id': activeVendorId,
                              }, endpoint: 'new_apis/digital_product_api.php');

                              Navigator.pop(context); // Close spinner

                              if (res['success'] == true && res['data'] != null) {
                                setModalState(() {
                                  isGenerated = true;
                                  generatedLink = res['data']['link']?.toString() ?? '';
                                });
                              } else {
                                final String errorMsg = res['message']?.toString() ?? 'Failed to generate link';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                                );
                              }
                            } catch (e) {
                              Navigator.pop(context); // Close spinner
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: const Text("Generate Link", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        "Generated Checkout Link",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                generatedLink,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Color(0xFF006565)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF006565).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: generatedLink));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Link copied to clipboard!")),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: Color(0xFF006565)),
                                foregroundColor: const Color(0xFF006565),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Done"),
                            ),
                          ),
                        ],
                      ),
                    ],
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
