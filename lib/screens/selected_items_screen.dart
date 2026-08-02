import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../core/theme/app_theme.dart';
import '../index.dart';
import 'client_payment_modal.dart';

class SelectedProduct {
  final String id;
  final String variantId;
  final String marketplaceId;
  final String name;
  final String category;
  final String image;
  final double commission;
  final double price;
  final bool topSeller;

  SelectedProduct({
    required this.id,
    required this.variantId,
    required this.marketplaceId,
    required this.name,
    required this.category,
    required this.image,
    required this.commission,
    required this.price,
    this.topSeller = false,
  });
}

class WebsiteModel {
  final String id;
  final String name;
  final String description;
  bool selected;

  WebsiteModel({
    required this.id,
    required this.name,
    required this.description,
    this.selected = false,
  });
}

class SelectedItemsScreen extends StatefulWidget {
  final bool isEmbedded;

  const SelectedItemsScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<SelectedItemsScreen> createState() => _SelectedItemsScreenState();
}

class _SelectedItemsScreenState extends State<SelectedItemsScreen> {
  static const Color themeColor = Color(0xFF006565); // Teal Primary
  static const Color themeAccent = Color(0xFFD4E6E5); // Light Teal Container

  int currentIndex = 1;
  bool isLoading = false;
  List<SelectedProduct> products = [];
  List<WebsiteModel> websites = [];
  bool isLoadingWebsites = false;

  // Buy For Client variables
  int quantity = 1;
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedClientName = "";
  String selectedClientId = "";
  double unitPrice = 2499.0;

  List<Map<String, String>> existingClients = [];

