import 'package:flutter/material.dart';
import '../Database/Database.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  // Category variables
  String? category;
  String? subCategory;
  String? childCategory;

  List<Map<String, dynamic>> categoriesList = [];
  List<Map<String, dynamic>> subCategoriesList = [];
  List<Map<String, dynamic>> childCategoriesList = [];

  // Expanded Accordions State
  bool basicInfoExpanded = true;
  bool variantExpanded = false;
  bool packagingExpanded = false;
  bool pricingExpanded = false;
  bool charityExpanded = false;
  bool gstExpanded = false;
  bool specificationExpanded = false;
  bool warrantyExpanded = false;
  bool mediaExpanded = false;
  bool certificateExpanded = false;
  bool publishExpanded = false;

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController skuController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<TextEditingController> featureControllers = [
    TextEditingController()
  ];

  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();

  final TextEditingController hsnController = TextEditingController();
  final TextEditingController taxCategoryController = TextEditingController();

  // State options/variables
  String selectedBrandOwnership = "Own";
  String selectedLabelType = "Private Label";
  String selectedGstType = "Inclusive";
  String selectedGstRate = "18%";

  bool sponsorForCharity = true;
  bool warrantyAvailable = true;
  bool returnAvailable = true;
  bool replacementAvailable = false;
  bool codAvailable = false;

  int returnWindow = 7;
  double volumetricWeight = 0.0;

  List<Map<String, dynamic>> variants = [
    {
      "type": "Color",
      "value": "Teal",
      "mrp": "1299",
      "sellingPrice": "999",
    }
  ];

  List<Map<String, dynamic>> pricingSlabs = [
    {
      "range": "1 - 50 Units",
      "price": "999",
    },
    {
      "range": "51 - 200 Units",
      "price": "899",
    }
  ];

  List<TextEditingController> highlights = [TextEditingController()];

  List<Map<String, dynamic>> specifications = [
    {
      "label": "",
      "value": "",
    }
  ];

  List<Map<String, dynamic>> certificates = [
    {
      "type": "",
      "number": "",
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    brandController.dispose();
    skuController.dispose();
    descriptionController.dispose();
    for (var controller in featureControllers) {
      controller.dispose();
    }
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    hsnController.dispose();
    taxCategoryController.dispose();
    for (var controller in highlights) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- Backend dynamic Category fetching ---
  Future<void> _fetchCategories() async {
    try {
      final response = await Database().getJsonData({
        'action': 'getCategories',
      }, endpoint: 'new_apis/product_listing_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          categoriesList = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _fetchSubCategories(String parentId) async {
    try {
      final response = await Database().getJsonData({
        'action': 'getSubCategories',
        'parent_id': parentId,
      }, endpoint: 'new_apis/product_listing_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          subCategoriesList = List<Map<String, dynamic>>.from(response['data']);
          subCategory = null;
          childCategory = null;
          childCategoriesList = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching sub-categories: $e');
    }
  }

  Future<void> _fetchChildCategories(String parentId) async {
    try {
      final response = await Database().getJsonData({
        'action': 'getChildCategories',
        'parent_id': parentId,
      }, endpoint: 'new_apis/product_listing_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          childCategoriesList =
              List<Map<String, dynamic>>.from(response['data']);
          childCategory = null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching child-categories: $e');
    }
  }

  // --- Save Product (Draft or Publish) ---
  Future<void> _saveProduct({required int status}) async {
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Category")),
      );
      return;
    }
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a Product Title")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final featuresList = featureControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final highlightsStr = highlights
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .join('\n');

      final techSpecsList = specifications
          .where((s) => s['label'].toString().isNotEmpty)
          .map((s) => "${s['label']}: ${s['value']}")
          .join('\n');

      List<Map<String, dynamic>> variantsData = variants.map((v) {
        return {
          "title": "${v['type']} - ${v['value']}",
          "size": v['type'] == 'Size' ? v['value'] : '',
          "color": v['type'] == 'Color' ? v['value'] : '',
          "fabric": '',
          "measurement": '',
          "price": double.tryParse(v['sellingPrice']?.toString() ?? '') ?? 0.0,
          "mrp": double.tryParse(v['mrp']?.toString() ?? '') ?? 0.0,
          "a_stock": '100',
          "s_stock": '100',
          "sku": "${skuController.text}-${v['value']}",
        };
      }).toList();

      List<Map<String, dynamic>> btbPricingData = pricingSlabs.map((p) {
        final rangeStr = p['range']?.toString() ?? '';
        String minQty = '1';
        String maxQty = '999';
        String unit = 'Units';
        if (rangeStr.contains('-')) {
          final parts = rangeStr.split('-');
          minQty = parts[0].trim();
          final afterDash = parts[1].trim();
          final afterDashParts = afterDash.split(' ');
          maxQty = afterDashParts[0].trim();
          if (afterDashParts.length > 1) {
            unit = afterDashParts[1].trim();
          }
        }
        return {
          "min_qty": minQty,
          "max_qty": maxQty,
          "mrp": variants.isNotEmpty
              ? (variants[0]['mrp']?.toString() ?? '0')
              : '0',
          "price": p['price']?.toString() ?? '0',
          "unit": unit
        };
      }).toList();

      final postData = {
        "action": "saveProduct",
        "cat_id": category,
        "sub_cat_id": subCategory ?? "",
        "child_cat_id": childCategory ?? "",
        "item_type": category == "Electronics" ? "1" : "2",
        "product_title": titleController.text.trim(),
        "brand_name": brandController.text.trim(),
        "sku": skuController.text.trim(),
        "origin": "India",
        "product_type": "Physical",
        "brand_ownership": selectedBrandOwnership,
        "label_type": selectedLabelType,
        "manufacturer_type": "Vendor",
        "brand_registration": "No",
        "tags": "",
        "short_description": descriptionController.text.trim(),
        "description": descriptionController.text.trim(),
        "features": featuresList,
        "pkg_length": lengthController.text.trim(),
        "pkg_width": widthController.text.trim(),
        "pkg_height": heightController.text.trim(),
        "pkg_weight": volumetricWeight.toString(),
        "packing_type": "Box",
        "units_per_box": "1",
        "gst_type": selectedGstType ?? "Inclusive",
        "gst": selectedGstRate ?? "0",
        "hsn_code": hsnController.text.trim(),
        "tax_category": taxCategoryController.text.trim(),
        "product_highlights": highlightsStr,
        "tech_specs": techSpecsList,
        "warranty_available": warrantyAvailable ? "Yes" : "No",
        "warranty_type": "Brand",
        "warranty_period": "1 Year",
        "warranty_service": "Service Center",
        "warranty_description": "Manufacturer warranty",
        "returnable": returnAvailable ? 1 : 0,
        "return_window": "${returnWindow} Days",
        "cod": codAvailable ? 1 : 0,
        "replacement": replacementAvailable ? 1 : 0,
        "status": status,
        "variants": variantsData,
        "btb_pricing": btbPricingData,
      };

      final response = await Database().getJsonData(
        postData,
        endpoint: 'new_apis/product_listing_api.php',
      );

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 1
                ? "Product published successfully!"
                : "Product draft saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message']?.toString() ?? "Failed to save product"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff008080);

    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "List Products",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xffD4E6E5),
              child: const Icon(
                Icons.person,
                color: primary,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// STEP 1: Basic Information
            buildAccordion(
              number: "1",
              title: "Basic Information",
              expanded: basicInfoExpanded,
              onTap: () {
                setState(() {
                  basicInfoExpanded = !basicInfoExpanded;
                });
              },
              child: buildBasicInformation(),
            ),

            const SizedBox(height: 16),

            /// STEP 2: Product Variants
            buildAccordion(
              number: "2",
              title: "Product Variants",
              expanded: variantExpanded,
              onTap: () {
                setState(() {
                  variantExpanded = !variantExpanded;
                });
              },
              child: buildVariantSection(),
            ),

            const SizedBox(height: 16),

            /// STEP 3: Packaging & Logistics
            buildAccordion(
              number: "3",
              title: "Packaging & Logistics",
              expanded: packagingExpanded,
              onTap: () {
                setState(() {
                  packagingExpanded = !packagingExpanded;
                });
              },
              child: buildPackagingSection(),
            ),

            const SizedBox(height: 16),

            /// STEP 4: Pricing Matrix
            buildAccordion(
              number: "4",
              title: "Pricing Matrix",
              expanded: pricingExpanded,
              onTap: () {
                setState(() {
                  pricingExpanded = !pricingExpanded;
                });
              },
              child: buildPricingSection(),
            ),

            const SizedBox(height: 16),

            /// STEP 5: Charity & Sponsorship
            buildAccordion(
              number: "5",
              title: "Charity & Sponsorship",
              expanded: charityExpanded,
              onTap: () {
                setState(() {
                  charityExpanded = !charityExpanded;
                });
              },
              child: buildCharitySection(),
            ),

            const SizedBox(height: 16),

            /// STEP 6: GST & Taxation
            buildAccordion(
              number: "6",
              title: "GST & Taxation",
              expanded: gstExpanded,
              onTap: () {
                setState(() {
                  gstExpanded = !gstExpanded;
                });
              },
              child: buildGSTSection(),
            ),

            const SizedBox(height: 16),

            /// STEP 7: Specifications & Attributes
            buildAccordion(
              number: "7",
              title: "Specifications & Attributes",
              expanded: specificationExpanded,
              onTap: () {
                setState(() {
                  specificationExpanded = !specificationExpanded;
                });
              },
              child: buildSpecificationSection(),
            ),

            const SizedBox(height: 16),

            /// STEP 8: Warranty & Return Policy
            buildAccordion(
              number: "8",
              title: "Warranty & Return Policy",
              expanded: warrantyExpanded,
              onTap: () {
                setState(() {
                  warrantyExpanded = !warrantyExpanded;
                });
              },
              child: buildWarrantySection(),
            ),

            const SizedBox(height: 16),

            /// STEP 9: Product Media & Documents
            buildAccordion(
              number: "9",
              title: "Product Media & Documents",
              expanded: mediaExpanded,
              onTap: () {
                setState(() {
                  mediaExpanded = !mediaExpanded;
                });
              },
              child: buildMediaSection(),
            ),

            const SizedBox(height: 16),

            /// STEP 10: Certificate & Compliance
            buildAccordion(
              number: "10",
              title: "Certificate & Compliance",
              expanded: certificateExpanded,
              onTap: () {
                setState(() {
                  certificateExpanded = !certificateExpanded;
                });
              },
              child: buildCertificateSection(),
            ),

            const SizedBox(height: 16),

            /// STEP 11: Review & Publish
            buildAccordion(
              number: "11",
              title: "Review & Publish",
              expanded: publishExpanded,
              onTap: () {
                setState(() {
                  publishExpanded = !publishExpanded;
                });
              },
              child: buildPublishSection(),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _saveProduct(status: 0),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(
                    color: primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  "Save Draft",
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _saveProduct(status: 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  "Publish Product",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBasicInformation() {
    return Column(
      children: [
        /// Category
        buildLabel("Category*"),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: inputDecoration(hint: "Select Category"),
          value: category,
          items: categoriesList.map((cat) {
            return DropdownMenuItem<String>(
              value: cat['id']?.toString(),
              child: Text(cat['category_title']?.toString() ?? ''),
            );
          }).toList(),
          onChanged: (v) {
            setState(() {
              category = v;
            });
            if (v != null) {
              _fetchSubCategories(v);
            }
          },
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: inputDecoration(hint: "Sub Category"),
                value: subCategory,
                items: subCategoriesList.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id']?.toString(),
                    child: Text(cat['category_title']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    subCategory = v;
                  });
                  if (v != null) {
                    _fetchChildCategories(v);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: inputDecoration(hint: "Child Category"),
                value: childCategory,
                items: childCategoriesList.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['id']?.toString(),
                    child: Text(cat['category_title']?.toString() ?? ''),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    childCategory = v;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        buildLabel("Product Title*"),

        const SizedBox(height: 6),

        TextFormField(
          controller: titleController,
          decoration: inputDecoration(
            hint: "Premium Cotton Oversized Tee",
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: brandController,
                decoration: inputDecoration(
                  hint: "Brand",
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: skuController,
                decoration: inputDecoration(
                  hint: "PRD-001",
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        buildLabel("Brand Ownership"),

        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          children: [
            chip("Own", selectedBrandOwnership == "Own"),
            chip("Third Party", selectedBrandOwnership == "Third Party"),
            chip("Licensed", selectedBrandOwnership == "Licensed"),
          ],
        ),

        const SizedBox(height: 20),

        buildLabel("Label Type"),

        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          children: [
            smallChip("White Label",
                selected: selectedLabelType == "White Label"),
            smallChip("Private Label",
                selected: selectedLabelType == "Private Label"),
            smallChip("DTC", selected: selectedLabelType == "DTC"),
          ],
        ),

        const SizedBox(height: 24),

        buildLabel("Detailed Description"),

        const SizedBox(height: 6),

        TextFormField(
          controller: descriptionController,
          maxLines: 4,
          decoration: inputDecoration(
            hint: "Explain the product features and benefits...",
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildLabel("Key Features"),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  featureControllers.add(TextEditingController());
                });
              },
              icon: const Icon(
                Icons.add,
                size: 18,
              ),
              label: const Text("Add Row"),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ...List.generate(
          featureControllers.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: featureControllers[index],
                      decoration: inputDecoration(
                        hint: "Feature ${index + 1}",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (featureControllers.length > 1) {
                        setState(() {
                          final controller = featureControllers.removeAt(index);
                          controller.dispose();
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildVariantSection() {
    return Column(
      children: [
        ...List.generate(
          variants.length,
          (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF0EDED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Variant #${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            variants.add(Map.from(variants[index]));
                          });
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.teal,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (variants.length > 1) {
                            setState(() {
                              variants.removeAt(index);
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: inputDecoration(),
                          value: variants[index]["type"],
                          items: const [
                            DropdownMenuItem(
                              value: "Color",
                              child: Text("Color"),
                            ),
                            DropdownMenuItem(
                              value: "Size",
                              child: Text("Size"),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              variants[index]["type"] = v;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: variants[index]["value"],
                          decoration: inputDecoration(
                            hint: "Value",
                          ),
                          onChanged: (v) {
                            variants[index]["value"] = v;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: variants[index]["mrp"],
                          decoration: inputDecoration(
                            hint: "MRP",
                          ),
                          onChanged: (v) {
                            variants[index]["mrp"] = v;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: variants[index]["sellingPrice"] ?? "",
                          decoration: inputDecoration(
                            hint: "Selling Price",
                          ),
                          onChanged: (v) {
                            variants[index]["sellingPrice"] = v;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Variant Images",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(
              Icons.add_circle,
            ),
            label: const Text(
              "Add New Variant",
            ),
            onPressed: () {
              setState(() {
                variants.add({
                  "type": "Color",
                  "value": "",
                  "mrp": "",
                  "sellingPrice": "",
                });
              });
            },
          ),
        )
      ],
    );
  }

  Widget buildPackagingSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: lengthController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration(
                  hint: "Length CM",
                ),
                onChanged: (_) => calculateVolume(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: widthController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration(
                  hint: "Width CM",
                ),
                onChanged: (_) => calculateVolume(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration(
                  hint: "Height CM",
                ),
                onChanged: (_) => calculateVolume(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xffD4E6E5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Volumetric Weight",
                ),
              ),
              Text(
                "${volumetricWeight.toStringAsFixed(2)} KG",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Shipment Services",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: true,
          activeColor: const Color(0xff008080),
          title: const Text(
            "Standard Shipping",
          ),
          onChanged: (_) {},
        ),
        CheckboxListTile(
          value: false,
          activeColor: const Color(0xff008080),
          title: const Text("Express"),
          onChanged: (_) {},
        ),
      ],
    );
  }

  void calculateVolume() {
    double l = double.tryParse(lengthController.text) ?? 0;
    double w = double.tryParse(widthController.text) ?? 0;
    double h = double.tryParse(heightController.text) ?? 0;

    setState(() {
      volumetricWeight = (l * w * h) / 5000;
    });
  }

  Widget buildPricingSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xffF0EDED),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "MOQ Range",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Price / Unit",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...pricingSlabs.map(
                (item) {
                  return ListTile(
                    title: Text(item["range"]),
                    trailing: Text(
                      "₹${item["price"]}",
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add New Price Slab"),
            onPressed: () {
              setState(() {
                pricingSlabs.add({
                  "range": "New MOQ Range",
                  "price": "0",
                });
              });
            },
          ),
        )
      ],
    );
  }

  Widget buildCharitySection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffD4E6E5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sponsor Product For Charity?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "A portion of proceeds goes to NGOs",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: sponsorForCharity,
                activeColor: Colors.teal,
                onChanged: (v) {
                  setState(() {
                    sponsorForCharity = v;
                  });
                },
              )
            ],
          ),
        ),
        if (sponsorForCharity) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: inputDecoration(
                    hint: "Donation %",
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: inputDecoration(
                    hint: "Quantity",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: inputDecoration(),
            items: const [
              DropdownMenuItem(
                value: "Education",
                child: Text("Education"),
              ),
              DropdownMenuItem(
                value: "Healthcare",
                child: Text("Healthcare"),
              ),
              DropdownMenuItem(
                value: "Environment",
                child: Text("Environment"),
              ),
            ],
            onChanged: (_) {},
          ),
        ]
      ],
    );
  }

  Widget buildGSTSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: inputDecoration(),
                value: selectedGstType,
                hint: const Text("GST Type"),
                items: const [
                  DropdownMenuItem(
                    value: "Inclusive",
                    child: Text("Inclusive"),
                  ),
                  DropdownMenuItem(
                    value: "Exclusive",
                    child: Text("Exclusive"),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    selectedGstType = v ?? "Inclusive";
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: inputDecoration(),
                value: selectedGstRate,
                hint: const Text("GST Rate"),
                items: const [
                  DropdownMenuItem(
                    value: "5%",
                    child: Text("5%"),
                  ),
                  DropdownMenuItem(
                    value: "12%",
                    child: Text("12%"),
                  ),
                  DropdownMenuItem(
                    value: "18%",
                    child: Text("18%"),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    selectedGstRate = v ?? "18%";
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: hsnController,
          decoration: inputDecoration(
            hint: "HSN Code",
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: taxCategoryController,
          decoration: inputDecoration(
            hint: "Tax Category",
          ),
        ),
      ],
    );
  }

  Widget buildSpecificationSection() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Product Highlights",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          highlights.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextFormField(
                controller: highlights[index],
                decoration: inputDecoration(
                  hint: "Highlight ${index + 1}",
                ),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(
              Icons.add,
            ),
            label: const Text("Add More"),
            onPressed: () {
              setState(() {
                highlights.add(TextEditingController());
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Technical Specifications",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          specifications.length,
          (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: specifications[index]["label"],
                      decoration: inputDecoration(
                        hint: "Material",
                      ),
                      onChanged: (v) {
                        specifications[index]["label"] = v;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: specifications[index]["value"],
                      decoration: inputDecoration(
                        hint: "Cotton",
                      ),
                      onChanged: (v) {
                        specifications[index]["value"] = v;
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add More"),
            onPressed: () {
              setState(() {
                specifications.add({
                  "label": "",
                  "value": "",
                });
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildWarrantySection() {
    return Column(
      children: [
        SwitchListTile(
          value: warrantyAvailable,
          activeColor: Colors.teal,
          title: const Text(
            "Warranty Available",
          ),
          onChanged: (v) {
            setState(() {
              warrantyAvailable = v;
            });
          },
        ),
        const SizedBox(height: 10),
        CheckboxListTile(
          value: returnAvailable,
          title: const Text(
            "Return Available",
          ),
          onChanged: (v) {
            setState(() {
              returnAvailable = v!;
            });
          },
        ),
        CheckboxListTile(
          value: replacementAvailable,
          title: const Text(
            "Replacement Available",
          ),
          onChanged: (v) {
            setState(() {
              replacementAvailable = v!;
            });
          },
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Return Window",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: windowButton(7),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: windowButton(15),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: windowButton(30),
            ),
          ],
        ),
        const SizedBox(height: 15),
        CheckboxListTile(
          value: codAvailable,
          title: const Text(
            "COD Available",
          ),
          onChanged: (v) {
            setState(() {
              codAvailable = v!;
            });
          },
        ),
      ],
    );
  }

  Widget windowButton(int days) {
    bool selected = returnWindow == days;

    return InkWell(
      onTap: () {
        setState(() {
          returnWindow = days;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            "$days Days",
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMediaSection() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        mediaBox(
          Icons.videocam,
          "Video",
        ),
        mediaBox(
          Icons.image,
          "Main",
        ),
        mediaBox(
          Icons.photo_library,
          "Gallery",
        ),
        mediaBox(
          Icons.straighten,
          "Size Guide",
        ),
        mediaBox(
          Icons.description,
          "Manual",
        ),
        mediaBox(
          Icons.threesixty,
          "360 View",
        ),
      ],
    );
  }

  Widget mediaBox(
    IconData icon,
    String title,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCertificateSection() {
    return Column(
      children: [
        ...List.generate(
          certificates.length,
          (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF0EDED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextFormField(
                    decoration: inputDecoration(
                      hint: "Certificate Type",
                    ),
                    onChanged: (v) {
                      certificates[index]["type"] = v;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: inputDecoration(
                      hint: "Certificate Number",
                    ),
                    onChanged: (v) {
                      certificates[index]["number"] = v;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: inputDecoration(
                            hint: "Issue Date",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: inputDecoration(
                            hint: "Expiry Date",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text(
                        "Upload Certificate",
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add More"),
            onPressed: () {
              setState(() {
                certificates.add({
                  "type": "",
                  "number": "",
                });
              });
            },
          ),
        )
      ],
    );
  }

  Widget buildPublishSection() {
    return Column(
      children: [
        publishItem(
          true,
          "Basic Information Complete",
        ),
        publishItem(
          true,
          "Pricing & Variants Configured",
        ),
        publishItem(
          false,
          "Media Uploads Pending",
        ),
      ],
    );
  }

  Widget publishItem(
    bool completed,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.teal : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
    );
  }

  Widget buildAccordion({
    required String number,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
          )
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xffD4E6E5),
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Color(0xff008080),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                  )
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            )
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xff6E7979),
        ),
      ),
    );
  }

  Widget chip(String text, bool selected) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: (bool val) {
        if (val) {
          setState(() {
            selectedBrandOwnership = text;
          });
        }
      },
    );
  }

  Widget smallChip(String text, {bool selected = false}) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedLabelType = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffD4E6E5) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    String? hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xffF6F3F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    );
  }
}
