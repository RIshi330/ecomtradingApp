import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../Database/Database.dart';
import '../app_constants.dart';
import '../services/auth_User_and_Business_Session.dart';

// Brand Colors
const Color kPrimary = Color(0xFF004349);
const Color kPrimaryContainer = Color(0xFF0D5C63);
const Color kSecondary = Color(0xFF4A626D);
const Color kSurfaceBg = Color(0xFFF8FAFA);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kTealBg = Color(0xFFF0FDFA);

class _CategoryModel {
  final int id;
  final String title;
  _CategoryModel({required this.id, required this.title});
}

class _ModuleModel {
  final int id;
  final String title;
  _ModuleModel({required this.id, required this.title});
}

class _VendorTypeModel {
  final int id;
  final String title;
  final bool isCustom;
  _VendorTypeModel({required this.id, required this.title, this.isCustom = false});
}

class CreateOpportunityScreen extends StatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  State<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends State<CreateOpportunityScreen> {
  // Form Controllers
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _customVendorController = TextEditingController();
  final _customActionController = TextEditingController();
  final _customCertController = TextEditingController();
  final _paidAmountController = TextEditingController(text: "0");
  final _solutionController = TextEditingController();
  final _locationInputController = TextEditingController();
  final _audienceController = TextEditingController();

  // Dynamic API State
  List<_CategoryModel> _categories = [];
  List<_CategoryModel> _subCategories = [];
  List<_ModuleModel> _modules = [];
  List<_VendorTypeModel> _vendorTypes = [];
  Map<String, dynamic>? _activeMembership;

  _CategoryModel? _selectedCategory;
  _CategoryModel? _selectedSubCategory;
  _ModuleModel? _selectedModule;

  final Set<String> _selectedVendorTypes = {};
  final Set<String> _selectedCertifications = {};
  final Set<String> _selectedActions = {};
  final List<String> _locations = [];

  final List<String> _allCertifications = [
    'ISO 9001',
    'GSTIN Registered',
    'OEKO-TEX Standard',
    'GMP Certified',
    'SOC 2 Type II',
  ];

  final List<String> _allActions = [
    'Apply',
    'Appointment',
    'Request Callback',
    'Donate',
    'Enroll',
    'Proposal',
    'Register',
  ];

  final List<String> _docFormats = ['PDF', 'JPG', 'PNG', 'DOCX'];

  // Financial Dropdown Options from Image
  final List<String> _financialTermTypes = [
    'Commission (Flat)',
    'Commission (%)',
    'Fixed Contract Pay',
    'Milestone Pay',
    'Retainer',
    'Incentive / Performance Bonus',
    'Advance Deposit',
  ];

  final List<String> _paymentFrequencies = [
    'Per Batch',
    'One-time',
    'Weekly',
    'Monthly',
    'Milestone-based',
  ];

  // Loaders
  bool _isLoadingInitialData = true;
  bool _isLoadingSubCategories = false;
  bool _isGeneratingAi = false;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;

  final int _marketplaceId = 50;
  int _opportunityId = 0;

  String _visibilityMode = 'business_user';
  bool _strictVerification = true;
  String _businessVintage = 'any';
  String _annualTurnover = 'none';
  String _pricingModel = 'free';
  String _selectedCurrency = 'USD';

  final List<Map<String, dynamic>> _financialTerms = [];
  final List<Map<String, dynamic>> _documents = [];
  final List<String> _uploadedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialScreenData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _customVendorController.dispose();
    _customActionController.dispose();
    _customCertController.dispose();
    _paidAmountController.dispose();
    _solutionController.dispose();
    _locationInputController.dispose();
    _audienceController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // API INTEGRATIONS
  // ===========================================================================

  Future<void> _loadInitialScreenData() async {
    setState(() => _isLoadingInitialData = true);
    await Future.wait([
      _fetchCategories(),
      _fetchModules(),
      _fetchVendorTypes(),
      _fetchCurrentMembership(),
    ]);
    if (mounted) setState(() => _isLoadingInitialData = false);
  }