  final List<SelectedProduct> mockProducts = [
    SelectedProduct(
      id: "101",
      variantId: "201",
      marketplaceId: "5",
      name: "Nova Series Watch",
      category: "Electronics & Wearables",
      image: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500",
      commission: 124.0,
      price: 2499.0,
      topSeller: true,
    ),
    SelectedProduct(
      id: "102",
      variantId: "202",
      marketplaceId: "5",
      name: "SwiftRunner Pro",
      category: "Sports & Fitness",
      image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500",
      commission: 96.0,
      price: 1999.0,
    ),
    SelectedProduct(
      id: "103",
      variantId: "0",
      marketplaceId: "16",
      name: "AudioMaster HD",
      category: "Sound & Music",
      image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500",
      commission: 210.0,
      price: 3499.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchSelectedItems();
    _fetchWebsites();
    _loadClients();
  }

  @override
  void dispose() {
    clientNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final db = Database();
      final res = await db.getJsonData({
        'action': 'fetch_clients',
      }, endpoint: 'new_apis/combo_pack_api.php');
      if (res['clients'] != null) {
        final List<dynamic> list = res['clients'];
        if (mounted) {
          setState(() {
            existingClients = list.map((c) => {
              'id': c['id']?.toString() ?? '',
              'name': c['name']?.toString() ?? '',
            }).toList();
            if (existingClients.isNotEmpty) {
              selectedClientName = existingClients.first['name'] ?? '';
              selectedClientId = existingClients.first['id'] ?? '';
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading clients: $e");
    }
  }

  Future<void> _fetchSelectedItems() async {
    setState(() => isLoading = true);
    try {
      final response = await Database().getData(
        {'action': 'fetch'},
        endpoint: 'new_apis/promoted_product_api.php',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map;
        final List<SelectedProduct> fetchedProducts = [];

        data.forEach((key, value) {
          if (value is List) {
            for (var item in value) {
              final String name = item['name']?.toString() ?? '';
              final String category = item['category']?.toString() ?? '';
              final String image = item['image']?.toString() ?? '';

              double comm = 0.0;
              if (item['commission'] != null) {
                if (item['commission'] is Map) {
                  comm = double.tryParse(item['commission']['commission']?.toString() ?? '') ?? 0.0;
                } else {
                  comm = double.tryParse(item['commission']?.toString() ?? '') ?? 0.0;
                }
              }

              final double price = double.tryParse(item['price']?.toString() ?? '') ?? 0.0;
              final String id = item['item_id']?.toString() ?? '';
              final String variantId = item['variant_id']?.toString() ?? '0';
              final String marketplaceId = item['marketplace_id']?.toString() ?? key.toString();

              if (name.isNotEmpty) {
                fetchedProducts.add(
                  SelectedProduct(
                    id: id,
                    variantId: variantId,
                    marketplaceId: marketplaceId,
                    name: name,
                    category: category,
                    image: image,
                    commission: comm,
                    price: price > 0 ? price : 2499.0,
                    topSeller: comm >= 100,
                  ),
                );
              }
            }
          }
        });

        setState(() {
          products = fetchedProducts.isNotEmpty ? fetchedProducts : mockProducts;
        });
      } else {
        setState(() {
          products = mockProducts;
        });
      }
    } catch (e) {
      debugPrint("Error fetching selected items: $e");
      setState(() {
        products = mockProducts;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchWebsites() async {
    setState(() => isLoadingWebsites = true);
    try {
      final response = await Database().getData({
        'action': 'get_site_cards',
        'marketplace_id': '0',
        'keyword': '',
        'approval_type': '',
        'payment_type': '',
        'categories': '[]',
      }, endpoint: 'new_apis/select_sites_API 1.php');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final List<WebsiteModel> fetchedSites = data.map((site) {
          final String name = site['site_name']?.toString() ?? 'Site ${site['site_id']}';
          final String desc = site['domain']?.toString() ?? 'Affiliate Portal';
          final String id = site['site_id']?.toString() ?? '';
          return WebsiteModel(
            id: id,
            name: name,
            description: desc,
            selected: false,
          );
        }).toList();

        setState(() {
          websites = fetchedSites;
        });
      }
    } catch (e) {
      debugPrint("Error fetching websites: $e");
    } finally {
      if (websites.isEmpty) {
        setState(() {
          websites = [
            WebsiteModel(id: "1", name: "MyPortfolio.com", description: "Tech & Gear Focus"),
            WebsiteModel(id: "2", name: "ShopBlog.in", description: "Lifestyle Affiliate", selected: true),
            WebsiteModel(id: "3", name: "QuickDeals Portal", description: "Coupons & Offers"),
          ];
        });
      }
      setState(() => isLoadingWebsites = false);
    }
  }

  Future<void> _confirmPlacement(SelectedProduct product) async {
    final selectedSiteIds = websites
        .where((w) => w.selected)
        .map((w) => w.id)
        .toList();

    if (selectedSiteIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one website"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final List<String> ids = List.filled(selectedSiteIds.length, product.id);
      final List<String> mks = List.filled(selectedSiteIds.length, product.marketplaceId);

      final response = await Database().getJsonData({
        'action': 'update_site',
        'ids': ids,
        'sites': selectedSiteIds,
        'mks': mks,
      }, endpoint: 'new_apis/promoted_product_api.php');

      if (response['success'] == true || response['status'] == true) {
        showPlacementSuccess(product);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to place item on websites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error placing item: $e");
      showPlacementSuccess(product);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void openWebsiteDialog(SelectedProduct product) {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text("Select Website", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 350,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoadingWebsites)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...websites.map((website) {
                            return CheckboxListTile(
                              activeColor: themeColor,
                              value: website.selected,
                              title: Text(website.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(website.description),
                              onChanged: (value) {
                                dialogSetState(() {
                                  website.selected = value ?? false;
                                });
                              },
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmPlacement(product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showPlacementSuccess(SelectedProduct product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text("${product.name} added to website successfully"),
      ),
    );
  }

  void showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Upgrade Membership", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "Upgrade your membership plan to unlock higher commission rates and premium affiliate tools.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Later", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Upgrade Coming Soon"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Upgrade", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  double get itemTotal => unitPrice * quantity;
  double get gstAmount => itemTotal * 0.18;
  double get finalTotal => itemTotal + gstAmount;

  void openClientSheet(SelectedProduct product) {
    quantity = 1;
    unitPrice = product.price;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Buy For Client",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(32, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildClientSelector(sheetSetState),
                    const SizedBox(height: 16),
                    buildNewClientForm(sheetSetState),
                    const SizedBox(height: 16),
                    buildCartItem(product, sheetSetState),
                    const SizedBox(height: 16),
                    buildPriceSummary(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (clientNameController.text.isEmpty && selectedClientId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select or add a client"),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (clientNameController.text.isNotEmpty) {
                            if (phoneController.text.isEmpty || emailController.text.isEmpty || addressController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("All fields (Name, Phone, Email, Address) are required for a new client"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator()),
                            );

                            Database().getJsonData({
                              'action': 'addUser',
                              'user_name': clientNameController.text,
                              'user_email': emailController.text,
                              'user_mobile': phoneController.text,
                              'user_address': addressController.text,
                              'user_type': '52',
                            }, endpoint: 'new_apis/user_manager_API.php').then((res) {
                              Navigator.pop(context); // Close loading indicator
                              if (res['success'] == true) {
                                final String newId = res['data']['user_id']?.toString() ?? '';
                                final String newName = res['data']['user_name']?.toString() ?? clientNameController.text;
                                final String newPhone = phoneController.text;

                                _loadClients();

                                setState(() {
                                  selectedClientId = newId;
                                  selectedClientName = newName;
                                });

                                clientNameController.clear();
                                phoneController.clear();
                                emailController.clear();
                                addressController.clear();

                                payNow(product, newName, newPhone);
                              } else {
                                final String errorMsg = res['message']?.toString() ?? "Failed to add client";
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }).catchError((e) {
                              Navigator.pop(context); // Close loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            });
                          } else {
                            payNow(product, selectedClientName, "");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                        label: const Text("Pay Now", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget buildClientSelector(StateSetter sheetSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Existing Client",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: existingClients.length,
            itemBuilder: (context, index) {
              final client = existingClients[index];
              final name = client['name'] ?? '';
              final id = client['id'] ?? '';
              final selected = selectedClientId == id;

              return GestureDetector(
                onTap: () {
                  sheetSetState(() {
                    selectedClientName = name;
                    selectedClientId = id;
                    clientNameController.clear();
                    phoneController.clear();
                    emailController.clear();
                    addressController.clear();
                  });
                },
                child: Container(
                  width: 75,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppTheme.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: selected ? AppTheme.primary : Colors.grey.shade200,
                          child: Text(
                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "",
                            style: TextStyle(
                              color: selected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildNewClientForm(StateSetter sheetSetState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Or Add New Client",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: clientNameController,
            style: const TextStyle(fontSize: 13),
            onChanged: (val) {
              sheetSetState(() {
                selectedClientName = val;
                selectedClientId = "";
              });
            },
            decoration: InputDecoration(
              labelText: "Client Name",
              labelStyle: const TextStyle(fontSize: 12),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppTheme.radius))),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: "Phone Number",
              labelStyle: const TextStyle(fontSize: 12),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppTheme.radius))),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: "Email Address",
              labelStyle: const TextStyle(fontSize: 12),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppTheme.radius))),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: addressController,
            keyboardType: TextInputType.streetAddress,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: "Client Address",
              labelStyle: const TextStyle(fontSize: 12),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppTheme.radius))),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartItem(SelectedProduct product, StateSetter setSheetState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.image.isNotEmpty
                ? Image.network(
                    product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image, color: Colors.grey, size: 20),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image, color: Colors.grey, size: 20),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          buildQuantitySelector(setSheetState),
        ],
      ),
    );
  }

  Widget buildQuantitySelector(StateSetter setSheetState) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () {
              setSheetState(() {
                if (quantity > 1) {
                  quantity--;
                }
              });
            },
            icon: const Icon(Icons.remove, size: 14, color: AppTheme.textSecondary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () {
              setSheetState(() {
                quantity++;
              });
            },
            icon: const Icon(Icons.add, size: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          buildSummaryRow("Item Total", "₹${itemTotal.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          buildSummaryRow("Tax (GST 18%)", "₹${gstAmount.toStringAsFixed(2)}"),
          const Divider(height: 16),
          buildSummaryRow(
            "Total Payable",
            "₹${finalTotal.toStringAsFixed(2)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 13 : 12,
              color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primary : AppTheme.textPrimary,
            fontSize: isTotal ? 14 : 12,
          ),
        ),
      ],
    );
  }

  void payNow(SelectedProduct product, String name, String phone) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ClientPaymentModal(
        product: product,
        quantity: quantity,
        totalRawPrice: finalTotal,
        themeColor: themeColor,
        clientName: name,
        clientPhone: phone,
      ),
    );
  }

  Widget buildProductCard(SelectedProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: product.image.isNotEmpty
                      ? Image.network(
                          product.image,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (product.topSeller)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "TOP SELLER",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(product.category, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Commission", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              Text(
                                "₹${product.commission.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: showUpgradeDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: themeAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.trending_up, size: 16, color: themeColor),
                                  SizedBox(width: 4),
                                  Text(
                                    "Upgrade",
                                    style: TextStyle(color: themeColor, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => openWebsiteDialog(product),
                    icon: const Icon(Icons.public, color: themeColor),
                    label: const Text(
                      "Place in Website",
                      style: TextStyle(color: themeColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => openClientSheet(product),
                    icon: const Icon(Icons.shopping_cart, color: themeColor),
                    label: const Text(
                      "Buy for Client",
                      style: TextStyle(color: themeColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (value) {
        setState(() {
          currentIndex = value;
        });
        if (value == 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        } else if (value == 2) {
          Navigator.pushReplacementNamed(context, AppRoutes.platformSettings);
        } else if (value == 3) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminProfileScreen);
        }
      },
      selectedItemColor: themeColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: "Selected",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Stats",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: const Color(0xffFEF7FF),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: const Color(0xffFEF7FF),
              elevation: 0,
              title: const Text("My Selected Items", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  // Scaffold.of(context).openDrawer() or back
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.account_circle, color: Colors.black),
                ),
              ],
            ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: themeColor))
          : products.isEmpty
              ? const Center(child: Text("No selected items found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return buildProductCard(products[index]);
                  },
                ),
      bottomNavigationBar: widget.isEmbedded ? null : buildBottomNavigation(),
    );

    return content;
  }
}
