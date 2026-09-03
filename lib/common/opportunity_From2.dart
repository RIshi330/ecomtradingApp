import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../Database/Database.dart';
import '../app_constants.dart';
import '../services/auth_User_and_Business_Session.dart';

/// TODO: point this at the same base URL your Database() class uses.
/// It's needed here because upload_opportunity_image must be sent as
/// multipart/form-data (a real file), which a plain JSON POST helper
/// like Database().getJsonData typically can't do.

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CategoryModel {
  final int id;
  final String title;
  _CategoryModel({required this.id, required this.title});
}

class _UploadedImage {
  final String url;
  final int? id;
  _UploadedImage({required this.url, this.id});
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _audienceController = TextEditingController();

  // Category State & Dynamic Loading
  _CategoryModel? _selectedCategory;
  _CategoryModel? _selectedSubCategory;
  List<_CategoryModel> _categories = [];
  List<_CategoryModel> _subCategories = [];

  bool _isPaid = false;
  bool _isLoadingCategories = false;
  bool _isLoadingSubCategories = false;
  bool _isGeneratingAi = false;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  final int _marketplaceId = 1; // Default Marketplace ID

  // If editing an existing opportunity, set this (e.g. via constructor arg).
  // 0 means "new opportunity, not saved yet".
  int _opportunityId = 0;

  final List<String> _userTypes = [
    'Tech Founders',
    'NGOs',
    'Individual Contributors',
    'Agencies'
  ];

  final List<String> _actions = [
    'Apply',
    'Enroll',
    'Request Callback',
    'Download RFP',
    'Submit Proposal'
  ];
  int _selectedActionIndex = 0;

  final List<Map<String, String>> _financialTerms = [
    {'type': 'Commission (Flat)', 'value': ''}
  ];

  final List<Map<String, dynamic>> _documents = [
    {
      'name': 'Business License',
      'action': 'Apply',
      'format': 'PDF',
      'isRequired': true,
    }
  ];

  final List<_UploadedImage> _uploadedImages = [];
  static const int _maxImages = 5;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _userTypeController.dispose();
    _locationController.dispose();
    _audienceController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // API METHODS
  // ===========================================================================

  /// Fetch Main Categories
  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final postData = {
        "action": "fetch_categories",
        "marketplace_id": _marketplaceId,
        "vendor_id": UserSessionSet.instance.vendorId,
      };

      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data'];
        setState(() {
          _categories = list
              .map((item) => _CategoryModel(
            id: int.parse(item['id'].toString()),
            title: item['category_title'].toString(),
          ))
              .toList();
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text("Failed to load categories: ${response['message'] ?? ''}"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load categories")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  /// Fetch Sub-Categories
  Future<void> _fetchSubCategories(int categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
      _subCategories = [];
      _selectedSubCategory = null;
    });

    try {
      final postData = {
        "action": "fetch_subcategories",
        "category_id": categoryId,
        "marketplace_id": _marketplaceId,
        "vendor_id": UserSessionSet.instance.vendorId,
      };

      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data'];
        setState(() {
          _subCategories = list
              .map((item) => _CategoryModel(
            id: int.parse(item['id'].toString()),
            title: item['category_title'].toString(),
          ))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching subcategories: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSubCategories = false);
    }
  }

  /// Generate Description with AI
  Future<void> _generateDescriptionWithAI() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Opportunity Title first")),
      );
      return;
    }

    setState(() => _isGeneratingAi = true);

    try {
      final postData = {
        "action": "generate_ai_description",
        "vendor_id": UserSessionSet.instance.vendorId,
        "title": _titleController.text.trim(),
        "category_name": _selectedCategory?.title ?? "",
        "subcategory_name": _selectedSubCategory?.title ?? "",
        "notes": _descriptionController.text.trim(),
      };

      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );

      if (response['success'] == true &&
          response['data']?['description'] != null) {
        setState(() {
          _descriptionController.text = response['data']['description'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "AI Generation Failed: ${response['message'] ?? 'Unknown error'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingAi = false);
    }
  }

  /// Pick + upload an image via upload_opportunity_image (multipart).
  Future<void> _pickAndUploadImage() async {
    if (_uploadedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can upload up to $_maxImages images")),
      );
      return;
    }

    final XFile? picked =
    await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final file = File(picked.path);
    final sizeInBytes = await file.length();
    if (sizeInBytes > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image exceeds 5MB limit")),
      );
      return;
    }

    final ext = picked.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unsupported image format")),
      );
      return;
    }

    setState(() => _isUploadingImage = true);

    try {
      final uri = Uri.parse("${baseUrl}new_apis/opportunity_form_api.php");
      final request = http.MultipartRequest("POST", uri)
        ..fields["action"] = "upload_opportunity_image"
        ..fields["marketplace_id"] = _marketplaceId.toString()
        ..fields["opportunity_id"] = _opportunityId.toString()
        ..fields["vendor_id"] = UserSessionSet.instance.vendorId.toString()
        ..files.add(await http.MultipartFile.fromPath("image", picked.path));

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode != 200) {
        throw Exception("Upload failed (${streamedResponse.statusCode})");
      }

      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      // If your Database() helper doesn't expose decodeJson, replace the
      // line above with: jsonDecode(responseBody) from dart:convert.

      if (decoded['success'] == true && decoded['data']?['image_url'] != null) {
        setState(() {
          _uploadedImages.add(_UploadedImage(
            url: decoded['data']['image_url'],
            id: decoded['data']['image_id'] != null
                ? int.tryParse(decoded['data']['image_id'].toString())
                : null,
          ));
        });
      } else {
        throw Exception(decoded['message'] ?? "Unknown upload error");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Image upload failed: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _uploadedImages.removeAt(index));
  }

  /// Submit Form Data (Save Draft or Publish)
  Future<void> _submitOpportunity({required bool isPublish}) async {
    if (isPublish && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final mappedFinancialTerms = _financialTerms
          .where((t) => (t['value'] ?? '').trim().isNotEmpty)
          .map((t) {
        String typeKey = 'commission';
        final typeStr = (t['type'] ?? '').toLowerCase();
        if (typeStr.contains('fixed')) typeKey = 'fixed';
        if (typeStr.contains('incentive')) typeKey = 'incentive';
        if (typeStr.contains('cashback')) typeKey = 'cashback';

        return {
          "term_type": typeKey,
          "amount": t['value']?.trim() ?? '',
          "payment_frequency": "One-time",
          "positions": 1
        };
      }).toList();

      final mappedDocuments = _documents
          .where((d) => (d['name'] ?? '').toString().trim().isNotEmpty)
          .map((d) => {
        "document_name": d['name'],
        "linked_action": d['action'],
        "format": d['format'],
        "is_required": d['isRequired'] ?? false,
      })
          .toList();

      final postData = {
        "action": "save_opportunity",
        "vendor_id": UserSessionSet.instance.vendorId,
        "marketplace_id": _marketplaceId,
        "opportunity_id": _opportunityId, // 0 = create new
        "is_publish": isPublish,
        "title": _titleController.text.trim(),
        "category_id": _selectedCategory?.id,
        "subcategory_id": _selectedSubCategory?.id,
        "description": _descriptionController.text.trim(),
        "pricing_type": _isPaid ? "paid" : "free",
        "price_amount":
        _isPaid ? (double.tryParse(_priceController.text) ?? 0.0) : 0,
        "preferred_locations": _locationController.text.trim(),
        "target_audience": _audienceController.text.trim().isNotEmpty
            ? _audienceController.text.trim()
            : _userTypes.join(', '),
        "financial_terms": mappedFinancialTerms,
        "expected_documents": mappedDocuments,
        "images": _uploadedImages.map((img) => img.url).toList(),
      };

      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );

      if (!mounted) return;

      if (response['success'] == true) {
        if (response['data']?['opportunity_id'] != null) {
          _opportunityId =
              int.tryParse(response['data']['opportunity_id'].toString()) ??
                  _opportunityId;
        }
        _showSuccessDialog(isPublish
            ? "Opportunity Published Successfully"
            : "Draft Saved Successfully");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Submission Failed: ${response['message'] ?? 'Unknown Error'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
        const Icon(Icons.check_circle, color: Color(0xFF004349), size: 50),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child:
            const Text("OK", style: TextStyle(color: Color(0xFF004349))),
          )
        ],
      ),
    );
  }

  // Row operations
  void _addFinancialRow() {
    setState(() {
      _financialTerms.add({'type': 'Commission (Flat)', 'value': ''});
    });
  }

  void _removeFinancialRow(int index) {
    if (_financialTerms.length > 1) {
      setState(() {
        _financialTerms.removeAt(index);
      });
    }
  }

  void _addDocumentRow() {
    setState(() {
      _documents.add({
        'name': '',
        'action': _actions[_selectedActionIndex],
        'format': 'PDF',
        'isRequired': false,
      });
    });
  }

  void _removeDocumentRow(int index) {
    setState(() {
      _documents.removeAt(index);
    });
  }

  void _addUserType(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _userTypes.add(value.trim());
        _userTypeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF004349)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create Opportunity',
          style: TextStyle(
            color: Color(0xFF191C1D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => _submitOpportunity(isPublish: false),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Draft',
                style: TextStyle(
                  color: Color(0xFF004349),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('BASIC INFORMATION'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _titleController,
                        hintText: 'Opportunity Title',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Category & Sub-category
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Category',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF191C1D),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _isLoadingCategories
                                    ? const SizedBox(
                                    height: 48,
                                    child: Center(
                                        child:
                                        CircularProgressIndicator()))
                                    : Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                        const Color(0xFFBFC8C9)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<
                                        _CategoryModel>(
                                      value: _selectedCategory,
                                      hint: const Text(
                                          'Select Category',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                              Color(0xFF6B7280))),
                                      isExpanded: true,
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF6F797A)),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF191C1D)),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() =>
                                          _selectedCategory = val);
                                          _fetchSubCategories(val.id);
                                        }
                                      },
                                      items: _categories
                                          .map((_CategoryModel item) {
                                        return DropdownMenuItem<
                                            _CategoryModel>(
                                          value: item,
                                          child: Text(item.title),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sub-Category',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF191C1D),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _isLoadingSubCategories
                                    ? const SizedBox(
                                    height: 48,
                                    child: Center(
                                        child:
                                        CircularProgressIndicator()))
                                    : Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                        const Color(0xFFBFC8C9)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<
                                        _CategoryModel>(
                                      value: _selectedSubCategory,
                                      hint: const Text(
                                          'Select Sub-Category',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color:
                                              Color(0xFF6B7280))),
                                      isExpanded: true,
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Color(0xFF6F797A)),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF191C1D)),
                                      onChanged: (val) => setState(
                                              () =>
                                          _selectedSubCategory =
                                              val),
                                      items: _subCategories
                                          .map((_CategoryModel item) {
                                        return DropdownMenuItem<
                                            _CategoryModel>(
                                          value: item,
                                          child: Text(item.title),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Opportunity Assets — now wired to real upload
                      _buildSectionHeader('OPPORTUNITY ASSETS'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _isUploadingImage ? null : _pickAndUploadImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFBFC8C9),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              _isUploadingImage
                                  ? const SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                                  : const Icon(
                                Icons.add_a_photo_outlined,
                                color: Color(0xFF004349),
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isUploadingImage
                                    ? 'Uploading...'
                                    : 'Add Images',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_uploadedImages.length}/$_maxImages uploaded · Max 5MB each',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_uploadedImages.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _uploadedImages.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final img = _uploadedImages[index];
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      img.url,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        color: const Color(0xFFECEEEE),
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Pricing Model
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F4),
                          borderRadius: BorderRadius.circular(12),
                          border:
                          Border.all(color: const Color(0x4DBFC8C9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('PRICING MODEL'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: false,
                                      groupValue: _isPaid,
                                      activeColor: const Color(0xFF004349),
                                      onChanged: (val) =>
                                          setState(() => _isPaid = val!),
                                    ),
                                    const Text(
                                      'Free Opportunity',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: _isPaid,
                                      activeColor: const Color(0xFF004349),
                                      onChanged: (val) =>
                                          setState(() => _isPaid = val!),
                                    ),
                                    const Text(
                                      'Paid Opportunity',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (_isPaid) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefixIcon: const Padding(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      '\$',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF3F484A),
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 0, minHeight: 0),
                                  hintText: 'Enter Price Amount',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFBFC8C9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFBFC8C9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF004349)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Financial Terms
                      _buildSectionHeader('FINANCIAL TERMS'),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _financialTerms.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border:
                              Border.all(color: const Color(0x80BFC8C9)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildDropdown(
                                    hint: 'Select',
                                    value: _financialTerms[index]['type'],
                                    items: const [
                                      'Commission (Flat)',
                                      'Commission (%)',
                                      'Incentive',
                                      'Fixed Pay',
                                      'Cashback',
                                      'Vouchers'
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _financialTerms[index]['type'] =
                                        val!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 5,
                                  child: _buildTextField(
                                    hintText: 'Value (e.g. 500 or 15%)',
                                    fontSize: 12,
                                    initialValue: _financialTerms[index]
                                    ['value'],
                                    onChanged: (val) =>
                                    _financialTerms[index]['value'] =
                                        val,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: _financialTerms.length > 1
                                        ? const Color(0xFF3F484A)
                                        : const Color(0x663F484A),
                                  ),
                                  onPressed: () => _removeFinancialRow(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: _addFinancialRow,
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFF004349)),
                        label: const Text(
                          'Add Financial Term',
                          style: TextStyle(
                            color: Color(0xFF004349),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Solution Details
                      _buildSectionHeader('SOLUTION DETAILS'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: const Color(0xFFBFC8C9)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFECEEEE),
                                borderRadius:
                                BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.format_bold,
                                        size: 18),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.format_italic,
                                        size: 18),
                                    onPressed: () {},
                                  ),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: _isGeneratingAi
                                        ? null
                                        : _generateDescriptionWithAI,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFF0D5C63),
                                      foregroundColor:
                                      const Color(0xFF90D2DA),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: _isGeneratingAi
                                        ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Icon(Icons.auto_awesome,
                                        size: 14),
                                    label: Text(
                                      _isGeneratingAi
                                          ? 'Generating...'
                                          : 'Generate with AI',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText:
                                'Describe the solution, brand, or hierarchy in detail...',
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.all(16),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Who Can Apply?
                      _buildSectionHeader('WHO CAN APPLY?'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: const Color(0xFFBFC8C9)),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ..._userTypes.map((type) => Chip(
                              label: Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF506873),
                                ),
                              ),
                              backgroundColor: const Color(0xFFCDE6F4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide.none,
                              ),
                              deleteIcon:
                              const Icon(Icons.close, size: 14),
                              onDeleted: () {
                                setState(() => _userTypes.remove(type));
                              },
                            )),
                            SizedBox(
                              width: 140,
                              child: TextField(
                                controller: _userTypeController,
                                onSubmitted: _addUserType,
                                decoration: const InputDecoration(
                                  hintText: 'Add user type...',
                                  hintStyle: TextStyle(fontSize: 13),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Preferred Actions
                      _buildSectionHeader('PREFERRED ACTIONS'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_actions.length, (index) {
                          final isSelected = _selectedActionIndex == index;
                          return ChoiceChip(
                            label: Text(_actions[index]),
                            selected: isSelected,
                            selectedColor: const Color(0xFF004349),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF3F484A),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF004349)
                                    : const Color(0xFFBFC8C9),
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedActionIndex = index);
                              }
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Expected Documents
                      _buildSectionHeader('EXPECTED DOCUMENTS'),
                      const SizedBox(height: 4),
                      const Text(
                        'Required documentation depends on your selected preferred actions.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _documents.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border:
                              Border.all(color: const Color(0x80BFC8C9)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          _buildFieldLabel('DOCUMENT NAME'),
                                          const SizedBox(height: 4),
                                          _buildTextField(
                                            hintText: 'e.g. Business License',
                                            fontSize: 12,
                                            initialValue: _documents[index]
                                            ['name'],
                                            onChanged: (val) =>
                                            _documents[index]['name'] =
                                                val,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          _buildFieldLabel(
                                              'LINKED TO ACTION'),
                                          const SizedBox(height: 4),
                                          _buildDropdown(
                                            hint: 'Select',
                                            value: _documents[index]
                                            ['action'],
                                            items: _actions,
                                            fontSize: 12,
                                            onChanged: (val) {
                                              setState(() {
                                                _documents[index]['action'] =
                                                val!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          _buildFieldLabel('FORMAT'),
                                          const SizedBox(height: 4),
                                          _buildDropdown(
                                            hint: 'Select',
                                            value: _documents[index]
                                            ['format'],
                                            items: const [
                                              'PDF',
                                              'DOCX',
                                              'JPG'
                                            ],
                                            fontSize: 12,
                                            onChanged: (val) {
                                              setState(() {
                                                _documents[index]['format'] =
                                                val!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Checkbox(
                                      value: _documents[index]
                                      ['isRequired'],
                                      activeColor: const Color(0xFF004349),
                                      onChanged: (val) {
                                        setState(() {
                                          _documents[index]['isRequired'] =
                                          val!;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Required',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Color(0x663F484A),
                                      ),
                                      onPressed: () =>
                                          _removeDocumentRow(index),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: _addDocumentRow,
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFF004349)),
                        label: const Text(
                          'Add Required Document',
                          style: TextStyle(
                            color: Color(0xFF004349),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Preferred Locations & Target Audience
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Preferred Locations',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _locationController,
                                  hintText: 'e.g. New York, Remote',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Target Audience',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _audienceController,
                                  hintText: 'e.g. Retailers, B2B',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFBFC8C9)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFECEEEE),
                            foregroundColor: const Color(0xFF3F484A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Preview',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _submitOpportunity(isPublish: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004349),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            'Publish Opportunity',
                            style:
                            TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3F484A),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFieldLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF004349),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    double fontSize = 14,
    String? initialValue,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
        TextStyle(fontSize: fontSize, color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBFC8C9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBFC8C9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF004349)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    double fontSize = 14,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFC8C9)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style:
            TextStyle(fontSize: fontSize, color: const Color(0xFF6B7280)),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6F797A)),
          style: TextStyle(fontSize: fontSize, color: const Color(0xFF191C1D)),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }
}