  Future<void> _fetchCategories() async {
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
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

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

  Future<void> _fetchModules() async {
    try {
      final postData = {
        "action": "fetch_modules",
        "vendor_id": UserSessionSet.instance.vendorId,
      };
      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );
      if (response['success'] == true && response['data'] != null) {
        final List list = response['data'];
        setState(() {
          _modules = list
              .map((item) => _ModuleModel(
            id: int.parse(item['id'].toString()),
            title: item['title']?.toString() ?? '',
          ))
              .toList();
          if (_modules.isNotEmpty) {
            _selectedModule = _modules.first;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching modules: $e");
    }
  }

  Future<void> _fetchVendorTypes() async {
    try {
      final postData = {
        "action": "fetch_vendor_types",
        "vendor_id": UserSessionSet.instance.vendorId,
      };
      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );
      if (response['success'] == true && response['data'] != null) {
        final List list = response['data'];
        setState(() {
          _vendorTypes = list
              .map((item) => _VendorTypeModel(
            id: int.parse(item['id'].toString()),
            title: item['title']?.toString() ?? '',
          ))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching vendor types: $e");
    }
  }

  Future<void> _fetchCurrentMembership() async {
    try {
      final postData = {
        "action": "get_current_membership",
        "vendor_id": UserSessionSet.instance.vendorId,
      };
      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );
      if (response['success'] == true && response['data'] is Map<String, dynamic>) {
        setState(() => _activeMembership = response['data']);
      }
    } catch (e) {
      debugPrint("Error fetching current membership: $e");
    }
  }

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
        "notes": _solutionController.text.trim().isNotEmpty
            ? _solutionController.text.trim()
            : _shortDescController.text.trim(),
      };

      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/opportunity_form_api.php",
      );

      if (response['success'] == true &&
          response['data']?['description'] != null) {
        setState(() {
          _solutionController.text = response['data']['description'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("AI Generation Failed: ${response['message'] ?? ''}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingAi = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_uploadedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 5 images allowed")),
      );
      return;
    }

    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    final file = File(picked.path);
    final sizeInBytes = await file.length();
    if (sizeInBytes > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image exceeds 5MB limit")),
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
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;

      if (decoded['success'] == true && decoded['data']?['image_url'] != null) {
        setState(() {
          _uploadedImages.add(decoded['data']['image_url'].toString());
        });
      } else {
        throw Exception(decoded['message'] ?? "Upload failed");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _submitOpportunity({required bool isPublish}) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opportunity Title is required")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final mappedFinancialTerms = _financialTerms
          .where((t) => (t['value'] ?? '').toString().trim().isNotEmpty)
          .map((t) {
        return {
          "term_type": t['type'],
          "amount": t['value']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
          "payment_frequency": t['frequency'] ?? "Per Batch",
          "positions": 1
        };
      }).toList();

      final mappedDocuments = _documents
          .where((d) => (d['name'] ?? '').toString().trim().isNotEmpty)
          .map((d) => {
        "document_name": d['name'],
        "linked_action": d['action'] ?? 'Apply',
        "format": d['format'] ?? 'PDF',
        "required": d['isRequired'] == true ? 1 : 0,
      })
          .toList();

      final postData = {
        "action": "save_opportunity",
        "vendor_id": UserSessionSet.instance.vendorId,
        "marketplace_id": _marketplaceId,
        "title": _titleController.text.trim(),
        "short_description": _shortDescController.text.trim(),
        "category_id": _selectedCategory?.id ?? 0,
        "subcategory_id": _selectedSubCategory?.id ?? 0,
        "visibility_type": _visibilityMode,
        "module_id": _visibilityMode == 'business_user' ? _selectedModule?.id : null,
        "vendor_types": _selectedVendorTypes.toList(),
        "strict_verification": _strictVerification ? 1 : 0,
        "min_vintage": _businessVintage,
        "min_turnover": _annualTurnover,
        "certifications": _selectedCertifications.toList(),
        "description": _solutionController.text.trim(),
        "pricing_type": _pricingModel,
        "currency": _pricingModel == 'paid' ? _selectedCurrency : null,
        "price_amount": _pricingModel == 'paid'
            ? (double.tryParse(_paidAmountController.text) ?? 0.0)
            : 0,
        "preferred_locations": _locations.join(', '),
        "target_audience": _audienceController.text.trim(),
        "preferred_actions": _selectedActions.toList(),
        "financial_terms": mappedFinancialTerms,
        "expected_documents": mappedDocuments,
        "images": _uploadedImages,
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
            content: Text("Error: ${response['message'] ?? 'Save failed'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: kPrimary, size: 48),
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
            child: const Text("OK", style: TextStyle(color: kPrimary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialData) {
      return const Scaffold(
        backgroundColor: kSurfaceBg,
        body: Center(
          child: CircularProgressIndicator(color: kPrimary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kSurfaceBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Opportunity",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "Define parameters, gates, & actions",
              style: TextStyle(color: Colors.black54, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => _submitOpportunity(isPublish: false),
            child: const Text(
              "Save Draft",
              style: TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              _buildTargetAudienceSection(),
              const SizedBox(height: 16),
              _buildEligibilitySection(),
              const SizedBox(height: 16),
              _buildPricingSection(),
              const SizedBox(height: 16),
              _buildSolutionDetailsSection(),
              const SizedBox(height: 16),
              _buildPreferredActionsSection(),
              const SizedBox(height: 16),
              _buildLocationScopeSection(),
              const SizedBox(height: 20),
              _buildBottomButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildCardWrapper(
      title: "1. BASIC INFORMATION",
      icon: Icons.feed_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Opportunity Title", isRequired: true),
          TextField(
            controller: _titleController,
            decoration: _inputDecoration(
              hint: "e.g., Sustainable Raw Cotton Supply 2025",
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildFieldLabel("Short Description", isRequired: true),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _shortDescController,
                builder: (context, value, _) => Text(
                  "${value.text.length} / 160",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
          TextField(
            controller: _shortDescController,
            maxLength: 160,
            decoration: _inputDecoration(
              hint: "Brief summary displayed on marketplace cards...",
            ).copyWith(counterText: ""),
          ),
          const SizedBox(height: 14),
          _buildFieldLabel("Category", isRequired: true),
          _buildDropdown<_CategoryModel>(
            value: _selectedCategory,
            items: _categories.map((cat) {
              return DropdownMenuItem<_CategoryModel>(
                value: cat,
                child: Text(cat.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedCategory = val);
                _fetchSubCategories(val.id);
              }
            },
          ),
          const SizedBox(height: 14),
          _buildFieldLabel("Sub-Category", isRequired: true),
          _isLoadingSubCategories
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
            ),
          )
              : _buildDropdown<_CategoryModel>(
            value: _selectedSubCategory,
            items: _subCategories.map((sub) {
              return DropdownMenuItem<_CategoryModel>(
                value: sub,
                child: Text(sub.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedSubCategory = val),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAudienceSection() {
    final isBiz = _visibilityMode == 'business_user';
    return _buildCardWrapper(
      title: "2. TARGET AUDIENCE & VISIBILITY",
      icon: Icons.visibility_outlined,
      trailingBadge: "Workflow Gate",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Select Opportunity Visibility", isRequired: true),
          const SizedBox(height: 6),
          _buildRadioCard(
            title: "End User",
            tag: "Public",
            subtitle:
            "Visible to all general applicants, individual members, and open community seekers.",
            isSelected: !isBiz,
            onTap: () => setState(() => _visibilityMode = 'end_user'),
          ),
          const SizedBox(height: 10),
          _buildRadioCard(
            title: "Business User",
            tag: "Enterprise",
            subtitle:
            "Restricted to verified commercial entities. Requires module integration mapping.",
            isSelected: isBiz,
            onTap: () => setState(() => _visibilityMode = 'business_user'),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            opacity: isBiz ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !isBiz,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MANDATORY MODULE MAPPING",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFieldLabel("Select Integration Module", isRequired: true),
                    _buildDropdown<_ModuleModel>(
                      value: _selectedModule,
                      items: _modules.map((mod) {
                        return DropdownMenuItem<_ModuleModel>(
                          value: mod,
                          child: Text(mod.title, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedModule = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEligibilitySection() {
    return _buildCardWrapper(
      title: "3. ELIGIBILITY & ACCESS CONTROL",
      icon: Icons.verified_user_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Allowed Vendor Types", isRequired: true),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _vendorTypes.map((type) {
              final isSel = _selectedVendorTypes.contains(type.title);
              return InputChip(
                label: Text(type.title),
                selected: isSel,
                showCheckmark: isSel,
                checkmarkColor: Colors.white,
                selectedColor: kPrimary,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSel ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    if (isSel) {
                      _selectedVendorTypes.remove(type.title);
                    } else {
                      _selectedVendorTypes.add(type.title);
                    }
                  });
                },
                deleteIcon: Icon(
                  Icons.cancel,
                  size: 16,
                  color: isSel ? Colors.white70 : Colors.grey.shade600,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedVendorTypes.remove(type.title);
                    _vendorTypes.removeWhere((v) => v.id == type.id);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _customVendorController,
                    decoration: _inputDecoration(hint: "Custom vendor type..."),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final text = _customVendorController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _vendorTypes.add(
                        _VendorTypeModel(
                          id: DateTime.now().millisecondsSinceEpoch,
                          title: text,
                          isCustom: true,
                        ),
                      );
                      _selectedVendorTypes.add(text);
                      _customVendorController.clear();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kTealBg,
                    border: Border.all(color: const Color(0xFF99F6E4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: kPrimary),
                      SizedBox(width: 4),
                      Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildFieldLabel("Your Membership Status"),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kTealBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: kPrimary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _activeMembership != null && _activeMembership!['membership_code'] != null
                        ? "Active Tier: ${_activeMembership!['membership_code']} (Exp: ${_activeMembership!['expiry_date'] ?? 'Lifetime'})"
                        : "No Active Subscription Found",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _strictVerification,
              activeColor: kPrimary,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) => setState(() => _strictVerification = val ?? false),
              title: const Text(
                "Strict Verification Gating (Prompt non-verified users to complete profile)",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const Divider(height: 24),
          const Text(
            "VENDOR VETTING & OPERATIONAL CRITERIA",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildFieldLabel("Minimum Experience"),
          _buildDropdown<String>(
            value: _businessVintage,
            items: const [
              DropdownMenuItem(value: 'any', child: Text("Any Experience")),
              DropdownMenuItem(value: '1', child: Text("1+ Year in Business")),
              DropdownMenuItem(value: '3', child: Text("3+ Years in Operation")),
              DropdownMenuItem(value: '5', child: Text("5+ Years Established Enterprise")),
            ],
            onChanged: (val) => setState(() => _businessVintage = val!),
          ),
          const SizedBox(height: 12),
          _buildFieldLabel("Minimum Turnover"),
          _buildDropdown<String>(
            value: _annualTurnover,
            items: const [
              DropdownMenuItem(value: 'none', child: Text("No Minimum Required")),
              DropdownMenuItem(value: '250k', child: Text("> \$250,000 / year")),
              DropdownMenuItem(value: '1m', child: Text("> \$1,000,000 / year")),
              DropdownMenuItem(value: '5m', child: Text("> \$5,000,000 / year")),
            ],
            onChanged: (val) => setState(() => _annualTurnover = val!),
          ),
          const SizedBox(height: 12),
          _buildFieldLabel("Mandatory Certifications"),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _allCertifications.map((cert) {
              final isSel = _selectedCertifications.contains(cert);
              return FilterChip(
                label: Text(cert),
                selected: isSel,
                checkmarkColor: Colors.white,
                selectedColor: kPrimary,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSel ? Colors.white : Colors.black87,
                ),
                onSelected: (selected) {
                  setState(() {
                    selected
                        ? _selectedCertifications.add(cert)
                        : _selectedCertifications.remove(cert);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _customCertController,
                    decoration: _inputDecoration(hint: "Add custom certification..."),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final text = _customCertController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _allCertifications.add(text);
                      _selectedCertifications.add(text);
                      _customCertController.clear();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kTealBg,
                    border: Border.all(color: const Color(0xFF99F6E4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: kPrimary),
                      SizedBox(width: 4),
                      Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return _buildCardWrapper(
      title: "4. OPPORTUNITY ASSETS & PRICING",
      icon: Icons.payments_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Opportunity Media & Assets"),
          InkWell(
            onTap: _isUploadingImage ? null : _pickAndUploadImage,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _isUploadingImage
                      ? const SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
                  )
                      : const Icon(Icons.add_photo_alternate_outlined, size: 36, color: kPrimary),
                  const SizedBox(height: 6),
                  Text(
                    _isUploadingImage ? "Uploading..." : "Click to upload media",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_uploadedImages.length}/5 uploaded · Max 5MB each",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (_uploadedImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _uploadedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          _uploadedImages[index],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _uploadedImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildFieldLabel("Pricing Model", isRequired: true),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              InkWell(
                onTap: () => setState(() => _pricingModel = 'free'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'free',
                      groupValue: _pricingModel,
                      activeColor: kPrimary,
                      onChanged: (val) => setState(() => _pricingModel = val!),
                    ),
                    const Text("Free Opportunity", style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              InkWell(
                onTap: () => setState(() => _pricingModel = 'paid'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'paid',
                      groupValue: _pricingModel,
                      activeColor: kPrimary,
                      onChanged: (val) => setState(() => _pricingModel = val!),
                    ),
                    const Text("Paid Opportunity", style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          if (_pricingModel == 'paid') ...[
            const SizedBox(height: 12),
            _buildFieldLabel("Fee Amount", isRequired: true),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: _buildDropdown<String>(
                    value: _selectedCurrency,
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text("USD")),
                      DropdownMenuItem(value: 'EUR', child: Text("EUR")),
                      DropdownMenuItem(value: 'GBP', child: Text("GBP")),
                      DropdownMenuItem(value: 'INR', child: Text("INR")),
                    ],
                    onChanged: (val) => setState(() => _selectedCurrency = val!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _paidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: "0.00"),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel("Financial Terms & Remuneration"),
                ],
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: kTealBg,
                  side: const BorderSide(color: Color(0xFF99F6E4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                onPressed: () {
                  setState(() {
                    _financialTerms.add({
                      'type': _financialTermTypes.first,
                      'value': '',
                      'frequency': _paymentFrequencies.first,
                    });
                  });
                },
                icon: const Icon(Icons.add, size: 14, color: kPrimary),
                label: const Text(
                  "Add Financial",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimary),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _financialTerms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final term = _financialTerms[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Term Type Dropdown
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _financialTermTypes.contains(term['type'])
                                ? term['type']
                                : _financialTermTypes.first,
                            items: _financialTermTypes.map((t) {
                              return DropdownMenuItem<String>(
                                value: t,
                                child: Text(t, style: const TextStyle(fontSize: 11)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => term['type'] = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Amount TextField
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 42,
                        child: TextField(
                          controller: TextEditingController(text: term['value'])
                            ..selection = TextSelection.collapsed(offset: (term['value'] ?? '').toString().length),
                          decoration: _inputDecoration(hint: "\$ Amount"),
                          style: const TextStyle(fontSize: 11),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => term['value'] = val,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Frequency Dropdown
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: kBorderColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _paymentFrequencies.contains(term['frequency'])
                                ? term['frequency']
                                : _paymentFrequencies.first,
                            items: _paymentFrequencies.map((f) {
                              return DropdownMenuItem<String>(
                                value: f,
                                child: Text(f, style: const TextStyle(fontSize: 11)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => term['frequency'] = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                      onPressed: () => setState(() => _financialTerms.removeAt(index)),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionDetailsSection() {
    return _buildCardWrapper(
      title: "5. SOLUTION DETAILS",
      icon: Icons.description_outlined,
      trailingWidget: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
        ),
        onPressed: _isGeneratingAi ? null : _generateDescriptionWithAI,
        icon: _isGeneratingAi
            ? const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.auto_awesome, size: 13),
        label: Text(
          _isGeneratingAi ? "Generating..." : "AI Assist",
          style: const TextStyle(fontSize: 11),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _solutionController,
            maxLines: 4,
            decoration: _inputDecoration(
              hint: "Describe scope, expectations, milestone requirements...",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferredActionsSection() {
    return _buildCardWrapper(
      title: "6. PREFERRED ACTIONS",
      icon: Icons.touch_app_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Active Action Triggers", isRequired: true),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _allActions.map((action) {
              final isSel = _selectedActions.contains(action);
              return FilterChip(
                label: Text(action),
                selected: isSel,
                checkmarkColor: Colors.white,
                selectedColor: kPrimary,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSel ? Colors.white : Colors.black87,
                ),
                onSelected: (selected) {
                  setState(() {
                    selected ? _selectedActions.add(action) : _selectedActions.remove(action);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _customActionController,
                    decoration: _inputDecoration(hint: "Add trigger action..."),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final val = _customActionController.text.trim();
                  if (val.isNotEmpty) {
                    setState(() {
                      _allActions.add(val);
                      _selectedActions.add(val);
                      _customActionController.clear();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel("Expected Documents"),
                ],
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: kTealBg,
                  side: const BorderSide(color: Color(0xFF99F6E4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
                onPressed: () {
                  setState(() {
                    _documents.add({
                      'name': '',
                      'action': _allActions.first,
                      'format': _docFormats.first,
                      'isRequired': true,
                    });
                  });
                },
                icon: const Icon(Icons.add, size: 14, color: kPrimary),
                label: const Text(
                  "Add Document",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = _documents[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: kBorderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Document Name Field
                        Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: 42,
                            child: TextField(
                              controller: TextEditingController(text: doc['name'])
                                ..selection = TextSelection.collapsed(offset: (doc['name'] ?? '').toString().length),
                              decoration: _inputDecoration(hint: "Document Name"),
                              style: const TextStyle(fontSize: 11),
                              onChanged: (val) => doc['name'] = val,
                            ),
                          ),
                        ),
                        // Linked Action Dropdown
                        const SizedBox(width: 4),
                        // Delete Button
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                          onPressed: () => setState(() => _documents.removeAt(index)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: kBorderColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _allActions.contains(doc['action'])
                                      ? doc['action']
                                      : _allActions.first,
                                  items: _allActions.map((a) {
                                    return DropdownMenuItem<String>(
                                      value: a,
                                      child: Text(a, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => doc['action'] = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Document Format Dropdown
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: kBorderColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _docFormats.contains(doc['format'])
                                      ? doc['format']
                                      : _docFormats.first,
                                  items: _docFormats.map((f) {
                                    return DropdownMenuItem<String>(
                                      value: f,
                                      child: Text(f, style: const TextStyle(fontSize: 11)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => doc['format'] = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Required Checkbox
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: doc['isRequired'] ?? false,
                                activeColor: const Color(0xFF0F766E),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onChanged: (val) {
                                  setState(() => doc['isRequired'] = val ?? false);
                                },
                              ),
                              const Text("Required", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    )

                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationScopeSection() {
    return _buildCardWrapper(
      title: "7. LOCATION & SCOPE",
      icon: Icons.pin_drop_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Preferred Locations"),
          if (_locations.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _locations.map((loc) {
                return Chip(
                  label: Text(loc, style: const TextStyle(fontSize: 11)),
                  backgroundColor: kTealBg,
                  side: const BorderSide(color: Color(0xFF99F6E4)),
                  deleteIcon: const Icon(Icons.close, size: 14, color: kPrimary),
                  onDeleted: () {
                    setState(() => _locations.remove(loc));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _locationInputController,
                    decoration: _inputDecoration(
                      hint: "Type a location (e.g. APAC Region, Germany)...",
                    ),
                    style: const TextStyle(fontSize: 12),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        setState(() {
                          _locations.add(val.trim());
                          _locationInputController.clear();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final loc = _locationInputController.text.trim();
                  if (loc.isNotEmpty) {
                    setState(() {
                      _locations.add(loc);
                      _locationInputController.clear();
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: kTealBg,
                    border: Border.all(color: const Color(0xFF99F6E4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 16, color: kPrimary),
                      SizedBox(width: 4),
                      Text("Add", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kPrimary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFieldLabel("Target Commercial Audience"),
          TextField(
            controller: _audienceController,
            decoration: _inputDecoration(
              hint: "e.g., Tier-1 Textile Retailers, B2B Exporters",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Draft preview generated")),
              );
            },
            child: const Text(
              "Preview",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _isSubmitting ? null : () => _submitOpportunity(isPublish: true),
            child: _isSubmitting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text(
              "Publish Opportunity",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
    String? trailingBadge,
    Widget? trailingWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (trailingBadge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: kTealBg,
                    border: Border.all(color: const Color(0xFF99F6E4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trailingBadge,
                    style: const TextStyle(
                      fontSize: 10,
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (trailingWidget != null) ...[
                const SizedBox(width: 4),
                trailingWidget,
              ],
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildRadioCard({
    required String title,
    required String tag,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? kTealBg : Colors.white,
          border: Border.all(
            color: isSelected ? kPrimary : kBorderColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? kPrimary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? kPrimary : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: " *",
                style: TextStyle(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: kBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }
}